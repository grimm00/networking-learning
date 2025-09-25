#!/bin/bash

# iptables Lab Script
# Interactive lab exercises for learning iptables

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

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

# Function to print step
print_step() {
    echo
    print_status $PURPLE "Step $1: $2"
    print_status $PURPLE "$(printf '=%.0s' {1..40})"
    echo
}

# Function to wait for user input
wait_for_user() {
    echo
    read -p "Press Enter to continue..."
    echo
}

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_status $RED "This script must be run as root (use sudo)"
        exit 1
    fi
}

# Function to backup current rules
backup_rules() {
    print_status $YELLOW "Creating backup of current iptables rules..."
    iptables-save > /tmp/iptables-backup-$(date +%Y%m%d-%H%M%S).txt
    print_status $GREEN "✅ Backup created"
}

# Function to restore rules
restore_rules() {
    local backup_file=$1
    if [[ -f "$backup_file" ]]; then
        print_status $YELLOW "Restoring iptables rules from backup..."
        iptables-restore < "$backup_file"
        print_status $GREEN "✅ Rules restored"
    else
        print_status $RED "❌ Backup file not found: $backup_file"
    fi
}

# Lab 1: Basic iptables Commands
lab1_basic_commands() {
    print_header "Lab 1: Basic iptables Commands"
    
    print_step "1" "View current iptables rules"
    echo "Command: iptables -L"
    iptables -L
    wait_for_user
    
    print_step "2" "View rules with verbose output"
    echo "Command: iptables -L -v"
    iptables -L -v
    wait_for_user
    
    print_step "3" "View rules with line numbers"
    echo "Command: iptables -L --line-numbers"
    iptables -L --line-numbers
    wait_for_user
    
    print_step "4" "View rules with numeric addresses"
    echo "Command: iptables -L -n"
    iptables -L -n
    wait_for_user
    
    print_step "5" "View all tables"
    echo "Commands:"
    echo "  iptables -t filter -L"
    echo "  iptables -t nat -L"
    echo "  iptables -t mangle -L"
    echo "  iptables -t raw -L"
    
    for table in filter nat mangle raw; do
        echo "--- $table table ---"
        iptables -t $table -L
        echo
    done
    wait_for_user
}

# Lab 2: Basic Rule Management
lab2_rule_management() {
    print_header "Lab 2: Basic Rule Management"
    
    print_step "1" "Add a rule to allow SSH (port 22)"
    echo "Command: iptables -A INPUT -p tcp --dport 22 -j ACCEPT"
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT
    print_status $GREEN "✅ Rule added"
    wait_for_user
    
    print_step "2" "Add a rule to allow HTTP (port 80)"
    echo "Command: iptables -A INPUT -p tcp --dport 80 -j ACCEPT"
    iptables -A INPUT -p tcp --dport 80 -j ACCEPT
    print_status $GREEN "✅ Rule added"
    wait_for_user
    
    print_step "3" "Add a rule to allow HTTPS (port 443)"
    echo "Command: iptables -A INPUT -p tcp --dport 443 -j ACCEPT"
    iptables -A INPUT -p tcp --dport 443 -j ACCEPT
    print_status $GREEN "✅ Rule added"
    wait_for_user
    
    print_step "4" "View the new rules"
    echo "Command: iptables -L -n --line-numbers"
    iptables -L -n --line-numbers
    wait_for_user
    
    print_step "5" "Insert a rule at the beginning"
    echo "Command: iptables -I INPUT 1 -p tcp --dport 8080 -j ACCEPT"
    iptables -I INPUT 1 -p tcp --dport 8080 -j ACCEPT
    print_status $GREEN "✅ Rule inserted at position 1"
    wait_for_user
    
    print_step "6" "View rules to see the change"
    iptables -L -n --line-numbers
    wait_for_user
    
    print_step "7" "Delete a rule by line number"
    echo "Command: iptables -D INPUT 1"
    iptables -D INPUT 1
    print_status $GREEN "✅ Rule deleted"
    wait_for_user
    
    print_step "8" "Delete a rule by specification"
    echo "Command: iptables -D INPUT -p tcp --dport 80 -j ACCEPT"
    iptables -D INPUT -p tcp --dport 80 -j ACCEPT
    print_status $GREEN "✅ Rule deleted"
    wait_for_user
}

# Lab 3: Security Rules
lab3_security_rules() {
    print_header "Lab 3: Security Rules"
    
    print_step "1" "Set default policy to DROP"
    echo "Commands:"
    echo "  iptables -P INPUT DROP"
    echo "  iptables -P FORWARD DROP"
    echo "  iptables -P OUTPUT ACCEPT"
    
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT
    print_status $GREEN "✅ Default policies set"
    wait_for_user
    
    print_step "2" "Allow loopback traffic"
    echo "Commands:"
    echo "  iptables -A INPUT -i lo -j ACCEPT"
    echo "  iptables -A OUTPUT -o lo -j ACCEPT"
    
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A OUTPUT -o lo -j ACCEPT
    print_status $GREEN "✅ Loopback rules added"
    wait_for_user
    
    print_step "3" "Allow established and related connections"
    echo "Command: iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT"
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    print_status $GREEN "✅ State rules added"
    wait_for_user
    
    print_step "4" "Allow SSH from specific IP"
    echo "Command: iptables -A INPUT -s 127.0.0.1 -p tcp --dport 22 -j ACCEPT"
    iptables -A INPUT -s 127.0.0.1 -p tcp --dport 22 -j ACCEPT
    print_status $GREEN "✅ SSH rule added"
    wait_for_user
    
    print_step "5" "Allow ICMP (ping)"
    echo "Command: iptables -A INPUT -p icmp -j ACCEPT"
    iptables -A INPUT -p icmp -j ACCEPT
    print_status $GREEN "✅ ICMP rule added"
    wait_for_user
    
    print_step "6" "View current security rules"
    iptables -L -n --line-numbers
    wait_for_user
}

# Lab 4: Logging and Monitoring
lab4_logging() {
    print_header "Lab 4: Logging and Monitoring"
    
    print_step "1" "Add logging rule for dropped packets"
    echo "Command: iptables -A INPUT -j LOG --log-prefix 'DROPPED: ' --log-level 4"
    iptables -A INPUT -j LOG --log-prefix 'DROPPED: ' --log-level 4
    print_status $GREEN "✅ Logging rule added"
    wait_for_user
    
    print_step "2" "Add logging rule for SSH attempts"
    echo "Command: iptables -A INPUT -p tcp --dport 22 -j LOG --log-prefix 'SSH: '"
    iptables -A INPUT -p tcp --dport 22 -j LOG --log-prefix 'SSH: '
    print_status $GREEN "✅ SSH logging rule added"
    wait_for_user
    
    print_step "3" "View current rules with logging"
    iptables -L -n --line-numbers
    wait_for_user
    
    print_step "4" "Check if logging is working"
    echo "Command: tail -f /var/log/kern.log | grep iptables"
    print_status $YELLOW "This will run for 10 seconds to show any iptables logs..."
    timeout 10 tail -f /var/log/kern.log | grep iptables || true
    wait_for_user
}

# Lab 5: NAT and Port Forwarding
lab5_nat() {
    print_header "Lab 5: NAT and Port Forwarding"
    
    print_step "1" "Enable IP forwarding"
    echo "Command: echo 1 > /proc/sys/net/ipv4/ip_forward"
    echo 1 > /proc/sys/net/ipv4/ip_forward
    print_status $GREEN "✅ IP forwarding enabled"
    wait_for_user
    
    print_step "2" "Add SNAT rule for masquerading"
    echo "Command: iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE"
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    print_status $GREEN "✅ SNAT rule added"
    wait_for_user
    
    print_step "3" "Add port forwarding rule"
    echo "Command: iptables -t nat -A PREROUTING -p tcp --dport 8080 -j REDIRECT --to-port 80"
    iptables -t nat -A PREROUTING -p tcp --dport 8080 -j REDIRECT --to-port 80
    print_status $GREEN "✅ Port forwarding rule added"
    wait_for_user
    
    print_step "4" "View NAT table rules"
    echo "Command: iptables -t nat -L -n --line-numbers"
    iptables -t nat -L -n --line-numbers
    wait_for_user
}

# Lab 6: Troubleshooting
lab6_troubleshooting() {
    print_header "Lab 6: Troubleshooting"
    
    print_step "1" "Test connectivity"
    echo "Testing ping to 8.8.8.8..."
    if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        print_status $GREEN "✅ Internet connectivity working"
    else
        print_status $RED "❌ Internet connectivity failed"
    fi
    wait_for_user
    
    print_step "2" "Check rule counters"
    echo "Command: iptables -L -n -v"
    iptables -L -n -v
    wait_for_user
    
    print_step "3" "Check for conflicting rules"
    echo "Looking for rules that might conflict..."
    iptables -L -n | grep -E "(ACCEPT|DROP|REJECT)"
    wait_for_user
    
    print_step "4" "Test specific port"
    echo "Testing if port 22 is accessible..."
    if nc -z localhost 22 2>/dev/null; then
        print_status $GREEN "✅ Port 22 is accessible"
    else
        print_status $RED "❌ Port 22 is not accessible"
    fi
    wait_for_user
}

# Lab 7: Rule Optimization
lab7_optimization() {
    print_header "Lab 7: Rule Optimization"
    
    print_step "1" "Show current rule order"
    iptables -L -n --line-numbers
    wait_for_user
    
    print_step "2" "Move frequently used rule to top"
    echo "Moving SSH rule to position 1..."
    iptables -I INPUT 1 -p tcp --dport 22 -j ACCEPT
    print_status $GREEN "✅ SSH rule moved to top"
    wait_for_user
    
    print_step "3" "Show optimized rule order"
    iptables -L -n --line-numbers
    wait_for_user
    
    print_step "4" "Show rule hit counts"
    echo "Command: iptables -L -n -v"
    iptables -L -n -v
    wait_for_user
}

# Function to show menu
show_menu() {
    echo
    print_status $BLUE "iptables Lab Menu"
    print_status $BLUE "================="
    echo
    echo "1. Basic iptables Commands"
    echo "2. Basic Rule Management"
    echo "3. Security Rules"
    echo "4. Logging and Monitoring"
    echo "5. NAT and Port Forwarding"
    echo "6. Troubleshooting"
    echo "7. Rule Optimization"
    echo "8. Run All Labs"
    echo "9. Exit"
    echo
}

# Function to run all labs
run_all_labs() {
    print_header "Running All Labs"
    
    lab1_basic_commands
    lab2_rule_management
    lab3_security_rules
    lab4_logging
    lab5_nat
    lab6_troubleshooting
    lab7_optimization
    
    print_header "All Labs Complete"
    print_status $GREEN "✅ All labs completed successfully!"
}

# Main function
main() {
    check_root
    
    print_header "iptables Lab Script"
    print_status $YELLOW "This script will help you learn iptables through hands-on exercises."
    print_status $YELLOW "Make sure you have a backup of your current rules!"
    
    # Create backup
    backup_rules
    
    while true; do
        show_menu
        read -p "Select an option (1-9): " choice
        
        case $choice in
            1)
                lab1_basic_commands
                ;;
            2)
                lab2_rule_management
                ;;
            3)
                lab3_security_rules
                ;;
            4)
                lab4_logging
                ;;
            5)
                lab5_nat
                ;;
            6)
                lab6_troubleshooting
                ;;
            7)
                lab7_optimization
                ;;
            8)
                run_all_labs
                ;;
            9)
                print_status $GREEN "Exiting lab script..."
                break
                ;;
            *)
                print_status $RED "Invalid option. Please select 1-9."
                ;;
        esac
    done
    
    print_status $YELLOW "Remember to restore your original rules if needed!"
    print_status $YELLOW "Backup file: /tmp/iptables-backup-*.txt"
}

# Run main function
main "$@"
