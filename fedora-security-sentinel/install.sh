#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$SCRIPT_DIR/fedora-security-sentinel.sh"
TARGET_DIR="${HOME}/.local/bin"
TARGET="$TARGET_DIR/fedora-security-sentinel"

if [[ ! -f "$SOURCE" ]]; then
  echo "Missing $SOURCE" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"
install -m 0755 "$SOURCE" "$TARGET"

echo "Installed: $TARGET"

if [[ ":$PATH:" != *":$TARGET_DIR:"* ]]; then
  echo
  echo "NOTE: $TARGET_DIR is not currently in PATH."
  echo 'For Bash, add this to ~/.bashrc:'
  echo '  export PATH="$HOME/.local/bin:$PATH"'
fi

echo
echo "Optional defensive packages:"
echo "  sudo dnf install -y firewalld lsof lynis rkhunter aide fail2ban"
echo
echo "Run:"
echo "  fedora-security-sentinel"
