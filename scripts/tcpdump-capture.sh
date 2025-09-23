#!/bin/bash

# TCP Dump Capture Script
# Advanced packet capture with filtering and analysis

set -e

# Signal handling for clean exit
cleanup() {
    print_warning "Received interrupt signal. Cleaning up..."
    if [ -n "$TCPDUMP_PID" ]; then
        kill $TCPDUMP_PID 2>/dev/null || true
    fi
    exit 0
}

trap cleanup SIGINT SIGTERM

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

# Default values
INTERFACE="eth0"
COUNT=100
TIMEOUT=60
FILTER=""
OUTPUT_FILE=""
VERBOSE=false
ANALYZE=false

# Function to show help
show_help() {
    echo "TCP Dump Capture Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -i, --interface INTERFACE    Network interface (default: eth0)"
    echo "  -c, --count COUNT           Number of packets to capture (default: 100)"
    echo "  -t, --timeout SECONDS       Capture timeout (default: 60)"
    echo "  -f, --filter FILTER         BPF filter expression"
    echo "  -o, --output FILE           Output file (default: auto-generated)"
    echo "  -v, --verbose               Verbose output"
    echo "  -a, --analyze               Analyze captured packets"
    echo "  -h, --help                  Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 -i eth0 -c 50                    # Capture 50 packets on eth0"
    echo "  $0 -f 'tcp port 80' -c 20           # Capture HTTP traffic"
    echo "  $0 -i eth0 -f 'host 8.8.8.8' -a     # Capture and analyze DNS traffic"
    echo "  $0 -i eth0 -o web_traffic.pcap       # Save to specific file"
    echo ""
    echo "Common Filters:"
    echo "  'tcp port 80'              HTTP traffic"
    echo "  'tcp port 443'             HTTPS traffic"
    echo "  'udp port 53'              DNS traffic"
    echo "  'icmp'                     Ping traffic"
    echo "  'host 192.168.1.100'       Traffic to/from specific host"
    echo "  'src host 192.168.1.100'   Traffic from specific host"
    echo "  'dst host 192.168.1.100'   Traffic to specific host"
}

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "This script requires root privileges for packet capture"
        print_info "Please run with sudo: sudo $0 $@"
        exit 1
    fi
}

# Function to check if interface exists
check_interface() {
    local interface="$1"
    if ! ip link show "$interface" >/dev/null 2>&1; then
        print_error "Interface $interface not found"
        print_info "Available interfaces:"
        ip link show | grep -E '^[0-9]+:' | awk -F': ' '{print $2}' | awk '{print $1}'
        exit 1
    fi
}

# Function to generate output filename
generate_filename() {
    local interface="$1"
    local filter="$2"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    if [ -n "$filter" ]; then
        # Create safe filename from filter
        local safe_filter=$(echo "$filter" | sed 's/[^a-zA-Z0-9._-]/_/g' | cut -c1-20)
        echo "capture_${interface}_${safe_filter}_${timestamp}.pcap"
    else
        echo "capture_${interface}_${timestamp}.pcap"
    fi
}

# Function to capture packets
capture_packets() {
    local interface="$1"
    local count="$2"
    local timeout="$3"
    local filter="$4"
    local output_file="$5"
    local verbose="$6"
    
    print_header "Starting Packet Capture"
    print_info "Interface: $interface"
    print_info "Count: $count packets"
    print_info "Timeout: $timeout seconds"
    print_info "Output: $output_file"
    
    if [ -n "$filter" ]; then
        print_info "Filter: $filter"
    fi
    
    # Build tcpdump command
    local cmd="tcpdump -i $interface -c $count -w $output_file"
    
    if [ "$verbose" = true ]; then
        cmd="$cmd -v"
    fi
    
    if [ -n "$filter" ]; then
        cmd="$cmd $filter"
    fi
    
    print_info "Command: $cmd"
    echo ""
    
    # Start capture
    print_warning "Starting capture... (Press Ctrl+C to stop early)"
    
    # Start tcpdump in background
    $cmd &
    TCPDUMP_PID=$!
    
    # Wait for tcpdump to complete or timeout
    local start_time=$(date +%s)
    while kill -0 $TCPDUMP_PID 2>/dev/null; do
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        
        if [ $elapsed -ge $timeout ]; then
            print_warning "Capture timed out after $timeout seconds"
            kill $TCPDUMP_PID 2>/dev/null || true
            wait $TCPDUMP_PID 2>/dev/null || true
            break
        fi
        
        sleep 1
    done
    
    # Wait for tcpdump to finish
    wait $TCPDUMP_PID 2>/dev/null
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        print_success "Capture completed successfully"
    elif [ $exit_code -eq 130 ]; then
        print_warning "Capture interrupted by user"
    else
        print_error "Capture failed with exit code $exit_code"
        return 1
    fi
    
    # Check if file was created and has content
    if [ -f "$output_file" ] && [ -s "$output_file" ]; then
        local file_size=$(du -h "$output_file" | cut -f1)
        print_success "Captured packets saved to $output_file ($file_size)"
        return 0
    else
        print_error "No packets captured or file is empty"
        return 1
    fi
}

# Function to analyze captured packets
analyze_packets() {
    local pcap_file="$1"
    
    print_header "Analyzing Captured Packets"
    
    if [ ! -f "$pcap_file" ]; then
        print_error "Capture file not found: $pcap_file"
        return 1
    fi
    
    # Basic statistics
    print_info "Basic Statistics:"
    local total_packets=$(tcpdump -r "$pcap_file" -n | wc -l)
    print_info "Total packets: $total_packets"
    
    # Protocol breakdown
    print_info "Protocol breakdown:"
    tcpdump -r "$pcap_file" -n | awk '{print $1}' | sort | uniq -c | sort -nr | head -10
    
    # Top hosts
    print_info "Top talking hosts:"
    tcpdump -r "$pcap_file" -n | awk '{print $3, $5}' | sed 's/:.*//' | sort | uniq -c | sort -nr | head -10
    
    # Port usage
    print_info "Port usage:"
    tcpdump -r "$pcap_file" -n | awk '{print $5}' | sed 's/.*\.//' | sort | uniq -c | sort -nr | head -10
    
    # Show sample packets
    print_info "Sample packets:"
    tcpdump -r "$pcap_file" -n | head -10
    
    # Check for errors
    local errors=$(tcpdump -r "$pcap_file" -n | grep -i "error\|reset\|unreachable" | wc -l)
    if [ $errors -gt 0 ]; then
        print_warning "Potential errors detected: $errors packets"
    fi
}

# Function to show real-time monitoring
monitor_realtime() {
    local interface="$1"
    local filter="$2"
    
    print_header "Real-time Packet Monitoring"
    print_info "Interface: $interface"
    if [ -n "$filter" ]; then
        print_info "Filter: $filter"
    fi
    print_warning "Press Ctrl+C to stop monitoring"
    echo ""
    
    local cmd="tcpdump -i $interface -n"
    if [ -n "$filter" ]; then
        cmd="$cmd $filter"
    fi
    
    # Start tcpdump in background
    $cmd &
    TCPDUMP_PID=$!
    
    # Wait for tcpdump to complete
    wait $TCPDUMP_PID 2>/dev/null
    local exit_code=$?
    
    if [ $exit_code -eq 130 ]; then
        print_warning "Monitoring stopped by user"
    fi
}

# Function to run predefined scenarios
run_scenario() {
    local scenario="$1"
    local interface="$2"
    
    case "$scenario" in
        "http")
            print_header "HTTP Traffic Analysis"
            capture_packets "$interface" 50 30 "tcp port 80" "$(generate_filename $interface http)" false
            analyze_packets "$(generate_filename $interface http)"
            ;;
        "dns")
            print_header "DNS Traffic Analysis"
            capture_packets "$interface" 30 20 "udp port 53" "$(generate_filename $interface dns)" false
            analyze_packets "$(generate_filename $interface dns)"
            ;;
        "ping")
            print_header "ICMP Traffic Analysis"
            capture_packets "$interface" 20 15 "icmp" "$(generate_filename $interface ping)" false
            analyze_packets "$(generate_filename $interface ping)"
            ;;
        "ssh")
            print_header "SSH Traffic Analysis"
            capture_packets "$interface" 20 15 "tcp port 22" "$(generate_filename $interface ssh)" false
            analyze_packets "$(generate_filename $interface ssh)"
            ;;
        "monitor")
            print_header "Real-time Traffic Monitoring"
            monitor_realtime "$interface" ""
            ;;
        *)
            print_error "Unknown scenario: $scenario"
            print_info "Available scenarios: http, dns, ping, ssh, monitor"
            return 1
            ;;
    esac
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--interface)
            INTERFACE="$2"
            shift 2
            ;;
        -c|--count)
            COUNT="$2"
            shift 2
            ;;
        -t|--timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        -f|--filter)
            FILTER="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -a|--analyze)
            ANALYZE=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        --scenario)
            SCENARIO="$2"
            shift 2
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Check if running as root
check_root

# Check if interface exists
check_interface "$INTERFACE"

# Generate output filename if not provided
if [ -z "$OUTPUT_FILE" ]; then
    OUTPUT_FILE=$(generate_filename "$INTERFACE" "$FILTER")
fi

# Run scenario if specified
if [ -n "$SCENARIO" ]; then
    run_scenario "$SCENARIO" "$INTERFACE"
    exit 0
fi

# Capture packets
if capture_packets "$INTERFACE" "$COUNT" "$TIMEOUT" "$FILTER" "$OUTPUT_FILE" "$VERBOSE"; then
    print_success "Packet capture completed successfully"
    
    # Analyze if requested
    if [ "$ANALYZE" = true ]; then
        analyze_packets "$OUTPUT_FILE"
    fi
    
    # Show file location
    print_info "Capture file: $OUTPUT_FILE"
    print_info "To analyze manually: tcpdump -r $OUTPUT_FILE -n"
    print_info "To analyze with Python tool: python3 /scripts/tcpdump-analyzer.py -f $OUTPUT_FILE"
    
else
    print_error "Packet capture failed"
    exit 1
fi
