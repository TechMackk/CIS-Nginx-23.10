# CIS Hardening Automation - Architecture Documentation

## Table of Contents

- [Overview](#overview)
- [System Architecture](#system-architecture)
- [4-Tier Environment Design](#4-tier-environment-design)
- [Role Architecture](#role-architecture)
- [Data Flow](#data-flow)
- [Security Architecture](#security-architecture)
- [High Availability](#high-availability)
- [Scalability](#scalability)

---

## Overview

The CIS Hardening Automation framework is designed as an enterprise-grade, scalable solution for implementing CIS (Center for Internet Security) benchmark controls across a 4-tier architecture (Development, Test, QA, Production).

### Design Principles

- **Modularity**: Each component is independent and reusable
- **Idempotency**: Safe to execute multiple times
- **Scalability**: Handles 1 to 1000+ servers
- **Auditability**: Complete logging and reporting
- **Recoverability**: Built-in backup and rollback
- **Security-First**: Defense in depth approach

---

## System Architecture

┌─────────────────────────────────────────────────────────────┐
│ Azure DevOps Pipeline │
│ ┌──────────────────────────────────────────────────────┐ │
│ │ Stages: Precheck → Backup → Harden → Validate │ │
│ └──────────────────────────────────────────────────────┘ │
└────────────────────┬────────────────────────────────────────┘


│ ▼ ┌────────────────────
────────────────────────────────────────┐ │ Ansible
Control Node / Runner │ │ ┌─────────────────
────────────────────────────────────┐ │ │ │ - ansible.cfg
│ │ │ │ - Inventory (4 e
vironments) │ │ │ │ - Playbooks (9 o
chestrators) │ │ │ │ - Roles (8 modul
r components) │ │ │ │ - Vault (encrypt
d secrets) │ │ │ └─────────────────
────────────────────────────────────┘ │ └────────────────────
─
───────────────────────────
──────────┘
│ ┌───────────
┼────────────┐ │ │
│ ▼ ▼
▼ ┌──────────┐ ┌──────────┐ ┌──────
───┐ │ DEV │ │ TEST │ │ QA


│ Tier
│ Tier
│ │ Tier

┌─────────────────────────────────────────────────────────────┐
│ Target RHEL Servers (Web Tier) │
│ ┌──────────────────────────────────────────────────────┐ │
│ │ CIS Controls Applied: │ │
│ │ - OS Hardening (SELinux, auditd, SSH) │ │
│ │ - NGINX (security headers, rate limiting) │ │
│ │ - SSL/TLS (TLS 1.2/1.3, strong ciphers) │ │
│ │ - Firewall (zone-based rules) │ │
│ │ - Monitoring (OpenSCAP validation) │ │
│ └──────────────────────────────────────────────────────┘ │

text

---

## 4-Tier Environment Design

### Environment Progression

Development → Test → QA → Production
(Unrestri

text

### Environment Characteristics

| Aspect | Dev | Test | QA | Production |
|--------|-----|------|----|-----------:|
| **CIS Level** | 1 | 1 | 2 | 2 |
| **Strict Mode** | No | No | Yes | Yes |
| **Manual Approval** | No | No | Yes | Yes |
| **Backup Retention** | 7 days | 14 days | 30 days | 90 days |
| **OpenSCAP Scan** | Optional | Yes | Yes | Yes |
| **Change Control** | No | No | Recommended | Mandatory |
| **Rollback Support** | Yes | Yes | Yes | Yes |
| **Server Count** | 2 | 3 | 4 | 6+ |

### Network Isolation

┌─────────────────────────────────────────────────┐
│ DMZ (Public-Facing) │
│ ┌──────────────────────────────────────────┐ │
│ │ Load Balancer (HTTPS:443) │ │
│ └────────────┬─────────────────────────────┘ │
└───────────────┼─────────────────────────────────┘

│ ┌───────────────┼──────────────────
──────────────┐ │ Web Tier (Private)
│ │ ┌────────────▼──────────────────
──────────┐ │ │ │ NGINX Servers (Hardened)
│ │ │ │ - prod-web-01 (Zone A)
│ │ │ │ - prod-web-02 (Zone A)
│ │ │ │ - prod-web-03 (Zone B)
│ │ │ │ - prod-web-04 (Zone B)
│ │ │ │ - prod-web-05 (Zone C)
│ │ │ │ - prod-web-06 (Zone C)
│ │ │ └───────────────────────────────

text

---

## Role Architecture

### Role Dependency Flow

┌──────────────┐
│ PRECHECK │ ← System validation
└──────┬───────┘


│ ▼ ┌─
────────────┐ │ BACKUP │ ← Config
ration backup └─
─
──┬───────┘
│
├───────────┐ ▼
┌──────────────┐ ┌──────────────┐ │RHEL_HARDENING│ │
NGINX │ ← Parallel executio
└──────┬───────┘
──────┬───────┘
│ │ ▼
▼ ┌──────────────┐ ┌──────────────┐ │
SSL_TLS │ │ FIREWALL │ ←
ecurity layers └──
───┬───────┘ └────
─
───────┘
│ └────────┬───────

▼
┌──────
───────┐ │ VALIDATION │ ← Complianc

text

### Role Components

Each role follows standard Ansible structure:

role_name/
├── README.md # Role documentation
├── defaults/ # Default variables (lowest precedence)
│ └── main.yml
├── vars/ # Role variables (higher precedence)
│ └── main.yml
├── handlers/ # Service restart handlers
│ └── main.yml
├── tasks/ # Task definitions
│ ├── main.yml # Entry point
│ ├── install.yml # Installation tasks
│ ├── configure.yml # Configuration tasks
│ └── harden.yml # Hardening tasks
├── templates/ # Jinja2 templates
│ └── config.j2
├── files/ # Static files
│ └── script.sh
└── meta/ # Role metadata

text

---

## Data Flow

### Execution Flow

Pipeline Trigger (Git push/Manual)

Pre-Check Stage

Syntax validation

Lint checks

Inventory validation
↓ 3. Back

te timestamped backup

Compress configs

Verify backup integrity

Hardening Stage

Execute precheck playbook

Apply CIS controls (RHEL)

Install/configure NGINX

Setup SSL/TLS

Configure firewall

Validation Stage

Run OpenSCAP scan

Custom compliance checks

Generate reports

Approval Gate (QA/Prod only)

Manual approval required

Change ticket reference

Production Deployment

Batch execution (2 servers at a time)

Health checks between batches

Rollback on failure

text

### Variable Precedence

(Highest)

Extra vars (--extra-vars)

Task vars

Block vars

Role vars (vars/)

Play vars

Host vars (host_vars/)

Group vars (group_vars/)

Role defaults (defaults/)

text

---

## Security Architecture

### Defense in Depth Layers

┌─────────────────────────────────────────────┐
│ Layer 7: Monitoring & Logging │
│ - Auditd, OpenSCAP, SIEM integration │
└─────────────────────────────────────────────┘
┌─────────────────────────────────────────────┐
│ Layer 6: Application Security │
│ - NGINX hardening, Security headers │
└─────────────────────────────────────────────┘
┌─────────────────────────────────────────────┐
│ Layer 5: Encryption │
│ - TLS 1.2/1.3, Strong ciphers, HSTS │
└─────────────────────────────────────────────┘
┌─────────────────────────────────────────────┐
│ Layer 4: Network Security │
│ - Firewalld zones, Rate limiting │
└─────────────────────────────────────────────┘
┌─────────────────────────────────────────────┐
│ Layer 3: Access Control │
│ - SSH hardening, Key-based auth, PAM │
└─────────────────────────────────────────────┘
┌─────────────────────────────────────────────┐
│ Layer 2: OS Hardening │
│ - SELinux, File permissions, Kernel params │
└─────────────────────────────────────────────┘
┌─────────────────────────────────────────────┐
│ Layer 1: Physical/Infrastructure │
│ - Azure datacenter, Network isolation │

text

### Secret Management

Ansible Vault (AES256)

↓ Encrypted Varia
l
s ↓ Runtime De
r
ption ↓ In-Memor

rocessing ↓ Secure Com
u

text

---

## High Availability

### Load Balancing

text
      ┌──────────────┐
      │ Load Balancer│
      └───────┬──────┘
              │
  ┌───────────┼───────────┐
  │           │           │
  ▼           ▼           ▼
┌─────────┐ ┌─────────┐ ┌─────────┐
│ Web-01 │ │ Web-02 │ │ Web-03 │
│ (Zone A)│ │ (Zone A)│ │ (Zone B)│

text

### Batch Deployment Strategy

For production, servers are updated in batches to maintain availability:

Batch 1: prod-web-01, prod-web-02 → Harden → Validate → Health Check
↓ (Succ
ss) Batch 2: prod-web-03, prod-web-04 → Harden → Validate → Health C
eck ↓ (

text

---

## Scalability

### Horizontal Scaling

- **Forks**: Ansible processes multiple hosts in parallel (default: 10)
- **Strategy**: `linear` for production (controlled), `free` for dev (faster)
- **Async Tasks**: Long-running tasks executed asynchronously
- **Delegation**: Heavy tasks delegated to control node

### Performance Optimization

ansible.cfg optimizations
forks = 10 # Parallel execution
gathering = smart # Cache facts
pipelining = True # Reduce SSH overhead

text

### Resource Requirements

| Environment | Control Node | Target Servers |
|-------------|-------------|----------------|
| Dev | 2 vCPU, 4GB RAM | 2 servers |
| Test | 2 vCPU, 4GB RAM | 3 servers |
| QA | 4 vCPU, 8GB RAM | 4 servers |
| Production | 4 vCPU, 8GB RAM | 6-100+ servers |

---

## Disaster Recovery

### Backup Strategy

┌─────────────────────────────────────────────┐
│ Backup Creation (Pre-Hardening) │
│ - Timestamp: {{ ansible_date_time.epoch }} │
│ - Location: /backup/{{ timestamp }}/ │
│ - Contents: All configs + manifests │
│ - Retention: 7-90 days (env-specific) │
└─────────────────────────────────────────────┘

↓ ┌─────────────────────────────────────
───────┐ │ Offsite Replication (Production only
│ │ - Azure Blob Storage
│ │ - Encrypted at rest
│ │ - 90-day retention

text

### Rollback Procedure

Trigger rollback playbook

Manual confirmation (typing "YES")

Verify backup exists

Stop services gracefully

Restore configurations

Restart services

Verify connectivity

Generate rollback report

text

---

## Integration Points

### External Systems

- **Azure DevOps**: CI/CD orchestration
- **Azure Key Vault**: Secret storage (optional)
- **SIEM**: Log aggregation (Splunk/ELK)
- **ServiceNow**: Change management integration
- **Monitoring**: Prometheus/Grafana dashboards

---

## Future Enhancements

- Container hardening (Docker/Kubernetes)
- Infrastructure as Code (Terraform integration)
- Automated certificate renewal (Let's Encrypt)
- Advanced threat detection (OSSEC/Wazuh)
- Automated patching workflows

---

**Document Version**: 1.0.0  
**Last Updated**: October 22, 2025  
**Maintained By**: DevOps Automation Team

################################################################################
# END OF FILE: docs/architecture.md
################################################################################