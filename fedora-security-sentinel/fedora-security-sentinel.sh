#!/usr/bin/env bash
set -Eeuo pipefail

VERSION="0.1.0"
STAMP="$(date +'%Y-%m-%d_%H-%M-%S')"
REPORT_ROOT="${XDG_STATE_HOME:-$HOME/.local/state}/fedora-security-sentinel"
OUT="$REPORT_ROOT/reports/$STAMP"
BLOCK_IP=""
LOCAL_WARNING=""

usage() {
  cat <<'EOF'
Fedora Security Sentinel - defensive Fedora incident-response scanner

Usage:
  ./fedora-security-sentinel.sh [options]

Options:
  --block IP              Block an IPv4/IPv6 address with firewalld.
  --local-warning TEXT    Broadcast a local warning with wall(1).
  --report-dir PATH       Store reports under PATH.
  --help                  Show this help.

This tool is defensive. It does not attack, exploit, scan, or access remote systems.
EOF
}

while (($#)); do
  case "$1" in
    --block) BLOCK_IP="${2:-}"; shift 2 ;;
    --local-warning) LOCAL_WARNING="${2:-}"; shift 2 ;;
    --report-dir) REPORT_ROOT="${2:-}"; OUT="$REPORT_ROOT/reports/$STAMP"; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 2 ;;
  esac
done

mkdir -p "$OUT"
chmod 700 "$REPORT_ROOT" "$REPORT_ROOT/reports" "$OUT" 2>/dev/null || true

log() { printf '[%s] %s\n' "$(date +'%F %T')" "$*" | tee -a "$OUT/summary.log"; }
run_capture() {
  local name="$1"; shift
  {
    printf '# Command: '
    printf '%q ' "$@"
    printf '\n# Time: %s\n\n' "$(date --iso-8601=seconds)"
    "$@"
  } >"$OUT/$name" 2>&1 || true
}
have() { command -v "$1" >/dev/null 2>&1; }

log "Fedora Security Sentinel v$VERSION"
log "Host: $(hostnamectl --static 2>/dev/null || hostname)"
log "Report: $OUT"

# Basic host context
run_capture host.txt bash -lc 'hostnamectl; echo; uname -a; echo; cat /etc/fedora-release 2>/dev/null || true; echo; uptime'
run_capture users.txt bash -lc 'who; echo; w; echo; last -n 40'
run_capture processes.txt bash -lc 'ps auxww --sort=-%cpu | head -n 80'
run_capture process-tree.txt bash -lc 'ps -eo user,pid,ppid,lstart,cmd --forest'

# Network state - local only
if have ss; then
  run_capture sockets-listening.txt sudo ss -lntup
  run_capture sockets-established.txt sudo ss -ntup state established
fi
if have lsof; then
  run_capture network-lsof.txt sudo lsof -nP -i
fi
run_capture routes.txt bash -lc 'ip -br addr; echo; ip route; echo; ip -6 route'

# Authentication and SSH evidence
run_capture auth-recent.txt sudo journalctl --since '7 days ago' -p notice..alert --no-pager
run_capture sshd-recent.txt bash -lc "sudo journalctl -u sshd --since '7 days ago' --no-pager 2>/dev/null || true"
run_capture failed-logins.txt bash -lc "sudo journalctl --since '7 days ago' --no-pager | grep -Ei 'failed password|authentication failure|invalid user|pam_unix.*failure' || true"

# Persistence checks
run_capture enabled-services.txt systemctl list-unit-files --state=enabled
run_capture running-services.txt systemctl --type=service --state=running --no-pager
run_capture user-services.txt bash -lc 'systemctl --user list-unit-files --state=enabled 2>/dev/null || true'
run_capture timers.txt bash -lc 'systemctl list-timers --all --no-pager; echo; systemctl --user list-timers --all --no-pager 2>/dev/null || true'
run_capture cron-system.txt bash -lc 'sudo find /etc/cron.d /etc/cron.daily /etc/cron.hourly /etc/cron.weekly /etc/cron.monthly -maxdepth 2 -type f -ls 2>/dev/null || true'
run_capture cron-user.txt bash -lc 'crontab -l 2>&1 || true'
run_capture autostart.txt bash -lc 'find ~/.config/autostart /etc/xdg/autostart -maxdepth 2 -type f -print 2>/dev/null || true'

# Accounts and privileges
run_capture accounts.txt bash -lc "getent passwd; echo; getent group wheel; echo; sudo grep -RHE '^[[:space:]]*[^#].*(ALL|NOPASSWD)' /etc/sudoers /etc/sudoers.d 2>/dev/null || true"
run_capture ssh-keys.txt bash -lc "find ~/.ssh /root/.ssh -maxdepth 2 -type f \( -name authorized_keys -o -name authorized_keys2 \) -exec sh -c 'echo === \"$1\"; sed -n \"1,200p\" \"$1\"' _ {} \; 2>/dev/null || true"

# Recently changed security-sensitive files. Metadata only; do not copy private file contents.
run_capture recent-sensitive-files.txt bash -lc "sudo find /etc /usr/local/bin /usr/local/sbin -xdev -type f -mtime -7 -printf '%TY-%Tm-%Td %TH:%TM:%TS %u:%g %m %p\n' 2>/dev/null | sort -r"

# Package integrity
if have rpm; then
  run_capture rpm-verification.txt bash -lc 'sudo rpm -Va --nomtime 2>/dev/null || true'
fi

# SELinux
if have getenforce; then
  run_capture selinux.txt bash -lc "getenforce; echo; sudo ausearch -m AVC,USER_AVC -ts recent 2>/dev/null | tail -n 300 || true"
fi

# Firewall
if have firewall-cmd; then
  run_capture firewall.txt sudo firewall-cmd --list-all-zones
fi

# Optional defensive tools
if have lynis; then
  run_capture lynis.txt sudo lynis audit system --quick --no-colors
fi
if have rkhunter; then
  run_capture rkhunter.txt sudo rkhunter --check --skip-keypress --report-warnings-only
fi
if have aide; then
  run_capture aide-check.txt sudo aide --check
fi
if have fail2ban-client; then
  run_capture fail2ban.txt sudo fail2ban-client status
fi

# Screenshot only when a GUI session and screenshot utility are available.
if [[ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]]; then
  if have spectacle; then
    spectacle -b -n -o "$OUT/screenshot.png" >/dev/null 2>&1 || true
  elif have gnome-screenshot; then
    gnome-screenshot -f "$OUT/screenshot.png" >/dev/null 2>&1 || true
  fi
fi

# Optional local warning. This broadcasts only to sessions on this machine.
if [[ -n "$LOCAL_WARNING" ]]; then
  printf '%s\n' "$LOCAL_WARNING" | sudo wall || true
  log "Local warning broadcast requested."
fi

# Optional firewall block. No retaliation or remote access is attempted.
if [[ -n "$BLOCK_IP" ]]; then
  if ! have firewall-cmd; then
    log "Cannot block $BLOCK_IP: firewalld/firewall-cmd is not installed."
  elif [[ "$BLOCK_IP" =~ ^[0-9A-Fa-f:.]+$ ]]; then
    FAMILY="ipv4"
    [[ "$BLOCK_IP" == *:* ]] && FAMILY="ipv6"
    sudo firewall-cmd --permanent --add-rich-rule="rule family=\"$FAMILY\" source address=\"$BLOCK_IP\" drop"
    sudo firewall-cmd --reload
    log "Blocked $BLOCK_IP with firewalld."
  else
    log "Refused invalid IP value: $BLOCK_IP"
  fi
fi

# Hash the evidence files so later changes can be detected.
(
  cd "$OUT"
  find . -maxdepth 1 -type f ! -name SHA256SUMS -print0 | sort -z | xargs -0 sha256sum > SHA256SUMS
) || true

cat >"$OUT/READ-FIRST.txt" <<EOF
Fedora Security Sentinel report
Generated: $(date --iso-8601=seconds)

Treat this directory as sensitive evidence. It can contain usernames, local IPs,
process names, SSH metadata, service configuration details, and screenshots.
Do NOT commit reports to a public Git repository.

Start with:
  summary.log
  sockets-established.txt
  sockets-listening.txt
  sshd-recent.txt
  failed-logins.txt
  enabled-services.txt
  accounts.txt
  recent-sensitive-files.txt
  rpm-verification.txt
EOF

log "Scan complete."
printf '\nReport directory:\n%s\n' "$OUT"
printf '\nDo not upload the generated report directory publicly.\n'
