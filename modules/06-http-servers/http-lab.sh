#!/bin/bash

# HTTP Server Lab
# Interactive lab for HTTP server management

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

# Check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
    print_success "Docker is running"
}

# Start HTTP servers
start_servers() {
    print_header "Starting HTTP Servers"
    
    cd "$(dirname "$0")"
    
    print_info "Starting basic Nginx server..."
    docker-compose up -d nginx-basic
    
    print_info "Waiting for server to start..."
    sleep 5
    
    # Test if server is responding
    if curl -f http://localhost:8090 >/dev/null 2>&1; then
        print_success "Nginx basic server is running on http://localhost:8090"
    else
        print_error "Failed to start Nginx basic server"
        return 1
    fi
}

# Test HTTP server
test_server() {
    local url="$1"
    local expected_status="${2:-200}"
    
    print_info "Testing HTTP server at $url"
    
    if curl -f -s "$url" >/dev/null; then
        print_success "HTTP server is responding at $url"
        return 0
    else
        print_error "HTTP server is not responding at $url"
        return 1
    fi
}

# Analyze HTTP headers
analyze_headers() {
    local url="$1"
    
    print_header "HTTP Headers Analysis"
    
    print_info "Analyzing headers for $url"
    
    echo "Response Headers:"
    curl -I -s "$url" | grep -E "^(HTTP|Server|Content-Type|Content-Length|Cache-Control|ETag|Last-Modified|X-|Strict-Transport-Security)"
    
    echo ""
    echo "Security Headers Check:"
    
    # Check for security headers
    local headers=$(curl -I -s "$url")
    
    if echo "$headers" | grep -q "Strict-Transport-Security"; then
        print_success "HSTS header present"
    else
        print_warning "HSTS header missing"
    fi
    
    if echo "$headers" | grep -q "X-Frame-Options"; then
        print_success "X-Frame-Options header present"
    else
        print_warning "X-Frame-Options header missing"
    fi
    
    if echo "$headers" | grep -q "X-XSS-Protection"; then
        print_success "X-XSS-Protection header present"
    else
        print_warning "X-XSS-Protection header missing"
    fi
    
    if echo "$headers" | grep -q "X-Content-Type-Options"; then
        print_success "X-Content-Type-Options header present"
    else
        print_warning "X-Content-Type-Options header missing"
    fi
}

# Performance test
performance_test() {
    local url="$1"
    local requests="${2:-10}"
    
    print_header "Performance Test"
    
    print_info "Running performance test with $requests requests to $url"
    
    # Create temporary file for curl format
    local curl_format_file=$(mktemp)
    cat > "$curl_format_file" << 'EOF'
     time_namelookup:  %{time_namelookup}\n
        time_connect:  %{time_connect}\n
     time_appconnect:  %{time_appconnect}\n
    time_pretransfer:  %{time_pretransfer}\n
       time_redirect:  %{time_redirect}\n
  time_starttransfer:  %{time_starttransfer}\n
                     ----------\n
          time_total:  %{time_total}\n
EOF
    
    print_info "Running $requests requests..."
    
    local total_time=0
    local success_count=0
    
    for i in $(seq 1 "$requests"); do
        local start_time=$(date +%s.%N)
        
        if curl -f -s "$url" >/dev/null; then
            local end_time=$(date +%s.%N)
            local duration=$(echo "$end_time - $start_time" | bc)
            total_time=$(echo "$total_time + $duration" | bc)
            success_count=$((success_count + 1))
        fi
        
        # Small delay between requests
        sleep 0.1
    done
    
    if [ "$success_count" -gt 0 ]; then
        local avg_time=$(echo "scale=3; $total_time / $success_count" | bc)
        print_success "Performance test completed"
        print_info "Successful requests: $success_count/$requests"
        print_info "Average response time: ${avg_time}s"
        print_info "Total time: ${total_time}s"
    else
        print_error "Performance test failed - no successful requests"
    fi
    
    # Cleanup
    rm -f "$curl_format_file"
}

# Load balancing test
test_load_balancing() {
    print_header "Load Balancing Test"
    
    print_info "Starting backend servers..."
    docker-compose --profile loadbalancer up -d backend-app1 backend-app2 backend-app3
    
    print_info "Waiting for backend servers to start..."
    sleep 5
    
    # Test each backend server
    for port in 9001 9002 9003; do
        if curl -f -s "http://localhost:$port" >/dev/null; then
            print_success "Backend server on port $port is responding"
        else
            print_warning "Backend server on port $port is not responding"
        fi
    done
    
    print_info "Load balancing test completed"
}

# SSL test
test_ssl() {
    print_header "SSL Test"
    
    print_info "Starting SSL server..."
    docker-compose --profile ssl up -d nginx-ssl
    
    print_info "Waiting for SSL server to start..."
    sleep 5
    
    # Test HTTPS
    if curl -k -f -s https://localhost:8445 >/dev/null; then
        print_success "HTTPS server is responding on port 8445"
    else
        print_warning "HTTPS server is not responding on port 8445"
    fi
    
    # Test SSL certificate
    print_info "Testing SSL certificate..."
    if echo | openssl s_client -connect localhost:8445 -servername localhost 2>/dev/null | grep -q "Verify return code: 0"; then
        print_success "SSL certificate is valid"
    else
        print_warning "SSL certificate validation failed (expected for self-signed cert)"
    fi
}

# Interactive menu
show_menu() {
    echo ""
    print_header "HTTP Server Lab Menu"
    echo "1. Start HTTP servers"
    echo "2. Test basic HTTP server"
    echo "3. Analyze HTTP headers"
    echo "4. Performance test"
    echo "5. Test load balancing"
    echo "6. Test SSL/HTTPS"
    echo "7. View server logs"
    echo "8. Stop all servers"
    echo "9. Show server status"
    echo "0. Exit"
    echo ""
}

# View logs
view_logs() {
    print_header "Server Logs"
    
    echo "Nginx Basic Server Logs:"
    docker-compose logs --tail=20 nginx-basic
    
    echo ""
    echo "Nginx Advanced Server Logs:"
    docker-compose logs --tail=20 nginx-advanced 2>/dev/null || echo "Advanced server not running"
    
    echo ""
    echo "Nginx SSL Server Logs:"
    docker-compose logs --tail=20 nginx-ssl 2>/dev/null || echo "SSL server not running"
}

# Stop servers
stop_servers() {
    print_header "Stopping HTTP Servers"
    
    print_info "Stopping all HTTP servers..."
    docker-compose down
    
    print_success "All HTTP servers stopped"
}

# Show status
show_status() {
    print_header "Server Status"
    
    echo "Docker Compose Services:"
    docker-compose ps
    
    echo ""
    echo "Running Containers:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    
    echo ""
    echo "Network Information:"
    docker network ls | grep http-network || echo "HTTP network not found"
}

# Main menu loop
main_menu() {
    while true; do
        show_menu
        read -p "Select an option (0-9): " choice
        
        case $choice in
            1)
                start_servers
                ;;
            2)
                test_server "http://localhost:8090"
                ;;
            3)
                analyze_headers "http://localhost:8090"
                ;;
            4)
                performance_test "http://localhost:8090"
                ;;
            5)
                test_load_balancing
                ;;
            6)
                test_ssl
                ;;
            7)
                view_logs
                ;;
            8)
                stop_servers
                ;;
            9)
                show_status
                ;;
            0)
                print_info "Exiting HTTP Server Lab"
                exit 0
                ;;
            *)
                print_error "Invalid option. Please select 0-9."
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Main execution
main() {
    print_header "HTTP Server Lab"
    print_info "Welcome to the HTTP Server Management Lab!"
    print_info "This lab will help you learn HTTP server configuration and management."
    
    # Check prerequisites
    check_docker
    
    # Check if required tools are available
    if ! command -v curl >/dev/null 2>&1; then
        print_error "curl is required but not installed"
        exit 1
    fi
    
    if ! command -v bc >/dev/null 2>&1; then
        print_error "bc is required but not installed"
        exit 1
    fi
    
    print_success "All prerequisites met"
    
    # Start main menu
    main_menu
}

# Run main function
main "$@"
