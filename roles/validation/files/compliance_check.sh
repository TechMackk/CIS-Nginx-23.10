#!/bin/bash
################################################################################
# Script: compliance_check.sh
# Purpose: Quick compliance check script
# Author: DevOps Automation Team
# Last Updated: October 22, 2025
################################################################################

set -e

echo "=========================================="
echo "Quick Compliance Check"
echo "=========================================="
echo "Date: $(date)"
echo "Hostname: $(hostname)"
echo "=========================================="

# Function to check and report
check_item() {
    local description="$1"
    local command="$2"
    local expected="$3"
    
    result=$(eval "$command" 2>/dev/null || echo "ERROR")
    
    if [[ "$result" == "$expected" ]]; then
        echo "[PASS] $description"
    else
        echo "[FAIL] $description (Expected: $expected, Got: $result)"
    fi
}

# SELinux
check_item "SELinux Enforcing" "getenforce" "Enforcing"

# Firewall
check_item "Firewalld Running" "systemctl is-active firewalld" "active"

# Auditd
check_item "Auditd Running" "systemctl is-active auditd" "active"

# SSH
check_item "SSH Root Login Disabled" "grep '^PermitRootLogin no' /etc/ssh/sshd_config && echo 'no' || echo 'yes'" "no"

# Core dumps
check_item "Core Dumps Disabled" "sysctl fs.suid_dumpable | awk '{print \$3}'" "0"

echo "=========================================="
echo "Compliance Check Complete"
echo "=========================================="

################################################################################
# END OF FILE: roles/validation/files/compliance_check.sh
################################################################################