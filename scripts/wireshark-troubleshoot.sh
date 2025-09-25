#!/bin/bash

# Wireshark Troubleshooting Script
# Comprehensive tool for diagnosing Wireshark and network analysis issues

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
LOG_FILE="/tmp/wireshark-troubleshoot.log"
OUTPUT_DIR="/tmp/wireshark-troubleshoot-output"

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
    echo "WIRESHARK TROUBLESHOOTING TOOL"
    echo "============================================================${NC}"
}

# Print section header
print_section() {
    echo -e "\n${YELLOW}=== $1 ===${NC}"
}

# Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "This script requires root privileges (use sudo)"
        exit 1
    fi
}

# Create output directory
create_output_dir() {
    mkdir -p "$OUTPUT_DIR"
    log "Output directory created: $OUTPUT_DIR"
}

# Check Wireshark installation
check_wireshark_installation() {
    print_section "Wireshark Installation Check"
    
    local missing_tools=()
    
    # Check tshark
    if command -v tshark &> /dev/null; then
        local tshark_version=$(tshark --version | head -1)
        log_success "tshark found: $tshark_version"
    else
        missing_tools+=("tshark")
        log_error "tshark not found"
    fi
    
    # Check wireshark
    if command -v wireshark &> /dev/null; then
        local wireshark_version=$(wireshark --version | head -1)
        log_success "wireshark found: $wireshark_version"
    else
        missing_tools+=("wireshark")
        log_error "wireshark not found"
    fi
    
    # Check dumpcap
    if command -v dumpcap &> /dev/null; then
        log_success "dumpcap found"
    else
        missing_tools+=("dumpcap")
        log_error "dumpcap not found"
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log "Install with: sudo apt-get install wireshark tshark"
        return 1
    fi
    
    return 0
}

# Check capture permissions
check_capture_permissions() {
    print_section "Capture Permissions Check"
    
    # Check if user is in wireshark group
    if groups | grep -q wireshark; then
        log_success "User is in wireshark group"
    else
        log_warning "User is not in wireshark group"
        log "Add user to wireshark group: sudo usermod -a -G wireshark $USER"
        log "Then log out and back in for changes to take effect"
    fi
    
    # Check if tshark can capture
    if tshark -i any -c 1 -f "icmp" >/dev/null 2>&1; then
        log_success "tshark can capture packets"
    else
        log_error "tshark cannot capture packets"
        log "This may be due to insufficient permissions"
        log "Try running with sudo or add user to wireshark group"
    fi
}

# Check network interfaces
check_network_interfaces() {
    print_section "Network Interface Check"
    
    echo "Available network interfaces:"
    ip link show | grep -E "^[0-9]+:" | while read line; do
        interface=$(echo "$line" | cut -d: -f2 | sed 's/^ *//')
        state=$(echo "$line" | grep -o "state [A-Z]*" | cut -d' ' -f2)
        echo "  $interface: $state"
    done
    
    echo -e "\nInterface statistics:"
    ip -s link show | grep -E "(RX|TX)" -A 1
    
    echo -e "\nIP addresses:"
    ip addr show | grep -E "inet [0-9]" | while read line; do
        interface=$(echo "$line" | awk '{print $NF}')
        ip=$(echo "$line" | awk '{print $2}')
        echo "  $interface: $ip"
    done
}

# Test packet capture
test_packet_capture() {
    print_section "Packet Capture Test"
    
    local test_file="$OUTPUT_DIR/test_capture_$(date +%Y%m%d_%H%M%S).pcap"
    
    echo "Testing packet capture..."
    log "Test capture file: $test_file"
    
    # Start capture in background
    tcpdump -i any -n -s 0 -w "$test_file" &
    local tcpdump_pid=$!
    
    # Wait for tcpdump to start
    sleep 2
    
    # Generate some traffic
    log "Generating test traffic..."
    ping -c 3 8.8.8.8 >/dev/null 2>&1
    
    # Wait for traffic to be captured
    sleep 3
    
    # Stop capture
    kill $tcpdump_pid 2>/dev/null
    wait $tcpdump_pid 2>/dev/null
    
    # Check if file was created and has content
    if [ -f "$test_file" ] && [ -s "$test_file" ]; then
        local packet_count=$(tshark -r "$test_file" -T fields -e frame.number | wc -l)
        log_success "Packet capture successful: $packet_count packets captured"
        
        echo "Sample packets:"
        tshark -r "$test_file" -T fields -e frame.number -e frame.time -e ip.src -e ip.dst -e frame.protocols | head -5
    else
        log_error "Packet capture failed or no packets captured"
        return 1
    fi
}

# Test display filters
test_display_filters() {
    print_section "Display Filter Test"
    
    local test_file="$OUTPUT_DIR/filter_test_$(date +%Y%m%d_%H%M%S).pcap"
    
    echo "Testing display filters..."
    
    # Capture some traffic
    tcpdump -i any -n -s 0 -w "$test_file" &
    local tcpdump_pid=$!
    
    sleep 2
    
    # Generate traffic
    ping -c 2 8.8.8.8 >/dev/null 2>&1
    curl -s http://httpbin.org/get >/dev/null 2>&1
    
    sleep 3
    
    kill $tcpdump_pid 2>/dev/null
    wait $tcpdump_pid 2>/dev/null
    
    if [ -f "$test_file" ] && [ -s "$test_file" ]; then
        echo "Testing basic display filters..."
        
        echo "All packets:"
        tshark -r "$test_file" -T fields -e frame.number -e ip.src -e ip.dst | head -3
        
        echo "ICMP packets only:"
        tshark -r "$test_file" -T fields -e frame.number -e ip.src -e ip.dst -Y "icmp" | head -3
        
        echo "HTTP packets only:"
        tshark -r "$test_file" -T fields -e frame.number -e ip.src -e ip.dst -Y "http" | head -3
        
        log_success "Display filters working correctly"
    else
        log_error "Display filter test failed"
    fi
}

# Test protocol analysis
test_protocol_analysis() {
    print_section "Protocol Analysis Test"
    
    local test_file="$OUTPUT_DIR/protocol_test_$(date +%Y%m%d_%H%M%S).pcap"
    
    echo "Testing protocol analysis..."
    
    # Capture traffic
    tcpdump -i any -n -s 0 -w "$test_file" &
    local tcpdump_pid=$!
    
    sleep 2
    
    # Generate various traffic
    ping -c 2 8.8.8.8 >/dev/null 2>&1
    nslookup google.com >/dev/null 2>&1
    curl -s http://httpbin.org/get >/dev/null 2>&1
    
    sleep 5
    
    kill $tcpdump_pid 2>/dev/null
    wait $tcpdump_pid 2>/dev/null
    
    if [ -f "$test_file" ] && [ -s "$test_file" ]; then
        echo "Protocol analysis results:"
        
        echo "Protocol distribution:"
        tshark -r "$test_file" -T fields -e frame.protocols | tr ',' '\n' | sort | uniq -c | sort -nr
        
        echo "TCP analysis:"
        tshark -r "$test_file" -T fields -e frame.number -e tcp.srcport -e tcp.dstport -e tcp.flags | head -5
        
        echo "DNS analysis:"
        tshark -r "$test_file" -T fields -e frame.number -e dns.qry.name -e dns.resp.name | grep -v "^$"
        
        log_success "Protocol analysis working correctly"
    else
        log_error "Protocol analysis test failed"
    fi
}

# Check system resources
check_system_resources() {
    print_section "System Resources Check"
    
    echo "Memory usage:"
    free -h
    
    echo -e "\nDisk usage:"
    df -h
    
    echo -e "\nCPU usage:"
    top -bn1 | grep "Cpu(s)"
    
    echo -e "\nLoad average:"
    uptime
    
    echo -e "\nNetwork interface statistics:"
    cat /proc/net/dev | head -5
}

# Check for common issues
check_common_issues() {
    print_section "Common Issues Check"
    
    local issues_found=0
    
    # Check for permission issues
    if ! groups | grep -q wireshark; then
        log_warning "User not in wireshark group"
        ((issues_found++))
    fi
    
    # Check for interface issues
    if ! ip link show | grep -q "state UP"; then
        log_warning "No network interfaces are UP"
        ((issues_found++))
    fi
    
    # Check for capture issues
    if ! tshark -i any -c 1 -f "icmp" >/dev/null 2>&1; then
        log_warning "Cannot capture packets"
        ((issues_found++))
    fi
    
    # Check for disk space
    local disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ "$disk_usage" -gt 90 ]; then
        log_warning "Disk usage is high: ${disk_usage}%"
        ((issues_found++))
    fi
    
    if [ $issues_found -eq 0 ]; then
        log_success "No common issues found"
    else
        log_warning "Found $issues_found potential issues"
    fi
}

# Performance analysis
analyze_performance() {
    print_section "Performance Analysis"
    
    local test_file="$OUTPUT_DIR/performance_test_$(date +%Y%m%d_%H%M%S).pcap"
    
    echo "Analyzing Wireshark performance..."
    
    # Test capture performance
    echo "Testing capture performance..."
    time tcpdump -i any -n -s 0 -w "$test_file" -c 100 &
    local tcpdump_pid=$!
    
    sleep 2
    
    # Generate traffic
    for i in {1..50}; do
        ping -c 1 8.8.8.8 >/dev/null 2>&1
    done
    
    wait $tcpdump_pid 2>/dev/null
    
    if [ -f "$test_file" ] && [ -s "$test_file" ]; then
        echo "Capture performance test completed"
        
        # Test analysis performance
        echo "Testing analysis performance..."
        time tshark -r "$test_file" -T fields -e frame.number -e ip.src -e ip.dst >/dev/null
        
        echo "Analysis performance test completed"
        
        log_success "Performance analysis completed"
    else
        log_error "Performance analysis failed"
    fi
}

# Generate troubleshooting report
generate_report() {
    print_section "Generating Troubleshooting Report"
    
    local report_file="$OUTPUT_DIR/wireshark_troubleshoot_report_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "Wireshark Troubleshooting Report"
        echo "Generated: $(date)"
        echo "========================================"
        echo ""
        
        echo "System Information:"
        uname -a
        echo ""
        
        echo "Wireshark Version:"
        tshark --version | head -1
        echo ""
        
        echo "Network Interfaces:"
        ip link show
        echo ""
        
        echo "IP Configuration:"
        ip addr show
        echo ""
        
        echo "Routing Table:"
        ip route show
        echo ""
        
        echo "System Resources:"
        free -h
        echo ""
        df -h
        echo ""
        
        echo "User Groups:"
        groups
        echo ""
        
        echo "Wireshark Group Members:"
        getent group wireshark
        echo ""
        
    } > "$report_file"
    
    log_success "Troubleshooting report saved to: $report_file"
}

# Main troubleshooting function
run_troubleshooting() {
    print_header
    
    # Check prerequisites
    check_root
    create_output_dir
    
    log "Starting Wireshark troubleshooting..."
    
    # Run all checks
    check_wireshark_installation
    check_capture_permissions
    check_network_interfaces
    test_packet_capture
    test_display_filters
    test_protocol_analysis
    check_system_resources
    check_common_issues
    analyze_performance
    
    # Generate report
    generate_report
    
    log_success "Wireshark troubleshooting completed!"
    echo -e "\n${GREEN}Check the output directory for detailed results: $OUTPUT_DIR${NC}"
}

# Show help
show_help() {
    echo "Wireshark Troubleshooting Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -v, --verbose  Enable verbose output"
    echo ""
    echo "This script performs comprehensive Wireshark troubleshooting including:"
    echo "  - Installation verification"
    echo "  - Permission checks"
    echo "  - Network interface analysis"
    echo "  - Packet capture testing"
    echo "  - Display filter testing"
    echo "  - Protocol analysis testing"
    echo "  - System resource analysis"
    echo "  - Performance analysis"
    echo ""
    echo "Output is saved to: $OUTPUT_DIR"
}

# Main function
main() {
    case "${1:-}" in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--verbose)
            set -x
            run_troubleshooting
            ;;
        "")
            run_troubleshooting
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
