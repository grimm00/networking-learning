#!/bin/bash

# DHCP Interactive Lab
# Hands-on exercises for understanding DHCP protocol and troubleshooting

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
LOG_FILE="/tmp/dhcp-lab.log"
OUTPUT_DIR="/tmp/dhcp-lab-output"

# Logging function
log() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

# Print header
print_header() {
    echo -e "\n${CYAN}============================================================"
    echo "DHCP INTERACTIVE LAB"
    echo "============================================================${NC}"
}

# Print section header
print_section() {
    echo -e "\n${YELLOW}=== $1 ===${NC}"
}

# Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "This lab requires root privileges (use sudo)"
        exit 1
    fi
}

# Check dependencies
check_dependencies() {
    local missing_tools=()
    
    if ! command -v tcpdump &> /dev/null; then
        missing_tools+=("tcpdump")
    fi
    
    if ! command -v tshark &> /dev/null; then
        missing_tools+=("tshark")
    fi
    
    if ! command -v dhclient &> /dev/null; then
        missing_tools+=("dhclient")
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log "Install with: sudo apt-get install tcpdump tshark isc-dhcp-client"
        return 1
    fi
    
    return 0
}

# Create output directory
create_output_dir() {
    mkdir -p "$OUTPUT_DIR"
    log "Output directory created: $OUTPUT_DIR"
}

# Lab 1: Basic DHCP Discovery
lab1_dhcp_discovery() {
    print_section "Lab 1: DHCP Discovery Process"
    
    echo "This lab demonstrates the DHCP discovery process (DORA)."
    echo "We'll capture DHCP traffic while requesting a new IP address."
    
    read -p "Press Enter to start DHCP discovery capture..."
    
    # Start packet capture in background
    local pcap_file="$OUTPUT_DIR/dhcp_discovery_$(date +%Y%m%d_%H%M%S).pcap"
    tcpdump -i any -n -s 0 port 67 or port 68 -w "$pcap_file" &
    local tcpdump_pid=$!
    
    log "Started packet capture (PID: $tcpdump_pid)"
    log "Capture file: $pcap_file"
    
    # Wait a moment for tcpdump to start
    sleep 2
    
    echo -e "\n${CYAN}Step 1: Release current IP address${NC}"
    dhclient -r
    log "Released current IP address"
    
    echo -e "\n${CYAN}Step 2: Request new IP address${NC}"
    dhclient
    log "Requested new IP address"
    
    # Wait for DHCP process to complete
    sleep 5
    
    # Stop packet capture
    kill $tcpdump_pid 2>/dev/null
    wait $tcpdump_pid 2>/dev/null
    
    log_success "Packet capture completed"
    
    # Analyze captured packets
    echo -e "\n${CYAN}Step 3: Analyze captured packets${NC}"
    if [ -f "$pcap_file" ]; then
        echo "DHCP messages captured:"
        tshark -r "$pcap_file" -T fields -e frame.number -e ip.src -e ip.dst -e udp.srcport -e udp.dstport -e dhcp.option.dhcp
    else
        log_warning "No packets captured"
    fi
    
    echo -e "\n${GREEN}Lab 1 completed! Check the capture file for detailed analysis.${NC}"
}

# Lab 2: DHCP Message Analysis
lab2_message_analysis() {
    print_section "Lab 2: DHCP Message Analysis"
    
    echo "This lab analyzes different types of DHCP messages."
    
    local pcap_file="$OUTPUT_DIR/dhcp_analysis_$(date +%Y%m%d_%H%M%S).pcap"
    
    echo -e "\n${CYAN}Step 1: Start packet capture${NC}"
    tcpdump -i any -n -s 0 port 67 or port 68 -w "$pcap_file" &
    local tcpdump_pid=$!
    
    sleep 2
    
    echo -e "\n${CYAN}Step 2: Generate DHCP traffic${NC}"
    echo "Releasing and renewing IP address..."
    dhclient -r
    sleep 2
    dhclient
    sleep 5
    
    # Stop capture
    kill $tcpdump_pid 2>/dev/null
    wait $tcpdump_pid 2>/dev/null
    
    echo -e "\n${CYAN}Step 3: Analyze message types${NC}"
    if [ -f "$pcap_file" ]; then
        echo "DHCP Message Types:"
        tshark -r "$pcap_file" -T fields -e dhcp.option.dhcp | sort | uniq -c
        
        echo -e "\nDetailed message analysis:"
        tshark -r "$pcap_file" -T fields -e frame.number -e ip.src -e ip.dst -e dhcp.option.dhcp -e dhcp.client_mac -e dhcp.your_ip
    fi
    
    echo -e "\n${GREEN}Lab 2 completed!${NC}"
}

# Lab 3: DHCP Server Detection
lab3_server_detection() {
    print_section "Lab 3: DHCP Server Detection"
    
    echo "This lab helps identify DHCP servers on the network."
    
    echo -e "\n${CYAN}Step 1: Scan for DHCP servers${NC}"
    echo "Scanning for DHCP servers on common ports..."
    
    # Scan for DHCP servers
    nmap -sU -p 67 --script broadcast-dhcp-discover 2>/dev/null || {
        log_warning "nmap DHCP script not available, using alternative method"
        
        # Alternative: capture DHCP traffic and identify servers
        local pcap_file="$OUTPUT_DIR/dhcp_servers_$(date +%Y%m%d_%H%M%S).pcap"
        tcpdump -i any -n -s 0 port 67 or port 68 -w "$pcap_file" &
        local tcpdump_pid=$!
        
        sleep 2
        dhclient -r
        dhclient
        sleep 5
        
        kill $tcpdump_pid 2>/dev/null
        wait $tcpdump_pid 2>/dev/null
        
        if [ -f "$pcap_file" ]; then
            echo "DHCP servers found:"
            tshark -r "$pcap_file" -T fields -e ip.src -e dhcp.option.server_id | grep -v "^$" | sort | uniq
        fi
    }
    
    echo -e "\n${CYAN}Step 2: Check current DHCP configuration${NC}"
    echo "Current IP configuration:"
    ip addr show | grep -E "inet |inet6"
    
    echo -e "\nCurrent routing table:"
    ip route show
    
    echo -e "\nDNS configuration:"
    cat /etc/resolv.conf
    
    echo -e "\n${GREEN}Lab 3 completed!${NC}"
}

# Lab 4: DHCP Troubleshooting
lab4_troubleshooting() {
    print_section "Lab 4: DHCP Troubleshooting"
    
    echo "This lab demonstrates common DHCP troubleshooting techniques."
    
    echo -e "\n${CYAN}Step 1: Check DHCP client status${NC}"
    echo "Current network interfaces:"
    ip link show
    
    echo -e "\nCurrent IP addresses:"
    ip addr show
    
    echo -e "\n${CYAN}Step 2: Test DHCP server connectivity${NC}"
    echo "Testing connectivity to DHCP server..."
    
    # Get current gateway
    local gateway=$(ip route | grep default | awk '{print $3}')
    if [ -n "$gateway" ]; then
        echo "Testing connectivity to gateway: $gateway"
        ping -c 3 "$gateway"
    else
        log_warning "No default gateway found"
    fi
    
    echo -e "\n${CYAN}Step 3: Check for DHCP conflicts${NC}"
    echo "Checking for duplicate IP addresses..."
    
    # Get current IP
    local current_ip=$(ip addr show | grep -E "inet [0-9]" | head -1 | awk '{print $2}' | cut -d'/' -f1)
    if [ -n "$current_ip" ]; then
        echo "Testing if current IP ($current_ip) is in use:"
        ping -c 1 -W 1 "$current_ip" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            log_warning "IP address $current_ip appears to be in use"
        else
            log_success "IP address $current_ip is not conflicting"
        fi
    fi
    
    echo -e "\n${CYAN}Step 4: Manual DHCP renewal${NC}"
    echo "Manually renewing DHCP lease..."
    dhclient -r
    sleep 2
    dhclient -v
    
    echo -e "\n${GREEN}Lab 4 completed!${NC}"
}

# Lab 5: DHCP Options Analysis
lab5_options_analysis() {
    print_section "Lab 5: DHCP Options Analysis"
    
    echo "This lab analyzes DHCP options and configuration parameters."
    
    local pcap_file="$OUTPUT_DIR/dhcp_options_$(date +%Y%m%d_%H%M%S).pcap"
    
    echo -e "\n${CYAN}Step 1: Capture DHCP traffic with options${NC}"
    tcpdump -i any -n -s 0 port 67 or port 68 -w "$pcap_file" &
    local tcpdump_pid=$!
    
    sleep 2
    dhclient -r
    dhclient
    sleep 5
    
    kill $tcpdump_pid 2>/dev/null
    wait $tcpdump_pid 2>/dev/null
    
    echo -e "\n${CYAN}Step 2: Analyze DHCP options${NC}"
    if [ -f "$pcap_file" ]; then
        echo "DHCP Options found:"
        tshark -r "$pcap_file" -T fields -e dhcp.option.subnet_mask -e dhcp.option.router -e dhcp.option.domain_name_server -e dhcp.option.domain_name -e dhcp.option.lease_time | grep -v "^$"
        
        echo -e "\nDetailed options analysis:"
        tshark -r "$pcap_file" -T fields -e frame.number -e dhcp.option.dhcp -e dhcp.option.subnet_mask -e dhcp.option.router -e dhcp.option.domain_name_server
    fi
    
    echo -e "\n${GREEN}Lab 5 completed!${NC}"
}

# Show menu
show_menu() {
    echo -e "\n${CYAN}DHCP Lab Menu:${NC}"
    echo "1. Lab 1: DHCP Discovery Process (DORA)"
    echo "2. Lab 2: DHCP Message Analysis"
    echo "3. Lab 3: DHCP Server Detection"
    echo "4. Lab 4: DHCP Troubleshooting"
    echo "5. Lab 5: DHCP Options Analysis"
    echo "6. Run All Labs"
    echo "7. Show Current Configuration"
    echo "8. Exit"
}

# Show current configuration
show_current_config() {
    print_section "Current Network Configuration"
    
    echo -e "\n${CYAN}Network Interfaces:${NC}"
    ip link show
    
    echo -e "\n${CYAN}IP Addresses:${NC}"
    ip addr show
    
    echo -e "\n${CYAN}Routing Table:${NC}"
    ip route show
    
    echo -e "\n${CYAN}DNS Configuration:${NC}"
    cat /etc/resolv.conf
    
    echo -e "\n${CYAN}DHCP Client Status:${NC}"
    systemctl status dhcpcd 2>/dev/null || systemctl status NetworkManager 2>/dev/null || echo "DHCP client status not available"
}

# Run all labs
run_all_labs() {
    print_section "Running All DHCP Labs"
    
    lab1_dhcp_discovery
    read -p "Press Enter to continue to Lab 2..."
    
    lab2_message_analysis
    read -p "Press Enter to continue to Lab 3..."
    
    lab3_server_detection
    read -p "Press Enter to continue to Lab 4..."
    
    lab4_troubleshooting
    read -p "Press Enter to continue to Lab 5..."
    
    lab5_options_analysis
    
    echo -e "\n${GREEN}All labs completed! Check the output directory for results.${NC}"
}

# Main function
main() {
    print_header
    
    # Check prerequisites
    check_root
    if ! check_dependencies; then
        exit 1
    fi
    
    # Create output directory
    create_output_dir
    
    # Main loop
    while true; do
        show_menu
        read -p "Select an option (1-8): " choice
        
        case $choice in
            1)
                lab1_dhcp_discovery
                ;;
            2)
                lab2_message_analysis
                ;;
            3)
                lab3_server_detection
                ;;
            4)
                lab4_troubleshooting
                ;;
            5)
                lab5_options_analysis
                ;;
            6)
                run_all_labs
                ;;
            7)
                show_current_config
                ;;
            8)
                echo -e "\n${GREEN}Exiting DHCP Lab. Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option. Please try again.${NC}"
                ;;
        esac
        
        echo -e "\nPress Enter to continue..."
        read
    done
}

# Run main function
main "$@"
