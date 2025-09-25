#!/bin/bash

# iptables Troubleshooting Script
# Comprehensive troubleshooting and diagnostics for iptables firewalls

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
VERBOSE=false
SECURITY=false
PERFORMANCE=false
OPTIMIZE=false
EXPORT_FILE=""

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to print header
print_header() {
    echo
    print_status $BLUE "=========================================="
    print_status $BLUE "$1"
    print_status $BLUE "=========================================="
    echo
}

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_status $RED "This script must be run as root (use sudo)"
        exit 1
    fi
}

# Function to check iptables installation
check_iptables() {
    print_header "Checking iptables Installation"
    
    if command -v iptables >/dev/null 2>&1; then
        print_status $GREEN "✅ iptables is installed"
        iptables --version
    else
        print_status $RED "❌ iptables is not installed"
        print_status $YELLOW "Installing iptables..."
        apt-get update && apt-get install -y iptables
    fi
}

# Function to check kernel modules
check_kernel_modules() {
    print_header "Checking Required Kernel Modules"
    
    local modules=("ip_tables" "iptable_filter" "iptable_nat" "nf_conntrack")
    
    for module in "${modules[@]}"; do
        if lsmod | grep -q "^$module "; then
            print_status $GREEN "✅ $module is loaded"
        else
            print_status $YELLOW "⚠️  $module is not loaded"
            print_status $YELLOW "Loading $module..."
            modprobe $module
        fi
    done
}

# Function to check IP forwarding
check_ip_forwarding() {
    print_header "Checking IP Forwarding"
    
    local forwarding=$(cat /proc/sys/net/ipv4/ip_forward)
    
    if [[ $forwarding -eq 1 ]]; then
        print_status $GREEN "✅ IP forwarding is enabled"
    else
        print_status $YELLOW "⚠️  IP forwarding is disabled"
        print_status $YELLOW "Enabling IP forwarding..."
        echo 1 > /proc/sys/net/ipv4/ip_forward
        print_status $GREEN "✅ IP forwarding enabled"
    fi
}

# Function to show current rules
show_rules() {
    print_header "Current iptables Rules"
    
    local tables=("filter" "nat" "mangle" "raw")
    
    for table in "${tables[@]}"; do
        print_status $BLUE "--- $table table ---"
        iptables -t $table -L -n -v --line-numbers
        echo
    done
}

# Function to check security issues
check_security() {
    print_header "Security Analysis"
    
    # Check default policies
    print_status $BLUE "Checking default policies..."
    local policies=$(iptables -L | grep "policy")
    echo "$policies"
    
    # Check for dangerous rules
    print_status $BLUE "Checking for dangerous rules..."
    local dangerous_rules=$(iptables -L -n | grep -E "(ACCEPT.*0\.0\.0\.0/0|ACCEPT.*anywhere.*anywhere)")
    if [[ -n "$dangerous_rules" ]]; then
        print_status $RED "⚠️  Potentially dangerous rules found:"
        echo "$dangerous_rules"
    else
        print_status $GREEN "✅ No obviously dangerous rules found"
    fi
    
    # Check for logging
    print_status $BLUE "Checking for logging rules..."
    local log_rules=$(iptables -L | grep "LOG")
    if [[ -n "$log_rules" ]]; then
        print_status $GREEN "✅ Logging rules found:"
        echo "$log_rules"
    else
        print_status $YELLOW "⚠️  No logging rules found"
    fi
}

# Function to check performance
check_performance() {
    print_header "Performance Analysis"
    
    # Count rules
    print_status $BLUE "Rule count by table:"
    for table in filter nat mangle raw; do
        local count=$(iptables -t $table -L | grep -c "^[A-Z]" || echo "0")
        print_status $GREEN "$table: $count rules"
    done
    
    # Check for inefficient rules
    print_status $BLUE "Checking for inefficient rules..."
    local common_ports=("22" "80" "443")
    
    for port in "${common_ports[@]}"; do
        local rule_line=$(iptables -L -n --line-numbers | grep "dpt:$port" | head -1)
        if [[ -n "$rule_line" ]]; then
            local line_num=$(echo "$rule_line" | awk '{print $1}')
            if [[ $line_num -gt 5 ]]; then
                print_status $YELLOW "⚠️  Port $port rule at line $line_num (consider moving up)"
            else
                print_status $GREEN "✅ Port $port rule at line $line_num (good position)"
            fi
        fi
    done
}

# Function to test connectivity
test_connectivity() {
    print_header "Connectivity Testing"
    
    # Test basic connectivity
    print_status $BLUE "Testing basic connectivity..."
    if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        print_status $GREEN "✅ Internet connectivity working"
    else
        print_status $RED "❌ Internet connectivity failed"
    fi
    
    # Test local connectivity
    print_status $BLUE "Testing local connectivity..."
    if ping -c 1 127.0.0.1 >/dev/null 2>&1; then
        print_status $GREEN "✅ Local connectivity working"
    else
        print_status $RED "❌ Local connectivity failed"
    fi
}

# Function to check for common issues
check_common_issues() {
    print_header "Common Issues Check"
    
    # Check if iptables service is running
    print_status $BLUE "Checking iptables service..."
    if systemctl is-active --quiet iptables 2>/dev/null; then
        print_status $GREEN "✅ iptables service is running"
    else
        print_status $YELLOW "⚠️  iptables service not found (this is normal on some systems)"
    fi
    
    # Check for conflicting rules
    print_status $BLUE "Checking for conflicting rules..."
    local accept_rules=$(iptables -L -n | grep -c "ACCEPT" || echo "0")
    local drop_rules=$(iptables -L -n | grep -c "DROP" || echo "0")
    local reject_rules=$(iptables -L -n | grep -c "REJECT" || echo "0")
    
    print_status $GREEN "ACCEPT rules: $accept_rules"
    print_status $GREEN "DROP rules: $drop_rules"
    print_status $GREEN "REJECT rules: $reject_rules"
    
    # Check for rules that might block SSH
    print_status $BLUE "Checking for SSH blocking rules..."
    local ssh_rules=$(iptables -L -n | grep -E "(22|ssh)" || echo "")
    if [[ -n "$ssh_rules" ]]; then
        print_status $YELLOW "SSH-related rules found:"
        echo "$ssh_rules"
    else
        print_status $YELLOW "⚠️  No SSH-specific rules found"
    fi
}

# Function to optimize rules
optimize_rules() {
    print_header "Rule Optimization"
    
    print_status $BLUE "Current rule order:"
    iptables -L -n --line-numbers
    
    print_status $YELLOW "Optimization suggestions:"
    print_status $YELLOW "1. Move most frequently hit rules to the top"
    print_status $YELLOW "2. Group similar rules together"
    print_status $YELLOW "3. Use specific rules before general ones"
    print_status $YELLOW "4. Consider using ipset for large lists"
    
    # Show rule hit counts if available
    print_status $BLUE "Rule hit counts:"
    iptables -L -n -v | head -20
}

# Function to export rules
export_rules() {
    local filename=${1:-"iptables-rules-$(date +%Y%m%d-%H%M%S).txt"}
    
    print_header "Exporting Rules to $filename"
    
    {
        echo "# iptables rules export"
        echo "# Generated on $(date)"
        echo "# Generated by iptables-troubleshoot.sh"
        echo ""
        
        for table in filter nat mangle raw; do
            echo "# Table: $table"
            iptables -t $table -L -n -v --line-numbers
            echo ""
        done
    } > "$filename"
    
    print_status $GREEN "✅ Rules exported to $filename"
}

# Function to show help
show_help() {
    echo "iptables Troubleshooting Script"
    echo
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -v, --verbose       Verbose output"
    echo "  -s, --security      Run security analysis"
    echo "  -p, --performance   Run performance analysis"
    echo "  -o, --optimize      Show optimization suggestions"
    echo "  -e, --export FILE   Export rules to file"
    echo "  -a, --all           Run all analyses (default)"
    echo
    echo "Examples:"
    echo "  $0                  # Run all analyses"
    echo "  $0 -s               # Security analysis only"
    echo "  $0 -p -o            # Performance and optimization"
    echo "  $0 -e rules.txt     # Export rules to file"
}

# Main function
main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -s|--security)
                SECURITY=true
                shift
                ;;
            -p|--performance)
                PERFORMANCE=true
                shift
                ;;
            -o|--optimize)
                OPTIMIZE=true
                shift
                ;;
            -e|--export)
                EXPORT_FILE="$2"
                shift 2
                ;;
            -a|--all)
                SECURITY=true
                PERFORMANCE=true
                OPTIMIZE=true
                shift
                ;;
            *)
                print_status $RED "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Default to all if no specific options
    if [[ "$SECURITY" == false && "$PERFORMANCE" == false && "$OPTIMIZE" == false ]]; then
        SECURITY=true
        PERFORMANCE=true
        OPTIMIZE=true
    fi
    
    print_header "iptables Troubleshooting Script"
    
    # Check prerequisites
    check_root
    check_iptables
    check_kernel_modules
    check_ip_forwarding
    
    # Show current state
    show_rules
    
    # Run analyses
    if [[ "$SECURITY" == true ]]; then
        check_security
    fi
    
    if [[ "$PERFORMANCE" == true ]]; then
        check_performance
    fi
    
    if [[ "$OPTIMIZE" == true ]]; then
        optimize_rules
    fi
    
    # Additional checks
    test_connectivity
    check_common_issues
    
    # Export if requested
    if [[ -n "$EXPORT_FILE" ]]; then
        export_rules "$EXPORT_FILE"
    fi
    
    print_header "Troubleshooting Complete"
    print_status $GREEN "✅ Analysis finished"
}

# Run main function
main "$@"
