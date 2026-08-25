<table width="100%"><tr><td><h1>Fedora Security Sentinel</h1></td><td align="right"><sub>Support development: $CabbagePatch206</sub></td></tr></table>

![Security](https://img.shields.io/badge/SECURITY-red)
![PC Tool](https://img.shields.io/badge/PC_TOOL-blue)
![Open Source](https://img.shields.io/badge/OPEN_SOURCE-brightgreen)
![Service Potential](https://img.shields.io/badge/SERVICE_POTENTIAL-green)
![Fedora](https://img.shields.io/badge/FEDORA-LINUX-blue)

A defensive incident-response and compromise-checking utility for Fedora Linux. It gathers local security evidence, checks common persistence points, reviews authentication activity, inventories network state, verifies packages, and can optionally block a reviewed IP address with firewalld.

> Defensive use only. Fedora Security Sentinel does not hack back, exploit remote machines, retrieve data from third-party systems, or attempt unauthorized access.

## What it checks

- Current and recent logged-in users
- Running processes and process trees
- Listening sockets and established connections
- Local interfaces and routes
- SSH and authentication events
- Failed login attempts
- Enabled and running systemd services
- User services and systemd timers
- Cron jobs and desktop autostart entries
- Local accounts, wheel membership, and sudo configuration
- Authorized SSH key locations
- Recently modified security-sensitive files
- RPM package-integrity differences
- SELinux mode and recent AVC events
- Firewalld configuration
- Optional Lynis, rkhunter, AIDE, and Fail2ban status
- Optional desktop screenshot for local incident evidence
- SHA-256 hashes of collected evidence

## Install

Clone or download this project, then:

```bash
chmod +x fedora-security-sentinel.sh
```

Recommended Fedora packages:

```bash
sudo dnf install -y firewalld lsof lynis rkhunter aide fail2ban
```

The scanner still runs if optional packages are missing.

## Run a scan

```bash
./fedora-security-sentinel.sh
```

Reports are written by default under:

```text
~/.local/state/fedora-security-sentinel/reports/
```

Generated reports are private incident evidence and should not be committed to a public repository.

## Block a reviewed IP

Only block an address after you have verified that it is unwanted. Normal connections may include browsers, cloud services, package mirrors, DNS resolvers, VPNs, LAN devices, and legitimate applications.

```bash
./fedora-security-sentinel.sh --block 203.0.113.25
```

This creates a firewalld drop rule. It does not connect to or retaliate against the remote machine.

## Broadcast a local warning

If you suspect an unauthorized interactive session on your own machine, you can broadcast a warning to locally logged-in sessions:

```bash
./fedora-security-sentinel.sh --local-warning "Unauthorized access is prohibited. This system is being monitored and logged."
```

## Reading the report

Start with these files:

```text
summary.log
sockets-established.txt
sockets-listening.txt
sshd-recent.txt
failed-logins.txt
enabled-services.txt
accounts.txt
recent-sensitive-files.txt
rpm-verification.txt
```

A connection is not proof of compromise. Investigate process ownership, executable path, package origin, authentication history, and whether the connection is expected before taking action.

## Recommended response sequence

```text
Detect
  -> Preserve evidence
  -> Verify the finding
  -> Isolate if necessary
  -> Block unauthorized access
  -> Rotate affected credentials
  -> Patch/remove persistence
  -> Re-scan
  -> Monitor
```

If compromise is strongly suspected, disconnecting the machine from untrusted networks before making major changes can preserve evidence and limit further access.

## Use cases

### Personal workstation

Run an on-demand security audit after unexpected behavior, unknown login prompts, suspicious network activity, unexplained processes, or configuration changes.

### PC repair / technician workflow

Use the scanner as the collection layer for a Linux security inspection. A technician-oriented version could turn raw outputs into a customer-facing HTML report while keeping sensitive evidence local.

### Incident-response toolkit

Use it as a first-pass evidence collector before deeper forensic work with dedicated tools.

### Open-source utility

The defensive core is appropriate for a public repository because it contains no credentials or private infrastructure configuration. Generated evidence remains private.

### Service opportunity

Potential future service package:

```text
Linux Security Inspection
- Account review
- Persistence review
- Network exposure review
- Package integrity review
- Firewall review
- Written findings and remediation plan
```

The scanner itself can remain free/open-source while expertise, interpretation, remediation, and reporting form the service layer.

## Strategy

### Build now

1. Reliable evidence collection on Fedora.
2. Clear separation between code and sensitive reports.
3. Human-reviewed IP blocking instead of automatic retaliation.
4. Repeatable output suitable for troubleshooting.
5. Documentation that explains false positives and safe response steps.

### Build next

1. Risk scoring based on multiple signals rather than single indicators.
2. Baseline mode for comparing a clean system against later scans.
3. HTML report generation.
4. Known-process/package correlation.
5. Optional quarantine workflow.
6. Fail2ban setup helper for exposed SSH systems.
7. AIDE baseline initialization and comparison helper.

### Later

1. Terminal dashboard.
2. Technician/customer report mode.
3. Multiple-host inventory for authorized machines.
4. Exportable JSON evidence format.
5. Local AI-assisted explanation of findings without uploading evidence.

### Avoid

- Hack-back functionality
- Automatic attacks against remote addresses
- Uploading private reports by default
- Treating every unfamiliar connection as malicious
- Automatically deleting files before preserving evidence
- Storing credentials or tokens in the repository

## Public / private repository strategy

**Public-ready code:** scanner, documentation, installer, generic configuration examples, and defensive detection rules.

**Keep private:** actual scan reports, screenshots, usernames, network topology, SSH keys, tokens, API credentials, customer information, private infrastructure details, and machine-specific forensic evidence.

## Project structure

```text
fedora-security-sentinel/
├── README.md
├── fedora-security-sentinel.sh
├── .gitignore
├── donation/
│   └── DONATE.md
└── strategy/
    └── ROADMAP.md
```

## Contributing

Contributions should remain defensive and auditable. Features that perform unauthorized remote access, exploitation, credential theft, destructive retaliation, or covert persistence are outside this project's scope.

## Support

If this tool saved you time or helped you diagnose a Linux system, development support is optional.

See [`donation/DONATE.md`](donation/DONATE.md).

<div align="right"><sub>Support development: $CabbagePatch206</sub></div>

<div align="left"><sub>NX-17/04:206-A</sub></div>
