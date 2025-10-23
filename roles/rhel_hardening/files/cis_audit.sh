#!/bin/bash
################################################################################
# Script: cis_audit.sh
# Purpose: Manual CIS compliance audit script for RHEL 8/9
# Author: DevOps Automation Team
# Last Updated: October 22, 2025
# Usage: ./cis_audit.sh [options]
#
# Description:
#   Performs manual checks for CIS RHEL 8/9 Benchmark controls that are
#   difficult to automate with Ansible. Generates a compliance report.
#
# Options:
#   -h, --help       Display this help message
#   -v, --verbose    Enable verbose output
#   -o, --output     Specify output file (default: cis_audit_report.txt)
################################################################################

set -u  # Exit on undefined variable

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables
SCRIPT_NAME=$(basename "$0")
VERBOSE=0
OUTPUT_FILE="cis_audit_report_$(date +%Y%m%d_%H%M%S).txt"
PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

################################################################################
# Functions
################################################################################

# Display help message
show_help() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Manual CIS RHEL 8/9 Benchmark Compliance Audit Script

Options:
    -h, --help       Display this help message
    -v, --verbose    Enable verbose output
    -o, --output     Specify output file (default: cis_audit_report.txt)

Examples:
    $SCRIPT_NAME
    $SCRIPT_NAME -v -o /tmp/audit.txt
    $SCRIPT_NAME --verbose --output=/var/log/cis_audit.txt

EOF
}

# Print formatted output
print_status() {
    local status="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$status" in
        PASS)
            echo -e "${GREEN}[PASS]${NC} $message" | tee -a "$OUTPUT_FILE"
            ((PASS_COUNT++))
            ;;
        FAIL)
            echo -e "${RED}[FAIL]${NC} $message" | tee -a "$OUTPUT_FILE"
            ((FAIL_COUNT++))
            ;;
        WARN)
            echo -e "${YELLOW}[WARN]${NC} $message" | tee -a "$OUTPUT_FILE"
            ((WARN_COUNT++))
            ;;
        INFO)
            echo -e "${BLUE}[INFO]${NC} $message" | tee -a "$OUTPUT_FILE"
            ;;
        *)
            echo "$message" | tee -a "$OUTPUT_FILE"
            ;;
    esac
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}ERROR: This script must be run as root${NC}"
        exit 1
    fi
}

# Initialize report file
init_report() {
    cat > "$OUTPUT_FILE" << EOF
================================================================================
                    CIS RHEL 8/9 Compliance Audit Report
================================================================================
Generated: $(date)
Hostname: $(hostname)
OS: $(cat /etc/redhat-release)
Kernel: $(uname -r)
Auditor: $(whoami)
================================================================================

EOF
}

################################################################################
# CIS Check Functions
################################################################################

# CIS 1.1.1.x - Check disabled filesystems
check_disabled_filesystems() {
    print_status "INFO" ""
    print_status "INFO" "=== CIS 1.1.1 - Disabled Filesystems ==="
    
    local filesystems=("cramfs" "freevxfs" "jffs2" "hfs" "hfsplus" "squashfs" "udf" "vfat")
    
    for fs in "${filesystems[@]}"; do
        if lsmod | grep -q "^$fs"; then
            print_status "FAIL" "Filesystem $fs is loaded"
        elif modprobe -n -v "$fs" 2>&1 | grep -q "install /bin/true"; then
            print_status "PASS" "Filesystem $fs is disabled"
        else
            print_status "WARN" "Filesystem $fs may not be properly disabled"
        fi
    done
}

# CIS 1.5.1 - Check core dump restrictions
check_core_dumps() {
    print_status "INFO" ""
    print_status "INFO" "=== CIS 1.5.1 - Core Dump Restrictions ==="
    
    # Check limits.conf
    if grep -q "hard core 0" /etc/security/limits.conf; then
        print_status "PASS" "Core dumps restricted in limits.conf"
    else
        print_status "FAIL" "Core dumps not restricted in limits.conf"
    fi
    
    # Check sysctl
    local suid_dumpable=$(sysctl fs.suid_dumpable | awk '{print $3}')
    if [[ "$suid_dumpable" == "0" ]]; then
        print_status "PASS" "fs.suid_dumpable is set to 0"
    else
        print_status "FAIL" "fs.suid_dumpable is set to $suid_dumpable (should be 0)"
    fi
}

# CIS 1.6.1 - Check SELinux status
check_selinux() {
    print_status "INFO" ""
    print_status "INFO" "=== CIS 1.6.1 - SELinux Configuration ==="
    
    if command -v getenforce &> /dev/null; then
        local selinux_status=$(getenforce)
        if [[ "$selinux_status" == "Enforcing" ]]; then
            print_status "PASS" "SELinux is in Enforcing mode"
        else
            print_status "FAIL" "SELinux is in $selinux_status mode (should be Enforcing)"
        fi
    else
        print_status "FAIL" "SELinux is not installed"
    fi
}

# CIS 3.3 - Check network parameters
check_network_parameters() {
    print_status "INFO" ""
    print_status "INFO" "=== CIS 3.3 - Network Parameters ==="
    
    declare -A params=(
        ["net.ipv4.ip_forward"]="0"
        ["net.ipv4.conf.all.send_redirects"]="0"
        ["net.ipv4.conf.all.accept_source_route"]="0"
        ["net.ipv4.conf.all.accept_redirects"]="0"
        ["net.ipv4.conf.all.log_martians"]="1"
        ["net.ipv4.icmp_echo_ignore_broadcasts"]="1"
        ["net.ipv4.tcp_syncookies"]="1"
    )
    
    for param in "${!params[@]}"; do
        local current=$(sysctl -n "$param" 2>/dev/null)
        local expected="${params[$param]}"
        
        if [[ "$current" == "$expected" ]]; then
            print_status "PASS" "$param = $current"
        else
            print_status "FAIL" "$param = $current (expected: $expected)"
        fi
    done
}

# CIS 4.1 - Check auditd
check_auditd() {
    print_status "INFO" ""
    print_status "INFO" "=== CIS 4.1 - Auditd Configuration ==="
    
    # Check if auditd is enabled
    if systemctl is-enabled auditd &> /dev/null; then
        print_status "PASS" "auditd service is enabled"
    else
        print_status "FAIL" "auditd service is not enabled"
    fi
    
    # Check if auditd is running
    if systemctl is-active auditd &> /dev/null; then
        print_status "PASS" "auditd service is running"
    else
        print_status "FAIL" "auditd service is not running"
    fi
    
    # Check audit rules count
    local rule_count=$(auditctl -l 2>/dev/null | wc -l)
    if [[ $rule_count -gt 10 ]]; then
        print_status "PASS" "Audit rules configured ($rule_count rules)"
    else
        print_status "WARN" "Few audit rules configured ($rule_count rules)"
    fi
}

# CIS 5.2 - Check SSH configuration
check_ssh_config() {
    print_status "INFO" ""
    print_status "INFO" "=== CIS 5.2 - SSH Configuration ==="
    
    local sshd_config="/etc/ssh/sshd_config"
    
    declare -A ssh_params=(
        ["PermitRootLogin"]="no"
        ["PermitEmptyPasswords"]="no"
        ["PasswordAuthentication"]="no"
        ["X11Forwarding"]="no"
        ["MaxAuthTries"]="3"
        ["LogLevel"]="INFO"
    )
    
    for param in "${!ssh_params[@]}"; do
        local expected="${ssh_params[$param]}"
        local current=$(grep "^$param" "$sshd_config" 2>/dev/null | awk '{print $2}')
        
        if [[ "$current" == "$expected" ]]; then
            print_status "PASS" "$param = $current"
        else
            print_status "FAIL" "$param = $current (expected: $expected)"
        fi
    done
}

# CIS 6.1 - Check system file permissions
check_file_permissions() {
    print_status "INFO" ""
    print_status "INFO" "=== CIS 6.1 - System File Permissions ==="
    
    declare -A files=(
        ["/etc/passwd"]="0644"
        ["/etc/shadow"]="0000"
        ["/etc/group"]="0644"
        ["/etc/gshadow"]="0000"
    )
    
    for file in "${!files[@]}"; do
        if [[ -f "$file" ]]; then
            local perms=$(stat -c %a "$file")
            local expected="${files[$file]}"
            
            if [[ "$perms" == "$expected" ]]; then
                print_status "PASS" "$file permissions: $perms"
            else
                print_status "FAIL" "$file permissions: $perms (expected: $expected)"
            fi
        else
            print_status "WARN" "$file does not exist"
        fi
    done
}

# Generate summary report
generate_summary() {
    cat >> "$OUTPUT_FILE" << EOF

================================================================================
                            Audit Summary
================================================================================
Total Checks: $((PASS_COUNT + FAIL_COUNT + WARN_COUNT))
Passed:       $PASS_COUNT
Failed:       $FAIL_COUNT
Warnings:     $WARN_COUNT

Compliance Rate: $(awk "BEGIN {printf \"%.2f\", ($PASS_COUNT/($PASS_COUNT+$FAIL_COUNT+$WARN_COUNT))*100}")%

Report saved to: $OUTPUT_FILE
================================================================================
EOF

    print_status "INFO" ""
    print_status "INFO" "Audit Summary:"
    print_status "INFO" "  Passed:   $PASS_COUNT"
    print_status "INFO" "  Failed:   $FAIL_COUNT"
    print_status "INFO" "  Warnings: $WARN_COUNT"
    print_status "INFO" ""
    print_status "INFO" "Full report: $OUTPUT_FILE"
}

################################################################################
# Main Execution
################################################################################

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=1
            shift
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --output=*)
            OUTPUT_FILE="${1#*=}"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Main execution
main() {
    check_root
    init_report
    
    print_status "INFO" "Starting CIS RHEL 8/9 Compliance Audit..."
    print_status "INFO" ""
    
    # Run all checks
    check_disabled_filesystems
    check_core_dumps
    check_selinux
    check_network_parameters
    check_auditd
    check_ssh_config
    check_file_permissions
    
    # Generate summary
    generate_summary
}

# Execute main function
main

exit 0

################################################################################
# END OF FILE: roles/rhel_hardening/files/cis_audit.sh
################################################################################