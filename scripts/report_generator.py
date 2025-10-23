#!/usr/bin/env python3
################################################################################
# Script: report_generator.py
# Purpose: Generate compliance reports from validation results
# Author: DevOps Automation Team
# Last Updated: October 22, 2025
#
# Usage: python3 scripts/report_generator.py --input reports/validation-*.json
################################################################################

import json
import glob
import argparse
from datetime import datetime
from collections import defaultdict

def load_validation_reports(pattern):
    """Load all validation report JSON files matching the pattern."""
    reports = []
    files = glob.glob(pattern)
    
    for file_path in files:
        try:
            with open(file_path, 'r') as f:
                data = json.load(f)
                reports.append(data)
        except Exception as e:
            print(f"Error loading {file_path}: {e}")
    
    return reports

def calculate_statistics(reports):
    """Calculate aggregate statistics from multiple reports."""
    stats = {
        'total_hosts': len(reports),
        'total_checks': 0,
        'total_passed': 0,
        'total_failed': 0,
        'total_warnings': 0,
        'by_host': {},
        'failed_checks': defaultdict(int),
        'compliance_scores': []
    }
    
    for report in reports:
        if 'validation_report' in report:
            vr = report['validation_report']
            hostname = vr['metadata']['hostname']
            summary = vr['summary']
            
            stats['total_checks'] += summary['total_checks']
            stats['total_passed'] += summary['passed']
            stats['total_failed'] += summary['failed']
            stats['total_warnings'] += summary['warnings']
            stats['compliance_scores'].append(summary['compliance_score'])
            
            stats['by_host'][hostname] = {
                'total_checks': summary['total_checks'],
                'passed': summary['passed'],
                'failed': summary['failed'],
                'warnings': summary['warnings'],
                'compliance_score': summary['compliance_score']
            }
            
            # Track which checks are failing across hosts
            for check in vr.get('checks', []):
                if check['status'] == 'FAIL':
                    stats['failed_checks'][check['name']] += 1
    
    # Calculate average compliance
    if stats['compliance_scores']:
        stats['average_compliance'] = sum(stats['compliance_scores']) / len(stats['compliance_scores'])
    else:
        stats['average_compliance'] = 0
    
    return stats

def generate_text_report(stats, output_file):
    """Generate a text-based compliance report."""
    with open(output_file, 'w') as f:
        f.write("=" * 80 + "\n")
        f.write("CIS HARDENING COMPLIANCE REPORT\n")
        f.write("=" * 80 + "\n")
        f.write(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write(f"Total Hosts Analyzed: {stats['total_hosts']}\n")
        f.write("\n")
        
        # Overall Summary
        f.write("-" * 80 + "\n")
        f.write("OVERALL SUMMARY\n")
        f.write("-" * 80 + "\n")
        f.write(f"Total Checks:        {stats['total_checks']}\n")
        f.write(f"Passed:              {stats['total_passed']} ({stats['total_passed']/stats['total_checks']*100:.2f}%)\n")
        f.write(f"Failed:              {stats['total_failed']} ({stats['total_failed']/stats['total_checks']*100:.2f}%)\n")
        f.write(f"Warnings:            {stats['total_warnings']}\n")
        f.write(f"Average Compliance:  {stats['average_compliance']:.2f}%\n")
        f.write("\n")
        
        # Per-Host Results
        f.write("-" * 80 + "\n")
        f.write("PER-HOST RESULTS\n")
        f.write("-" * 80 + "\n")
        for hostname, host_stats in stats['by_host'].items():
            f.write(f"\nHost: {hostname}\n")
            f.write(f"  Compliance Score: {host_stats['compliance_score']:.2f}%\n")
            f.write(f"  Passed:           {host_stats['passed']}/{host_stats['total_checks']}\n")
            f.write(f"  Failed:           {host_stats['failed']}/{host_stats['total_checks']}\n")
            f.write(f"  Warnings:         {host_stats['warnings']}\n")
        f.write("\n")
        
        # Most Common Failures
        if stats['failed_checks']:
            f.write("-" * 80 + "\n")
            f.write("MOST COMMON FAILURES\n")
            f.write("-" * 80 + "\n")
            sorted_failures = sorted(stats['failed_checks'].items(), key=lambda x: x[1], reverse=True)
            for check_name, count in sorted_failures[:10]:
                f.write(f"  [{count} hosts] {check_name}\n")
            f.write("\n")
        
        # Recommendations
        f.write("-" * 80 + "\n")
        f.write("RECOMMENDATIONS\n")
        f.write("-" * 80 + "\n")
        if stats['average_compliance'] < 80:
            f.write("  CRITICAL: Compliance below 80%. Immediate remediation required.\n")
        elif stats['average_compliance'] < 90:
            f.write("  WARNING: Compliance below 90%. Remediation recommended.\n")
        else:
            f.write("  GOOD: Compliance above 90%. Continue monitoring.\n")
        
        if stats['total_failed'] > 0:
            f.write(f"  - Address {stats['total_failed']} failed checks\n")
        if stats['total_warnings'] > 0:
            f.write(f"  - Review {stats['total_warnings']} warnings\n")
        
        f.write("\n")
        f.write("=" * 80 + "\n")
        f.write("END OF REPORT\n")
        f.write("=" * 80 + "\n")
    
    print(f"Text report generated: {output_file}")

def generate_csv_report(stats, output_file):
    """Generate a CSV report for spreadsheet analysis."""
    with open(output_file, 'w') as f:
        # Header
        f.write("Hostname,Total Checks,Passed,Failed,Warnings,Compliance Score\n")
        
        # Data rows
        for hostname, host_stats in stats['by_host'].items():
            f.write(f"{hostname},{host_stats['total_checks']},{host_stats['passed']},")
            f.write(f"{host_stats['failed']},{host_stats['warnings']},{host_stats['compliance_score']:.2f}\n")
    
    print(f"CSV report generated: {output_file}")

def main():
    parser = argparse.ArgumentParser(description='Generate CIS compliance reports from validation results')
    parser.add_argument('--input', required=True, help='Input file pattern (e.g., reports/validation-*.json)')
    parser.add_argument('--output', default='compliance-report', help='Output file prefix (default: compliance-report)')
    parser.add_argument('--format', choices=['text', 'csv', 'both'], default='both', help='Output format')
    
    args = parser.parse_args()
    
    print("=" * 80)
    print("CIS Compliance Report Generator")
    print("=" * 80)
    print(f"Input pattern: {args.input}")
    print(f"Output prefix: {args.output}")
    print()
    
    # Load reports
    print("Loading validation reports...")
    reports = load_validation_reports(args.input)
    
    if not reports:
        print("ERROR: No validation reports found matching pattern")
        return 1
    
    print(f"Loaded {len(reports)} report(s)")
    print()
    
    # Calculate statistics
    print("Calculating statistics...")
    stats = calculate_statistics(reports)
    print()
    
    # Generate reports
    if args.format in ['text', 'both']:
        generate_text_report(stats, f"{args.output}.txt")
    
    if args.format in ['csv', 'both']:
        generate_csv_report(stats, f"{args.output}.csv")
    
    print()
    print("=" * 80)
    print(f"Report generation complete!")
    print(f"Average Compliance Score: {stats['average_compliance']:.2f}%")
    print("=" * 80)
    
    return 0

if __name__ == '__main__':
    exit(main())

################################################################################
# END OF FILE: scripts/report_generator.py
################################################################################