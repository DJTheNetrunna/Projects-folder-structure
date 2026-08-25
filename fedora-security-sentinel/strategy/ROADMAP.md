# Fedora Security Sentinel Roadmap

## Positioning

Fedora Security Sentinel should stay focused on defensive Linux auditing and incident response. The strongest path is to keep the collection engine free and auditable while building higher-value layers around interpretation, reporting, technician workflows, and authorized multi-machine management.

## Current stage

Stage: foundation

Goal: produce repeatable local evidence without modifying the system more than necessary.

Current capabilities:

- Authentication review
- Process inventory
- Network-state inventory
- Persistence checks
- Account and privilege review
- RPM verification
- SELinux review
- Firewall review
- Optional third-party defensive checks
- Evidence hashing
- Human-reviewed IP blocking
- Local warning broadcast

## Phase 1 - Reliable scanner

Priority: highest

- Test on current Fedora KDE installations
- Improve error handling when optional packages are missing
- Add a compact terminal summary
- Add severity-neutral findings instead of declaring compromise
- Document common false positives
- Validate IPv4 and IPv6 firewall rule handling
- Add versioned report metadata

Success condition: repeated scans produce understandable evidence without damaging or destabilizing the host.

## Phase 2 - Baseline and comparison

- Add `--baseline` mode
- Store hashes and inventories from a known-good system
- Add `--compare` mode
- Highlight new users, services, listeners, autostart entries, SSH keys, and changed files
- Keep baseline files local by default

Strategic value: comparison against a known-good machine is more useful than trying to classify every unfamiliar process globally.

## Phase 3 - Human-readable reporting

- Generate HTML reports
- Create executive summary and technical detail sections
- Add finding confidence levels
- Link findings to remediation steps
- Support redaction before sharing reports
- Export JSON for automation

Business use: this becomes the bridge from a personal security script to a technician-grade Linux security inspection workflow.

## Phase 4 - Technician mode

- Case identifier support
- Customer-safe report export
- Before/after remediation comparison
- Checklists for account recovery, credential rotation, firewall review, updates, and persistence cleanup
- Optional signed report hashes

Possible service model:

1. Free scanner
2. Paid interpretation / inspection
3. Paid remediation
4. Optional maintenance or recurring security review

## Phase 5 - Authorized fleet support

Only for systems the operator owns or is authorized to administer.

- Run locally across multiple machines
- Aggregate sanitized status information
- Never centralize secrets by default
- Keep raw evidence on the endpoint unless explicitly exported
- Add machine aliases instead of exposing unnecessary host details

## Integration opportunities

Potential integrations:

- PC-repair diagnostic toolkit
- Bootable repair environment
- Local AI explanation layer
- Technician dashboard
- General Linux maintenance suite
- Security-health section in a broader PC service workflow

## Monetization strategy

Do not cripple the open-source scanner to manufacture a paid tier. Monetize the expertise and convenience layers instead.

Strongest options:

- Linux security inspection service
- Incident triage service
- Customer-facing report generation
- Remediation service
- Managed recurring audit for authorized systems
- Technician toolkit bundle

Lower-priority options:

- Affiliate links for unrelated security products
- Advertising inside the scanner
- Selling raw threat lists

These add distraction without improving the core tool.

## Public vs private strategy

Public repository:

- Scanner source
- Generic rules
- Documentation
- Installer
- Example sanitized reports
- Roadmap

Private repositories or local storage:

- Real incident reports
- Customer reports
- Internal infrastructure configuration
- Credentials
- API tokens
- Private network information
- Unreleased business automation

## Security boundaries

Do not add:

- Hack-back functionality
- Credential harvesting
- Remote exploitation
- Persistence on third-party systems
- Covert monitoring of people
- Automatic destructive remediation

The project becomes more credible, reusable, and commercially useful by staying defensive and evidence-driven.
