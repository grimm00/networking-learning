#!/bin/bash

# DHCP Troubleshooting Script
# Comprehensive tool for diagnosing DHCP-related issues

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
LOG_FILE="/tmp/dhcp-troubleshoot.log"
OUTPUT_DIR="/tmp/dhcp-troubleshoot-output"

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
    echo "DHCP TROUBLESHOOTING TOOL"
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

# Check network interfaces
check_interfaces() {
    print_section "Network Interface Status"
    
    echo "Active network interfaces:"
    ip link show | grep -E "^[0-9]+:" | while read line; do
        interface=$(echo "$line" | cut -d: -f2 | sed 's/^ *//')
        state=$(echo "$line" | grep -o "state [A-Z]*" | cut -d' ' -f2)
        echo "  $interface: $state"
    done
    
    echo -e "\nIP addresses assigned:"
    ip addr show | grep -E "inet [0-9]" | while read line; do
        interface=$(echo "$line" | awk '{print $NF}')
        ip=$(echo "$line" | awk '{print $2}')
        echo "  $interface: $ip"
    done
}

# Check DHCP client status
check_dhcp_client() {
    print_section "DHCP Client Status"
    
    # Check if dhclient is running
    if pgrep -f dhclient > /dev/null; then
        log_success "DHCP client (dhclient) is running"
        echo "Active dhclient processes:"
        ps aux | grep dhclient | grep -v grep
    else
        log_warning "DHCP client (dhclient) is not running"
    fi
    
    # Check DHCP client configuration
    if [ -f "/etc/dhcp/dhcpcd.conf" ]; then
        echo -e "\nDHCP client configuration:"
        cat /etc/dhcp/dhcpcd.conf | grep -v "^#" | grep -v "^$"
    fi
    
    # Check for DHCP leases
    if [ -f "/var/lib/dhcp/dhcpcd.leases" ]; then
        echo -e "\nCurrent DHCP leases:"
        cat /var/lib/dhcp/dhcpcd.leases
    fi
}

# Test network connectivity
test_connectivity() {
    print_section "Network Connectivity Tests"
    
    # Get current IP and gateway
    local current_ip=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $7}' | head -1)
    local gateway=$(ip route | grep default | awk '{print $3}' | head -1)
    
    if [ -n "$current_ip" ]; then
        log "Current IP: $current_ip"
    else
        log_warning "No IP address assigned"
    fi
    
    if [ -n "$gateway" ]; then
        log "Default gateway: $gateway"
        
        echo -e "\nTesting gateway connectivity:"
        ping -c 3 -W 2 "$gateway" 2>/dev/null
        if [ $? -eq 0 ]; then
            log_success "Gateway is reachable"
        else
            log_error "Gateway is not reachable"
        fi
    else
        log_warning "No default gateway configured"
    fi
    
    # Test external connectivity
    echo -e "\nTesting external connectivity:"
    ping -c 3 -W 2 8.8.8.8 2>/dev/null
    if [ $? -eq 0 ]; then
        log_success "External connectivity working"
    else
        log_error "External connectivity failed"
    fi
}

# Check for DHCP servers
check_dhcp_servers() {
    print_section "DHCP Server Detection"
    
    echo "Scanning for DHCP servers..."
    
    # Method 1: Use nmap if available
    if command -v nmap &> /dev/null; then
        echo "Using nmap to scan for DHCP servers:"
        nmap -sU -p 67 --script broadcast-dhcp-discover 2>/dev/null || {
            log_warning "nmap DHCP script not available"
        }
    fi
    
    # Method 2: Capture DHCP traffic
    echo -e "\nCapturing DHCP traffic to identify servers..."
    local pcap_file="$OUTPUT_DIR/dhcp_servers_$(date +%Y%m%d_%H%M%S).pcap"
    
    # Start capture in background
    tcpdump -i any -n -s 0 port 67 or port 68 -w "$pcap_file" &
    local tcpdump_pid=$!
    
    # Wait for tcpdump to start
    sleep 2
    
    # Trigger DHCP request
    log "Triggering DHCP request..."
    dhclient -r 2>/dev/null
    sleep 1
    dhclient 2>/dev/null
    
    # Wait for DHCP process
    sleep 5
    
    # Stop capture
    kill $tcpdump_pid 2>/dev/null
    wait $tcpdump_pid 2>/dev/null
    
    # Analyze captured packets
    if [ -f "$pcap_file" ] && [ -s "$pcap_file" ]; then
        echo "DHCP servers found:"
        tshark -r "$pcap_file" -T fields -e ip.src -e dhcp.option.server_id 2>/dev/null | grep -v "^$" | sort | uniq || {
            log_warning "Could not analyze captured packets"
        }
    else
        log_warning "No DHCP traffic captured"
    fi
}

# Check for IP conflicts
check_ip_conflicts() {
    print_section "IP Conflict Detection"
    
    # Get current IP addresses
    local ips=$(ip addr show | grep -E "inet [0-9]" | awk '{print $2}' | cut -d'/' -f1)
    
    if [ -z "$ips" ]; then
        log_warning "No IP addresses found"
        return
    fi
    
    echo "Checking for IP conflicts..."
    
    for ip in $ips; do
        if [ "$ip" != "127.0.0.1" ]; then
            echo "Testing IP: $ip"
            ping -c 1 -W 1 "$ip" >/dev/null 2>&1
            if [ $? -eq 0 ]; then
                log_warning "Potential IP conflict detected for $ip"
            else
                log_success "No conflict detected for $ip"
            fi
        fi
    done
}

# Check DNS configuration
check_dns_config() {
    print_section "DNS Configuration Check"
    
    echo "Current DNS configuration:"
    cat /etc/resolv.conf
    
    echo -e "\nTesting DNS resolution:"
    
    # Test DNS resolution
    if nslookup google.com >/dev/null 2>&1; then
        log_success "DNS resolution working"
    else
        log_error "DNS resolution failed"
    fi
    
    # Check for multiple DNS servers
    local dns_count=$(grep -c "nameserver" /etc/resolv.conf)
    if [ "$dns_count" -gt 1 ]; then
        log "Multiple DNS servers configured: $dns_count"
    else
        log_warning "Only one DNS server configured"
    fi
}

# Check DHCP lease information
check_lease_info() {
    print_section "DHCP Lease Information"
    
    # Check for lease files
    local lease_files=(
        "/var/lib/dhcp/dhcpcd.leases"
        "/var/lib/dhcp/dhcpd.leases"
        "/var/lib/dhcpcd/dhcpcd.leases"
    )
    
    for lease_file in "${lease_files[@]}"; do
        if [ -f "$lease_file" ]; then
            echo "Found lease file: $lease_file"
            echo "Lease information:"
            cat "$lease_file"
            echo ""
        fi
    done
    
    # Check current lease status
    echo "Current network configuration:"
    ip addr show | grep -E "inet [0-9]" | while read line; do
        interface=$(echo "$line" | awk '{print $NF}')
        ip=$(echo "$line" | awk '{print $2}')
        echo "  $interface: $ip"
    done
}

# Test DHCP renewal
test_dhcp_renewal() {
    print_section "DHCP Renewal Test"
    
    echo "Testing DHCP lease renewal..."
    
    # Get current IP before renewal
    local old_ip=$(ip addr show | grep -E "inet [0-9]" | head -1 | awk '{print $2}')
    log "Current IP: $old_ip"
    
    # Release current lease
    log "Releasing current lease..."
    dhclient -r 2>/dev/null
    
    # Wait a moment
    sleep 2
    
    # Request new lease
    log "Requesting new lease..."
    dhclient -v 2>/dev/null
    
    # Wait for new lease
    sleep 5
    
    # Get new IP
    local new_ip=$(ip addr show | grep -E "inet [0-9]" | head -1 | awk '{print $2}')
    log "New IP: $new_ip"
    
    if [ "$old_ip" = "$new_ip" ]; then
        log_success "IP address maintained after renewal"
    else
        log_warning "IP address changed after renewal"
    fi
}

# Generate troubleshooting report
generate_report() {
    print_section "Generating Troubleshooting Report"
    
    local report_file="$OUTPUT_DIR/dhcp_troubleshoot_report_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "DHCP Troubleshooting Report"
        echo "Generated: $(date)"
        echo "========================================"
        echo ""
        
        echo "Network Interface Status:"
        ip link show
        echo ""
        
        echo "IP Address Configuration:"
        ip addr show
        echo ""
        
        echo "Routing Table:"
        ip route show
        echo ""
        
        echo "DNS Configuration:"
        cat /etc/resolv.conf
        echo ""
        
        echo "DHCP Client Processes:"
        ps aux | grep dhclient | grep -v grep
        echo ""
        
        echo "System Logs (DHCP related):"
        journalctl -u dhcpcd --no-pager 2>/dev/null || echo "DHCP logs not available"
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
    
    log "Starting DHCP troubleshooting..."
    
    # Run all checks
    check_interfaces
    check_dhcp_client
    test_connectivity
    check_dhcp_servers
    check_ip_conflicts
    check_dns_config
    check_lease_info
    test_dhcp_renewal
    
    # Generate report
    generate_report
    
    log_success "DHCP troubleshooting completed!"
    echo -e "\n${GREEN}Check the output directory for detailed results: $OUTPUT_DIR${NC}"
}

# Show help
show_help() {
    echo "DHCP Troubleshooting Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -v, --verbose  Enable verbose output"
    echo ""
    echo "This script performs comprehensive DHCP troubleshooting including:"
    echo "  - Network interface status check"
    echo "  - DHCP client status verification"
    echo "  - Network connectivity tests"
    echo "  - DHCP server detection"
    echo "  - IP conflict detection"
    echo "  - DNS configuration check"
    echo "  - Lease information analysis"
    echo "  - DHCP renewal testing"
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
