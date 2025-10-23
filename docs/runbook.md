# CIS Hardening Automation - Operations Runbook

## Table of Contents

- [Quick Reference](#quick-reference)
- [Pre-Deployment](#pre-deployment)
- [Deployment Procedures](#deployment-procedures)
- [Post-Deployment](#post-deployment)
- [Emergency Procedures](#emergency-procedures)
- [Maintenance Tasks](#maintenance-tasks)
- [Monitoring](#monitoring)

---

## Quick Reference

### Essential Commands

Pre-check system readiness
ansible-playbook -i inventory/ENVIRONMENT/hosts.yml playbooks/precheck.yml

Create backup
ansible-playbook -i inventory/ENVIRONMENT/hosts.yml playbooks/backup.yml

Full hardening (all stages)
ansible-playbook -i inventory/ENVIRONMENT/hosts.yml playbooks/site.yml --ask-vault-pass

Validation only
ansible-playbook -i inventory/ENVIRONMENT/hosts.yml playbooks/validate.yml

Emergency rollback
ansible-playbook -i inventory/ENVIRONMENT/hosts.yml playbooks/rollback.yml --ask-vault-pass

text

### Environment Variables

export ENVIRONMENT=dev|test|qa|production
export INVENTORY_PATH=inventory/$ENVIRONMENT/hosts.yml

text

---

## Pre-Deployment

### 1. Pre-Deployment Checklist

- [ ] Change management approval obtained (QA/Prod only)
- [ ] Maintenance window scheduled
- [ ] Backup verification completed
- [ ] Team notification sent
- [ ] Rollback plan reviewed
- [ ] Health check baseline captured
- [ ] Access credentials verified

### 2. Environment Validation

Verify Ansible installation
ansible --version

Check connectivity to all hosts
ansible -i inventory/$ENVIRONMENT/hosts.yml all -m ping

Validate inventory
ansible-inventory -i inventory/$ENVIRONMENT/hosts.yml --list

Test SSH access
ansible -i inventory/$ENVIRONMENT/hosts.yml all -m shell -a "hostname"

text

### 3. Pre-Deploy Health Checks

Run pre-deploy check script
./scripts/pre_deploy_check.sh $ENVIRONMENT

Capture baseline metrics
ansible -i inventory/$ENVIRONMENT/hosts.yml all -m setup --tree /tmp/facts-before

text

### 4. Backup Verification

Create fresh backup
ansible-playbook -i inventory/$ENVIRONMENT/hosts.yml playbooks/backup.yml --ask-vault-pass

Verify backup created
ssh target-host "ls -lh /backup/"

Verify backup manifest
ssh target-host "cat /backup/LAST_BACKUP"

text

---

## Deployment Procedures

### Development Environment

**When**: After code commit to develop branch  
**Approval**: None required  
**Process**: Automated via Azure DevOps

Manual execution (if needed)
ansible-playbook -i inventory/dev/hosts.yml playbooks/site.yml
--vault-password-file=$VAULT_PASSWORD_FILE
-vv

text

**Expected Duration**: 15-20 minutes

### Test Environment

**When**: After successful dev deployment  
**Approval**: None required  
**Process**: Automated via Azure DevOps

Manual execution
ansible-playbook -i inventory/test/hosts.yml playbooks/site.yml
--vault-password-file=$VAULT_PASSWORD_FILE
--tags backup,harden,validate
-vv

text

**Expected Duration**: 20-25 minutes

### QA Environment

**When**: After successful test deployment  
**Approval**: Team lead approval required  
**Process**: Manual trigger in Azure DevOps

Manual execution
ansible-playbook -i inventory/qa/hosts.yml playbooks/site.yml
--vault-password-file=$VAULT_PASSWORD_FILE
--tags backup,harden,validate
-vv

text

**Expected Duration**: 25-30 minutes

### Production Environment

**When**: After QA validation + Change approval  
**Approval**: Change Management + VP approval  
**Process**: Manual trigger with approvals

#### Production Deployment Steps

**Step 1: Preparation (T-30 minutes)**

1. Set environment
export ENVIRONMENT=production
export INVENTORY_PATH=

2. Verify change ticket
echo "Change Ticket: CHG-XXXXX"

3. Pre-deployment meeting
- Review deployment plan
- Confirm rollback procedures
- Verify team availability
text

**Step 2: Pre-Deployment Checks (T-15 minutes)**

1. Run pre-deploy validation
./scripts/pre_deploy_check.sh production

2. Verify all hosts reachable
ansible -i $INVENTORY_PATH all -m ping

3. Create production backup
ansible-playbook -i $INVENTORY_PATH playbooks/backup.yml --ask-vault-pass

4. Verify backup
ansible -i $INVENTORY_PATH all -m shell -a "ls -lh /backup/$(cat /backup/LAST_BACKUP | grep TIMESTAMP | cut -d= -f2)"

text

**Step 3: Batch 1 Deployment (T-0)**

Deploy to first batch (2 servers)
ansible-playbook -i $INVENTORY_PATH playbooks/site.yml
--vault-password-file=$VAULT_PASSWORD_FILE
--limit prod-web-01,prod-web-02
-vv

Validation
ansible-playbook -i $INVENTORY_PATH playbooks/validate.yml
--limit prod-web-01,prod-web-02

Health check (wait 5 minutes)
curl -I https://prod-web-01.company.com/health
curl -Ihttps://prod-web-02.company.com/health

text

**Step 4: Batch 2 Deployment (T+15 minutes)**

If Batch 1 successful, proceed to Batch 2
ansible-playbook -i $INVENTORY_PATH playbooks/site.yml
--vault-password-file=$VAULT_PASSWORD_FILE
--limit prod-web-03,prod-web-04
-vv

Validation and health check
text

**Step 5: Batch 3 Deployment (T+30 minutes)**

If Batch 2 successful, proceed to Batch 3
ansible-playbook -i $INVENTORY_PATH playbooks/site.yml
--vault-password-file=$VAULT_PASSWORD_FILE
--limit prod-web-05,prod-web-06
-vv

Final validation
ansible-playbook -i $INVENTORY_PATH playbooks/validate.yml

text

**Expected Duration**: 60-90 minutes (batched deployment)

---

## Post-Deployment

### 1. Immediate Validation

Run validation playbook
ansible-playbook -i inventory/$ENVIRONMENT/hosts.yml playbooks/validate.yml

Check service status
ansible -i inventory/$ENVIRONMENT/hosts.yml all -m systemd -a "name=nginx state=started"
ansible -i inventory/$ENVIRONMENT/hosts.yml all -m systemd -a "name=firewalld state=started"

Verify SELinux
ansible -i inventory/$ENVIRONMENT/hosts.yml all -m command -a "getenforce"

text

### 2. Health Checks

HTTP/HTTPS connectivity
for server in web-01 web-02 web-03; do
curl -I https://$server.$ENVIRONMENT.company.com/heal

SSL/TLS validation
echo | openssl s_client -connect web-01.$ENVIRONMENT.company.com:443 -brief

Certificate expiry
ansible -i inventory/$ENVIRONMENT/hosts.yml all -m shell -a "openssl x509 -enddate -noout -in /etc/nginx/ssl/server.crt"

text

### 3. Compliance Validation

Generate compliance report
ansible-playbook -i inventory/$ENVIRONMENT/hosts.yml playbooks/validate.yml

Review reports
cat reports/validation-*.json | jq '.summary'

Check OpenSCAP results
firefox reports/oscap-report-*.html

text

### 4. Monitoring Verification

Check logs
ansible -i inventory/$ENVIRONMENT/hosts.yml all -m shell -a "tail -20 /var/log/messages"

Verify auditd logging
ansible -i inventory/$ENVIRONMENT/hosts.yml all -m shell -a "auditctl -l | wc -l"

Check NGINX logs
ansible -i inventory/$ENVIRONMENT/hosts.yml webservers -m shell -a "tail -10 /var/log/nginx/access.log"

text

### 5. Post-Deployment Report

**Template**:

Deployment Report: CIS Hardening - [ENVIRONMENT]
Date: [DATE]

Deployment Summary:

Start Time: [TIME]

End Time: [TIME]

Duration: [MINUTES]

Hosts Affected: [COUNT]

Status: SUCCESS/FAILED

Validation Results:

Pre-checks: PASSED

Hardening: COMPLETED

Validation: [X/Y checks passed]

Compliance Score: [XX%]

Issues Encountered:

None / [List issues]

Rollback Required: NO/YES

Team Members:

[Name] - Deployment Lead

[Name] - Technical Reviewer

[Name] - Change Approver

Next Steps:

Monitor for 24 hours

Close change ticket

Archive reports

text

---

## Emergency Procedures

### Emergency Rollback

**Trigger Criteria**:
- Critical service outage
- Application functionality broken
- Security vulnerability introduced
- Performance degradation >50%

**Procedure**:

1. Declare incident
echo "INCIDENT: Rollback initiated on $ENVIRONMENT at $(date)"

2. Get approval
- Notify: DevOps Manager, VP Engineering
- Document: Incident ticket
3. Execute rollback
ansible-playbook -i inventory/$ENVIRONMENT/hosts.yml playbooks/rollback.yml
--vault-password-file=$VAULT_PASSWORD_FILE
--extra-vars "rollback_confirmation_required=false"
-vv

4. Verify services
ansible -i inventory/$ENVIRONMENT/hosts.yml all -m systemd -a "name=nginx state=started"
ansible -i inventory

5. Health check
for server in $(ansible -i inventory/$ENVIRONMENT/hosts.yml webservers --list-hosts | grep -v hosts); do
curl -I https://$server/heal

6. Post-rollback validation
./scripts/pre_deploy_check.sh $ENVIRONMENT

text

**Recovery Time Objective (RTO)**: 15 minutes  
**Recovery Point Objective (RPO)**: Last backup (pre-hardening state)

### Partial Failure Recovery

**If single host fails during batch deployment**:

1. Identify failed host
cat logs/ansible.log | grep -i "failed:"

2. Rollback single host
ansible-playbook -i inventory/production/hosts.yml playbooks/rollback.yml
--limit prod-web-XX
--vault-password-file=$VAULT_PASSWORD_FILE

3. Investigate issue
ssh prod-web-XX
tail -100 /

4. Fix and retry
ansible-playbook -i inventory/production/hosts.yml playbooks/site.yml
--limit prod-web-XX
--vault-password-file=$VAULT_PASSWORD_FILE

text

### Service Restart (If Needed)

Restart NGINX
ansible -i inventory/$ENVIRONMENT/hosts.yml webservers -m systemd -a "name=nginx state=restarted"

Restart firewalld
ansible -i inventory/$ENVIRONMENT/hosts.yml all -m systemd -a "name=firewalld state=restarted"

Restart SSH (CAREFUL!)
ansible -i inventory/$ENVIRONMENT/hosts.yml all -m systemd -a "name=sshd state=restarted"

text

---

## Maintenance Tasks

### Weekly Tasks

1. Review compliance reports
ls -lh reports/validation-production-*

2. Check backup integrity
ansible -i inventory/production/hosts.yml all -m shell -a "ls -lh /backup/"

3. Cleanup old logs
ansible -i inventory/production/hosts.yml all -m shell -a "find /var/log/nginx -name '*.gz' -mtime +30 -delete"

4. Review audit logs
ansible -i inventory/production/hosts.yml all -m shell -a "aureport --summary"

text

### Monthly Tasks

1. Run full compliance scan
ansible-playbook -i inventory/production/hosts.yml playbooks/validate.yml

2. Review and rotate vault passwords
./scripts/generate_vault_password.sh production

3. Update Ansible collections
ansible-galaxy collection install -r requirements.yml --force

4. Archive old reports
tar -czf reports-archive-$(date +%Y%m).tar.gz reports/
m

text

### Quarterly Tasks

1. Review and update CIS controls
2. Update SCAP content
sudo yum update scap-security-guide

3. Certificate renewal planning
ansible -i inventory/production/hosts.yml webservers -m shell -a "openssl x509 -enddate -noout -in /etc/nginx/ssl/server.crt"

4. Conduct DR test (rollback drill)
Test in QA environment
text

---

## Monitoring

### Key Metrics

- **Service Availability**: nginx, sshd, firewalld, auditd
- **Compliance Score**: Target >90%
- **Failed Checks**: Target 0
- **Certificate Expiry**: Alert at 30 days
- **Backup Age**: Alert if >7 days old

### Alerts Configuration

Example alert rules (Prometheus)
groups:

name: cis_hardening
ru
es: - alert: S
rviceDown expr: up

text
- alert: ComplianceLow
  expr: compliance_score < 90
  for: 1h
  
- alert: CertificateExpiringSoon
  expr: ssl_cert_expiry_days < 30
text

### Log Locations

- **Ansible Logs**: `logs/ansible.log`
- **Audit Logs**: `/var/log/audit/audit.log`
- **NGINX Logs**: `/var/log/nginx/`
- **System Logs**: `/var/log/messages`
- **Compliance Reports**: `reports/`

---

## Contact Information

### Escalation Path

1. **Level 1**: DevOps Team (devops@company.com)
2. **Level 2**: DevOps Manager (manager@company.com)
3. **Level 3**: VP Engineering (vp@company.com)

### On-Call Rotation

Check internal wiki for current on-call schedule.

---

**Document Version**: 1.0.0  
**Last Updated**: October 22, 2025  
**Maintained By**: DevOps Operations Team

################################################################################
# END OF FILE: docs/runbook.md
################################################################################