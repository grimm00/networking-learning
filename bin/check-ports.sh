#!/bin/bash

# Port Conflict Checker
# Checks for port conflicts between different modules

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️ $1${NC}"
}

# Check if port is in use
check_port() {
    local port="$1"
    local service="$2"
    
    if lsof -i :"$port" >/dev/null 2>&1; then
        echo "Port $port ($service) is in use"
        return 1
    else
        echo "Port $port ($service) is available"
        return 0
    fi
}

# Check Docker port mappings
check_docker_ports() {
    print_header "Docker Port Mappings"
    
    if command -v docker >/dev/null 2>&1; then
        echo "Active Docker containers and their ports:"
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(NAMES|networking|nginx|apache|coredns)" || echo "No networking containers running"
    else
        print_warning "Docker not available"
    fi
}

# Check specific port conflicts
check_conflicts() {
    print_header "Port Conflict Analysis"
    
    local conflicts=()
    local warnings=()
    
    # Check main service ports
    print_info "Checking main service ports..."
    
    if ! check_port 80 "Main HTTP"; then
        conflicts+=("80")
    fi
    
    if ! check_port 443 "Main HTTPS"; then
        conflicts+=("443")
    fi
    
    if ! check_port 53 "Main DNS"; then
        conflicts+=("53")
    fi
    
    if ! check_port 5433 "PostgreSQL"; then
        conflicts+=("5433")
    fi
    
    if ! check_port 8080 "Main Practice Container"; then
        conflicts+=("8080")
    fi
    
    if ! check_port 9090 "Prometheus"; then
        conflicts+=("9090")
    fi
    
    # Check module-specific ports
    print_info "Checking module-specific ports..."
    
    # DNS module ports
    if ! check_port 5353 "DNS Advanced"; then
        warnings+=("5353")
    fi
    
    if ! check_port 5354 "DNS Secure"; then
        warnings+=("5354")
    fi
    
    # HTTP module ports
    if ! check_port 8081 "HTTP Advanced"; then
        warnings+=("8081")
    fi
    
    if ! check_port 8082 "HTTP SSL"; then
        warnings+=("8082")
    fi
    
    if ! check_port 8083 "Apache"; then
        warnings+=("8083")
    fi
    
    # Report results
    echo ""
    if [ ${#conflicts[@]} -gt 0 ]; then
        print_error "Port conflicts detected: ${conflicts[*]}"
        echo "These ports are used by main services and may conflict with modules"
    fi
    
    if [ ${#warnings[@]} -gt 0 ]; then
        print_warning "Module ports in use: ${warnings[*]}"
        echo "These ports are used by modules - this is normal if modules are running"
    fi
    
    if [ ${#conflicts[@]} -eq 0 ] && [ ${#warnings[@]} -eq 0 ]; then
        print_success "No port conflicts detected"
    fi
}

# Show port allocation
show_port_allocation() {
    print_header "Port Allocation Guide"
    
    echo "Main Services:"
    echo "  80    - Main HTTP (nginx-frontend)"
    echo "  443   - Main HTTPS (nginx-frontend)"
    echo "  53    - Main DNS (dns-server)"
    echo "  5433  - PostgreSQL database"
    echo "  8080  - Main practice container"
    echo "  9090  - Prometheus monitoring"
    echo ""
    
    echo "DNS Module (05-dns-server):"
    echo "  53    - CoreDNS basic (conflicts with main)"
    echo "  5353  - CoreDNS advanced"
    echo "  5354  - CoreDNS secure"
    echo "  9080  - Health check endpoint"
    echo "  9154  - Prometheus metrics"
    echo ""
    
    echo "HTTP Module (06-http-servers):"
    echo "  8080  - Nginx basic (conflicts with main)"
    echo "  8081  - Nginx advanced"
    echo "  8082  - Nginx SSL"
    echo "  8083  - Apache basic"
    echo "  8443  - HTTPS endpoints"
    echo "  9001  - Backend app 1"
    echo "  9002  - Backend app 2"
    echo "  9003  - Backend app 3"
    echo ""
    
    echo "Analysis Module (04-network-analysis):"
    echo "  8080  - Reserved for analysis tools"
    echo "  8443  - Reserved for secure analysis"
    echo ""
}

# Show running services
show_running_services() {
    print_header "Running Services"
    
    echo "System services using networking ports:"
    lsof -i :80,443,53,8080,9090 2>/dev/null | head -20 || echo "No system services found on main ports"
    
    echo ""
    echo "Docker containers:"
    if command -v docker >/dev/null 2>&1; then
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(NAMES|networking|nginx|apache|coredns)" || echo "No networking containers running"
    else
        echo "Docker not available"
    fi
}

# Suggest solutions
suggest_solutions() {
    print_header "Conflict Resolution Suggestions"
    
    echo "If you have port conflicts, try these solutions:"
    echo ""
    echo "1. Use different modules:"
    echo "   cd 05-dns-server && docker-compose up -d"
    echo "   cd 06-http-servers && docker-compose up -d"
    echo ""
    echo "2. Stop conflicting services:"
    echo "   docker-compose down"
    echo "   docker-compose -f 05-dns-server/docker-compose.yml down"
    echo "   docker-compose -f 06-http-servers/docker-compose.yml down"
    echo ""
    echo "3. Use profiles to manage services:"
    echo "   docker-compose --profile main up -d"
    echo "   docker-compose --profile dns up -d"
    echo "   docker-compose --profile http up -d"
    echo ""
    echo "4. Check what's using specific ports:"
    echo "   lsof -i :8080"
    echo "   lsof -i :53"
    echo "   lsof -i :80"
}

# Main function
main() {
    print_header "Port Conflict Checker"
    print_info "Checking for port conflicts between networking modules"
    
    # Check if required tools are available
    if ! command -v lsof >/dev/null 2>&1; then
        print_error "lsof is required but not installed"
        echo "Install with: brew install lsof (macOS) or apt-get install lsof (Linux)"
        exit 1
    fi
    
    # Run checks
    check_conflicts
    echo ""
    check_docker_ports
    echo ""
    show_running_services
    echo ""
    show_port_allocation
    echo ""
    suggest_solutions
    
    print_success "Port conflict check completed"
}

# Run main function
main "$@"
