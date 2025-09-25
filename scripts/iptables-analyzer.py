#!/usr/bin/env python3
"""
iptables Firewall Analyzer Tool
A comprehensive tool for analyzing iptables rules, security policies, and performance.
"""

import subprocess
import json
import re
import argparse
import sys
from datetime import datetime
from collections import defaultdict

class IptablesAnalyzer:
    def __init__(self):
        self.rules = {}
        self.stats = {}
        self.security_issues = []
        self.performance_issues = []
        
    def run_command(self, command):
        """Run a command and return output"""
        try:
            result = subprocess.run(command, shell=True, capture_output=True, text=True)
            return result.stdout, result.stderr, result.returncode
        except Exception as e:
            return "", str(e), 1
    
    def get_iptables_rules(self):
        """Get all iptables rules from all tables"""
        tables = ['filter', 'nat', 'mangle', 'raw']
        
        for table in tables:
            stdout, stderr, returncode = self.run_command(f"iptables -t {table} -L -n -v --line-numbers")
            if returncode == 0:
                self.rules[table] = self.parse_rules(stdout)
            else:
                print(f"Warning: Could not get {table} table rules: {stderr}")
    
    def parse_rules(self, output):
        """Parse iptables output into structured data"""
        rules = []
        lines = output.strip().split('\n')
        
        for line in lines:
            if line.startswith('Chain'):
                continue
            if line.startswith('target') and 'prot' in line:
                continue
            if line.strip() == '':
                continue
                
            # Parse rule line
            parts = line.split()
            if len(parts) >= 4:
                rule = {
                    'line_number': parts[0] if parts[0].isdigit() else None,
                    'target': parts[1] if len(parts) > 1 else 'UNKNOWN',
                    'prot': parts[2] if len(parts) > 2 else 'all',
                    'opt': parts[3] if len(parts) > 3 else '',
                    'source': parts[4] if len(parts) > 4 else 'anywhere',
                    'destination': parts[5] if len(parts) > 5 else 'anywhere',
                    'raw_line': line.strip()
                }
                rules.append(rule)
        
        return rules
    
    def analyze_security(self):
        """Analyze security aspects of the firewall rules"""
        print("🔒 Security Analysis")
        print("=" * 50)
        
        # Check for default policies
        self.check_default_policies()
        
        # Check for dangerous rules
        self.check_dangerous_rules()
        
        # Check for missing security rules
        self.check_missing_security_rules()
        
        # Check for open ports
        self.check_open_ports()
        
        # Check for logging
        self.check_logging_rules()
    
    def check_default_policies(self):
        """Check default policies for security"""
        print("\n📋 Default Policies:")
        
        for table, rules in self.rules.items():
            if table == 'filter':
                # Get policy information
                stdout, _, _ = self.run_command("iptables -L | grep 'policy'")
                policies = stdout.strip().split('\n')
                
                for policy in policies:
                    if 'policy' in policy:
                        print(f"  {policy.strip()}")
                        
                        # Check if policies are secure
                        if 'ACCEPT' in policy and 'DROP' not in policy:
                            self.security_issues.append(f"Insecure default policy: {policy.strip()}")
    
    def check_dangerous_rules(self):
        """Check for potentially dangerous rules"""
        print("\n⚠️  Dangerous Rules Check:")
        
        dangerous_patterns = [
            (r'ACCEPT.*0\.0\.0\.0/0', 'Allows traffic from anywhere'),
            (r'ACCEPT.*anywhere.*anywhere', 'Allows all traffic'),
            (r'DROP.*22', 'Blocks SSH access'),
            (r'ACCEPT.*23', 'Allows telnet (insecure)'),
            (r'ACCEPT.*135:139', 'Allows NetBIOS ports'),
        ]
        
        for table, rules in self.rules.items():
            for rule in rules:
                for pattern, description in dangerous_patterns:
                    if re.search(pattern, rule['raw_line']):
                        print(f"  ⚠️  {description}: {rule['raw_line']}")
                        self.security_issues.append(f"Dangerous rule: {description}")
    
    def check_missing_security_rules(self):
        """Check for missing important security rules"""
        print("\n🛡️  Missing Security Rules:")
        
        # Check for established connections rule
        has_established = False
        for table, rules in self.rules.items():
            for rule in rules:
                if 'ESTABLISHED' in rule['raw_line'] or 'RELATED' in rule['raw_line']:
                    has_established = True
                    break
        
        if not has_established:
            print("  ❌ Missing rule for established/related connections")
            self.security_issues.append("Missing established/related connections rule")
        else:
            print("  ✅ Has established/related connections rule")
        
        # Check for loopback rules
        has_loopback = False
        for table, rules in self.rules.items():
            for rule in rules:
                if 'lo' in rule['raw_line']:
                    has_loopback = True
                    break
        
        if not has_loopback:
            print("  ❌ Missing loopback interface rules")
            self.security_issues.append("Missing loopback interface rules")
        else:
            print("  ✅ Has loopback interface rules")
    
    def check_open_ports(self):
        """Check for open ports and services"""
        print("\n🔍 Open Ports Analysis:")
        
        open_ports = []
        for table, rules in self.rules.items():
            for rule in rules:
                if rule['target'] == 'ACCEPT' and 'dpt:' in rule['raw_line']:
                    # Extract port from rule
                    port_match = re.search(r'dpt:(\d+)', rule['raw_line'])
                    if port_match:
                        port = port_match.group(1)
                        protocol = rule['prot']
                        open_ports.append(f"{protocol}:{port}")
        
        if open_ports:
            print("  Open ports:")
            for port in set(open_ports):
                print(f"    - {port}")
        else:
            print("  No open ports found in iptables rules")
    
    def check_logging_rules(self):
        """Check for logging rules"""
        print("\n📝 Logging Rules:")
        
        has_logging = False
        for table, rules in self.rules.items():
            for rule in rules:
                if rule['target'] == 'LOG':
                    has_logging = True
                    print(f"  ✅ {rule['raw_line']}")
        
        if not has_logging:
            print("  ❌ No logging rules found")
            self.security_issues.append("No logging rules configured")
    
    def analyze_performance(self):
        """Analyze performance aspects of the firewall rules"""
        print("\n⚡ Performance Analysis")
        print("=" * 50)
        
        # Count rules per table
        print("\n📊 Rule Count by Table:")
        for table, rules in self.rules.items():
            print(f"  {table}: {len(rules)} rules")
        
        # Check for inefficient rules
        self.check_inefficient_rules()
        
        # Check rule order
        self.check_rule_order()
    
    def check_inefficient_rules(self):
        """Check for inefficient rules"""
        print("\n🔧 Rule Efficiency:")
        
        for table, rules in self.rules.items():
            if table == 'filter':
                # Check for rules that should be at the top
                common_ports = ['22', '80', '443']
                for i, rule in enumerate(rules):
                    for port in common_ports:
                        if port in rule['raw_line'] and i > 5:
                            print(f"  ⚠️  Common port {port} rule at position {i+1} (consider moving up)")
                            self.performance_issues.append(f"Port {port} rule should be moved up")
    
    def check_rule_order(self):
        """Check rule ordering for efficiency"""
        print("\n📋 Rule Order Analysis:")
        
        for table, rules in self.rules.items():
            if table == 'filter':
                # Check if most specific rules come first
                specific_rules = 0
                general_rules = 0
                
                for rule in rules:
                    if '0.0.0.0/0' in rule['raw_line'] or 'anywhere' in rule['raw_line']:
                        general_rules += 1
                    else:
                        specific_rules += 1
                
                if general_rules > specific_rules:
                    print("  ⚠️  Many general rules - consider reordering for efficiency")
                    self.performance_issues.append("Consider reordering rules for better performance")
                else:
                    print("  ✅ Good rule ordering")
    
    def generate_report(self):
        """Generate comprehensive analysis report"""
        print("\n📊 Analysis Report")
        print("=" * 50)
        
        # Summary statistics
        total_rules = sum(len(rules) for rules in self.rules.values())
        print(f"Total rules across all tables: {total_rules}")
        
        # Security issues
        if self.security_issues:
            print(f"\nSecurity issues found: {len(self.security_issues)}")
            for issue in self.security_issues:
                print(f"  - {issue}")
        else:
            print("\n✅ No major security issues found")
        
        # Performance issues
        if self.performance_issues:
            print(f"\nPerformance issues found: {len(self.performance_issues)}")
            for issue in self.performance_issues:
                print(f"  - {issue}")
        else:
            print("\n✅ No major performance issues found")
    
    def export_rules(self, filename):
        """Export current rules to file"""
        print(f"\n💾 Exporting rules to {filename}")
        
        with open(filename, 'w') as f:
            f.write("# iptables rules export\n")
            f.write(f"# Generated on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
            
            for table, rules in self.rules.items():
                f.write(f"# Table: {table}\n")
                for rule in rules:
                    f.write(f"{rule['raw_line']}\n")
                f.write("\n")
        
        print(f"Rules exported to {filename}")
    
    def run_analysis(self, security=False, performance=False, export_file=None):
        """Run the complete analysis"""
        print("🔍 iptables Firewall Analyzer")
        print("=" * 50)
        
        # Get rules
        print("📋 Gathering iptables rules...")
        self.get_iptables_rules()
        
        # Run analyses
        if security:
            self.analyze_security()
        
        if performance:
            self.analyze_performance()
        
        # Generate report
        self.generate_report()
        
        # Export if requested
        if export_file:
            self.export_rules(export_file)

def main():
    parser = argparse.ArgumentParser(description='iptables Firewall Analyzer')
    parser.add_argument('-s', '--security', action='store_true', help='Run security analysis')
    parser.add_argument('-p', '--performance', action='store_true', help='Run performance analysis')
    parser.add_argument('-e', '--export', help='Export rules to file')
    parser.add_argument('-a', '--all', action='store_true', help='Run all analyses')
    
    args = parser.parse_args()
    
    # Default to all analyses if no specific option is given
    if not any([args.security, args.performance, args.export]):
        args.all = True
    
    analyzer = IptablesAnalyzer()
    
    # Run analysis
    analyzer.run_analysis(
        security=args.security or args.all,
        performance=args.performance or args.all,
        export_file=args.export
    )

if __name__ == "__main__":
    main()
