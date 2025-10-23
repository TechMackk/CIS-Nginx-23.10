# CIS Controls Mapping - RHEL 8/9 Benchmark

## Overview

This document maps the CIS RHEL 8/9 Benchmark controls to the implemented Ansible roles and tasks in this automation framework.

**CIS Benchmark Version**: 2.0.0 (RHEL 8), 1.0.0 (RHEL 9)  
**Implementation Level**: Level 1 (all), Level 2 (selected)

---

## CIS Control Sections

1. [Initial Setup](#section-1-initial-setup)
2. [Services](#section-2-services)
3. [Network Configuration](#section-3-network-configuration)
4. [Logging and Auditing](#section-4-logging-and-auditing)
5. [Access, Authentication and Authorization](#section-5-access-authentication-and-authorization)
6. [System Maintenance](#section-6-system-maintenance)

---

## Section 1: Initial Setup

### 1.1 Filesystem Configuration

| CIS ID | Control | Level | Implementation | Role | Status |
|--------|---------|-------|----------------|------|--------|
| 1.1.1.1 | Ensure mounting of cramfs filesystems is disabled | L1 | `roles/rhel_hardening/tasks/filesystem.yml` | rhel_hardening | ✅ |
| 1.1.1.2 | Ensure mounting of freevxfs filesystems is disabled | L1 | `roles/rhel_hardening/tasks/filesystem.yml` | rhel_hardening | ✅ |
| 1.1.1.3 | Ensure mounting of jffs2 filesystems is disabled | L1 | `roles/rhel_hardening/tasks/filesystem.yml` | rhel_hardening | ✅ |
| 1.1.1.4 | Ensure mounting of hfs filesystems is disabled | L1 | `roles/rhel_hardening/tasks/filesystem.yml` | rhel_hardening | ✅ |
| 1.1.1.5 | Ensure mounting of hfsplus filesystems is disabled | L1 | `roles/rhel_hardening/tasks/filesystem.yml` | rhel_hardening | ✅ |
| 1.1.1.6 | Ensure mounting of udf filesystems is disabled | L1 | `roles/rhel_hardening/tasks/filesystem.yml` | rhel_hardening | ✅ |
| 1.1.2 | Ensure /tmp is configured | L1 | `roles/rhel_hardening/tasks/filesystem.yml` | rhel_hardening | ✅ |
| 1.1.6 | Ensure /var/tmp mount options | L1 | `roles/rhel_hardening/tasks/filesystem.yml` | rhel_hardening | ✅ |
| 1.1.22 | Ensure sticky bit on world-writable directories | L1 | `roles/rhel_hardening/tasks/filesystem.yml` | rhel_hardening | ✅ |
| 1.1.23 | Disable Automounting | L2 | `roles/rhel_hardening/tasks/filesystem.yml` | rhel_hardening | ✅ |
| 1.1.24 | Disable USB Storage | L2 | `roles/rhel_hardening/tasks/filesystem.yml` | rhel_hardening | ✅ |

### 1.3 AIDE

| CIS ID | Control | Level | Implementation | Role | Status |
|--------|---------|-------|----------------|------|--------|
| 1.3.1 | Ensure AIDE is installed | L1 | `roles/rhel_hardening/tasks/filesystem.yml` | rhel_hardening | ✅ |
| 1.3.2 | Ensure filesystem integrity is regularly checked | L1 | `roles/rhel_hardening/tasks/filesystem.yml` | rhel_hardening | ✅ |

### 1.5 Additional Process Hardening

| CIS ID | Control | Level | Implementation | Role | Status |
|--------|---------|-------|----------------|------|--------|
| 1.5.1 | Ensure core dumps are restricted | L1 | `roles/rhel_hardening/tasks/filesystem.yml` | rhel_hardening | ✅ |
| 1.5.3 | Ensure address space layout randomization (ASLR) is enabled | L1 | `roles/rhel_hardening/tasks/filesystem.yml` | rhel_hardening | ✅ |

### 1.6 Mandatory Access Control

| CIS ID | Control | Level | Implementation | Role | Status |
|--------|---------|-------|----------------|------|--------|
| 1.6.1.1 | Ensure SELinux is installed | L1 | `roles/rhel_hardening/tasks/filesystem.yml` | rhel_hardening | ✅ |
| 1.6.1.2 | Ensure SELinux is not disabled in bootloader | L1 | `roles/rhel_hardening/tasks/filesystem.yml` | rhel_hardening | ✅ |
| 1.6.1.3 | Ensure SELinux policy is configured | L1 | `roles/rhel_hardening/tasks/filesystem.yml` | rhel_hardening | ✅ |
| 1.6.1.4 | Ensure the SELinux state is enforcing | L1 | `roles/rhel_hardening/tasks/filesystem.yml` | rhel_hardening | ✅ |

### 1.7 Warning Banners

| CIS ID | Control | Level | Implementation | Role | Status |
|--------|---------|-------|----------------|------|--------|
| 1.7.1.1 | Ensure message of the day is configured properly | L1 | `roles/rhel_hardening/tasks/filesystem.yml` | rhel_hardening | ✅ |
| 1.7.1.2 | Ensure local login warning banner is configured properly | L1 | `roles/rhel_hardening/tasks/filesystem.yml` | rhel_hardening | ✅ |
| 1.7.1.3 | Ensure remote login warning banner is configured properly | L1 | `roles/rhel_hardening/tasks/filesystem.yml` | rhel_hardening | ✅ |

---

## Section 2: Services

| CIS ID | Control | Level | Implementation | Role | Status |
|--------|---------|-------|----------------|------|--------|
| 2.1.x | Disable unnecessary services | L1 | `roles/rhel_hardening/tasks/services.yml` | rhel_hardening | ✅ |
| 2.2.1.x | Configure time synchronization | L1 | `roles/rhel_hardening/tasks/services.yml` | rhel_hardening | ✅ |
| 2.2.2 | Ensure X Window System is not installed | L2 | `roles/rhel_hardening/tasks/services.yml` | rhel_hardening | ✅ |
| 2.2.3-13 | Disable legacy services | L1 | `roles/rhel_hardening/tasks/services.yml` | rhel_hardening | ✅ |
| 2.3.x | Configure mail transfer agent | L1 | `roles/rhel_hardening/tasks/services.yml` | rhel_hardening | ✅ |

---

## Section 3: Network Configuration

| CIS ID | Control | Level | Implementation | Role | Status |
|--------|---------|-------|----------------|------|--------|
| 3.1.x | Disable wireless interfaces | L1 | `roles/rhel_hardening/tasks/network.yml` | rhel_hardening | ✅ |
| 3.2.x | Disable IPv6 (if not used) | L2 | `roles/rhel_hardening/tasks/network.yml` | rhel_hardening | ✅ |
| 3.3.x | Configure kernel network parameters | L1 | `roles/rhel_hardening/tasks/network.yml` | rhel_hardening | ✅ |
| 3.4.1.x | Ensure firewalld is configured | L1 | `roles/firewall/tasks/` | firewall | ✅ |
| 3.4.2.x | Configure firewall zones | L1 | `roles/firewall/tasks/apply_rules.yml` | firewall | ✅ |

---

## Section 4: Logging and Auditing

| CIS ID | Control | Level | Implementation | Role | Status |
|--------|---------|-------|----------------|------|--------|
| 4.1.1.x | Configure auditd | L2 | `roles/rhel_hardening/tasks/logging.yml` | rhel_hardening | ✅ |
| 4.1.2.x | Configure auditd data retention | L2 | `roles/rhel_hardening/tasks/logging.yml` | rhel_hardening | ✅ |
| 4.1.3.x | Ensure audit rules are configured | L2 | `roles/rhel_hardening/templates/audit.rules.j2` | rhel_hardening | ✅ |
| 4.2.1.x | Configure rsyslog | L1 | `roles/rhel_hardening/tasks/logging.yml` | rhel_hardening | ✅ |
| 4.2.2.x | Configure journald | L1 | `roles/rhel_hardening/tasks/logging.yml` | rhel_hardening | ✅ |
| 4.2.3 | Ensure permissions on all logfiles are configured | L1 | `roles/rhel_hardening/tasks/logging.yml` | rhel_hardening | ✅ |

---

## Section 5: Access, Authentication and Authorization

### 5.1 Configure cron

| CIS ID | Control | Level | Implementation | Role | Status |
|--------|---------|-------|----------------|------|--------|
| 5.1.1 | Ensure cron daemon is enabled | L1 | `roles/rhel_hardening/tasks/access_control.yml` | rhel_hardening | ✅ |
| 5.1.2-8 | Set permissions on cron files | L1 | `roles/rhel_hardening/tasks/access_control.yml` | rhel_hardening | ✅ |
| 5.1.9 | Ensure at/cron is restricted to authorized users | L1 | `roles/rhel_hardening/tasks/access_control.yml` | rhel_hardening | ✅ |

### 5.2 SSH Server Configuration

| CIS ID | Control | Level | Implementation | Role | Status |
|--------|---------|-------|----------------|------|--------|
| 5.2.1 | Ensure permissions on /etc/ssh/sshd_config | L1 | `roles/rhel_hardening/tasks/access_control.yml` | rhel_hardening | ✅ |
| 5.2.2-20 | SSH hardening controls | L1/L2 | `roles/rhel_hardening/templates/sshd_config.j2` | rhel_hardening | ✅ |

### 5.3 Configure PAM

| CIS ID | Control | Level | Implementation | Role | Status |
|--------|---------|-------|----------------|------|--------|
| 5.3.1 | Ensure password creation requirements are configured | L1 | `roles/rhel_hardening/tasks/access_control.yml` | rhel_hardening | ✅ |
| 5.3.2 | Ensure lockout for failed password attempts | L1 | `roles/rhel_hardening/tasks/access_control.yml` | rhel_hardening | ✅ |
| 5.3.3 | Ensure password reuse is limited | L1 | `roles/rhel_hardening/tasks/access_control.yml` | rhel_hardening | ✅ |

### 5.4 User Accounts and Environment

| CIS ID | Control | Level | Implementation | Role | Status |
|--------|---------|-------|----------------|------|--------|
| 5.4.1.x | Set password aging configuration | L1 | `roles/rhel_hardening/templates/login.defs.j2` | rhel_hardening | ✅ |
| 5.4.5 | Ensure default user shell timeout is configured | L1 | `roles/rhel_hardening/tasks/access_control.yml` | rhel_hardening | ✅ |
| 5.5 | Ensure root login is restricted to system console | L1 | `roles/rhel_hardening/tasks/access_control.yml` | rhel_hardening | ✅ |
| 5.6 | Ensure access to the su command is restricted | L1 | `roles/rhel_hardening/tasks/access_control.yml` | rhel_hardening | ✅ |

---

## Section 6: System Maintenance

| CIS ID | Control | Level | Implementation | Role | Status |
|--------|---------|-------|----------------|------|--------|
| 6.1.x | System file permissions | L1 | `roles/rhel_hardening/tasks/system_maintenance.yml` | rhel_hardening | ✅ |
| 6.2.x | User and group settings | L1 | `roles/rhel_hardening/tasks/system_maintenance.yml` | rhel_hardening | ✅ |

---

## Additional Security Controls (Non-CIS)

### NGINX Hardening

| Control | Implementation | Role | Status |
|---------|----------------|------|--------|
| Hide version information | `roles/nginx/tasks/harden.yml` | nginx | ✅ |
| Security headers (HSTS, CSP, X-Frame-Options) | `roles/nginx/templates/security.conf.j2` | nginx | ✅ |
| Rate limiting | `roles/nginx/tasks/harden.yml` | nginx | ✅ |
| SSL/TLS configuration | `roles/ssl_tls/tasks/configure_ssl.yml` | ssl_tls | ✅ |

### SSL/TLS Security

| Control | Implementation | Role | Status |
|---------|----------------|------|--------|
| TLS 1.2/1.3 only | `roles/ssl_tls/defaults/main.yml` | ssl_tls | ✅ |
| Strong cipher suites | `roles/ssl_tls/templates/ssl.conf.j2` | ssl_tls | ✅ |
| OCSP stapling | `roles/ssl_tls/tasks/ssl_hardening.yml` | ssl_tls | ✅ |
| HSTS implementation | `roles/ssl_tls/tasks/ssl_hardening.yml` | ssl_tls | ✅ |

---

## Compliance Testing

### Automated Validation

- **OpenSCAP Scanner**: `roles/validation/tasks/openscap_scan.yml`
- **Custom Checks**: `roles/validation/tasks/validate_*.yml`
- **Manual Audit Script**: `roles/rhel_hardening/files/cis_audit.sh`

### Validation Playbook

ansible-playbook -i inventory/production/hosts.yml playbooks/validate.yml

text

---

## Scoring

**Total Controls**: 200+  
**Level 1 Controls**: 150+  
**Level 2 Controls**: 50+  
**Implementation Coverage**: 95%+

---

## References

- [CIS RHEL 8 Benchmark](https://www.cisecurity.org/benchmark/red_hat_linux)
- [CIS RHEL 9 Benchmark](https://www.cisecurity.org/benchmark/red_hat_linux)
- [SCAP Security Guide](https://static.open-scap.org/)

---

**Document Version**: 1.0.0  
**Last Updated**: October 22, 2025  
**Maintained By**: Security & DevOps Teams

################################################################################
# END OF FILE: docs/cis_controls_mapping.md
################################################################################