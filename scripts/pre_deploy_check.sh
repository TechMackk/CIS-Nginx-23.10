#!/bin/bash
################################################################################
# Script: pre_deploy_check.sh
# Purpose: Pre-deployment validation checks before CIS hardening
# Author: DevOps Automation Team
# Last Updated: October 22, 2025
#
# Usage: ./scripts/pre_deploy_check.sh [environment]
################################################################################

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Variables
ENVIRONMENT=${1:-dev}
INVENTORY_FILE="inventory/${ENVIRONMENT}/hosts.yml"
ANSIBLE_CONFIG="ansible.cfg"
VAULT_PASSWORD_FILE="${HOME}/.ansible/vault_password_${ENVIRONMENT}"

# Counters
PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

# Functions
print_header() {
    echo -e "${BLUE}=========================================="
    echo -e "Pre-Deployment Check: ${ENVIRONMENT^^}"
    echo -e "==========================================${NC}"
    echo -e "Date: $(date)"
    echo -e "User: $(whoami)"
    echo
}

check_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASS_COUNT++))
}

check_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((FAIL_COUNT++))
}

check_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    ((WARN_COUNT++))
}

check_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Check 1: Environment validation
check_environment() {
    echo "## Environment Validation"
    
    if [[ "$ENVIRONMENT" =~ ^(dev|test|qa|production)$ ]]; then
        check_pass "Valid environment: $ENVIRONMENT"
    else
        check_fail "Invalid environment: $ENVIRONMENT (must be: dev, test, qa, production)"
    fi
    echo
}

# Check 2: Ansible installation
check_ansible() {
    echo "## Ansible Installation"
    
    if command -v ansible &> /dev/null; then
        local version=$(ansible --version | head -1)
        check_pass "Ansible installed: $version"
        
        # Check version compatibility
        local ansible_version=$(ansible --version | grep "^ansible" | awk '{print $2}' | cut -d. -f1,2)
        if (( $(echo "$ansible_version >= 2.9" | bc -l) )); then
            check_pass "Ansible version is compatible (>= 2.9)"
        else
            check_warn "Ansible version may be incompatible (< 2.9)"
        fi
    else
        check_fail "Ansible is not installed"
    fi
    echo
}

# Check 3: Inventory file
check_inventory() {
    echo "## Inventory Validation"
    
    if [ -f "$INVENTORY_FILE" ]; then
        check_pass "Inventory file exists: $INVENTORY_FILE"
        
        # Validate inventory syntax
        if ansible-inventory -i "$INVENTORY_FILE" --list &> /dev/null; then
            check_pass "Inventory syntax is valid"
            
            # Count hosts
            local host_count=$(ansible-inventory -i "$INVENTORY_FILE" --list | jq -r '.all.children | keys[]' 2>/dev/null | wc -l)
            check_info "Host groups found: $host_count"
        else
            check_fail "Inventory syntax is invalid"
        fi
    else
        check_fail "Inventory file not found: $INVENTORY_FILE"
    fi
    echo
}

# Check 4: Ansible configuration
check_ansible_config() {
    echo "## Ansible Configuration"
    
    if [ -f "$ANSIBLE_CONFIG" ]; then
        check_pass "ansible.cfg found"
        
        # Check key settings
        if grep -q "^host_key_checking = False" "$ANSIBLE_CONFIG"; then
            check_pass "Host key checking disabled"
        else
            check_warn "Host key checking may cause issues"
        fi
        
        if grep -q "^retry_files_enabled = False" "$ANSIBLE_CONFIG"; then
            check_pass "Retry files disabled"
        fi
    else
        check_warn "ansible.cfg not found (using defaults)"
    fi
    echo
}

# Check 5: Vault password
check_vault_password() {
    echo "## Vault Password"
    
    if [ -f "$VAULT_PASSWORD_FILE" ]; then
        check_pass "Vault password file exists"
        
        # Check permissions
        local perms=$(stat -c %a "$VAULT_PASSWORD_FILE")
        if [ "$perms" == "600" ]; then
            check_pass "Vault password file has correct permissions (600)"
        else
            check_warn "Vault password file permissions should be 600 (current: $perms)"
        fi
    else
        check_fail "Vault password file not found: $VAULT_PASSWORD_FILE"
        check_info "Run: ./scripts/generate_vault_password.sh $ENVIRONMENT"
    fi
    echo
}

# Check 6: SSH connectivity
check_ssh_connectivity() {
    echo "## SSH Connectivity"
    
    if [ -f "$INVENTORY_FILE" ]; then
        check_info "Testing SSH connectivity to all hosts..."
        
        if ansible -i "$INVENTORY_FILE" all -m ping &> /dev/null; then
            check_pass "All hosts are reachable via SSH"
        else
            check_fail "Some hosts are not reachable"
            check_info "Run: ansible -i $INVENTORY_FILE all -m ping"
        fi
    else
        check_warn "Cannot test SSH (inventory not found)"
    fi
    echo
}

# Check 7: Required collections
check_collections() {
    echo "## Ansible Collections"
    
    if [ -f "requirements.yml" ]; then
        check_pass "requirements.yml found"
        
        # Check if collections are installed
        local required_collections=$(grep "name:" requirements.yml | awk '{print $3}' | tr -d '"')
        for collection in $required_collections; do
            if ansible-galaxy collection list | grep -q "$collection"; then
                check_pass "Collection installed: $collection"
            else
                check_warn "Collection not installed: $collection"
                check_info "Run: ansible-galaxy collection install -r requirements.yml"
            fi
        done
    else
        check_warn "requirements.yml not found"
    fi
    echo
}

# Check 8: Directory structure
check_directory_structure() {
    echo "## Directory Structure"
    
    local required_dirs=("playbooks" "roles" "inventory" "reports" "logs")
    
    for dir in "${required_dirs[@]}"; do
        if [ -d "$dir" ]; then
            check_pass "Directory exists: $dir/"
        else
            check_fail "Directory missing: $dir/"
        fi
    done
    echo
}

# Check 9: Playbook syntax
check_playbook_syntax() {
    echo "## Playbook Syntax"
    
    local playbooks=("site.yml" "precheck.yml" "backup.yml" "validate.yml")
    
    for playbook in "${playbooks[@]}"; do
        if [ -f "playbooks/$playbook" ]; then
            if ansible-playbook "playbooks/$playbook" --syntax-check &> /dev/null; then
                check_pass "Syntax valid: playbooks/$playbook"
            else
                check_fail "Syntax error: playbooks/$playbook"
            fi
        else
            check_warn "Playbook not found: playbooks/$playbook"
        fi
    done
    echo
}

# Check 10: Disk space
check_disk_space() {
    echo "## Disk Space"
    
    local required_space_gb=5
    local available_space=$(df -BG . | tail -1 | awk '{print $4}' | tr -d 'G')
    
    if [ "$available_space" -gt "$required_space_gb" ]; then
        check_pass "Sufficient disk space: ${available_space}GB available"
    else
        check_warn "Low disk space: ${available_space}GB available (${required_space_gb}GB recommended)"
    fi
    echo
}

# Check 11: Python dependencies
check_python_deps() {
    echo "## Python Dependencies"
    
    local python_cmd="python3"
    
    if command -v $python_cmd &> /dev/null; then
        local python_version=$($python_cmd --version 2>&1)
        check_pass "Python installed: $python_version"
        
        # Check for required modules
        local required_modules=("jinja2" "yaml")
        for module in "${required_modules[@]}"; do
            if $python_cmd -c "import $module" &> /dev/null; then
                check_pass "Python module available: $module"
            else
                check_warn "Python module missing: $module"
            fi
        done
    else
        check_fail "Python3 not found"
    fi
    echo
}

# Summary
print_summary() {
    echo -e "${BLUE}=========================================="
    echo -e "Pre-Deployment Check Summary"
    echo -e "==========================================${NC}"
    echo -e "Environment: ${ENVIRONMENT}"
    echo -e "Passed:      ${GREEN}${PASS_COUNT}${NC}"
    echo -e "Failed:      ${RED}${FAIL_COUNT}${NC}"
    echo -e "Warnings:    ${YELLOW}${WARN_COUNT}${NC}"
    echo
    
    if [ $FAIL_COUNT -eq 0 ]; then
        echo -e "${GREEN}✓ All critical checks passed!${NC}"
        echo -e "${GREEN}✓ Ready for deployment${NC}"
        echo
        return 0
    else
        echo -e "${RED}✗ ${FAIL_COUNT} critical check(s) failed${NC}"
        echo -e "${RED}✗ Fix issues before deployment${NC}"
        echo
        return 1
    fi
}

# Main execution
main() {
    print_header
    
    check_environment
    check_ansible
    check_inventory
    check_ansible_config
    check_vault_password
    check_ssh_connectivity
    check_collections
    check_directory_structure
    check_playbook_syntax
    check_disk_space
    check_python_deps
    
    print_summary
}

# Run main
main

################################################################################
# END OF FILE: scripts/pre_deploy_check.sh
################################################################################