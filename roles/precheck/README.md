# Ansible Role: Precheck

## Description

Pre-flight validation role that verifies system readiness before applying CIS hardening. Performs comprehensive checks on OS compatibility, resources, connectivity, and prerequisites.

## Purpose

- Validate OS version and compatibility
- Check system resources (CPU, memory, disk)
- Verify required packages are available
- Test network connectivity
- Check service status
- Prevent partial hardening due to unmet prerequisites

## Requirements

- RHEL/CentOS/Rocky 8.x or 9.x
- Minimum 2GB RAM
- Minimum 10GB free disk space
- Internet connectivity (for package repositories)
- SSH access with sudo privileges

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `precheck_fail_on_error` | `true` | Fail immediately on check failure |
| `precheck_min_memory_mb` | `2048` | Minimum required memory (MB) |
| `precheck_min_disk_gb` | `10` | Minimum required disk space (GB) |
| `precheck_required_packages` | `[]` | List of required packages |
| `precheck_check_internet` | `true` | Verify internet connectivity |

## Dependencies

None

## Example Playbook

hosts: all
roles:

role: precheck
vars:
precheck_min_memory_mb: 4096
precheck_min_disk_gb: 20

text

## Tags

- `precheck` - Run all precheck tasks
- `system_checks` - OS and resource checks only
- `service_checks` - Service status checks only

## Author

DevOps Automation Team

## License

Proprietary

################################################################################
# END OF FILE: roles/precheck/README.md
################################################################################