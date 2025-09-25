#!/bin/bash

# Wireshark Interactive Lab
# Hands-on exercises for learning Wireshark and network analysis

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
LOG_FILE="/tmp/wireshark-lab.log"
OUTPUT_DIR="/tmp/wireshark-lab-output"

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
    echo "WIRESHARK INTERACTIVE LAB"
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
    
    if ! command -v tshark &> /dev/null; then
        missing_tools+=("tshark")
    fi
    
    if ! command -v wireshark &> /dev/null; then
        missing_tools+=("wireshark")
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log "Install with: sudo apt-get install wireshark tshark"
        return 1
    fi
    
    return 0
}

# Create output directory
create_output_dir() {
    mkdir -p "$OUTPUT_DIR"
    log "Output directory created: $OUTPUT_DIR"
}

# Lab 1: Basic Packet Capture
lab1_basic_capture() {
    print_section "Lab 1: Basic Packet Capture"
    
    echo "This lab demonstrates basic packet capture using tshark."
    echo "We'll capture packets and analyze them step by step."
    
    read -p "Press Enter to start basic packet capture..."
    
    # Start packet capture
    local pcap_file="$OUTPUT_DIR/basic_capture_$(date +%Y%m%d_%H%M%S).pcap"
    
    echo -e "\n${CYAN}Step 1: Starting packet capture${NC}"
    log "Capturing packets to: $pcap_file"
    
    tcpdump -i any -n -s 0 -w "$pcap_file" &
    local tcpdump_pid=$!
    
    log "Started packet capture (PID: $tcpdump_pid)"
    
    # Wait a moment for tcpdump to start
    sleep 2
    
    echo -e "\n${CYAN}Step 2: Generate some network traffic${NC}"
    echo "Generating test traffic..."
    
    # Generate some traffic
    ping -c 3 8.8.8.8 >/dev/null 2>&1
    nslookup google.com >/dev/null 2>&1
    curl -s http://httpbin.org/get >/dev/null 2>&1
    
    # Wait for traffic to be captured
    sleep 5
    
    # Stop packet capture
    kill $tcpdump_pid 2>/dev/null
    wait $tcpdump_pid 2>/dev/null
    
    log_success "Packet capture completed"
    
    # Analyze captured packets
    echo -e "\n${CYAN}Step 3: Analyze captured packets${NC}"
    if [ -f "$pcap_file" ]; then
        echo "Packet summary:"
        tshark -r "$pcap_file" -T fields -e frame.number -e frame.time -e ip.src -e ip.dst -e frame.protocols | head -10
        
        echo -e "\nProtocol distribution:"
        tshark -r "$pcap_file" -T fields -e frame.protocols | tr ',' '\n' | sort | uniq -c | sort -nr
    else
        log_warning "No packets captured"
    fi
    
    echo -e "\n${GREEN}Lab 1 completed! Check the capture file for detailed analysis.${NC}"
}

# Lab 2: Display Filters
lab2_display_filters() {
    print_section "Lab 2: Display Filters"
    
    echo "This lab demonstrates how to use display filters to focus on specific traffic."
    
    local pcap_file="$OUTPUT_DIR/filter_capture_$(date +%Y%m%d_%H%M%S).pcap"
    
    echo -e "\n${CYAN}Step 1: Capture traffic with specific filter${NC}"
    echo "Capturing HTTP traffic only..."
    
    tcpdump -i any -n -s 0 -w "$pcap_file" port 80 &
    local tcpdump_pid=$!
    
    sleep 2
    
    echo -e "\n${CYAN}Step 2: Generate HTTP traffic${NC}"
    echo "Making HTTP requests..."
    
    curl -s http://httpbin.org/get >/dev/null 2>&1
    curl -s http://httpbin.org/ip >/dev/null 2>&1
    
    sleep 3
    
    kill $tcpdump_pid 2>/dev/null
    wait $tcpdump_pid 2>/dev/null
    
    echo -e "\n${CYAN}Step 3: Apply display filters${NC}"
    if [ -f "$pcap_file" ]; then
        echo "All packets:"
        tshark -r "$pcap_file" -T fields -e frame.number -e ip.src -e ip.dst -e frame.protocols
        
        echo -e "\nHTTP requests only:"
        tshark -r "$pcap_file" -T fields -e frame.number -e ip.src -e ip.dst -e http.request.method -e http.request.uri
        
        echo -e "\nPackets from specific IP:"
        tshark -r "$pcap_file" -T fields -e frame.number -e ip.src -e ip.dst -e frame.protocols | head -5
    fi
    
    echo -e "\n${GREEN}Lab 2 completed!${NC}"
}

# Lab 3: Protocol Analysis
lab3_protocol_analysis() {
    print_section "Lab 3: Protocol Analysis"
    
    echo "This lab demonstrates deep protocol analysis using Wireshark."
    
    local pcap_file="$OUTPUT_DIR/protocol_analysis_$(date +%Y%m%d_%H%M%S).pcap"
    
    echo -e "\n${CYAN}Step 1: Capture diverse traffic${NC}"
    echo "Capturing various protocol traffic..."
    
    tcpdump -i any -n -s 0 -w "$pcap_file" &
    local tcpdump_pid=$!
    
    sleep 2
    
    echo -e "\n${CYAN}Step 2: Generate different types of traffic${NC}"
    echo "Generating various protocol traffic..."
    
    # Generate different types of traffic
    ping -c 2 8.8.8.8 >/dev/null 2>&1
    nslookup google.com >/dev/null 2>&1
    curl -s http://httpbin.org/get >/dev/null 2>&1
    curl -s https://httpbin.org/get >/dev/null 2>&1
    
    sleep 5
    
    kill $tcpdump_pid 2>/dev/null
    wait $tcpdump_pid 2>/dev/null
    
    echo -e "\n${CYAN}Step 3: Analyze different protocols${NC}"
    if [ -f "$pcap_file" ]; then
        echo "ICMP Analysis:"
        tshark -r "$pcap_file" -T fields -e frame.number -e icmp.type -e icmp.code -e ip.src -e ip.dst | grep -v "^$"
        
        echo -e "\nDNS Analysis:"
        tshark -r "$pcap_file" -T fields -e frame.number -e dns.qry.name -e dns.resp.name -e dns.flags.response | grep -v "^$"
        
        echo -e "\nHTTP Analysis:"
        tshark -r "$pcap_file" -T fields -e frame.number -e http.request.method -e http.request.uri -e http.response.code | grep -v "^$"
        
        echo -e "\nTCP Connection Analysis:"
        tshark -r "$pcap_file" -T fields -e frame.number -e tcp.srcport -e tcp.dstport -e tcp.flags -e ip.src -e ip.dst | head -10
    fi
    
    echo -e "\n${GREEN}Lab 3 completed!${NC}"
}

# Lab 4: Statistical Analysis
lab4_statistical_analysis() {
    print_section "Lab 4: Statistical Analysis"
    
    echo "This lab demonstrates statistical analysis of network traffic."
    
    local pcap_file="$OUTPUT_DIR/statistics_$(date +%Y%m%d_%H%M%S).pcap"
    
    echo -e "\n${CYAN}Step 1: Capture traffic for analysis${NC}"
    echo "Capturing traffic for statistical analysis..."
    
    tcpdump -i any -n -s 0 -w "$pcap_file" &
    local tcpdump_pid=$!
    
    sleep 2
    
    echo -e "\n${CYAN}Step 2: Generate sustained traffic${NC}"
    echo "Generating sustained traffic for analysis..."
    
    # Generate sustained traffic
    for i in {1..10}; do
        ping -c 1 8.8.8.8 >/dev/null 2>&1
        curl -s http://httpbin.org/get >/dev/null 2>&1
        sleep 1
    done
    
    sleep 3
    
    kill $tcpdump_pid 2>/dev/null
    wait $tcpdump_pid 2>/dev/null
    
    echo -e "\n${CYAN}Step 3: Generate statistics${NC}"
    if [ -f "$pcap_file" ]; then
        echo "Protocol Hierarchy:"
        tshark -r "$pcap_file" -T fields -e frame.protocols | tr ',' '\n' | sort | uniq -c | sort -nr
        
        echo -e "\nTop Talkers:"
        tshark -r "$pcap_file" -T fields -e ip.src | sort | uniq -c | sort -nr | head -5
        
        echo -e "\nPacket Size Distribution:"
        tshark -r "$pcap_file" -T fields -e frame.len | sort -n | uniq -c | head -10
        
        echo -e "\nConversation Statistics:"
        tshark -r "$pcap_file" -T fields -e ip.src -e ip.dst | sort | uniq -c | sort -nr | head -5
    fi
    
    echo -e "\n${GREEN}Lab 4 completed!${NC}"
}

# Lab 5: Troubleshooting
lab5_troubleshooting() {
    print_section "Lab 5: Network Troubleshooting"
    
    echo "This lab demonstrates how to use Wireshark for network troubleshooting."
    
    local pcap_file="$OUTPUT_DIR/troubleshooting_$(date +%Y%m%d_%H%M%S).pcap"
    
    echo -e "\n${CYAN}Step 1: Capture troubleshooting traffic${NC}"
    echo "Capturing traffic for troubleshooting analysis..."
    
    tcpdump -i any -n -s 0 -w "$pcap_file" &
    local tcpdump_pid=$!
    
    sleep 2
    
    echo -e "\n${CYAN}Step 2: Generate test traffic${NC}"
    echo "Generating test traffic..."
    
    # Generate test traffic
    ping -c 3 8.8.8.8 >/dev/null 2>&1
    ping -c 3 192.168.1.1 >/dev/null 2>&1
    nslookup google.com >/dev/null 2>&1
    curl -s http://httpbin.org/get >/dev/null 2>&1
    
    sleep 5
    
    kill $tcpdump_pid 2>/dev/null
    wait $tcpdump_pid 2>/dev/null
    
    echo -e "\n${CYAN}Step 3: Analyze for common issues${NC}"
    if [ -f "$pcap_file" ]; then
        echo "ICMP Error Analysis:"
        tshark -r "$pcap_file" -T fields -e frame.number -e icmp.type -e icmp.code -e ip.src -e ip.dst | grep -v "^$"
        
        echo -e "\nTCP Reset Analysis:"
        tshark -r "$pcap_file" -T fields -e frame.number -e tcp.flags -e ip.src -e ip.dst | grep "R"
        
        echo -e "\nDNS Response Analysis:"
        tshark -r "$pcap_file" -T fields -e frame.number -e dns.flags.response -e dns.flags.rcode -e dns.qry.name | grep -v "^$"
        
        echo -e "\nConnection Timeout Analysis:"
        tshark -r "$pcap_file" -T fields -e frame.number -e tcp.flags -e ip.src -e ip.dst | head -10
    fi
    
    echo -e "\n${GREEN}Lab 5 completed!${NC}"
}

# Lab 6: Security Analysis
lab6_security_analysis() {
    print_section "Lab 6: Security Analysis"
    
    echo "This lab demonstrates security analysis using Wireshark."
    
    local pcap_file="$OUTPUT_DIR/security_analysis_$(date +%Y%m%d_%H%M%S).pcap"
    
    echo -e "\n${CYAN}Step 1: Capture traffic for security analysis${NC}"
    echo "Capturing traffic for security analysis..."
    
    tcpdump -i any -n -s 0 -w "$pcap_file" &
    local tcpdump_pid=$!
    
    sleep 2
    
    echo -e "\n${CYAN}Step 2: Generate various traffic types${NC}"
    echo "Generating various traffic types..."
    
    # Generate various traffic
    ping -c 2 8.8.8.8 >/dev/null 2>&1
    curl -s http://httpbin.org/get >/dev/null 2>&1
    curl -s https://httpbin.org/get >/dev/null 2>&1
    nslookup google.com >/dev/null 2>&1
    
    sleep 5
    
    kill $tcpdump_pid 2>/dev/null
    wait $tcpdump_pid 2>/dev/null
    
    echo -e "\n${CYAN}Step 3: Analyze for security issues${NC}"
    if [ -f "$pcap_file" ]; then
        echo "Suspicious Port Analysis:"
        tshark -r "$pcap_file" -T fields -e frame.number -e tcp.dstport -e udp.dstport -e ip.src -e ip.dst | grep -E "(23|21|135|139|445|1433|3389)"
        
        echo -e "\nLarge Packet Analysis:"
        tshark -r "$pcap_file" -T fields -e frame.number -e frame.len -e ip.src -e ip.dst | awk '$2 > 1500'
        
        echo -e "\nHTTP Method Analysis:"
        tshark -r "$pcap_file" -T fields -e frame.number -e http.request.method -e http.request.uri -e ip.src -e ip.dst | grep -v "^$"
        
        echo -e "\nTLS/SSL Analysis:"
        tshark -r "$pcap_file" -T fields -e frame.number -e tls.handshake.type -e tls.record.version -e ip.src -e ip.dst | grep -v "^$"
    fi
    
    echo -e "\n${GREEN}Lab 6 completed!${NC}"
}

# Show menu
show_menu() {
    echo -e "\n${CYAN}Wireshark Lab Menu:${NC}"
    echo "1. Lab 1: Basic Packet Capture"
    echo "2. Lab 2: Display Filters"
    echo "3. Lab 3: Protocol Analysis"
    echo "4. Lab 4: Statistical Analysis"
    echo "5. Lab 5: Network Troubleshooting"
    echo "6. Lab 6: Security Analysis"
    echo "7. Run All Labs"
    echo "8. Show Available Interfaces"
    echo "9. Exit"
}

# Show available interfaces
show_interfaces() {
    print_section "Available Network Interfaces"
    
    echo "Network interfaces available for capture:"
    ip link show | grep -E "^[0-9]+:" | while read line; do
        interface=$(echo "$line" | cut -d: -f2 | sed 's/^ *//')
        state=$(echo "$line" | grep -o "state [A-Z]*" | cut -d' ' -f2)
        echo "  $interface: $state"
    done
    
    echo -e "\nInterface statistics:"
    ip -s link show | grep -E "(RX|TX)" -A 1
}

# Run all labs
run_all_labs() {
    print_section "Running All Wireshark Labs"
    
    lab1_basic_capture
    read -p "Press Enter to continue to Lab 2..."
    
    lab2_display_filters
    read -p "Press Enter to continue to Lab 3..."
    
    lab3_protocol_analysis
    read -p "Press Enter to continue to Lab 4..."
    
    lab4_statistical_analysis
    read -p "Press Enter to continue to Lab 5..."
    
    lab5_troubleshooting
    read -p "Press Enter to continue to Lab 6..."
    
    lab6_security_analysis
    
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
        read -p "Select an option (1-9): " choice
        
        case $choice in
            1)
                lab1_basic_capture
                ;;
            2)
                lab2_display_filters
                ;;
            3)
                lab3_protocol_analysis
                ;;
            4)
                lab4_statistical_analysis
                ;;
            5)
                lab5_troubleshooting
                ;;
            6)
                lab6_security_analysis
                ;;
            7)
                run_all_labs
                ;;
            8)
                show_interfaces
                ;;
            9)
                echo -e "\n${GREEN}Exiting Wireshark Lab. Goodbye!${NC}"
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
