#!/bin/bash

# Containerized Networking Practice Script
# This script helps you practice networking commands safely in containers

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
    print_success "Docker is running"
}

# Function to start the networking environment
start_environment() {
    print_header "Starting Core Networking Practice Environment"
    
    # Start core networking containers only
    docker-compose up -d
    
    # Wait for containers to be ready
    print_warning "Waiting for containers to initialize..."
    sleep 10
    
    # Check container status
    print_header "Container Status"
    docker-compose ps
    
    print_success "Environment started successfully!"
}

# Function to stop the environment
stop_environment() {
    print_header "Stopping Networking Practice Environment"
    docker-compose down
    print_success "Environment stopped"
}

# Function to show available practice scenarios
show_scenarios() {
    print_header "Available Practice Scenarios"
    
    echo "1. Basic Connectivity Testing"
    echo "   - ping, traceroute, netstat"
    echo "   - Container: net-practice"
    
    echo ""
    echo "2. Network Configuration"
    echo "   - ip addr, ip route, ifconfig"
    echo "   - Container: net-practice"
    
    echo ""
    echo "3. Firewall and Security"
    echo "   - iptables, ufw, netfilter"
    echo "   - Container: firewall-test"
    
    echo ""
    echo "4. Routing and Forwarding"
    echo "   - ip route, route, routing tables"
    echo "   - Container: router"
    
    echo ""
    echo "5. Service Discovery"
    echo "   - nslookup, dig, DNS resolution"
    echo "   - Container: net-practice"
    
    echo ""
    echo "6. Packet Analysis"
    echo "   - tcpdump, wireshark, packet capture"
    echo "   - Container: net-practice"
    
    echo ""
    echo "7. DNS Analysis"
    echo "   - dns-analyzer.py, dns-troubleshoot.sh"
    echo "   - Container: net-practice"
    
    echo ""
    echo "8. SSH Analysis"
    echo "   - ssh-analyzer.py, ssh-troubleshoot.sh"
    echo "   - Container: net-practice"
    
    echo ""
    echo "9. NTP Analysis"
    echo "   - ntp-analyzer.py, ntp-troubleshoot.sh"
    echo "   - Container: net-practice"
    
    echo ""
    echo "10. All Project Scripts"
    echo "   - Python tools: /scripts/*.py"
    echo "   - Shell scripts: /scripts/*.sh"
    echo "   - Container: net-practice"
}

# Function to enter practice container
enter_practice() {
    local container=${1:-net-practice}
    
    print_header "Entering Practice Container: $container"
    print_warning "You can now run networking commands safely!"
    print_warning "Type 'exit' to return to host system"
    print_info "The 'run' command is available for easy script execution"
    print_info "Try: run help or run list"
    echo ""
    
    docker exec -it $container /scripts/start-with-run.sh
}

# Function to run specific practice exercises
run_exercises() {
    local container=${1:-net-practice}
    
    print_header "Running Practice Exercises in $container"
    
    echo "Exercise 1: Basic Connectivity"
    docker exec $container bash -c "
        echo 'Testing ping to Google...'
        ping -c 3 8.8.8.8
        echo ''
        echo 'Testing traceroute...'
        traceroute -n 8.8.8.8
    "
    
    echo ""
    echo "Exercise 2: Network Interfaces"
    docker exec $container bash -c "
        echo 'Network interfaces:'
        ip addr show
        echo ''
        echo 'Routing table:'
        ip route show
    "
    
    echo ""
    echo "Exercise 3: Active Connections"
    docker exec $container bash -c "
        echo 'Active connections:'
        netstat -tuln
        echo ''
        echo 'Using ss command:'
        ss -tuln
    "
}

# Function to show container network info
show_network_info() {
    print_header "Container Network Information"
    
    echo "Container IPs:"
    docker inspect $(docker-compose ps -q) | jq -r '.[] | "\(.Name): \(.NetworkSettings.IPAddress)"' 2>/dev/null || {
        echo "net-practice: $(docker inspect net-practice --format='{{.NetworkSettings.IPAddress}}')"
        echo "web-server: $(docker inspect web-server --format='{{.NetworkSettings.IPAddress}}')"
        echo "database: $(docker inspect database --format='{{.NetworkSettings.IPAddress}}')"
        echo "router: $(docker inspect router --format='{{.NetworkSettings.IPAddress}}')"
    }
    
    echo ""
    echo "Docker Networks:"
    docker network ls
    
    echo ""
    echo "Network Details:"
    docker network inspect networking_frontend
    docker network inspect networking_backend
}

# Function to run specific command in container
run_command() {
    local container=${1:-net-practice}
    local command=${2:-"ip addr show"}
    
    print_header "Running Command in $container"
    print_warning "Command: $command"
    echo ""
    
    docker exec $container bash -c "$command"
}

# Function to run DNS analysis tools
run_dns_analysis() {
    local container=${1:-net-practice}
    local domain=${2:-"google.com"}
    
    print_header "Running DNS Analysis for $domain"
    
    echo "🔍 DNS Analyzer (Python):"
    docker exec $container python3 /scripts/dns-analyzer.py $domain
    
    echo ""
    echo "🛠️ DNS Troubleshoot (Shell):"
    docker exec $container /scripts/dns-troubleshoot.sh -a $domain
}

# Function to run SSH analysis tools
run_ssh_analysis() {
    local container=${1:-net-practice}
    local host=${2:-"localhost"}
    local port=${3:-"22"}
    local username=${4:-""}
    
    print_header "Running SSH Analysis for $host:$port"
    
    echo "🔍 SSH Analyzer (Python):"
    if [ -n "$username" ]; then
        docker exec $container python3 /scripts/ssh-analyzer.py -u "$username" "$host" -p "$port"
    else
        docker exec $container python3 /scripts/ssh-analyzer.py "$host" -p "$port"
    fi
    
    echo ""
    echo "🛠️ SSH Troubleshoot (Shell):"
    if [ -n "$username" ]; then
        docker exec $container /scripts/ssh-troubleshoot.sh -u "$username" "$host" -p "$port"
    else
        docker exec $container /scripts/ssh-troubleshoot.sh "$host" -p "$port"
    fi
}

# Function to run NTP analysis tools
run_ntp_analysis() {
    local container=${1:-net-practice}
    local server=${2:-"pool.ntp.org"}
    local port=${3:-"123"}
    
    print_header "Running NTP Analysis for $server:$port"
    
    echo "🔍 NTP Analyzer (Python):"
    docker exec $container python3 /scripts/ntp-analyzer.py "$server" -p "$port"
    
    echo ""
    echo "🛠️ NTP Troubleshoot (Shell):"
    docker exec $container /scripts/ntp-troubleshoot.sh "$server" -p "$port"
}

# Function to run Nmap analysis tools
run_nmap_analysis() {
    local container=${1:-net-practice}
    local target=${2:-"127.0.0.1"}
    local scan_type=${3:-"basic"}
    
    print_header "Running Nmap Analysis for $target"
    
    echo "🔍 Nmap Analyzer (Python):"
    docker exec $container python3 /scripts/nmap-analyzer.py -t "$scan_type" "$target"
    
    echo ""
    echo "🛠️ Nmap Lab (Interactive):"
    echo "To run the interactive nmap lab, enter the container and run:"
    echo "  /scripts/nmap-lab.sh"
}

# Function to run Tshark analysis tools
run_tshark_analysis() {
    local container=${1:-net-practice}
    local interface=${2:-"any"}
    local count=${3:-50}
    
    print_header "Running Tshark Analysis on interface $interface"
    
    echo "🔍 Tshark Analyzer (Python):"
    docker exec $container python3 /scripts/tshark-analyzer.py -i "$interface" -c "$count"
    
    echo ""
    echo "🛠️ Tshark Lab (Interactive):"
    echo "To run the interactive tshark lab, enter the container and run:"
    echo "  /scripts/tshark-lab.sh"
}

# Function to run DHCP analysis tools
run_dhcp_analysis() {
    local container=${1:-net-practice}
    local interface=${2:-"any"}
    local count=${3:-50}
    
    print_header "Running DHCP Analysis on interface $interface"
    
    echo "🔍 DHCP Analyzer (Python):"
    docker exec $container python3 /scripts/dhcp-analyzer.py -i "$interface" -c "$count"
    
    echo ""
    echo "🛠️ DHCP Lab (Interactive):"
    echo "To run the interactive DHCP lab, enter the container and run:"
    echo "  /scripts/dhcp-lab.sh"
    
    echo ""
    echo "🔧 DHCP Troubleshooting:"
    echo "To run DHCP troubleshooting, enter the container and run:"
    echo "  /scripts/dhcp-troubleshoot.sh"
}

# Function to list all available scripts
list_scripts() {
    local container=${1:-net-practice}
    
    print_header "Available Scripts in Container"
    
    echo "🐍 Python Scripts:"
    docker exec $container find /scripts -name "*.py" -exec basename {} \; | sort
    
    echo ""
    echo "🐚 Shell Scripts:"
    docker exec $container find /scripts -name "*.sh" -exec basename {} \; | sort
    
    echo ""
    echo "📁 Scripts are located in: /scripts/"
    echo "💡 Use: docker exec $container python3 /scripts/script-name.py"
    echo "💡 Use: docker exec $container /scripts/script-name.sh"
}

# Main menu
show_menu() {
    print_header "Containerized Networking Practice"
    echo "1. Start Environment"
    echo "2. Stop Environment"
    echo "3. Enter Practice Container"
    echo "4. Run Practice Exercises"
    echo "5. Show Network Information"
    echo "6. Run Specific Command"
    echo "7. Run DNS Analysis"
    echo "8. Run SSH Analysis"
    echo "9. Run NTP Analysis"
    echo "10. Run Nmap Analysis"
    echo "11. Run Tshark Analysis"
    echo "12. Run DHCP Analysis"
    echo "13. List All Scripts"
    echo "14. Show Available Scenarios"
    echo "15. Exit"
    echo ""
    read -p "Choose an option (1-15): " choice
    
    case $choice in
        1)
            check_docker
            start_environment
            ;;
        2)
            stop_environment
            ;;
        3)
            echo "Available containers:"
            echo "  - net-practice (main practice container)"
            echo "  - firewall-test (firewall testing)"
            echo "  - router (routing practice)"
            echo "  - client (basic client)"
            read -p "Enter container name (default: net-practice): " container
            enter_practice ${container:-net-practice}
            ;;
        4)
            echo "Available containers:"
            echo "  - net-practice (main practice container)"
            echo "  - firewall-test (firewall testing)"
            read -p "Enter container name (default: net-practice): " container
            run_exercises ${container:-net-practice}
            ;;
        5)
            show_network_info
            ;;
        6)
            echo "Available containers:"
            echo "  - net-practice (main practice container)"
            echo "  - firewall-test (firewall testing)"
            echo "  - router (routing practice)"
            read -p "Enter container name (default: net-practice): " container
            read -p "Enter command (default: 'ip addr show'): " command
            run_command ${container:-net-practice} "${command:-ip addr show}"
            ;;
        7)
            read -p "Enter domain to analyze (default: google.com): " domain
            run_dns_analysis net-practice ${domain:-google.com}
            ;;
        8)
            read -p "Enter host to analyze (default: localhost): " host
            read -p "Enter SSH port (default: 22): " port
            read -p "Enter username (optional): " username
            run_ssh_analysis net-practice ${host:-localhost} ${port:-22} "$username"
            ;;
        9)
            read -p "Enter NTP server to analyze (default: pool.ntp.org): " server
            read -p "Enter NTP port (default: 123): " port
            run_ntp_analysis net-practice ${server:-pool.ntp.org} ${port:-123}
            ;;
        10)
            echo "Available containers:"
            echo "  - net-practice (main practice container)"
            echo "  - firewall-test (firewall testing)"
            read -p "Enter container name (default: net-practice): " container
            read -p "Enter target (default: 127.0.0.1): " target
            read -p "Enter scan type (basic/discovery/ports/services/os/scripts/comprehensive, default: basic): " scan_type
            run_nmap_analysis ${container:-net-practice} ${target:-127.0.0.1} ${scan_type:-basic}
            ;;
        11)
            echo "Available containers:"
            echo "  - net-practice (main practice container)"
            read -p "Enter container name (default: net-practice): " container
            read -p "Enter interface (default: any): " interface
            read -p "Enter packet count (default: 50): " count
            run_tshark_analysis ${container:-net-practice} ${interface:-any} ${count:-50}
            ;;
        12)
            echo "Available containers:"
            echo "  - net-practice (main practice container)"
            read -p "Enter container name (default: net-practice): " container
            read -p "Enter interface (default: any): " interface
            read -p "Enter packet count (default: 50): " count
            run_dhcp_analysis ${container:-net-practice} ${interface:-any} ${count:-50}
            ;;
        13)
            list_scripts net-practice
            ;;
        14)
            show_scenarios
            ;;
        15)
            print_success "Goodbye!"
            exit 0
            ;;
        *)
            print_error "Invalid option. Please choose 1-15."
            ;;
    esac
}

# Check if script is being run with arguments
if [ $# -gt 0 ]; then
    case $1 in
        start)
            check_docker
            start_environment
            ;;
        stop)
            stop_environment
            ;;
        enter)
            enter_practice ${2:-net-practice}
            ;;
        exercises)
            run_exercises ${2:-net-practice}
            ;;
        info)
            show_network_info
            ;;
        run)
            run_command ${2:-net-practice} "${3:-ip addr show}"
            ;;
        dns)
            read -p "Enter domain to analyze (default: google.com): " domain
            run_dns_analysis net-practice ${domain:-google.com}
            ;;
        ssh)
            read -p "Enter host to analyze (default: localhost): " host
            read -p "Enter SSH port (default: 22): " port
            read -p "Enter username (optional): " username
            run_ssh_analysis net-practice ${host:-localhost} ${port:-22} "$username"
            ;;
        ntp)
            read -p "Enter NTP server to analyze (default: pool.ntp.org): " server
            read -p "Enter NTP port (default: 123): " port
            run_ntp_analysis net-practice ${server:-pool.ntp.org} ${port:-123}
            ;;
        nmap)
            read -p "Enter target to scan (default: 127.0.0.1): " target
            read -p "Enter scan type (basic/discovery/ports/services/os/scripts/comprehensive, default: basic): " scan_type
            run_nmap_analysis net-practice ${target:-127.0.0.1} ${scan_type:-basic}
            ;;
        tshark)
            read -p "Enter interface (default: any): " interface
            read -p "Enter packet count (default: 50): " count
            run_tshark_analysis net-practice ${interface:-any} ${count:-50}
            ;;
        dhcp)
            read -p "Enter interface (default: any): " interface
            read -p "Enter packet count (default: 50): " count
            run_dhcp_analysis net-practice ${interface:-any} ${count:-50}
            ;;
        scenarios)
            show_scenarios
            ;;
        list-scripts)
            list_scripts net-practice
            ;;
        *)
            echo "Usage: $0 {start|stop|enter|exercises|info|run|dns|ssh|ntp|nmap|tshark|dhcp|scenarios|list-scripts}"
            echo "  start         - Start the networking environment"
            echo "  stop          - Stop the networking environment"
            echo "  enter         - Enter practice container"
            echo "  exercises     - Run practice exercises"
            echo "  info          - Show network information"
            echo "  run           - Run specific command"
            echo "  dns           - Run DNS analysis"
            echo "  ssh           - Run SSH analysis"
            echo "  ntp           - Run NTP analysis"
            echo "  nmap          - Run Nmap analysis"
            echo "  tshark        - Run Tshark analysis"
            echo "  dhcp          - Run DHCP analysis"
            echo "  scenarios     - Show available scenarios"
            echo "  list-scripts  - List all available scripts"
            exit 1
            ;;
    esac
else
    # Interactive mode
    while true; do
        show_menu
        echo ""
        read -p "Press Enter to continue..."
        clear
    done
fi
