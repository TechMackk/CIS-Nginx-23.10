# Ansible Role: Firewall

## Description

Configures and hardens firewalld on RHEL systems according to CIS benchmark requirements. Implements network security controls, zone-based access, and custom firewall rules.

## Purpose

- Install and enable firewalld
- Configure firewall zones
- Define allowed services and ports
- Implement source IP restrictions
- Enable logging for denied packets
- Apply CIS network security controls

## Requirements

- RHEL/CentOS/Rocky 8.x or 9.x
- firewalld package
- Root or sudo access

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `firewall_enabled` | `true` | Enable firewall configuration |
| `firewall_default_zone` | `public` | Default firewall zone |
| `firewall_allowed_ports` | `[]` | List of allowed ports |
| `firewall_allowed_services` | `[]` | List of allowed services |
| `firewall_allowed_sources` | `[]` | Source IP whitelist |
| `firewall_log_denied` | `all` | Log denied packets |

## Firewall Zones

- **drop**: Drop all incoming, allow outgoing
- **block**: Reject all incoming, allow outgoing  
- **public**: Default zone for public-facing servers
- **trusted**: Allow all (for management networks)
- **internal**: Internal network zone

## Security Features

- Zone-based access control
- Service whitelisting
- Port-based filtering
- Source IP restrictions
- Logging of denied packets
- ICMP flood protection

## Dependencies

None

## Example Playbook

hosts: webservers
roles: - ro

ll

vars: firewall_default_
one: "public" f
rewall_a
lowed_por
s: - 80/tcp

text

## Tags

- `firewall` - Run all firewall tasks
- `firewall_install` - Installation only
- `firewall_configure` - Configuration only
- `firewall_rules` - Apply rules only

## Common Firewall Commands

Check firewall status
firewall-cmd --state

List all zones
firewall-cmd --get-zones

List active zones
firewall-cmd --get-active-zones

List rules in zone
firewall-cmd --zone=public --list-all

Reload firewall
firewall-cmd --reload

text

## Security Notes

⚠️ **Important:**
- Test firewall rules before applying to production
- Ensure SSH access is maintained
- Use source IP restrictions for critical services
- Enable logging for security monitoring
- Review logs regularly for suspicious activity

## References

- Firewalld Documentation: https://firewalld.org/documentation/
- CIS Benchmark Section 3.4: Host Firewall

## Author

DevOps Automation Team

## License

Proprietary

################################################################################
# END OF FILE: roles/firewall/README.md
################################################################################