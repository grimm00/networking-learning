#!/bin/bash

# TCP Dump Learning Lab
# Interactive lab for learning packet capture and analysis

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

# Lab configuration
LAB_DIR="/tmp/tcpdump_lab"
INTERFACE="eth0"

# Function to setup lab environment
setup_lab() {
    print_header "Setting Up TCP Dump Lab Environment"
    
    # Create lab directory
    mkdir -p "$LAB_DIR"
    print_success "Created lab directory: $LAB_DIR"
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        print_error "This lab requires root privileges for packet capture"
        print_info "Please run with sudo: sudo $0"
        exit 1
    fi
    
    # Check if tcpdump is available
    if ! command -v tcpdump &> /dev/null; then
        print_error "tcpdump is not installed"
        print_info "Installing tcpdump..."
        apt-get update && apt-get install -y tcpdump
    fi
    
    # Check if interface exists
    if ! ip link show "$INTERFACE" >/dev/null 2>&1; then
        print_warning "Interface $INTERFACE not found, using default"
        INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)
        print_info "Using interface: $INTERFACE"
    fi
    
    print_success "Lab environment ready!"
    print_info "Interface: $INTERFACE"
    print_info "Lab directory: $LAB_DIR"
}

# Function to run lab 1: Basic Packet Capture
lab1_basic_capture() {
    print_header "Lab 1: Basic Packet Capture"
    
    print_step "1" "Understanding tcpdump basics"
    echo "tcpdump is a command-line packet analyzer that captures network traffic."
    echo "It shows packets in real-time or saves them to files for analysis."
    echo ""
    
    print_step "2" "Capturing your first packets"
    echo "Let's capture 10 packets to see what's happening on the network..."
    echo ""
    
    read -p "Press Enter to start capture..."
    
    print_info "Capturing 10 packets on $INTERFACE..."
    tcpdump -i "$INTERFACE" -c 10 -n
    
    echo ""
    print_step "3" "Understanding the output"
    echo "Each line shows:"
    echo "  - Timestamp: When the packet was captured"
    echo "  - Source IP: Where the packet came from"
    echo "  - Destination IP: Where the packet is going"
    echo "  - Protocol: TCP, UDP, ICMP, etc."
    echo "  - Additional info: Ports, flags, data length"
    echo ""
    
    print_success "Lab 1 completed! You've captured your first packets."
}

# Function to run lab 2: Filtering Traffic
lab2_filtering() {
    print_header "Lab 2: Filtering Network Traffic"
    
    print_step "1" "Understanding filters"
    echo "tcpdump uses BPF (Berkeley Packet Filter) syntax for filtering."
    echo "This allows you to capture only specific types of traffic."
    echo ""
    
    print_step "2" "Capturing ICMP traffic (ping)"
    echo "Let's capture ping traffic to see ICMP packets..."
    echo ""
    
    read -p "Press Enter to start ICMP capture (ping 8.8.8.8 in another terminal)..."
    
    print_info "Capturing ICMP traffic..."
    tcpdump -i "$INTERFACE" -c 5 icmp -n
    
    echo ""
    print_step "3" "Capturing HTTP traffic"
    echo "Now let's capture HTTP traffic (port 80)..."
    echo ""
    
    read -p "Press Enter to start HTTP capture (curl http://httpbin.org/get in another terminal)..."
    
    print_info "Capturing HTTP traffic..."
    tcpdump -i "$INTERFACE" -c 10 'tcp port 80' -n
    
    echo ""
    print_step "4" "Capturing DNS traffic"
    echo "Let's capture DNS queries (port 53)..."
    echo ""
    
    read -p "Press Enter to start DNS capture (nslookup google.com in another terminal)..."
    
    print_info "Capturing DNS traffic..."
    tcpdump -i "$INTERFACE" -c 5 'udp port 53' -n
    
    print_success "Lab 2 completed! You've learned to filter traffic."
}

# Function to run lab 3: Saving and Reading Captures
lab3_save_read() {
    print_header "Lab 3: Saving and Reading Packet Captures"
    
    print_step "1" "Saving packets to file"
    echo "tcpdump can save packets to files for later analysis."
    echo "This is useful for detailed analysis or sharing captures."
    echo ""
    
    local capture_file="$LAB_DIR/lab3_capture.pcap"
    
    print_info "Saving 20 packets to $capture_file..."
    print_warning "Generate some traffic (ping, curl, etc.) in another terminal..."
    
    read -p "Press Enter to start capture..."
    
    tcpdump -i "$INTERFACE" -c 20 -w "$capture_file"
    
    print_success "Capture saved to $capture_file"
    
    print_step "2" "Reading packets from file"
    echo "Now let's read the captured packets from the file..."
    echo ""
    
    print_info "Reading captured packets..."
    tcpdump -r "$capture_file" -n
    
    print_step "3" "Analyzing saved capture"
    echo "Let's get some statistics about our capture..."
    echo ""
    
    print_info "Packet count:"
    tcpdump -r "$capture_file" -n | wc -l
    
    print_info "Protocol breakdown:"
    tcpdump -r "$capture_file" -n | awk '{print $1}' | sort | uniq -c | sort -nr
    
    print_success "Lab 3 completed! You've learned to save and analyze captures."
}

# Function to run lab 4: Advanced Filtering
lab4_advanced_filtering() {
    print_header "Lab 4: Advanced Filtering Techniques"
    
    print_step "1" "Host-based filtering"
    echo "Filter traffic to/from specific hosts..."
    echo ""
    
    print_info "Capturing traffic to/from 8.8.8.8..."
    tcpdump -i "$INTERFACE" -c 5 'host 8.8.8.8' -n
    
    echo ""
    print_step "2" "Port-based filtering"
    echo "Filter traffic on specific ports..."
    echo ""
    
    print_info "Capturing traffic on port 443 (HTTPS)..."
    tcpdump -i "$INTERFACE" -c 5 'port 443' -n
    
    echo ""
    print_step "3" "Complex filters"
    echo "Combine multiple conditions..."
    echo ""
    
    print_info "Capturing TCP traffic to port 80 from specific network..."
    tcpdump -i "$INTERFACE" -c 5 'tcp and port 80 and src net 192.168.0.0/16' -n
    
    echo ""
    print_step "4" "Excluding traffic"
    echo "Use 'not' to exclude certain traffic..."
    echo ""
    
    print_info "Capturing all traffic except SSH..."
    tcpdump -i "$INTERFACE" -c 5 'not port 22' -n
    
    print_success "Lab 4 completed! You've learned advanced filtering."
}

# Function to run lab 5: Protocol Analysis
lab5_protocol_analysis() {
    print_header "Lab 5: Protocol Analysis"
    
    print_step "1" "TCP Analysis"
    echo "Let's analyze TCP connections..."
    echo ""
    
    print_info "Capturing TCP handshake..."
    print_warning "Make a web request in another terminal (curl httpbin.org/get)..."
    
    read -p "Press Enter to start TCP capture..."
    
    tcpdump -i "$INTERFACE" -c 10 'tcp' -n -S
    
    echo ""
    print_step "2" "UDP Analysis"
    echo "Let's analyze UDP traffic..."
    echo ""
    
    print_info "Capturing UDP traffic..."
    print_warning "Make a DNS query in another terminal (nslookup google.com)..."
    
    read -p "Press Enter to start UDP capture..."
    
    tcpdump -i "$INTERFACE" -c 5 'udp' -n
    
    echo ""
    print_step "3" "ICMP Analysis"
    echo "Let's analyze ICMP traffic..."
    echo ""
    
    print_info "Capturing ICMP traffic..."
    print_warning "Ping a host in another terminal (ping 8.8.8.8)..."
    
    read -p "Press Enter to start ICMP capture..."
    
    tcpdump -i "$INTERFACE" -c 5 'icmp' -n
    
    print_success "Lab 5 completed! You've analyzed different protocols."
}

# Function to run lab 6: Troubleshooting
lab6_troubleshooting() {
    print_header "Lab 6: Network Troubleshooting with tcpdump"
    
    print_step "1" "Connectivity Issues"
    echo "Let's simulate and diagnose connectivity problems..."
    echo ""
    
    print_info "Capturing traffic to diagnose connectivity..."
    print_warning "Try to ping 8.8.8.8 in another terminal..."
    
    read -p "Press Enter to start connectivity capture..."
    
    tcpdump -i "$INTERFACE" -c 10 'host 8.8.8.8' -n
    
    echo ""
    print_step "2" "DNS Issues"
    echo "Let's diagnose DNS resolution problems..."
    echo ""
    
    print_info "Capturing DNS traffic..."
    print_warning "Try nslookup google.com in another terminal..."
    
    read -p "Press Enter to start DNS capture..."
    
    tcpdump -i "$INTERFACE" -c 5 'udp port 53' -n -A
    
    echo ""
    print_step "3" "HTTP Issues"
    echo "Let's diagnose HTTP connection problems..."
    echo ""
    
    print_info "Capturing HTTP traffic..."
    print_warning "Try curl httpbin.org/get in another terminal..."
    
    read -p "Press Enter to start HTTP capture..."
    
    tcpdump -i "$INTERFACE" -c 10 'tcp port 80' -n -A
    
    print_success "Lab 6 completed! You've learned troubleshooting techniques."
}

# Function to run lab 7: Security Analysis
lab7_security_analysis() {
    print_header "Lab 7: Security Analysis with tcpdump"
    
    print_step "1" "Detecting Port Scans"
    echo "Let's detect potential port scanning activity..."
    echo ""
    
    print_info "Monitoring for SYN packets (potential port scans)..."
    tcpdump -i "$INTERFACE" -c 10 'tcp[tcpflags] & tcp-syn != 0 and tcp[tcpflags] & tcp-ack = 0' -n
    
    echo ""
    print_step "2" "Monitoring Failed Connections"
    echo "Let's monitor for connection failures..."
    echo ""
    
    print_info "Monitoring for RST packets (connection resets)..."
    tcpdump -i "$INTERFACE" -c 5 'tcp[tcpflags] & tcp-rst != 0' -n
    
    echo ""
    print_step "3" "Analyzing Suspicious Traffic"
    echo "Let's look for unusual traffic patterns..."
    echo ""
    
    print_info "Monitoring traffic to unusual ports..."
    tcpdump -i "$INTERFACE" -c 10 'portrange 10000-65535' -n
    
    print_success "Lab 7 completed! You've learned security analysis techniques."
}

# Function to show lab menu
show_menu() {
    print_header "TCP Dump Learning Lab"
    echo "Choose a lab to run:"
    echo ""
    echo "1. Basic Packet Capture"
    echo "2. Filtering Network Traffic"
    echo "3. Saving and Reading Captures"
    echo "4. Advanced Filtering Techniques"
    echo "5. Protocol Analysis"
    echo "6. Network Troubleshooting"
    echo "7. Security Analysis"
    echo "8. Run All Labs"
    echo "9. Exit"
    echo ""
    read -p "Enter your choice (1-9): " choice
    
    case $choice in
        1) lab1_basic_capture ;;
        2) lab2_filtering ;;
        3) lab3_save_read ;;
        4) lab4_advanced_filtering ;;
        5) lab5_protocol_analysis ;;
        6) lab6_troubleshooting ;;
        7) lab7_security_analysis ;;
        8) run_all_labs ;;
        9) print_success "Goodbye!"; exit 0 ;;
        *) print_error "Invalid choice. Please select 1-9." ;;
    esac
}

# Function to run all labs
run_all_labs() {
    print_header "Running All TCP Dump Labs"
    
    lab1_basic_capture
    echo ""
    read -p "Press Enter to continue to Lab 2..."
    
    lab2_filtering
    echo ""
    read -p "Press Enter to continue to Lab 3..."
    
    lab3_save_read
    echo ""
    read -p "Press Enter to continue to Lab 4..."
    
    lab4_advanced_filtering
    echo ""
    read -p "Press Enter to continue to Lab 5..."
    
    lab5_protocol_analysis
    echo ""
    read -p "Press Enter to continue to Lab 6..."
    
    lab6_troubleshooting
    echo ""
    read -p "Press Enter to continue to Lab 7..."
    
    lab7_security_analysis
    
    print_success "All labs completed! You're now proficient with tcpdump."
}

# Function to cleanup lab environment
cleanup_lab() {
    print_header "Cleaning Up Lab Environment"
    
    if [ -d "$LAB_DIR" ]; then
        rm -rf "$LAB_DIR"
        print_success "Lab directory cleaned up"
    fi
    
    print_success "Lab cleanup completed"
}

# Main function
main() {
    # Setup lab environment
    setup_lab
    
    # Show menu and run labs
    while true; do
        show_menu
        echo ""
        read -p "Press Enter to continue..."
        clear
    done
}

# Handle script interruption
trap cleanup_lab EXIT

# Run main function
main
