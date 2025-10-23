# CIS Hardening Automation for RHEL + NGINX

**Enterprise-grade Ansible project for automated CIS benchmark compliance across 4-tier architecture**

[![Ansible](https://img.shields.io/badge/Ansible-2.9%2B-blue.svg)](https://www.ansible.com/)
[![RHEL](https://img.shields.io/badge/RHEL-8%20%7C%209-red.svg)](https://www.redhat.com/en/technologies/linux-platforms/enterprise-linux)
[![CIS](https://img.shields.io/badge/CIS-Benchmark-green.svg)](https://www.cisecurity.org/)
[![License](https://img.shields.io/badge/License-Proprietary-orange.svg)](LICENSE)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Usage](#usage)
- [Configuration](#configuration)
- [Security](#security)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

This Ansible automation project implements **CIS (Center for Internet Security) hardening benchmarks** for RHEL-based servers running NGINX web services. Designed for enterprise MNC environments with rigorous compliance and security requirements.

### **Key Features**

✅ **CIS Compliance**: Automated hardening based on CIS RHEL 8/9 benchmarks  
✅ **4-Tier Architecture**: Dev → Test → QA → Production segregation  
✅ **Modular Design**: 8 reusable roles with granular task separation  
✅ **Idempotent**: Safe to run multiple times without side effects  
✅ **Tag-Based Execution**: Run specific stages (precheck, backup, harden, validate, rollback)  
✅ **Azure DevOps Ready**: Full CI/CD pipeline integration  
✅ **Rollback Support**: Emergency restore capability with backed-up configs  
✅ **Validation & Reporting**: OpenSCAP and custom compliance checks with JSON reports  

---

## 🏗️ Architecture

### **Execution Flow**

site.yml (Master Orchestrator)
│
├─► precheck.yml [Tag: precheck] → System readiness
├─► backup.yml [Tag: backup] → Configuration backup
├─► harden_rhel.yml [Tag: harden] → OS hardening (CIS)
├─► harden_nginx.yml[Tag: harden] → NGINX hardening
├─► ssl_tls.yml [Tag: ssl] → SSL/TLS setup
├─► firewall.yml [Tag: firewall] → Firewall rules
├─► validate.yml [Tag: validate] → Compliance checks
└─► rollback.yml [Tag: rollback] → Emergency restore

text

---

## ✅ Prerequisites

### **Control Node**
- Ansible 2.9+
- Python 3.6+
- SSH access to target servers

### **Target Servers**
- RHEL 8.x or 9.x
- NGINX 1.20+ (will be installed)
- SSH enabled with sudo access

---

## 🚀 Quick Start

1. Clone repository
git clone <repo-url>
cd cis-hardening-automation

2. Install dependencies
ansible-galaxy install -r requirements.yml

3. Configure inventory
vi inventory/dev/hosts.yml

4. Create vault password
./scripts/generate_vault_password.sh

5. Run precheck
ansible-playbook -i inventory/dev/hosts.yml playbooks/precheck.yml

6. Execute full hardening
ansible-playbook -i inventory/dev/hosts.yml playbooks/site.yml

text

---

## 📁 Project Structure

cis-hardening-automation/
├── ansible.cfg # Ansible configuration
├── inventory/ # 4-tier environments (dev/test/qa/prod)
├── playbooks/ # Orchestration playbooks
├── roles/ # 8 modular roles
├── pipeline/ # Azure DevOps CI/CD
├── scripts/ # Helper utilities
├── docs/ # Documentation
└── reports/ # Compliance reports

text

---

## 🎯 Usage

### **Tag-Based Execution**

Run only precheck
ansible-playbook playbooks/site.yml --tags precheck

Run backup + hardening
ansible-playbook playbooks/site.yml --tags backup,harden

Run validation only
ansible-playbook playbooks/site.yml --tags validate

Emergency rollback
ansible-playbook playbooks/rollback.yml --tags rollback

text

### **Environment-Specific**

Development
ansible-playbook -i inventory/dev/hosts.yml playbooks/site.yml

Production
ansible-playbook -i inventory/production/hosts.yml playbooks/site.yml

text

---

## 🔒 Security

- All secrets managed via Ansible Vault
- Vault files: `inventory/*/group_vars/vault.yml`
- Encrypt: `ansible-vault encrypt inventory/dev/group_vars/vault.yml`
- Edit: `ansible-vault edit inventory/dev/group_vars/vault.yml`

---

## 📚 Documentation

- [Architecture](docs/architecture.md) - System design
- [CIS Controls Mapping](docs/cis_controls_mapping.md) - Compliance matrix
- [Runbook](docs/runbook.md) - Operations guide
- [Troubleshooting](docs/troubleshooting.md) - Common issues

---

## 🤝 Support

For issues or questions:
- Internal Wiki: [link]
- DevOps Team: devops@company.com
- Slack: #ansible-hardening

---

**Last Updated**: October 22, 2025  
**Maintained By**: DevOps Automation Team  
**Version**: 1.0.0

################################################################################
# END OF FILE: README.md
################################################################################