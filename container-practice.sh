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
    print_header "Starting Networking Practice Environment"
    
    # Start all containers
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
    echo "8. All Project Scripts"
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
    echo ""
    
    docker exec -it $container bash
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
    docker exec $container python3 /tools/dns-analyzer.py $domain
    
    echo ""
    echo "🛠️ DNS Troubleshoot (Shell):"
    docker exec $container /tools/dns-troubleshoot.sh -a $domain
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
    echo "8. List All Scripts"
    echo "9. Show Available Scenarios"
    echo "10. Exit"
    echo ""
    read -p "Choose an option (1-10): " choice
    
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
            list_scripts net-practice
            ;;
        9)
            show_scenarios
            ;;
        10)
            print_success "Goodbye!"
            exit 0
            ;;
        *)
            print_error "Invalid option. Please choose 1-10."
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
        scenarios)
            show_scenarios
            ;;
        list-scripts)
            list_scripts net-practice
            ;;
        *)
            echo "Usage: $0 {start|stop|enter|exercises|info|run|scenarios|list-scripts}"
            echo "  start         - Start the networking environment"
            echo "  stop          - Stop the networking environment"
            echo "  enter         - Enter practice container"
            echo "  exercises     - Run practice exercises"
            echo "  info          - Show network information"
            echo "  run           - Run specific command"
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
