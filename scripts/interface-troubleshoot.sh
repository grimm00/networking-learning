#!/bin/bash

# Network Interface Troubleshooting Script
# Comprehensive diagnostic tool for network interface issues

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
LOG_FILE="/tmp/interface-troubleshoot.log"
TIMEOUT=10

# Logging function
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

# Error logging function
log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

# Warning logging function
log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

# Success logging function
log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

# Print header
print_header() {
    echo -e "${BLUE}"
    echo "============================================================"
    echo "NETWORK INTERFACE TROUBLESHOOTING SCRIPT"
    echo "============================================================"
    echo -e "${NC}"
}

# Print section header
print_section() {
    echo -e "\n${YELLOW}=== $1 ===${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Get interface list
get_interfaces() {
    if command_exists ip; then
        ip link show | grep -E '^[0-9]+:' | cut -d: -f2 | sed 's/^ *//' | grep -v '^lo$'
    elif command_exists ifconfig; then
        ifconfig -a | grep -E '^[a-zA-Z0-9]+:' | cut -d: -f1 | grep -v '^lo$'
    else
        log_error "Neither 'ip' nor 'ifconfig' command found"
        return 1
    fi
}

# Check interface status
check_interface_status() {
    local interface="$1"
    log "Checking status of interface: $interface"
    
    if command_exists ip; then
        local status=$(ip link show "$interface" 2>/dev/null | grep -o 'state [A-Z]*' | cut -d' ' -f2)
        if [ "$status" = "UP" ]; then
            log_success "Interface $interface is UP"
            return 0
        else
            log_error "Interface $interface is DOWN"
            return 1
        fi
    elif command_exists ifconfig; then
        if ifconfig "$interface" 2>/dev/null | grep -q "status: active"; then
            log_success "Interface $interface is UP"
            return 0
        else
            log_error "Interface $interface is DOWN"
            return 1
        fi
    fi
}

# Check interface configuration
check_interface_config() {
    local interface="$1"
    log "Checking configuration of interface: $interface"
    
    # Check IP address
    if command_exists ip; then
        local ip_addr=$(ip addr show "$interface" 2>/dev/null | grep -o 'inet [0-9.]*' | cut -d' ' -f2 | head -1)
    elif command_exists ifconfig; then
        local ip_addr=$(ifconfig "$interface" 2>/dev/null | grep -o 'inet [0-9.]*' | cut -d' ' -f2 | head -1)
    fi
    
    if [ -n "$ip_addr" ]; then
        log_success "Interface $interface has IP address: $ip_addr"
    else
        log_warning "Interface $interface has no IP address"
    fi
    
    # Check MTU
    if command_exists ip; then
        local mtu=$(ip link show "$interface" 2>/dev/null | grep -o 'mtu [0-9]*' | cut -d' ' -f2)
    elif command_exists ifconfig; then
        local mtu=$(ifconfig "$interface" 2>/dev/null | grep -o 'mtu [0-9]*' | cut -d' ' -f2)
    fi
    
    if [ -n "$mtu" ]; then
        log "Interface $interface MTU: $mtu"
    fi
    
    # Check MAC address
    if command_exists ip; then
        local mac=$(ip link show "$interface" 2>/dev/null | grep -o 'link/ether [a-f0-9:]*' | cut -d' ' -f2)
    elif command_exists ifconfig; then
        local mac=$(ifconfig "$interface" 2>/dev/null | grep -o 'ether [a-f0-9:]*' | cut -d' ' -f2)
    fi
    
    if [ -n "$mac" ]; then
        log "Interface $interface MAC: $mac"
    fi
}

# Check interface errors
check_interface_errors() {
    local interface="$1"
    log "Checking errors for interface: $interface"
    
    if [ -f "/proc/net/dev" ]; then
        local errors=$(grep "$interface:" /proc/net/dev 2>/dev/null | awk '{print $4, $12}')
        if [ -n "$errors" ]; then
            local rx_errors=$(echo "$errors" | awk '{print $1}')
            local tx_errors=$(echo "$errors" | awk '{print $2}')
            
            if [ "$rx_errors" -gt 0 ] || [ "$tx_errors" -gt 0 ]; then
                log_warning "Interface $interface has errors - RX: $rx_errors, TX: $tx_errors"
            else
                log_success "Interface $interface has no errors"
            fi
        fi
    else
        log_warning "Cannot check interface errors (no /proc/net/dev)"
    fi
}

# Test connectivity
test_connectivity() {
    local interface="$1"
    local target="${2:-8.8.8.8}"
    
    log "Testing connectivity from interface $interface to $target"
    
    # Test with ping
    if command_exists ping; then
        if timeout "$TIMEOUT" ping -c 3 -I "$interface" "$target" >/dev/null 2>&1; then
            log_success "Ping test from $interface to $target: SUCCESS"
            return 0
        else
            log_error "Ping test from $interface to $target: FAILED"
            return 1
        fi
    else
        log_warning "Ping command not available"
        return 1
    fi
}

# Check routing
check_routing() {
    local interface="$1"
    log "Checking routing for interface: $interface"
    
    if command_exists ip; then
        local routes=$(ip route show dev "$interface" 2>/dev/null)
        if [ -n "$routes" ]; then
            log_success "Interface $interface has routes configured"
            echo "$routes" | while read -r route; do
                log "  Route: $route"
            done
        else
            log_warning "Interface $interface has no routes configured"
        fi
    elif command_exists route; then
        local routes=$(route -n | grep "$interface")
        if [ -n "$routes" ]; then
            log_success "Interface $interface has routes configured"
            echo "$routes" | while read -r route; do
                log "  Route: $route"
            done
        else
            log_warning "Interface $interface has no routes configured"
        fi
    fi
}

# Check DNS resolution
check_dns() {
    log "Checking DNS resolution"
    
    if command_exists nslookup; then
        if timeout "$TIMEOUT" nslookup google.com >/dev/null 2>&1; then
            log_success "DNS resolution: SUCCESS"
        else
            log_error "DNS resolution: FAILED"
        fi
    elif command_exists dig; then
        if timeout "$TIMEOUT" dig google.com >/dev/null 2>&1; then
            log_success "DNS resolution: SUCCESS"
        else
            log_error "DNS resolution: FAILED"
        fi
    else
        log_warning "DNS tools not available"
    fi
}

# Check network services
check_network_services() {
    log "Checking network services"
    
    # Check if NetworkManager is running
    if command_exists systemctl; then
        if systemctl is-active NetworkManager >/dev/null 2>&1; then
            log_success "NetworkManager is running"
        else
            log_warning "NetworkManager is not running"
        fi
    fi
    
    # Check if networking is enabled
    if command_exists systemctl; then
        if systemctl is-enabled networking >/dev/null 2>&1; then
            log_success "Networking service is enabled"
        else
            log_warning "Networking service is not enabled"
        fi
    fi
}

# Check for IP conflicts
check_ip_conflicts() {
    local interface="$1"
    log "Checking for IP conflicts on interface: $interface"
    
    if command_exists ip; then
        local ip_addr=$(ip addr show "$interface" 2>/dev/null | grep -o 'inet [0-9.]*' | cut -d' ' -f2 | head -1)
    elif command_exists ifconfig; then
        local ip_addr=$(ifconfig "$interface" 2>/dev/null | grep -o 'inet [0-9.]*' | cut -d' ' -f2 | head -1)
    fi
    
    if [ -n "$ip_addr" ]; then
        # Extract network address
        local network=$(echo "$ip_addr" | cut -d. -f1-3).0/24
        
        # Check for duplicate IPs
        if command_exists arping; then
            if timeout "$TIMEOUT" arping -I "$interface" -c 1 "$ip_addr" >/dev/null 2>&1; then
                log_warning "Potential IP conflict detected for $ip_addr"
            else
                log_success "No IP conflict detected for $ip_addr"
            fi
        else
            log_warning "arping not available for conflict detection"
        fi
    fi
}

# Check interface driver
check_interface_driver() {
    local interface="$1"
    log "Checking driver for interface: $interface"
    
    if [ -f "/sys/class/net/$interface/device/driver" ]; then
        local driver=$(readlink "/sys/class/net/$interface/device/driver" | xargs basename)
        log "Interface $interface driver: $driver"
    else
        log_warning "Cannot determine driver for interface $interface"
    fi
}

# Check interface speed and duplex
check_interface_speed() {
    local interface="$1"
    log "Checking speed and duplex for interface: $interface"
    
    if command_exists ethtool; then
        local speed_info=$(ethtool "$interface" 2>/dev/null | grep -E "(Speed|Duplex)")
        if [ -n "$speed_info" ]; then
            log "Interface $interface speed info:"
            echo "$speed_info" | while read -r line; do
                log "  $line"
            done
        else
            log_warning "Cannot get speed information for interface $interface"
        fi
    else
        log_warning "ethtool not available for speed checking"
    fi
}

# Generate recommendations
generate_recommendations() {
    local interface="$1"
    log "Generating recommendations for interface: $interface"
    
    echo -e "\n${YELLOW}RECOMMENDATIONS:${NC}"
    
    # Check if interface is down
    if ! check_interface_status "$interface" >/dev/null 2>&1; then
        echo "1. Bring interface up: sudo ip link set $interface up"
    fi
    
    # Check if no IP address
    if command_exists ip; then
        local ip_addr=$(ip addr show "$interface" 2>/dev/null | grep -o 'inet [0-9.]*' | cut -d' ' -f2 | head -1)
    elif command_exists ifconfig; then
        local ip_addr=$(ifconfig "$interface" 2>/dev/null | grep -o 'inet [0-9.]*' | cut -d' ' -f2 | head -1)
    fi
    
    if [ -z "$ip_addr" ]; then
        echo "2. Configure IP address: sudo ip addr add 192.168.1.100/24 dev $interface"
        echo "3. Or enable DHCP: sudo dhclient $interface"
    fi
    
    # Check if no default route
    if ! ip route show | grep -q "default"; then
        echo "4. Add default route: sudo ip route add default via 192.168.1.1 dev $interface"
    fi
    
    # Check if DNS is not working
    if ! timeout "$TIMEOUT" nslookup google.com >/dev/null 2>&1; then
        echo "5. Configure DNS: echo 'nameserver 8.8.8.8' | sudo tee /etc/resolv.conf"
    fi
    
    echo "6. Restart network service: sudo systemctl restart NetworkManager"
    echo "7. Check cable connection and switch/router status"
}

# Main troubleshooting function
troubleshoot_interface() {
    local interface="$1"
    
    print_section "Troubleshooting Interface: $interface"
    
    # Basic checks
    check_interface_status "$interface"
    check_interface_config "$interface"
    check_interface_errors "$interface"
    check_interface_driver "$interface"
    check_interface_speed "$interface"
    
    # Network checks
    check_routing "$interface"
    check_ip_conflicts "$interface"
    
    # Connectivity tests
    test_connectivity "$interface"
    
    # Generate recommendations
    generate_recommendations "$interface"
}

# Troubleshoot all interfaces
troubleshoot_all() {
    print_section "Troubleshooting All Interfaces"
    
    local interfaces
    interfaces=$(get_interfaces)
    
    if [ -z "$interfaces" ]; then
        log_error "No network interfaces found"
        return 1
    fi
    
    log "Found interfaces: $interfaces"
    
    for interface in $interfaces; do
        troubleshoot_interface "$interface"
        echo ""
    done
    
    # Global checks
    check_dns
    check_network_services
}

# Show usage
show_usage() {
    echo "Usage: $0 [OPTIONS] [INTERFACE]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -a, --all      Troubleshoot all interfaces"
    echo "  -v, --verbose  Verbose output"
    echo "  -l, --log      Show log file location"
    echo ""
    echo "Examples:"
    echo "  $0                    # Troubleshoot all interfaces"
    echo "  $0 eth0               # Troubleshoot specific interface"
    echo "  $0 --all              # Troubleshoot all interfaces"
    echo "  $0 --verbose eth0     # Verbose troubleshooting"
}

# Main function
main() {
    local interface=""
    local troubleshoot_all_flag=false
    local verbose=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -a|--all)
                troubleshoot_all_flag=true
                shift
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            -l|--log)
                echo "Log file: $LOG_FILE"
                exit 0
                ;;
            -*)
                echo "Unknown option: $1"
                show_usage
                exit 1
                ;;
            *)
                interface="$1"
                shift
                ;;
        esac
    done
    
    # Initialize log file
    echo "Network Interface Troubleshooting Log - $(date)" > "$LOG_FILE"
    
    # Print header
    print_header
    
    # Run troubleshooting
    if [ "$troubleshoot_all_flag" = true ] || [ -z "$interface" ]; then
        troubleshoot_all
    else
        troubleshoot_interface "$interface"
    fi
    
    log_success "Troubleshooting completed. Log saved to: $LOG_FILE"
}

# Run main function
main "$@"
