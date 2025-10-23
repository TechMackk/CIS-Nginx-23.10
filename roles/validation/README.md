# Ansible Role: Validation

## Description

Performs post-hardening compliance validation and security posture assessment. Executes OpenSCAP scanning, custom compliance checks, and generates detailed reports.

## Purpose

- OpenSCAP CIS benchmark scanning
- Custom compliance checks
- Service status verification
- Configuration validation
- Security posture assessment
- Generate compliance reports

## Requirements

- RHEL/CentOS/Rocky 8.x or 9.x
- OpenSCAP scanner
- SCAP Security Guide
- Root or sudo access

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `validation_enabled` | `true` | Enable validation |
| `openscap_enabled` | `true` | Run OpenSCAP scans |
| `custom_checks_enabled` | `true` | Run custom checks |
| `validation_report_format` | `html` | Report format |
| `validation_fail_on_error` | `false` | Fail on non-compliance |

## Validation Categories

### OpenSCAP Scanning
- CIS RHEL 8/9 Benchmark
- STIG profiles
- PCI-DSS compliance
- HIPAA requirements

### Custom Checks
- RHEL hardening validation
- NGINX security verification
- SSL/TLS configuration
- Firewall rule validation
- Service status checks

## Reports Generated

- HTML compliance report
- XML results (XCCDF format)
- JSON summary
- CSV findings export

## Dependencies

- OpenSCAP scanner
- scap-security-guide package

## Example Playbook

hosts: all
roles:

role: validation
vars:
openscap_enabled: true
validation_report_format: "html"

text

## Tags

- `validation` - Run all validation tasks
- `openscap` - OpenSCAP scanning only
- `custom_checks` - Custom checks only
- `reports` - Generate reports only

## Validation Commands

Run OpenSCAP scan manually
oscap xccdf eval --profile cis --results results.xml profile.xml

Generate HTML report
oscap xccdf generate report results.xml > report.html

List available profiles
oscap info /usr/share/xml/scap/ssg/content/ssg-rhel8-ds.xml

text

## Compliance Levels

- **PASS**: Control fully implemented
- **FAIL**: Control not implemented
- **WARN**: Partial implementation
- **INFO**: Informational finding

## Security Notes

⚠️ **Important:**
- Validation scans can be resource-intensive
- Schedule scans during maintenance windows
- Review findings before remediation
- Keep SCAP content updated
- Archive reports for audit trails

## References

- OpenSCAP: https://www.open-scap.org/
- SCAP Security Guide: https://github.com/ComplianceAsCode/content
- CIS Benchmarks: https://www.cisecurity.org/cis-benchmarks/

## Author

DevOps Automation Team

## License

Proprietary

################################################################################
# END OF FILE: roles/validation/README.md
################################################################################