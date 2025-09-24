#!/bin/bash

# Netcat Lab Script
# Interactive learning environment for netcat network utility

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
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_step() {
    echo -e "\n${GREEN}Step $1: $2${NC}"
    echo -e "${CYAN}$3${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if netcat is available
check_netcat() {
    if ! command -v nc >/dev/null 2>&1; then
        print_error "Netcat is not installed or not in PATH"
        print_info "Install netcat with: apt-get install netcat-openbsd"
        exit 1
    fi
    
    print_success "Netcat is available"
    nc -h 2>&1 | head -1
}

# Get target from user
get_target() {
    echo -e "\n${CYAN}Enter target for testing:${NC}"
    echo "Examples:"
    echo "  - Localhost: localhost or 127.0.0.1"
    echo "  - IP address: 192.168.1.1"
    echo "  - Hostname: google.com"
    echo "  - Web server: 172.18.0.2 (if available)"
    echo ""
    read -p "Target: " TARGET
    
    if [ -z "$TARGET" ]; then
        print_error "Target cannot be empty"
        exit 1
    fi
    
    print_success "Target set to: $TARGET"
}

# Basic connectivity lab
basic_connectivity_lab() {
    print_header "BASIC CONNECTIVITY LAB"
    
    print_step "1" "Test Single Port" \
        "Test connectivity to a specific port"
    
    read -p "Enter port to test (default: 80): " PORT
    PORT=${PORT:-80}
    
    print_info "Running: nc -v -z $TARGET $PORT"
    echo ""
    nc -v -z "$TARGET" "$PORT"
    
    print_step "2" "Test Multiple Ports" \
        "Test connectivity to multiple ports"
    
    print_info "Running: nc -v -z $TARGET 22 80 443"
    echo ""
    nc -v -z "$TARGET" 22 80 443
    
    print_step "3" "Test Port Range" \
        "Test connectivity to a range of ports"
    
    print_info "Running: nc -v -z $TARGET 80-85"
    echo ""
    nc -v -z "$TARGET" 80-85
    
    print_step "4" "Test UDP Ports" \
        "Test UDP connectivity (DNS port 53)"
    
    print_info "Running: nc -u -v -z $TARGET 53"
    echo ""
    nc -u -v -z "$TARGET" 53
}

# Interactive connection lab
interactive_connection_lab() {
    print_header "INTERACTIVE CONNECTION LAB"
    
    print_step "1" "HTTP Connection Test" \
        "Connect to HTTP service and send manual request"
    
    print_info "Connecting to $TARGET:80..."
    echo "Type HTTP request manually, then press Ctrl+C to exit"
    echo "Example: GET / HTTP/1.1"
    echo "         Host: $TARGET"
    echo "         (blank line to send)"
    echo ""
    read -p "Press Enter to connect..."
    
    nc -v "$TARGET" 80
    
    print_step "2" "SSH Connection Test" \
        "Test SSH connection (if available)"
    
    print_info "Testing SSH connection to $TARGET:22..."
    nc -v "$TARGET" 22
}

# File transfer lab
file_transfer_lab() {
    print_header "FILE TRANSFER LAB"
    
    print_step "1" "Create Test File" \
        "Create a test file for transfer"
    
    TEST_FILE="/tmp/netcat_test_$(date +%s).txt"
    echo "This is a test file created at $(date)" > "$TEST_FILE"
    echo "File content: $(cat "$TEST_FILE")"
    print_success "Test file created: $TEST_FILE"
    
    print_step "2" "Set Up File Transfer" \
        "Start receiver in background, then send file"
    
    print_info "Starting file transfer test..."
    print_warning "This will start a receiver on port 1234"
    echo ""
    
    # Start receiver in background
    nc -l -p 1234 > "/tmp/received_$(date +%s).txt" &
    RECEIVER_PID=$!
    
    sleep 2
    
    # Send file
    print_info "Sending file to localhost:1234..."
    nc localhost 1234 < "$TEST_FILE"
    
    # Clean up
    kill $RECEIVER_PID 2>/dev/null || true
    rm -f "$TEST_FILE"
    
    print_success "File transfer test completed"
}

# Chat server lab
chat_server_lab() {
    print_header "CHAT SERVER LAB"
    
    print_step "1" "Start Chat Server" \
        "Start a simple chat server"
    
    print_info "Starting chat server on port 1234..."
    print_warning "Press Ctrl+C to stop the server"
    echo ""
    
    nc -l -p 1234
}

# Port scanning lab
port_scanning_lab() {
    print_header "PORT SCANNING LAB"
    
    print_step "1" "Scan Common Ports" \
        "Scan common service ports"
    
    COMMON_PORTS="22 23 25 53 80 110 143 443 993 995"
    print_info "Scanning common ports: $COMMON_PORTS"
    echo ""
    
    for port in $COMMON_PORTS; do
        echo -n "Port $port: "
        if nc -v -z "$TARGET" "$port" 2>/dev/null; then
            print_success "Open"
        else
            print_error "Closed"
        fi
    done
    
    print_step "2" "Scan Web Ports" \
        "Scan common web service ports"
    
    WEB_PORTS="80 443 8080 8443 8000 3000"
    print_info "Scanning web ports: $WEB_PORTS"
    echo ""
    
    for port in $WEB_PORTS; do
        echo -n "Port $port: "
        if nc -v -z "$TARGET" "$port" 2>/dev/null; then
            print_success "Open"
        else
            print_error "Closed"
        fi
    done
}

# Service testing lab
service_testing_lab() {
    print_header "SERVICE TESTING LAB"
    
    print_step "1" "HTTP Service Test" \
        "Test HTTP service with manual request"
    
    print_info "Testing HTTP service on $TARGET:80..."
    echo "Sending HTTP GET request..."
    echo ""
    
    echo -e "GET / HTTP/1.1\r\nHost: $TARGET\r\n\r\n" | nc "$TARGET" 80
    
    print_step "2" "SMTP Service Test" \
        "Test SMTP service (if available)"
    
    print_info "Testing SMTP service on $TARGET:25..."
    echo "Sending SMTP commands..."
    echo ""
    
    echo -e "EHLO test.com\r\nQUIT\r\n" | nc "$TARGET" 25
}

# Advanced techniques lab
advanced_techniques_lab() {
    print_header "ADVANCED TECHNIQUES LAB"
    
    print_step "1" "Persistent Server" \
        "Create a persistent server that stays open"
    
    print_info "Starting persistent server on port 1234..."
    print_warning "This server will stay open for multiple connections"
    print_warning "Press Ctrl+C to stop"
    echo ""
    
    nc -k -l -p 1234
    
    print_step "2" "UDP Communication" \
        "Test UDP communication"
    
    print_info "Testing UDP communication on port 1234..."
    print_warning "Start UDP server in another terminal: nc -u -l -p 1234"
    echo ""
    read -p "Press Enter after starting UDP server..."
    
    nc -u localhost 1234
}

# Network debugging lab
network_debugging_lab() {
    print_header "NETWORK DEBUGGING LAB"
    
    print_step "1" "Connection Timeout Test" \
        "Test connection with timeout"
    
    print_info "Testing connection with 5-second timeout..."
    nc -w 5 "$TARGET" 80
    
    print_step "2" "Verbose Connection Test" \
        "Test connection with verbose output"
    
    print_info "Testing connection with verbose output..."
    nc -v "$TARGET" 80
    
    print_step "3" "Source Port Test" \
        "Test connection from specific source port"
    
    print_info "Testing connection from source port 1234..."
    nc -p 1234 "$TARGET" 80
}

# Interactive menu
show_menu() {
    echo -e "\n${PURPLE}NETCAT LAB MENU${NC}"
    echo "================"
    echo "1. Basic Connectivity Lab"
    echo "2. Interactive Connection Lab"
    echo "3. File Transfer Lab"
    echo "4. Chat Server Lab"
    echo "5. Port Scanning Lab"
    echo "6. Service Testing Lab"
    echo "7. Advanced Techniques Lab"
    echo "8. Network Debugging Lab"
    echo "9. Run All Labs"
    echo "10. Custom Netcat Command"
    echo "0. Exit"
    echo ""
}

# Custom command function
custom_command() {
    print_header "CUSTOM NETCAT COMMAND"
    
    echo -e "${CYAN}Enter custom netcat command (without target):${NC}"
    echo "Examples:"
    echo "  -v -z 80"
    echo "  -u -v -z 53"
    echo "  -l -p 1234"
    echo "  -w 5 80"
    echo ""
    read -p "Command: " CUSTOM_CMD
    
    if [ -z "$CUSTOM_CMD" ]; then
        print_error "Command cannot be empty"
        return
    fi
    
    print_info "Running: nc $CUSTOM_CMD $TARGET"
    echo ""
    nc $CUSTOM_CMD "$TARGET"
}

# Run all labs
run_all_labs() {
    print_header "RUNNING ALL LABS"
    
    basic_connectivity_lab
    interactive_connection_lab
    file_transfer_lab
    port_scanning_lab
    service_testing_lab
    advanced_techniques_lab
    network_debugging_lab
    
    print_success "All labs completed!"
}

# Main function
main() {
    print_header "NETCAT LEARNING LAB"
    print_info "Interactive netcat networking exercises"
    print_warning "Only test networks you own or have permission to test!"
    
    # Check prerequisites
    check_netcat
    get_target
    
    # Main loop
    while true; do
        show_menu
        read -p "Select option (0-10): " choice
        
        case $choice in
            1) basic_connectivity_lab ;;
            2) interactive_connection_lab ;;
            3) file_transfer_lab ;;
            4) chat_server_lab ;;
            5) port_scanning_lab ;;
            6) service_testing_lab ;;
            7) advanced_techniques_lab ;;
            8) network_debugging_lab ;;
            9) run_all_labs ;;
            10) custom_command ;;
            0) 
                print_success "Exiting netcat lab"
                exit 0
                ;;
            *)
                print_error "Invalid option. Please select 0-10."
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Run main function
main "$@"
