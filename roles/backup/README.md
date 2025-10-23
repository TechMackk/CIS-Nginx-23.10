# Ansible Role: Backup

## Description

Creates timestamped backups of critical system and application configuration files before applying CIS hardening. Provides rollback capability if hardening causes issues.

## Purpose

- Backup system configuration files
- Backup NGINX configuration
- Backup firewall rules
- Create backup manifest for tracking
- Enable safe rollback capability

## Requirements

- Sufficient disk space for backups (minimum 1GB recommended)
- Write permissions to backup directory
- tar utility installed

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `backup_enabled` | `true` | Enable/disable backup operations |
| `backup_root_dir` | `/backup` | Root backup directory |
| `backup_retention_days` | `30` | Backup retention period |
| `backup_compress` | `true` | Compress backup archives |
| `backup_verify` | `true` | Verify backup integrity |

## Backup Locations

- System configs: `/etc/ssh`, `/etc/sysctl.d`, `/etc/security`
- NGINX configs: `/etc/nginx`
- Firewall rules: `/etc/firewalld`
- SELinux policies: `/etc/selinux`
- Audit rules: `/etc/audit`

## Dependencies

None

## Example Playbook

hosts: all
roles:

role: backup
vars:
backup_root_dir: "/var/backup"
backup_retention_days: 60

text

## Tags

- `backup` - Run all backup tasks
- `backup_configs` - Backup system configs only
- `backup_nginx` - Backup NGINX configs only

## Author

DevOps Automation Team

## License

Proprietary

################################################################################
# END OF FILE: roles/backup/README.md
################################################################################