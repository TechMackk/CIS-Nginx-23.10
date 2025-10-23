# Ansible Role: RHEL Hardening

## Description

Implements comprehensive CIS (Center for Internet Security) benchmark hardening controls for RHEL 8/9 operating systems. This is the core security hardening role that applies OS-level controls across all CIS benchmark categories.

## Purpose

Apply CIS RHEL 8/9 benchmark controls:
- **Section 1**: Filesystem hardening and partitioning
- **Section 2**: Services and daemon management
- **Section 3**: Network configuration and parameters
- **Section 4**: Logging and auditing (auditd, rsyslog)
- **Section 5**: Access control (PAM, SSH, sudo)
- **Section 6**: System maintenance (user accounts, permissions)

## CIS Levels

- **Level 1**: Basic security hardening (recommended for all systems)
- **Level 2**: Advanced security hardening (may impact compatibility)

## Requirements

- RHEL/CentOS/Rocky 8.x or 9.x
- Root or sudo access
- Backup completed before execution
- Minimum 2GB RAM, 10GB free disk space

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `cis_level` | `1` | CIS hardening level (1 or 2) |
| `cis_apply_all` | `true` | Apply all controls for the level |
| `strict_cis_mode` | `false` | Fail on any control failure |
| `selinux_state` | `enforcing` | SELinux mode |
| `aide_enabled` | `true` | Enable AIDE file integrity |
| `auditd_enabled` | `true` | Enable audit daemon |

## CIS Controls Implemented

### Filesystem (CIS 1.x)
- Disable unused filesystems
- Configure /tmp, /var, /home mount options
- Set sticky bit on world-writable directories
- Disable automounting

### Services (CIS 2.x)
- Disable unnecessary services
- Configure time synchronization
- Secure X Window System
- Remove obsolete services

### Network (CIS 3.x)
- Disable IPv6 (if not used)
- Configure host firewall
- Kernel network parameters
- Disable wireless interfaces

### Logging (CIS 4.x)
- Configure rsyslog/journald
- Enable auditd with comprehensive rules
- Log file permissions
- Remote log aggregation

### Access Control (CIS 5.x)
- SSH hardening
- PAM configuration
- Password policies
- Sudo configuration
- User account lockout

### System Maintenance (CIS 6.x)
- File permissions on system files
- User and group settings
- Restrict core dumps
- Address space randomization

## Dependencies

- `auditd` package
- `aide` package
- `firewalld` package

## Example Playbook

hosts: all
roles:

role: rhel_hardening
vars:
cis_level: 2
strict_cis_mode: true
aide_enabled: true

text

## Tags

- `rhel_hardening` - Run all hardening tasks
- `filesystem` - Filesystem controls only
- `services` - Service controls only
- `network` - Network controls only
- `logging` - Logging and audit controls only
- `access_control` - Access control only
- `system_maintenance` - System maintenance only

## Important Notes

⚠️ **WARNING**: This role makes significant system changes. Always:
1. Run precheck playbook first
2. Create backup before execution
3. Test in dev/test environment first
4. Review CIS benchmark documentation
5. Have rollback plan ready

## References

- CIS RHEL 8 Benchmark: https://www.cisecurity.org/benchmark/red_hat_linux
- CIS RHEL 9 Benchmark: https://www.cisecurity.org/benchmark/red_hat_linux
- Red Hat Security Guide: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/security_hardening/

## Author

DevOps Automation Team

## License

Proprietary

################################################################################
# END OF FILE: roles/rhel_hardening/README.md
################################################################################