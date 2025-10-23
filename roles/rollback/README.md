# Ansible Role: Rollback

## Description

Emergency rollback role to restore system to pre-hardening state using backed-up configurations. Use only when hardening causes critical issues.

## Purpose

- Restore backed-up configuration files
- Revert system settings
- Restart affected services
- Document rollback actions
- Minimal downtime recovery

## Requirements

- RHEL/CentOS/Rocky 8.x or 9.x
- Valid backup created by backup role
- Root or sudo access
- Emergency change approval

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `rollback_enabled` | `true` | Enable rollback |
| `backup_timestamp` | `LAST_BACKUP` | Backup to restore |
| `backup_root_dir` | `/backup` | Backup directory |
| `rollback_services` | `[]` | Services to restart |
| `rollback_confirmation_required` | `true` | Require manual confirmation |

## Rollback Process

1. **Validation**: Verify backup exists
2. **Confirmation**: Manual approval required
3. **Stop Services**: Gracefully stop affected services
4. **Restore Configs**: Copy backed-up files
5. **Restart Services**: Bring services back online
6. **Verification**: Verify system functionality

## Security Notes

⚠️ **CRITICAL WARNING**:
- This operation REVERTS ALL hardening changes
- Use only in emergency situations
- Requires change management approval
- Test connectivity before completing rollback
- Document all rollback actions

## Usage

Rollback to last backup
ansible-playbook playbooks/rollback.yml

Rollback to specific backup
ansible-playbook playbooks/rollback.yml --extra-vars "backup_timestamp=1234567890"

text

## Manual Confirmation

Rollback requires typing "YES" to proceed by default.
Override with `rollback_confirmation_required=false` (not recommended).

## Dependencies

- backup role (backup must exist)

## Tags

- `rollback` - Run all rollback tasks
- `restore_configs` - Restore configs only
- `restore_services` - Restart services only

## Post-Rollback Actions

1. Verify SSH connectivity
2. Check critical services status
3. Review system logs
4. Document incident
5. Plan re-hardening strategy

## Author

DevOps Automation Team

## License

Proprietary

################################################################################
# END OF FILE: roles/rollback/README.md
################################################################################