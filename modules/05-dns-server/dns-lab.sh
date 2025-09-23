#!/bin/bash

# DNS Server Lab Script
# Interactive lab for CoreDNS configuration and testing

set -e

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

# Function to show menu
show_menu() {
    echo ""
    print_header "DNS Server Lab Menu"
    echo "1.  Setup Basic DNS Server"
    echo "2.  Setup Advanced DNS Server"
    echo "3.  Setup Secure DNS Server"
    echo "4.  Test DNS Resolution"
    echo "5.  Create Zone File"
    echo "6.  Validate Configuration"
    echo "7.  Monitor DNS Queries"
    echo "8.  Troubleshoot DNS Issues"
    echo "9.  Show Server Status"
    echo "10. Stop All Servers"
    echo "11. Cleanup"
    echo "0.  Exit"
    echo ""
}

# Function to setup basic DNS server
setup_basic_server() {
    print_header "Setting up Basic DNS Server"
    
    print_info "Starting basic CoreDNS server..."
    
    # Start basic server
    docker-compose up -d coredns
    
    # Wait for server to start
    sleep 5
    
    # Test server
    if dig @localhost google.com +short >/dev/null 2>&1; then
        print_success "Basic DNS server is running on port 53"
        print_info "Test with: dig @localhost google.com"
    else
        print_error "Failed to start basic DNS server"
        return 1
    fi
}

# Function to setup advanced DNS server
setup_advanced_server() {
    print_header "Setting up Advanced DNS Server"
    
    print_info "Starting advanced CoreDNS server..."
    
    # Start advanced server
    docker-compose --profile advanced up -d coredns-advanced
    
    # Wait for server to start
    sleep 5
    
    # Test server
    if dig @localhost -p 5353 google.com +short >/dev/null 2>&1; then
        print_success "Advanced DNS server is running on port 5353"
        print_info "Test with: dig @localhost -p 5353 google.com"
    else
        print_error "Failed to start advanced DNS server"
        return 1
    fi
}

# Function to setup secure DNS server
setup_secure_server() {
    print_header "Setting up Secure DNS Server"
    
    print_info "Starting secure CoreDNS server..."
    
    # Start secure server
    docker-compose --profile secure up -d coredns-secure
    
    # Wait for server to start
    sleep 5
    
    # Test server
    if dig @localhost -p 5354 google.com +short >/dev/null 2>&1; then
        print_success "Secure DNS server is running on port 5354"
        print_info "Test with: dig @localhost -p 5354 google.com"
    else
        print_error "Failed to start secure DNS server"
        return 1
    fi
}

# Function to test DNS resolution
test_dns_resolution() {
    print_header "Testing DNS Resolution"
    
    echo "Select server to test:"
    echo "1. Basic server (port 53)"
    echo "2. Advanced server (port 5353)"
    echo "3. Secure server (port 5354)"
    echo "4. Custom server"
    read -p "Enter choice (1-4): " server_choice
    
    case $server_choice in
        1)
            server="localhost"
            port="53"
            ;;
        2)
            server="localhost"
            port="5353"
            ;;
        3)
            server="localhost"
            port="5354"
            ;;
        4)
            read -p "Enter server IP: " server
            read -p "Enter port (default 53): " port
            port=${port:-53}
            ;;
        *)
            print_error "Invalid choice"
            return 1
            ;;
    esac
    
    read -p "Enter domain to test (default: google.com): " domain
    domain=${domain:-google.com}
    
    print_info "Testing DNS resolution for $domain via $server:$port"
    
    # Test A record
    print_info "Testing A record..."
    dig @"$server" -p "$port" "$domain" A +short
    
    # Test AAAA record
    print_info "Testing AAAA record..."
    dig @"$server" -p "$port" "$domain" AAAA +short
    
    # Test MX record
    print_info "Testing MX record..."
    dig @"$server" -p "$port" "$domain" MX +short
    
    # Test NS record
    print_info "Testing NS record..."
    dig @"$server" -p "$port" "$domain" NS +short
    
    print_success "DNS resolution test completed"
}

# Function to create zone file
create_zone_file() {
    print_header "Creating Zone File"
    
    read -p "Enter domain name (e.g., example.com): " domain
    read -p "Enter IP address for domain (default: 192.168.1.100): " ip_address
    ip_address=${ip_address:-192.168.1.100}
    
    zone_file="zones/${domain}.db"
    
    print_info "Creating zone file: $zone_file"
    
    cat > "$zone_file" << EOF
; Zone file for $domain
\$TTL 3600
\$ORIGIN $domain.

@       IN      SOA     ns1.$domain. admin.$domain. (
                        2024010101      ; Serial number
                        3600            ; Refresh interval
                        1800            ; Retry interval
                        604800          ; Expire time
                        86400           ; Minimum TTL
                        )

; Name servers
@       IN      NS      ns1.$domain.
@       IN      NS      ns2.$domain.

; A records
@       IN      A       $ip_address
ns1     IN      A       192.168.1.101
ns2     IN      A       192.168.1.102
www     IN      A       $ip_address
mail    IN      A       192.168.1.103

; CNAME records
web     IN      CNAME   www.$domain.

; MX records
@       IN      MX      10 mail.$domain.

; TXT records
@       IN      TXT     "v=spf1 mx ~all"
EOF
    
    print_success "Zone file created: $zone_file"
    print_info "You can now configure CoreDNS to serve this zone"
}

# Function to validate configuration
validate_configuration() {
    print_header "Validating Configuration"
    
    echo "Select configuration to validate:"
    echo "1. Basic configuration"
    echo "2. Advanced configuration"
    echo "3. Secure configuration"
    echo "4. Custom configuration"
    read -p "Enter choice (1-4): " config_choice
    
    case $config_choice in
        1)
            config_file="coredns-configs/basic.conf"
            ;;
        2)
            config_file="coredns-configs/advanced.conf"
            ;;
        3)
            config_file="coredns-configs/secure.conf"
            ;;
        4)
            read -p "Enter configuration file path: " config_file
            ;;
        *)
            print_error "Invalid choice"
            return 1
            ;;
    esac
    
    print_info "Validating configuration: $config_file"
    
    # Test configuration syntax
    if docker run --rm -v "$(pwd)/$config_file:/etc/coredns/Corefile" coredns/coredns:latest -conf /etc/coredns/Corefile -test; then
        print_success "Configuration syntax is valid"
    else
        print_error "Configuration syntax is invalid"
        return 1
    fi
    
    # Validate zone files if they exist
    for zone_file in zones/*.db; do
        if [ -f "$zone_file" ]; then
            domain=$(basename "$zone_file" .db)
            print_info "Validating zone file: $zone_file"
            if named-checkzone "$domain" "$zone_file" >/dev/null 2>&1; then
                print_success "Zone file $zone_file is valid"
            else
                print_warning "Zone file $zone_file validation failed"
            fi
        fi
    done
}

# Function to monitor DNS queries
monitor_dns_queries() {
    print_header "Monitoring DNS Queries"
    
    echo "Select server to monitor:"
    echo "1. Basic server (port 53)"
    echo "2. Advanced server (port 5353)"
    echo "3. Secure server (port 5354)"
    read -p "Enter choice (1-3): " server_choice
    
    case $server_choice in
        1)
            container="coredns-server"
            ;;
        2)
            container="coredns-advanced"
            ;;
        3)
            container="coredns-secure"
            ;;
        *)
            print_error "Invalid choice"
            return 1
            ;;
    esac
    
    print_info "Monitoring DNS queries for $container"
    print_warning "Press Ctrl+C to stop monitoring"
    
    # Monitor logs
    docker logs -f "$container"
}

# Function to troubleshoot DNS issues
troubleshoot_dns() {
    print_header "Troubleshooting DNS Issues"
    
    print_info "Running comprehensive DNS diagnostics..."
    
    # Run DNS troubleshooting script
    if [ -f "../scripts/dns-troubleshoot.sh" ]; then
        bash ../scripts/dns-troubleshoot.sh -d google.com -s localhost -v
    else
        print_error "DNS troubleshooting script not found"
        return 1
    fi
}

# Function to show server status
show_server_status() {
    print_header "DNS Server Status"
    
    print_info "Checking running containers..."
    docker ps --filter "name=coredns" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    
    echo ""
    print_info "Testing DNS resolution..."
    
    # Test basic server
    if dig @localhost google.com +short >/dev/null 2>&1; then
        print_success "Basic server (port 53) is responding"
    else
        print_warning "Basic server (port 53) is not responding"
    fi
    
    # Test advanced server
    if dig @localhost -p 5353 google.com +short >/dev/null 2>&1; then
        print_success "Advanced server (port 5353) is responding"
    else
        print_warning "Advanced server (port 5353) is not responding"
    fi
    
    # Test secure server
    if dig @localhost -p 5354 google.com +short >/dev/null 2>&1; then
        print_success "Secure server (port 5354) is responding"
    else
        print_warning "Secure server (port 5354) is not responding"
    fi
}

# Function to stop all servers
stop_all_servers() {
    print_header "Stopping All DNS Servers"
    
    print_info "Stopping all CoreDNS containers..."
    docker-compose down
    
    print_success "All DNS servers stopped"
}

# Function to cleanup
cleanup() {
    print_header "Cleanup"
    
    print_info "Stopping all containers..."
    docker-compose down
    
    print_info "Removing containers and networks..."
    docker-compose down --volumes --remove-orphans
    
    print_info "Cleaning up logs..."
    rm -rf logs/*
    
    print_success "Cleanup completed"
}

# Main loop
main() {
    print_header "DNS Server Lab"
    print_info "Welcome to the CoreDNS configuration lab!"
    print_info "This lab will help you learn DNS server configuration with CoreDNS"
    
    while true; do
        show_menu
        read -p "Enter your choice (0-11): " choice
        
        case $choice in
            1)
                setup_basic_server
                ;;
            2)
                setup_advanced_server
                ;;
            3)
                setup_secure_server
                ;;
            4)
                test_dns_resolution
                ;;
            5)
                create_zone_file
                ;;
            6)
                validate_configuration
                ;;
            7)
                monitor_dns_queries
                ;;
            8)
                troubleshoot_dns
                ;;
            9)
                show_server_status
                ;;
            10)
                stop_all_servers
                ;;
            11)
                cleanup
                ;;
            0)
                print_info "Exiting DNS Server Lab"
                exit 0
                ;;
            *)
                print_error "Invalid choice. Please try again."
                ;;
        esac
        
        read -p "Press Enter to continue..."
    done
}

# Run main function
main
