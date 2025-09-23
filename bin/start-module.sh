#!/bin/bash

# Module Starter Script
# Starts specific networking modules with proper port management

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

# Show usage
show_usage() {
    echo "Usage: $0 <module> [action]"
    echo ""
    echo "Available modules:"
    echo "  main        - Main networking services"
    echo "  dns         - DNS server module"
    echo "  http        - HTTP servers module"
    echo "  analysis    - Network analysis module"
    echo ""
    echo "Available actions:"
    echo "  start       - Start the module (default)"
    echo "  stop        - Stop the module"
    echo "  restart     - Restart the module"
    echo "  status      - Show module status"
    echo ""
    echo "Examples:"
    echo "  $0 main start"
    echo "  $0 dns start"
    echo "  $0 http stop"
    echo "  $0 analysis status"
}

# Check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
}

# Start main module
start_main() {
    print_header "Starting Main Networking Services"
    
    cd "$(dirname "$0")/.."
    
    print_info "Starting main networking services..."
    docker-compose up -d
    
    print_info "Waiting for services to start..."
    sleep 10
    
    # Check if services are running
    if docker-compose ps | grep -q "Up"; then
        print_success "Main services started successfully"
        echo ""
        echo "Available services:"
        echo "  Web Interface: http://localhost:80"
        echo "  HTTPS Interface: https://localhost:443"
        echo "  DNS Server: localhost:53"
        echo "  PostgreSQL: localhost:5433"
        echo "  Prometheus: http://localhost:9090"
    else
        print_error "Failed to start main services"
        return 1
    fi
}

# Stop main module
stop_main() {
    print_header "Stopping Main Networking Services"
    
    cd "$(dirname "$0")/.."
    
    print_info "Stopping main networking services..."
    docker-compose down
    
    print_success "Main services stopped"
}

# Start DNS module
start_dns() {
    print_header "Starting DNS Server Module"
    
    cd "$(dirname "$0")/../modules/05-dns-server"
    
    print_info "Starting DNS servers..."
    docker-compose up -d
    
    print_info "Waiting for DNS servers to start..."
    sleep 10
    
    # Check if services are running
    if docker-compose ps | grep -q "Up"; then
        print_success "DNS servers started successfully"
        echo ""
        echo "Available DNS services:"
        echo "  CoreDNS Basic: localhost:53"
        echo "  CoreDNS Advanced: localhost:5353"
        echo "  CoreDNS Secure: localhost:5354"
        echo "  Health Check: http://localhost:9080"
    else
        print_error "Failed to start DNS servers"
        return 1
    fi
}

# Stop DNS module
stop_dns() {
    print_header "Stopping DNS Server Module"
    
    cd "$(dirname "$0")/../modules/05-dns-server"
    
    print_info "Stopping DNS servers..."
    docker-compose down
    
    print_success "DNS servers stopped"
}

# Start HTTP module
start_http() {
    print_header "Starting HTTP Servers Module"
    
    cd "$(dirname "$0")/../modules/06-http-servers"
    
    print_info "Starting HTTP servers..."
    docker-compose up -d
    
    print_info "Waiting for HTTP servers to start..."
    sleep 10
    
    # Check if services are running
    if docker-compose ps | grep -q "Up"; then
        print_success "HTTP servers started successfully"
        echo ""
        echo "Available HTTP services:"
        echo "  Nginx Basic: http://localhost:8090"
        echo "  Nginx Advanced: http://localhost:8091"
        echo "  Nginx SSL: https://localhost:8442"
        echo "  Apache Basic: http://localhost:8093"
        echo "  Backend Apps: http://localhost:9001-9003"
    else
        print_error "Failed to start HTTP servers"
        return 1
    fi
}

# Stop HTTP module
stop_http() {
    print_header "Stopping HTTP Servers Module"
    
    cd "$(dirname "$0")/../modules/06-http-servers"
    
    print_info "Stopping HTTP servers..."
    docker-compose down
    
    print_success "HTTP servers stopped"
}

# Start analysis module
start_analysis() {
    print_header "Starting Network Analysis Module"
    
    cd "$(dirname "$0")/../modules/04-network-analysis"
    
    print_info "Starting analysis tools..."
    # Analysis module doesn't have its own docker-compose yet
    print_warning "Analysis module doesn't have containerized services yet"
    print_info "Use the main practice container for analysis tools"
    
    print_success "Analysis module ready"
}

# Stop analysis module
stop_analysis() {
    print_header "Stopping Network Analysis Module"
    
    print_info "Analysis module doesn't have containerized services"
    print_success "Analysis module stopped"
}

# Show module status
show_status() {
    local module="$1"
    
    print_header "Module Status: $module"
    
    case $module in
        main)
            cd "$(dirname "$0")/.."
            docker-compose ps
            ;;
        dns)
            cd "$(dirname "$0")/../modules/05-dns-server"
            docker-compose ps
            ;;
        http)
            cd "$(dirname "$0")/../modules/06-http-servers"
            docker-compose ps
            ;;
        analysis)
            print_info "Analysis module uses main practice container"
            cd "$(dirname "$0")/.."
            docker-compose ps | grep net-practice
            ;;
    esac
}

# Main function
main() {
    local module="$1"
    local action="${2:-start}"
    
    # Check if module is provided
    if [ -z "$module" ]; then
        show_usage
        exit 1
    fi
    
    # Check Docker
    check_docker
    
    # Execute action
    case $action in
        start)
            case $module in
                main) start_main ;;
                dns) start_dns ;;
                http) start_http ;;
                analysis) start_analysis ;;
                *) print_error "Unknown module: $module"; show_usage; exit 1 ;;
            esac
            ;;
        stop)
            case $module in
                main) stop_main ;;
                dns) stop_dns ;;
                http) stop_http ;;
                analysis) stop_analysis ;;
                *) print_error "Unknown module: $module"; show_usage; exit 1 ;;
            esac
            ;;
        restart)
            case $module in
                main) stop_main && start_main ;;
                dns) stop_dns && start_dns ;;
                http) stop_http && start_http ;;
                analysis) stop_analysis && start_analysis ;;
                *) print_error "Unknown module: $module"; show_usage; exit 1 ;;
            esac
            ;;
        status)
            show_status "$module"
            ;;
        *)
            print_error "Unknown action: $action"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
