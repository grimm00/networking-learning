#!/bin/bash

# Network Interface Configuration Lab
# Hands-on practice for network interface configuration and management

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
BACKUP_DIR="/tmp/interface-backup-$(date +%Y%m%d-%H%M%S)"
LOG_FILE="/tmp/interface-config-lab.log"

# Environment detection
IS_CONTAINER=false
IS_INTERACTIVE=false

# Detect if running in container
if [ -f /.dockerenv ] || [ -n "${DOCKER_CONTAINER:-}" ] || grep -q docker /proc/1/cgroup 2>/dev/null; then
    IS_CONTAINER=true
fi

# Detect if running interactively
if [ -t 0 ] && [ -t 1 ]; then
    IS_INTERACTIVE=true
fi

# Logging function
log() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
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
    echo -e "${CYAN}"
    echo "============================================================"
    echo "NETWORK INTERFACE CONFIGURATION LAB"
    echo "============================================================"
    echo -e "${NC}"
}

# Print section header
print_section() {
    echo -e "\n${YELLOW}=== $1 ===${NC}"
}

# Handle non-interactive mode
handle_non_interactive() {
    log "Running in non-interactive mode"
    
    if [ "$IS_CONTAINER" = true ]; then
        log "Container environment detected - using educational mode"
        echo -e "\n${YELLOW}📚 CONTAINER EDUCATIONAL MODE${NC}"
        echo "This lab is designed for real network interface configuration."
        echo "In a container environment, most interfaces are virtual and not configurable."
        echo ""
        echo "Available educational activities:"
        echo "1. Show current interface status"
        echo "2. Demonstrate interface commands (read-only)"
        echo "3. Show interface statistics"
        echo "4. Display routing information"
        echo ""
        
        # Show current configuration
        local interfaces
        interfaces=$(get_interfaces)
        if [ -n "$interfaces" ]; then
            local interface=$(echo "$interfaces" | head -1)
            log "Using interface: $interface"
            show_current_config "$interface"
        else
            log_warning "No suitable interfaces found for demonstration"
        fi
        
        echo ""
        echo "💡 For hands-on interface configuration practice:"
        echo "   - Use a virtual machine with real network interfaces"
        echo "   - Use the interface analyzer: python3 /scripts/interface-analyzer.py"
        echo "   - Use the troubleshoot script: /scripts/interface-troubleshoot.sh"
        
    else
        log "Non-interactive mode on host system"
        echo "This script requires interactive input. Please run with:"
        echo "  $0"
    fi
    
    return 0
}

# Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Get interface list
get_interfaces() {
    if command_exists ip; then
        # Get all interfaces and filter out problematic ones
        local all_interfaces
        all_interfaces=$(ip link show | grep -E '^[0-9]+:' | cut -d: -f2 | sed 's/^ *//')
        
        # Filter out loopback and Docker internal interfaces
        echo "$all_interfaces" | grep -v -E '^(lo|tunl0@|gre0@|gretap0@|erspan0@|ip_vti0@|ip6_vti0@|sit0@|ip6tnl0@|ip6gre0@|eth[0-9]+@)' | head -1
        
        # If no suitable interfaces found, use lo for educational purposes
        if [ -z "$(echo "$all_interfaces" | grep -v -E '^(lo|tunl0@|gre0@|gretap0@|erspan0@|ip_vti0@|ip6_vti0@|sit0@|ip6tnl0@|ip6gre0@|eth[0-9]+@)' | head -1)" ]; then
            echo "lo"
        fi
    elif command_exists ifconfig; then
        ifconfig -a | grep -E '^[a-zA-Z0-9]+:' | cut -d: -f1 | \
        grep -v -E '^(lo|tunl0|gre0|gretap0|erspan0|ip_vti0|ip6_vti0|sit0|ip6tnl0|ip6gre0)' | head -1
    else
        log_error "Neither 'ip' nor 'ifconfig' command found"
        return 1
    fi
}

# Backup current configuration
backup_config() {
    log "Creating backup of current configuration..."
    mkdir -p "$BACKUP_DIR"
    
    # Backup routing table
    if command_exists ip; then
        ip route show > "$BACKUP_DIR/routes.txt" 2>/dev/null || true
    elif command_exists route; then
        route -n > "$BACKUP_DIR/routes.txt" 2>/dev/null || true
    fi
    
    # Backup interface configurations
    for interface in $(get_interfaces); do
        if command_exists ip; then
            ip addr show "$interface" > "$BACKUP_DIR/${interface}_addr.txt" 2>/dev/null || true
            ip link show "$interface" > "$BACKUP_DIR/${interface}_link.txt" 2>/dev/null || true
        elif command_exists ifconfig; then
            ifconfig "$interface" > "$BACKUP_DIR/${interface}_config.txt" 2>/dev/null || true
        fi
    done
    
    # Backup DNS configuration
    cp /etc/resolv.conf "$BACKUP_DIR/resolv.conf" 2>/dev/null || true
    
    log_success "Configuration backed up to: $BACKUP_DIR"
}

# Restore configuration
restore_config() {
    log "Restoring configuration from backup..."
    
    if [ ! -d "$BACKUP_DIR" ]; then
        log_error "No backup directory found: $BACKUP_DIR"
        return 1
    fi
    
    # Restore DNS configuration
    if [ -f "$BACKUP_DIR/resolv.conf" ]; then
        cp "$BACKUP_DIR/resolv.conf" /etc/resolv.conf
        log_success "DNS configuration restored"
    fi
    
    # Restore routing table
    if [ -f "$BACKUP_DIR/routes.txt" ]; then
        # Clear current routes
        if command_exists ip; then
            ip route flush table main 2>/dev/null || true
        fi
        
        # Restore routes
        while read -r route; do
            if [ -n "$route" ]; then
                if command_exists ip; then
                    ip route add $route 2>/dev/null || true
                fi
            fi
        done < "$BACKUP_DIR/routes.txt"
        
        log_success "Routing table restored"
    fi
    
    log_success "Configuration restored from: $BACKUP_DIR"
}

# Show current configuration
show_current_config() {
    local interface="$1"
    print_section "Current Configuration: $interface"
    
    if command_exists ip; then
        echo "Interface Status:"
        ip link show "$interface" 2>/dev/null || log_error "Interface $interface not found"
        
        echo -e "\nIP Addresses:"
        ip addr show "$interface" 2>/dev/null || log_error "Interface $interface not found"
        
        echo -e "\nRoutes:"
        ip route show dev "$interface" 2>/dev/null || echo "No routes for $interface"
    elif command_exists ifconfig; then
        echo "Interface Configuration:"
        ifconfig "$interface" 2>/dev/null || log_error "Interface $interface not found"
    fi
}

# Lab 1: Basic Interface Management
lab1_basic_management() {
    print_section "Lab 1: Basic Interface Management"
    
    local interfaces
    interfaces=$(get_interfaces)
    
    if [ -z "$interfaces" ]; then
        log_error "No network interfaces found"
        return 1
    fi
    
    local interface=$(echo "$interfaces" | head -1)
    log "Using interface: $interface"
    
    echo -e "\n${CYAN}Step 1: Show current interface status${NC}"
    show_current_config "$interface"
    
    echo -e "\n${CYAN}Step 2: Bring interface down${NC}"
    if command_exists ip; then
        ip link set "$interface" down
        log_success "Interface $interface brought down"
    elif command_exists ifconfig; then
        ifconfig "$interface" down
        log_success "Interface $interface brought down"
    fi
    
    echo -e "\n${CYAN}Step 3: Show interface status after bringing down${NC}"
    show_current_config "$interface"
    
    echo -e "\n${CYAN}Step 4: Bring interface back up${NC}"
    if command_exists ip; then
        ip link set "$interface" up
        log_success "Interface $interface brought up"
    elif command_exists ifconfig; then
        ifconfig "$interface" up
        log_success "Interface $interface brought up"
    fi
    
    echo -e "\n${CYAN}Step 5: Verify interface is up${NC}"
    show_current_config "$interface"
    
    echo -e "\n${GREEN}Lab 1 Complete!${NC}"
    read -p "Press Enter to continue..."
}

# Lab 2: Static IP Configuration
lab2_static_ip() {
    print_section "Lab 2: Static IP Configuration"
    
    local interfaces
    interfaces=$(get_interfaces)
    
    if [ -z "$interfaces" ]; then
        log_error "No network interfaces found"
        return 1
    fi
    
    local interface=$(echo "$interfaces" | head -1)
    log "Using interface: $interface"
    
    echo -e "\n${CYAN}Step 1: Remove existing IP addresses${NC}"
    if command_exists ip; then
        ip addr flush dev "$interface"
        log_success "Cleared IP addresses from $interface"
    elif command_exists ifconfig; then
        ifconfig "$interface" 0.0.0.0
        log_success "Cleared IP addresses from $interface"
    fi
    
    echo -e "\n${CYAN}Step 2: Add static IP address${NC}"
    local static_ip="192.168.100.100/24"
    if command_exists ip; then
        ip addr add "$static_ip" dev "$interface"
        log_success "Added IP address $static_ip to $interface"
    elif command_exists ifconfig; then
        ifconfig "$interface" 192.168.100.100 netmask 255.255.255.0
        log_success "Added IP address 192.168.100.100/24 to $interface"
    fi
    
    echo -e "\n${CYAN}Step 3: Verify IP configuration${NC}"
    show_current_config "$interface"
    
    echo -e "\n${CYAN}Step 4: Test connectivity${NC}"
    if command_exists ping; then
        if ping -c 3 192.168.100.1 >/dev/null 2>&1; then
            log_success "Connectivity test passed"
        else
            log_warning "Connectivity test failed (expected if no gateway at 192.168.100.1)"
        fi
    fi
    
    echo -e "\n${GREEN}Lab 2 Complete!${NC}"
    read -p "Press Enter to continue..."
}

# Lab 3: Default Route Configuration
lab3_default_route() {
    print_section "Lab 3: Default Route Configuration"
    
    local interfaces
    interfaces=$(get_interfaces)
    
    if [ -z "$interfaces" ]; then
        log_error "No network interfaces found"
        return 1
    fi
    
    local interface=$(echo "$interfaces" | head -1)
    log "Using interface: $interface"
    
    echo -e "\n${CYAN}Step 1: Show current routing table${NC}"
    if command_exists ip; then
        ip route show
    elif command_exists route; then
        route -n
    fi
    
    echo -e "\n${CYAN}Step 2: Add default route${NC}"
    local gateway="192.168.100.1"
    if command_exists ip; then
        ip route add default via "$gateway" dev "$interface"
        log_success "Added default route via $gateway dev $interface"
    elif command_exists route; then
        route add default gw "$gateway" "$interface"
        log_success "Added default route via $gateway dev $interface"
    fi
    
    echo -e "\n${CYAN}Step 3: Verify routing table${NC}"
    if command_exists ip; then
        ip route show
    elif command_exists route; then
        route -n
    fi
    
    echo -e "\n${CYAN}Step 4: Test default route${NC}"
    if command_exists ping; then
        if ping -c 3 8.8.8.8 >/dev/null 2>&1; then
            log_success "Default route test passed"
        else
            log_warning "Default route test failed (expected if no internet access)"
        fi
    fi
    
    echo -e "\n${GREEN}Lab 3 Complete!${NC}"
    read -p "Press Enter to continue..."
}

# Lab 4: DNS Configuration
lab4_dns_config() {
    print_section "Lab 4: DNS Configuration"
    
    echo -e "\n${CYAN}Step 1: Show current DNS configuration${NC}"
    cat /etc/resolv.conf
    
    echo -e "\n${CYAN}Step 2: Backup current DNS configuration${NC}"
    cp /etc/resolv.conf "$BACKUP_DIR/resolv.conf.backup"
    log_success "DNS configuration backed up"
    
    echo -e "\n${CYAN}Step 3: Configure custom DNS servers${NC}"
    cat > /etc/resolv.conf << EOF
# Custom DNS configuration
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
EOF
    log_success "DNS servers configured"
    
    echo -e "\n${CYAN}Step 4: Verify DNS configuration${NC}"
    cat /etc/resolv.conf
    
    echo -e "\n${CYAN}Step 5: Test DNS resolution${NC}"
    if command_exists nslookup; then
        nslookup google.com
    elif command_exists dig; then
        dig google.com
    else
        log_warning "DNS testing tools not available"
    fi
    
    echo -e "\n${GREEN}Lab 4 Complete!${NC}"
    read -p "Press Enter to continue..."
}

# Lab 5: VLAN Configuration
lab5_vlan_config() {
    print_section "Lab 5: VLAN Configuration"
    
    local interfaces
    interfaces=$(get_interfaces)
    
    if [ -z "$interfaces" ]; then
        log_error "No network interfaces found"
        return 1
    fi
    
    local interface=$(echo "$interfaces" | head -1)
    log "Using interface: $interface"
    
    echo -e "\n${CYAN}Step 1: Check if VLAN module is loaded${NC}"
    if lsmod | grep -q 8021q; then
        log_success "VLAN module (8021q) is loaded"
    else
        log "Loading VLAN module..."
        modprobe 8021q
        log_success "VLAN module loaded"
    fi
    
    echo -e "\n${CYAN}Step 2: Create VLAN interface${NC}"
    local vlan_id="100"
    local vlan_interface="${interface}.${vlan_id}"
    
    if command_exists ip; then
        ip link add link "$interface" name "$vlan_interface" type vlan id "$vlan_id"
        log_success "Created VLAN interface $vlan_interface"
    else
        log_error "VLAN creation requires 'ip' command"
        return 1
    fi
    
    echo -e "\n${CYAN}Step 3: Configure VLAN interface${NC}"
    ip addr add 192.168.100.200/24 dev "$vlan_interface"
    ip link set "$vlan_interface" up
    log_success "VLAN interface configured and brought up"
    
    echo -e "\n${CYAN}Step 4: Verify VLAN configuration${NC}"
    ip link show "$vlan_interface"
    ip addr show "$vlan_interface"
    
    echo -e "\n${CYAN}Step 5: Clean up VLAN interface${NC}"
    ip link set "$vlan_interface" down
    ip link delete "$vlan_interface"
    log_success "VLAN interface removed"
    
    echo -e "\n${GREEN}Lab 5 Complete!${NC}"
    read -p "Press Enter to continue..."
}

# Lab 6: Interface Monitoring
lab6_interface_monitoring() {
    print_section "Lab 6: Interface Monitoring"
    
    local interfaces
    interfaces=$(get_interfaces)
    
    if [ -z "$interfaces" ]; then
        log_error "No network interfaces found"
        return 1
    fi
    
    local interface=$(echo "$interfaces" | head -1)
    log "Using interface: $interface"
    
    echo -e "\n${CYAN}Step 1: Show interface statistics${NC}"
    if [ -f "/proc/net/dev" ]; then
        echo "Interface Statistics:"
        cat /proc/net/dev | grep "$interface"
    else
        log_warning "Interface statistics not available"
    fi
    
    echo -e "\n${CYAN}Step 2: Monitor interface traffic${NC}"
    log "Monitoring interface $interface for 10 seconds..."
    if command_exists iftop; then
        timeout 10 iftop -i "$interface" || true
    else
        log_warning "iftop not available, using basic monitoring"
        for i in {1..10}; do
            if [ -f "/proc/net/dev" ]; then
                cat /proc/net/dev | grep "$interface" | awk '{print "RX:", $2, "TX:", $10}'
            fi
            sleep 1
        done
    fi
    
    echo -e "\n${CYAN}Step 3: Show interface errors${NC}"
    if [ -f "/proc/net/dev" ]; then
        cat /proc/net/dev | grep "$interface" | awk '{print "RX Errors:", $4, "TX Errors:", $12}'
    fi
    
    echo -e "\n${GREEN}Lab 6 Complete!${NC}"
    read -p "Press Enter to continue..."
}

# Show menu
show_menu() {
    echo -e "\n${CYAN}Network Interface Configuration Lab Menu${NC}"
    echo "=========================================="
    echo "1. Lab 1: Basic Interface Management"
    echo "2. Lab 2: Static IP Configuration"
    echo "3. Lab 3: Default Route Configuration"
    echo "4. Lab 4: DNS Configuration"
    echo "5. Lab 5: VLAN Configuration"
    echo "6. Lab 6: Interface Monitoring"
    echo "7. Show Current Configuration"
    echo "8. Restore Configuration"
    echo "9. Exit"
    echo ""
}

# Main function
main() {
    print_header
    
    # Check if running as root
    check_root
    
    # Create backup
    backup_config
    
    # Check if running non-interactively
    if [ "$IS_INTERACTIVE" = false ]; then
        handle_non_interactive
        return 0
    fi
    
    # Main loop
    while true; do
        show_menu
        read -t 30 -p "Select an option (1-9): " choice
        
        # Handle timeout or empty input
        if [ $? -ne 0 ] || [ -z "$choice" ]; then
            log_warning "No input received or timeout. Exiting..."
            break
        fi
        
        case $choice in
            1)
                lab1_basic_management
                ;;
            2)
                lab2_static_ip
                ;;
            3)
                lab3_default_route
                ;;
            4)
                lab4_dns_config
                ;;
            5)
                lab5_vlan_config
                ;;
            6)
                lab6_interface_monitoring
                ;;
            7)
                local interfaces
                interfaces=$(get_interfaces)
                if [ -n "$interfaces" ]; then
                    local interface=$(echo "$interfaces" | head -1)
                    show_current_config "$interface"
                fi
                read -p "Press Enter to continue..."
                ;;
            8)
                restore_config
                read -p "Press Enter to continue..."
                ;;
            9)
                log "Exiting lab..."
                break
                ;;
            *)
                log_error "Invalid option. Please select 1-9."
                ;;
        esac
    done
    
    log_success "Lab completed. Log saved to: $LOG_FILE"
    log "Backup directory: $BACKUP_DIR"
}

# Run main function
main "$@"
