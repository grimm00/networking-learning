#!/bin/bash

# ARP Traffic Simulation Lab
# Interactive lab for learning ARP protocol through simulation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Function to print colored output
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_step() {
    echo -e "${PURPLE}📋 Step $1: $2${NC}"
}

# Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "This lab requires root privileges for packet sending"
        print_info "Please run with sudo: sudo $0"
        exit 1
    fi
}

# Get network information
get_network_info() {
    print_header "Network Information"
    
    # Get interface
    INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)
    print_info "Interface: $INTERFACE"
    
    # Get our IP
    OUR_IP=$(ip addr show $INTERFACE | grep 'inet ' | awk '{print $2}' | cut -d/ -f1 | head -1)
    print_info "Our IP: $OUR_IP"
    
    # Get our MAC
    OUR_MAC=$(ip link show $INTERFACE | grep 'link/ether' | awk '{print $2}')
    print_info "Our MAC: $OUR_MAC"
    
    # Get gateway
    GATEWAY=$(ip route | grep default | awk '{print $3}')
    print_info "Gateway: $GATEWAY"
    
    # Get subnet
    SUBNET=$(echo $OUR_IP | cut -d. -f1-3)
    print_info "Subnet: $SUBNET.0/24"
}

# Lab 1: Basic ARP Discovery
lab1_arp_discovery() {
    print_header "Lab 1: ARP Discovery"
    
    print_step "1" "Understanding ARP Discovery"
    echo "ARP Discovery is used to find the MAC address of a known IP address."
    echo "It sends a broadcast ARP request asking 'Who has IP X? Tell IP Y'"
    echo ""
    
    print_step "2" "Viewing ARP table before"
    print_info "Current ARP table:"
    arp -a
    echo ""
    
    print_step "3" "Sending ARP request"
    print_warning "We'll send an ARP request for the gateway..."
    
    read -p "Press Enter to send ARP request..."
    
    # Send ARP request using arping
    print_info "Sending ARP request for $GATEWAY..."
    arping -c 1 $GATEWAY
    
    print_step "4" "Viewing ARP table after"
    print_info "ARP table after request:"
    arp -a
    echo ""
    
    print_success "Lab 1 completed! You've learned ARP discovery."
}

# Lab 2: ARP Announcement (Gratuitous ARP)
lab2_arp_announcement() {
    print_header "Lab 2: ARP Announcement (Gratuitous ARP)"
    
    print_step "1" "Understanding Gratuitous ARP"
    echo "Gratuitous ARP is used to announce an IP address to the network."
    echo "It's sent when a device wants to inform others of its IP-MAC mapping."
    echo ""
    
    print_step "2" "Starting packet capture"
    print_warning "Start tcpdump in another terminal to capture ARP traffic:"
    echo "sudo tcpdump -i $INTERFACE arp -n"
    echo ""
    
    read -p "Press Enter when tcpdump is running..."
    
    print_step "3" "Sending gratuitous ARP"
    print_info "Sending gratuitous ARP for our IP: $OUR_IP"
    
    # Send gratuitous ARP using arping
    arping -A -c 1 $OUR_IP
    
    print_step "4" "Analyzing captured traffic"
    print_info "Check your tcpdump output to see the gratuitous ARP packet"
    print_info "Look for: ARP, Reply $OUR_IP is-at $OUR_MAC"
    echo ""
    
    read -p "Press Enter to continue..."
    
    print_success "Lab 2 completed! You've learned gratuitous ARP."
}

# Lab 3: ARP Table Management
lab3_arp_table() {
    print_header "Lab 3: ARP Table Management"
    
    print_step "1" "Understanding ARP table"
    echo "The ARP table stores IP-to-MAC address mappings."
    echo "It's used to avoid repeated ARP requests for known addresses."
    echo ""
    
    print_step "2" "Viewing ARP table"
    print_info "Current ARP table entries:"
    arp -a
    echo ""
    
    print_step "3" "Adding static ARP entry"
    print_info "Adding a static ARP entry..."
    
    # Add a static entry (using a fake MAC)
    FAKE_MAC="aa:bb:cc:dd:ee:ff"
    FAKE_IP="$SUBNET.100"
    
    print_warning "Adding static entry: $FAKE_IP -> $FAKE_MAC"
    arp -s $FAKE_IP $FAKE_MAC
    
    print_info "ARP table after adding static entry:"
    arp -a
    echo ""
    
    print_step "4" "Removing ARP entry"
    print_info "Removing the static entry..."
    arp -d $FAKE_IP
    
    print_info "ARP table after removal:"
    arp -a
    echo ""
    
    print_success "Lab 3 completed! You've learned ARP table management."
}

# Lab 4: ARP Conflict Detection
lab4_arp_conflict() {
    print_header "Lab 4: ARP Conflict Detection"
    
    print_step "1" "Understanding ARP conflicts"
    echo "ARP conflicts occur when multiple devices claim the same IP address."
    echo "This can happen due to misconfiguration or malicious activity."
    echo ""
    
    print_step "2" "Starting packet capture"
    print_warning "Start tcpdump in another terminal:"
    echo "sudo tcpdump -i $INTERFACE arp -n -v"
    echo ""
    
    read -p "Press Enter when tcpdump is running..."
    
    print_step "3" "Simulating ARP conflict"
    print_info "We'll simulate an ARP conflict by sending conflicting ARP announcements"
    
    # Use the ARP simulator if available
    if [ -f "/scripts/arp-simulator.py" ]; then
        print_info "Using ARP simulator to create conflict..."
        python3 /scripts/arp-simulator.py -s conflict -t $OUR_IP -c 3
    else
        print_warning "ARP simulator not available, using manual method..."
        
        # Manual ARP conflict simulation
        FAKE_MAC1="11:22:33:44:55:66"
        FAKE_MAC2="77:88:99:aa:bb:cc"
        
        print_info "Sending conflicting ARP announcements..."
        
        # Send first announcement
        arping -A -c 1 -s $FAKE_MAC1 $OUR_IP &
        sleep 1
        
        # Send second announcement with different MAC
        arping -A -c 1 -s $FAKE_MAC2 $OUR_IP &
        sleep 1
    fi
    
    print_step "4" "Analyzing conflict"
    print_info "Check your tcpdump output for conflicting ARP announcements"
    print_info "Look for multiple ARP replies for the same IP with different MACs"
    echo ""
    
    read -p "Press Enter to continue..."
    
    print_success "Lab 4 completed! You've learned ARP conflict detection."
}

# Lab 5: ARP Flooding
lab5_arp_flood() {
    print_header "Lab 5: ARP Flooding"
    
    print_step "1" "Understanding ARP flooding"
    echo "ARP flooding is a technique used to discover devices on a network."
    echo "It sends ARP requests to multiple IP addresses to see which respond."
    echo ""
    
    print_step "2" "Starting packet capture"
    print_warning "Start tcpdump in another terminal:"
    echo "sudo tcpdump -i $INTERFACE arp -n"
    echo ""
    
    read -p "Press Enter when tcpdump is running..."
    
    print_step "3" "Performing ARP flood"
    print_info "Sending ARP requests to multiple IPs in our subnet..."
    
    # ARP flood using nmap
    print_info "Using nmap to perform ARP scan..."
    nmap -sn $SUBNET.0/24
    
    print_step "4" "Analyzing results"
    print_info "Check your tcpdump output for ARP requests and replies"
    print_info "Look for devices that responded to ARP requests"
    echo ""
    
    read -p "Press Enter to continue..."
    
    print_success "Lab 5 completed! You've learned ARP flooding."
}

# Lab 6: ARP Spoofing (Educational)
lab6_arp_spoofing() {
    print_header "Lab 6: ARP Spoofing (Educational)"
    
    print_step "1" "Understanding ARP spoofing"
    echo "ARP spoofing is a technique where an attacker sends fake ARP messages."
    echo "This can be used for man-in-the-middle attacks."
    echo "⚠️  This is for educational purposes only!"
    echo ""
    
    print_warning "IMPORTANT: Only perform this in isolated lab environments!"
    read -p "Do you want to continue with ARP spoofing demo? (y/N): " confirm
    
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        print_info "Skipping ARP spoofing demo"
        return
    fi
    
    print_step "2" "Starting packet capture"
    print_warning "Start tcpdump in another terminal:"
    echo "sudo tcpdump -i $INTERFACE arp -n -v"
    echo ""
    
    read -p "Press Enter when tcpdump is running..."
    
    print_step "3" "ARP spoofing simulation"
    print_info "Simulating ARP spoofing attack..."
    
    # Use ARP simulator if available
    if [ -f "/scripts/arp-simulator.py" ]; then
        print_info "Using ARP simulator for spoofing demo..."
        python3 /scripts/arp-simulator.py -s spoofing -t $GATEWAY -f $OUR_IP -c 3
    else
        print_warning "ARP simulator not available for spoofing demo"
        print_info "Manual spoofing requires advanced tools like ettercap"
    fi
    
    print_step "4" "Analyzing spoofing attempt"
    print_info "Check your tcpdump output for fake ARP replies"
    print_info "Look for ARP replies claiming our IP is at different MACs"
    echo ""
    
    read -p "Press Enter to continue..."
    
    print_success "Lab 6 completed! You've learned about ARP spoofing."
}

# Lab 7: ARP Troubleshooting
lab7_arp_troubleshooting() {
    print_header "Lab 7: ARP Troubleshooting"
    
    print_step "1" "Common ARP problems"
    echo "Common ARP issues include:"
    echo "- Duplicate IP addresses"
    echo "- ARP table corruption"
    echo "- Network connectivity problems"
    echo "- ARP cache poisoning"
    echo ""
    
    print_step "2" "ARP troubleshooting commands"
    print_info "Useful ARP troubleshooting commands:"
    echo ""
    echo "View ARP table:"
    echo "  arp -a"
    echo ""
    echo "Clear ARP table:"
    echo "  sudo ip -s -s neigh flush all"
    echo ""
    echo "Test ARP resolution:"
    echo "  arping -c 1 <target_ip>"
    echo ""
    echo "Monitor ARP traffic:"
    echo "  sudo tcpdump -i <interface> arp -n"
    echo ""
    
    print_step "3" "ARP troubleshooting scenario"
    print_info "Let's troubleshoot a simulated ARP problem..."
    
    # Simulate problem by clearing ARP table
    print_warning "Clearing ARP table to simulate problem..."
    sudo ip -s -s neigh flush all
    
    print_info "ARP table after clearing:"
    arp -a
    echo ""
    
    print_info "Testing connectivity to gateway..."
    ping -c 1 $GATEWAY
    
    print_info "ARP table after ping:"
    arp -a
    echo ""
    
    print_step "4" "ARP troubleshooting best practices"
    print_info "ARP troubleshooting best practices:"
    echo "- Always check ARP table first"
    echo "- Use packet capture to see ARP traffic"
    echo "- Test with known good devices"
    echo "- Check for duplicate IPs"
    echo "- Verify network configuration"
    echo ""
    
    print_success "Lab 7 completed! You've learned ARP troubleshooting."
}

# Show lab menu
show_menu() {
    print_header "ARP Traffic Simulation Lab"
    echo "Choose a lab to run:"
    echo ""
    echo "1. ARP Discovery"
    echo "2. ARP Announcement (Gratuitous ARP)"
    echo "3. ARP Table Management"
    echo "4. ARP Conflict Detection"
    echo "5. ARP Flooding"
    echo "6. ARP Spoofing (Educational)"
    echo "7. ARP Troubleshooting"
    echo "8. Run All Labs"
    echo "9. Exit"
    echo ""
    read -p "Enter your choice (1-9): " choice
    
    case $choice in
        1) lab1_arp_discovery ;;
        2) lab2_arp_announcement ;;
        3) lab3_arp_table ;;
        4) lab4_arp_conflict ;;
        5) lab5_arp_flood ;;
        6) lab6_arp_spoofing ;;
        7) lab7_arp_troubleshooting ;;
        8) run_all_labs ;;
        9) print_success "Goodbye!"; exit 0 ;;
        *) print_error "Invalid choice. Please select 1-9." ;;
    esac
}

# Run all labs
run_all_labs() {
    print_header "Running All ARP Labs"
    
    lab1_arp_discovery
    echo ""
    read -p "Press Enter to continue to Lab 2..."
    
    lab2_arp_announcement
    echo ""
    read -p "Press Enter to continue to Lab 3..."
    
    lab3_arp_table
    echo ""
    read -p "Press Enter to continue to Lab 4..."
    
    lab4_arp_conflict
    echo ""
    read -p "Press Enter to continue to Lab 5..."
    
    lab5_arp_flood
    echo ""
    read -p "Press Enter to continue to Lab 6..."
    
    lab6_arp_spoofing
    echo ""
    read -p "Press Enter to continue to Lab 7..."
    
    lab7_arp_troubleshooting
    
    print_success "All ARP labs completed! You're now proficient with ARP."
}

# Main function
main() {
    # Check root privileges
    check_root
    
    # Get network information
    get_network_info
    
    # Show menu and run labs
    while true; do
        show_menu
        echo ""
        read -p "Press Enter to continue..."
        clear
    done
}

# Run main function
main
