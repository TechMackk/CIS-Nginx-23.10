# CIS Hardening Automation - Troubleshooting Guide

## Table of Contents

- [Common Issues](#common-issues)
- [Deployment Failures](#deployment-failures)
- [Connectivity Issues](#connectivity-issues)
- [Service Issues](#service-issues)
- [Security Issues](#security-issues)
- [Performance Issues](#performance-issues)
- [Validation Failures](#validation-failures)
- [Diagnostic Commands](#diagnostic-commands)

---

## Common Issues

### Issue: Ansible Cannot Connect to Hosts

**Symptoms**:
fatal: [host]: UNREACHABLE! => {"changed": false, "msg": "Failed to connect to the host via ssh"}

text

**Causes**:
- SSH key not configured
- Firewall blocking port 22
- SSH service not running
- Wrong inventory IP/hostname

**Solution**:
1. Test SSH connectivity
ssh -i ~/.ssh/ansible_key ansible@target-host

2. Verify SSH service
ansible -i inventory/dev/hosts.yml target-host -m shell -a "systemctl status sshd"

3. Check firewall
ansible -i inventory/dev/hosts.yml target-host -m shell -a "firewall-cmd --list-all"

4. Verify inventory
ansible-inventory -i inventory/dev/hosts.yml --list

text

---

### Issue: Vault Password Incorrect

**Symptoms**:
ERROR! Decryption failed (no vault secrets loaded)

text

**Solution**:
1. Verify vault password file
cat ~/.ansible/vault_password

2. Test decryption
ansible-vault view inventory/dev/group_vars/vault.yml --vault-password-file=~/.ansible/vault_password

3. If forgotten, re-encrypt with new password
ansible-vault rekey inventory/dev/group_vars/vault.yml

text

---

### Issue: Permission Denied Errors

**Symptoms**:
fatal: [host]: FAILED! => {"changed": false, "msg": "Permission denied"}

text

**Solution**:
1. Verify sudo access
ansible -i inventory/dev/hosts.yml all -m shell -a "sudo -l"

2. Check ansible.cfg settings
grep become ansible.cfg

3. Use --become flag
ansible-playbook playbooks/site.yml --become --ask-become-pass

text

---

## Deployment Failures

### Issue: Playbook Fails Mid-Execution

**Symptoms**:
- Some tasks complete, then failure
- Partial configuration applied

**Diagnosis**:
1. Check last successful task
grep "ok:" logs/ansible.log | tail -5

2. Check failed task
grep "fatal:" logs/ansible.log | tail -5

3. Review detailed error
grep -A 10 "fatal:" logs/ansible.log

text

**Recovery**:
Option 1: Retry from failed task
ansible-playbook playbooks/site.yml --start-at-task="Task Name"

Option 2: Retry failed hosts only
ansible-playbook playbooks/site.yml --limit @logs/retry/site.retry

Option 3: Full rollback
ansible-playbook playbooks/rollback.yml

text

---

### Issue: Role Task Fails

**Example Error**:
TASK [rhel_hardening : CIS 1.6.1.3-5 | Configure SELinux state] *****
fatal: [host]: FAILED! => {"msg": "SELinux state change requires reboot"}

text

**Solution**:
1. Check if reboot required
ansible -i inventory/dev/hosts.yml all -m shell -a "needs-restarting -r"

2. Schedule reboot
ansible -i inventory/dev/hosts.yml all -m reboot

3. Re-run playbook
ansible-playbook playbooks/site.yml

text

---

## Connectivity Issues

### Issue: Hosts Unreachable After Hardening

**Symptoms**:
- SSH works before hardening
- Cannot connect after hardening
- Timeout errors

**Causes**:
- Firewall blocked SSH
- SSH configuration error
- SELinux denials

**Diagnosis**:
1. Try from different source
ssh -i ~/.ssh/ansible_key ansible@target-host

2. Check console access (Azure/VMware)
Login via console and check:
systemctl status sshd
systemctl status firewalld
firewall-cmd --list-all
getenforce

text

**Solution**:
Via console:
1. Verify SSH service
systemctl restart sshd

2. Temporarily open firewall
firewall-cmd --add-service=ssh

3. Check SELinux denials
ausearch -m avc -ts recent

4. If needed, rollback
ansible-playbook playbooks/rollback.yml --limit target-host

text

---

### Issue: SSH Connection Slow

**Symptoms**:
- SSH takes 30+ seconds to connect
- Ansible tasks timeout

**Causes**:
- DNS resolution delays
- GSSAPI authentication attempts

**Solution**:
1. Disable DNS in SSH
echo "UseDNS no" >> /etc/ssh/sshd_config
systemctl restart sshd

2. Disable GSSAPI
echo "GSSAPIAuthentication no" >> /etc/ssh/sshd_config
systemctl restart sshd

3. Update ansible.cfg
echo "ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o GSSAPIAuthentication=no" >> ansible.cfg

text

---

## Service Issues

### Issue: NGINX Won't Start

**Symptoms**:
Job for nginx.service failed because the control process exited with error code

text

**Diagnosis**:
1. Check NGINX error log
tail -50 /var/log/nginx/error.log

2. Test configuration
nginx -t

3. Check port conflicts
ss -tulpn | grep :80
ss -tulpn | grep :443

4. Check SELinux denials
ausearch -m avc -c nginx

text

**Common Fixes**:
Fix 1: Configuration syntax error
nginx -t

Fix syntax errors in /etc/nginx/nginx.conf
Fix 2: Port already in use
systemctl stop httpd # If Apache running
systemctl start nginx

Fix 3: SELinux blocking
setsebool -P httpd_can_network_connect on
semanage port -a -t http_port_t -p tcp 8080 # If custom port

Fix 4: SSL certificate issues
openssl x509 -noout -text -in /etc/nginx/ssl/server.crt

Regenerate if needed
text

---

### Issue: Firewalld Not Starting

**Symptoms**:
Failed to start firewalld.service: Unit firewalld.service not found

text

**Solution**:
1. Install firewalld
yum install -y firewalld

2. Enable and start
systemctl enable --now firewalld

3. Verify
firewall-cmd --state

text

---

### Issue: Auditd Service Fails

**Symptoms**:
Failed to restart auditd.service: Operation refused, unit auditd.service may be requested by dependency only

text

**Solution**:
Auditd requires special restart command
service auditd restart

Not: systemctl restart auditd
text

---

## Security Issues

### Issue: SELinux Denials

**Symptoms**:
SELinux is preventing /usr/sbin/nginx from ...

text

**Diagnosis**:
1. Check recent denials
ausearch -m avc -ts recent

2. Generate policy
audit2allow -a

3. Check nginx context
ls -Z /etc/nginx/
ps -eZ | grep nginx

text

**Solution**:
Fix 1: Restore correct context
restorecon -Rv /etc/nginx/
restorecon -Rv /var/www/html/

Fix 2: Allow specific permission
ausearch -m avc -ts recent | audit2allow -M mynginx
semodule -i mynginx.pp

Fix 3: Set boolean (if applicable)
setsebool -P httpd_can_network_connect on

text

---

### Issue: Certificate Validation Fails

**Symptoms**:
SSL certificate problem: self signed certificate

text

**Diagnosis**:
Check certificate details
openssl x509 -noout -text -in /etc/nginx/ssl/server.crt

Verify certificate and key match
openssl x509 -noout -modulus -in /etc/nginx/ssl/server.crt | openssl md5
openssl rsa -noout -modulus -in /etc/nginx/ssl/server.key | openssl md5

text

**Solution**:
Regenerate self-signed cert
ansible-playbook playbooks/ssl_tls.yml --extra-vars "ssl_force_regenerate=true"

Or deploy proper certificate
scp production-cert.crt target-host:/etc/nginx/ssl/server.crt
scp production-key.key target-host:/etc/nginx/ssl/server.key
systemctl restart nginx

text

---

## Performance Issues

### Issue: Ansible Playbook Runs Slowly

**Symptoms**:
- Tasks take minutes instead of seconds
- Gathering facts is slow
- Overall execution >2x expected time

**Solutions**:
1. Disable fact gathering if not needed
ansible-playbook playbooks/site.yml --tags backup -e "gather_facts=False"

2. Increase forks in ansible.cfg
sed -i 's/forks = 5/forks = 20/' ansible.cfg

3. Enable pipelining
echo "pipelining = True" >> ansible.cfg

4. Use fact caching
echo "fact_caching = jsonfile" >> ansible.cfg
echo "fact_caching_connection = /tmp/ansible_facts" >> ansible.cfg

text

---

### Issue: NGINX Performance Degraded

**Symptoms**:
- High response times
- Connection timeouts
- High CPU usage

**Diagnosis**:
Check NGINX status
curl http://localhost:8080/nginx_status

Check error logs
tail -100 /var/log/nginx/error.log | grep -i error

Check system resources
top
iostat
netstat -an | grep :80 | wc -l

text

**Solutions**:
Increase worker connections
sed -i 's/worker_connections 1024;/worker_connections 4096;/' /etc/nginx/nginx.conf

Adjust worker processes
sed -i 's/worker_processes auto;/worker_processes 4;/' /etc/nginx/nginx.conf

Reload configuration
nginx -t && systemctl reload nginx

text

---

## Validation Failures

### Issue: OpenSCAP Scan Fails

**Symptoms**:
oscap: command not found

text

**Solution**:
Install OpenSCAP
yum install -y openscap-scanner scap-security-guide

Verify installation
oscap --version

Re-run validation
ansible-playbook playbooks/validate.yml

text

---

### Issue: Compliance Score Low

**Symptoms**:
- Compliance score <80%
- Multiple failed checks

**Diagnosis**:
Review validation report
cat reports/validation-*.json | jq '.checks[] | select(.status=="FAIL")'

Check specific control
ansible -i inventory/production/hosts.yml all -m shell -a "getenforce"

text

**Solution**:
Re-run hardening for failed controls
ansible-playbook playbooks/harden_rhel.yml --tags cis_1,cis_5

Or re-run full hardening
ansible-playbook playbooks/site.yml

text

---

## Diagnostic Commands

### System Information

OS version
ansible -i inventory/ENVIRONMENT/hosts.yml all -m shell -a "cat /etc/redhat-release"

Kernel version
ansible -i inventory/ENVIRONMENT/hosts.yml all -m shell -a "uname -r"

Uptime
ansible -i inventory/ENVIRONMENT/hosts.yml all -m shell -a "uptime"

Disk space
ansible -i inventory/ENVIRONMENT/hosts.yml all -m shell -a "df -h"

Memory
ansible -i inventory/ENVIRONMENT/hosts.yml all -m shell -a "free -h"

text

### Service Status

All services
ansible -i inventory/ENVIRONMENT/hosts.yml all -m shell -a "systemctl list-units --type=service --state=running"

Specific services
ansible -i inventory/ENVIRONMENT/hosts.yml all -m systemd -a "name=nginx"
ansible -i inventory/ENVIRONMENT/hosts.yml all -m systemd -a "name=firewalld"
ansible -i inventory/ENVIRONMENT/hosts.yml all -m shell -a "systemctl status auditd"

text

### Security Status

SELinux
ansible -i inventory/ENVIRONMENT/hosts.yml all -m shell -a "getenforce"

Firewall
ansible -i inventory/ENVIRONMENT/hosts.yml all -m shell -a "firewall-cmd --list-all"

Audit rules
ansible -i inventory/ENVIRONMENT/hosts.yml all -m shell -a "auditctl -l | wc -l"

Failed login attempts
ansible -i inventory/ENVIRONMENT/hosts.yml all -m shell -a "faillog -a"

text

### Log Analysis

Recent errors
ansible -i inventory/ENVIRONMENT/hosts.yml all -m shell -a "journalctl -p err -n 20"

Audit denials
ansible -i inventory/ENVIRONMENT/hosts.yml all -m shell -a "ausearch -m avc -ts recent"

NGINX errors
ansible -i inventory/ENVIRONMENT/hosts.yml webservers -m shell -a "tail -50 /var/log/nginx/error.log"

text

---

## Getting Help

### Internal Resources

- **Documentation**: `docs/` directory
- **Logs**: `logs/ansible.log`
- **Reports**: `reports/`
- **Internal Wiki**: https://wiki.company.com/cis-hardening

### External Resources

- **Ansible Docs**: https://docs.ansible.com
- **CIS Benchmarks**: https://www.cisecurity.org
- **RHEL Documentation**: https://access.redhat.com

### Support Contacts

- **Email**: devops@company.com
- **Slack**: #ansible-hardening
- **On-Call**: Check internal wiki

---

**Document Version**: 1.0.0  
**Last Updated**: October 22, 2025  
**Maintained By**: DevOps Support Team

################################################################################
# END OF FILE: docs/troubleshooting.md
################################################################################