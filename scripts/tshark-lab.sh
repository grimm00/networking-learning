#!/bin/bash
# Tshark Interactive Lab
# Comprehensive hands-on exercises for packet analysis

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print functions
print_header() {
    echo -e "\n${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check if tshark is available
check_tshark() {
    if ! command -v tshark &> /dev/null; then
        print_error "Tshark is not installed or not in PATH"
        print_info "Installing tshark..."
        apt-get update && apt-get install -y tshark
    else
        print_success "Tshark is available"
        tshark --version | head -1
    fi
}

# List available interfaces
list_interfaces() {
    print_header "Available Capture Interfaces"
    tshark -D
    echo ""
}

# Basic capture exercises
basic_capture() {
    print_header "Basic Packet Capture"
    
    echo "1. Capturing 10 packets on any interface..."
    print_info "Press Ctrl+C to stop early"
    tshark -i any -c 10
    
    echo -e "\n2. Capturing HTTP traffic only..."
    print_info "This will capture packets on port 80"
    timeout 10 tshark -i any -f "port 80" -c 5 || true
    
    echo -e "\n3. Capturing with display filter..."
    print_info "This will show only HTTP packets"
    timeout 10 tshark -i any -Y "http" -c 5 || true
}

# Protocol analysis exercises
protocol_analysis() {
    print_header "Protocol Analysis"
    
    echo "1. Analyzing HTTP traffic..."
    print_info "Capturing HTTP requests and responses"
    timeout 15 tshark -i any -Y "http" -c 10 || true
    
    echo -e "\n2. Analyzing DNS traffic..."
    print_info "Capturing DNS queries and responses"
    timeout 15 tshark -i any -Y "dns" -c 5 || true
    
    echo -e "\n3. Analyzing TCP handshake..."
    print_info "Capturing TCP connection establishment"
    timeout 15 tshark -i any -Y "tcp.flags.syn == 1" -c 5 || true
    
    echo -e "\n4. Analyzing ICMP traffic..."
    print_info "Capturing ping packets"
    timeout 15 tshark -i any -Y "icmp" -c 5 || true
}

# Statistical analysis
statistical_analysis() {
    print_header "Statistical Analysis"
    
    echo "1. Protocol hierarchy statistics..."
    print_info "Showing protocol distribution"
    timeout 10 tshark -i any -q -z io,phs -c 20 || true
    
    echo -e "\n2. Conversation statistics..."
    print_info "Showing network conversations"
    timeout 10 tshark -i any -q -z conv,tcp -c 20 || true
    
    echo -e "\n3. Endpoint statistics..."
    print_info "Showing network endpoints"
    timeout 10 tshark -i any -q -z endpoints,ip -c 20 || true
    
    echo -e "\n4. HTTP statistics..."
    print_info "Showing HTTP traffic statistics"
    timeout 10 tshark -i any -q -z http,tree -c 20 || true
}

# Advanced filtering
advanced_filtering() {
    print_header "Advanced Filtering"
    
    echo "1. Capture filter examples..."
    print_info "Different capture filters"
    
    echo "   - TCP traffic only:"
    timeout 5 tshark -i any -f "tcp" -c 3 || true
    
    echo "   - UDP traffic only:"
    timeout 5 tshark -i any -f "udp" -c 3 || true
    
    echo "   - Specific host:"
    timeout 5 tshark -i any -f "host 8.8.8.8" -c 3 || true
    
    echo -e "\n2. Display filter examples..."
    print_info "Different display filters"
    
    echo "   - HTTP requests only:"
    timeout 5 tshark -i any -Y "http.request" -c 3 || true
    
    echo "   - DNS queries only:"
    timeout 5 tshark -i any -Y "dns.flags.response == 0" -c 3 || true
    
    echo "   - TCP errors:"
    timeout 5 tshark -i any -Y "tcp.analysis.flags" -c 3 || true
}

# File operations
file_operations() {
    print_header "File Operations"
    
    local capture_file="tshark_lab_capture.pcap"
    
    echo "1. Capturing to file..."
    print_info "Capturing 20 packets to $capture_file"
    tshark -i any -w "$capture_file" -c 20
    
    if [ -f "$capture_file" ]; then
        print_success "Capture file created: $capture_file"
        
        echo -e "\n2. Reading from file..."
        print_info "Reading captured packets"
        tshark -r "$capture_file"
        
        echo -e "\n3. Reading with filter..."
        print_info "Reading only HTTP packets"
        tshark -r "$capture_file" -Y "http"
        
        echo -e "\n4. Exporting to different formats..."
        print_info "Exporting to CSV"
        tshark -r "$capture_file" -T fields -e frame.number -e ip.src -e ip.dst -E header=y -E separator=, > tshark_export.csv
        
        if [ -f "tshark_export.csv" ]; then
            print_success "CSV export created: tshark_export.csv"
            echo "First few lines:"
            head -5 tshark_export.csv
        fi
        
        echo -e "\n5. Cleaning up..."
        rm -f "$capture_file" tshark_export.csv
        print_success "Temporary files cleaned up"
    else
        print_error "Failed to create capture file"
    fi
}

# Performance monitoring
performance_monitoring() {
    print_header "Performance Monitoring"
    
    echo "1. Real-time statistics..."
    print_info "Monitoring network activity (10 seconds)"
    timeout 10 tshark -i any -q -z io,stat,1 || true
    
    echo -e "\n2. Bandwidth monitoring..."
    print_info "Monitoring bandwidth usage"
    timeout 10 tshark -i any -q -z io,stat,1 || true
    
    echo -e "\n3. Error detection..."
    print_info "Looking for network errors"
    timeout 10 tshark -i any -Y "tcp.analysis.flags" -c 5 || true
}

# Security analysis
security_analysis() {
    print_header "Security Analysis"
    
    echo "1. Suspicious traffic detection..."
    print_info "Looking for unusual patterns"
    timeout 10 tshark -i any -Y "tcp.flags.syn == 1 and tcp.flags.ack == 0" -c 5 || true
    
    echo -e "\n2. Port scan detection..."
    print_info "Detecting potential port scans"
    timeout 10 tshark -i any -Y "tcp.flags.syn == 1" -c 10 || true
    
    echo -e "\n3. Connection resets..."
    print_info "Looking for connection resets"
    timeout 10 tshark -i any -Y "tcp.flags.reset == 1" -c 5 || true
}

# Troubleshooting exercises
troubleshooting() {
    print_header "Troubleshooting Exercises"
    
    echo "1. Connection issues..."
    print_info "Checking for connection problems"
    timeout 10 tshark -i any -Y "tcp.flags.reset == 1" -c 5 || true
    
    echo -e "\n2. Performance issues..."
    print_info "Checking for retransmissions"
    timeout 10 tshark -i any -Y "tcp.analysis.retransmission" -c 5 || true
    
    echo -e "\n3. DNS resolution issues..."
    print_info "Checking DNS queries"
    timeout 10 tshark -i any -Y "dns" -c 5 || true
}

# Interactive menu
show_menu() {
    print_header "Tshark Interactive Lab"
    echo "1. Check Tshark Installation"
    echo "2. List Interfaces"
    echo "3. Basic Capture"
    echo "4. Protocol Analysis"
    echo "5. Statistical Analysis"
    echo "6. Advanced Filtering"
    echo "7. File Operations"
    echo "8. Performance Monitoring"
    echo "9. Security Analysis"
    echo "10. Troubleshooting"
    echo "11. Run All Exercises"
    echo "12. Exit"
    echo ""
}

# Run all exercises
run_all_exercises() {
    print_header "Running All Tshark Exercises"
    
    check_tshark
    list_interfaces
    basic_capture
    protocol_analysis
    statistical_analysis
    advanced_filtering
    file_operations
    performance_monitoring
    security_analysis
    troubleshooting
    
    print_success "All exercises completed!"
}

# Main function
main() {
    print_header "Welcome to Tshark Interactive Lab"
    print_info "This lab provides hands-on exercises for packet analysis"
    print_warning "Make sure you have permission to capture network traffic"
    
    while true; do
        show_menu
        read -p "Choose an option (1-12): " choice
        
        case $choice in
            1)
                check_tshark
                ;;
            2)
                list_interfaces
                ;;
            3)
                basic_capture
                ;;
            4)
                protocol_analysis
                ;;
            5)
                statistical_analysis
                ;;
            6)
                advanced_filtering
                ;;
            7)
                file_operations
                ;;
            8)
                performance_monitoring
                ;;
            9)
                security_analysis
                ;;
            10)
                troubleshooting
                ;;
            11)
                run_all_exercises
                ;;
            12)
                print_success "Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid option. Please choose 1-12."
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Check if running in container
if [ -f /.dockerenv ]; then
    print_info "Running in container environment"
else
    print_warning "Not running in container - ensure you have proper permissions"
fi

# Run main function
main
