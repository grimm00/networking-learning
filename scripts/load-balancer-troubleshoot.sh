#!/bin/bash
# Load Balancer Troubleshooting Guide
# Comprehensive troubleshooting and diagnostic tools for load balancer issues

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

print_step() {
    echo -e "${CYAN}→ $1${NC}"
}

# Function to check if running in container
check_container() {
    if [ -f /.dockerenv ] || [ -n "${DOCKER_CONTAINER:-}" ]; then
        return 0
    else
        return 1
    fi
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to run command with timeout
run_with_timeout() {
    local timeout=$1
    shift
    timeout "$timeout" "$@" 2>/dev/null || return 1
}

# Troubleshooting: Load Balancer Not Starting
troubleshoot_load_balancer_startup() {
    print_header "Load Balancer Startup Issues"
    
    print_step "Checking Nginx status..."
    if command_exists nginx; then
        if systemctl is-active nginx >/dev/null 2>&1; then
            print_status "Nginx is running"
        else
            print_error "Nginx is not running"
            
            print_step "Checking Nginx configuration..."
            if nginx -t 2>&1 | grep -q "syntax is ok"; then
                print_status "Nginx configuration is valid"
                print_step "Attempting to start Nginx..."
                systemctl start nginx
                if systemctl is-active nginx >/dev/null 2>&1; then
                    print_status "Nginx started successfully"
                else
                    print_error "Failed to start Nginx"
                    print_step "Checking Nginx error logs..."
                    journalctl -u nginx --no-pager -n 20
                fi
            else
                print_error "Nginx configuration has errors"
                nginx -t
            fi
        fi
    else
        print_warning "Nginx not installed"
    fi
    
    print_step "Checking HAProxy status..."
    if command_exists haproxy; then
        if systemctl is-active haproxy >/dev/null 2>&1; then
            print_status "HAProxy is running"
        else
            print_error "HAProxy is not running"
            
            print_step "Checking HAProxy configuration..."
            if haproxy -c -f /etc/haproxy/haproxy.cfg 2>&1 | grep -q "Configuration file is valid"; then
                print_status "HAProxy configuration is valid"
                print_step "Attempting to start HAProxy..."
                systemctl start haproxy
                if systemctl is-active haproxy >/dev/null 2>&1; then
                    print_status "HAProxy started successfully"
                else
                    print_error "Failed to start HAProxy"
                    print_step "Checking HAProxy error logs..."
                    journalctl -u haproxy --no-pager -n 20
                fi
            else
                print_error "HAProxy configuration has errors"
                haproxy -c -f /etc/haproxy/haproxy.cfg
            fi
        fi
    else
        print_warning "HAProxy not installed"
    fi
}

# Troubleshooting: Backend Server Connectivity
troubleshoot_backend_connectivity() {
    print_header "Backend Server Connectivity Issues"
    
    local servers=("192.168.1.10:80" "192.168.1.11:80" "192.168.1.12:80")
    
    print_step "Testing backend server connectivity..."
    
    for server in "${servers[@]}"; do
        local host=$(echo "$server" | cut -d':' -f1)
        local port=$(echo "$server" | cut -d':' -f2)
        
        print_step "Testing $server..."
        
        # Test basic connectivity
        if run_with_timeout 5 nc -z "$host" "$port" 2>/dev/null; then
            print_status "$server is reachable"
            
            # Test HTTP response
            if command_exists curl; then
                local response=$(run_with_timeout 10 curl -s -o /dev/null -w "%{http_code}" "http://$server/" 2>/dev/null)
                if [ "$response" = "200" ]; then
                    print_status "$server HTTP response: OK (200)"
                else
                    print_warning "$server HTTP response: $response"
                fi
            fi
        else
            print_error "$server is not reachable"
            
            # Check if it's a DNS issue
            if ! run_with_timeout 5 nslookup "$host" >/dev/null 2>&1; then
                print_error "DNS resolution failed for $host"
            fi
            
            # Check if it's a network issue
            if ! run_with_timeout 5 ping -c 1 "$host" >/dev/null 2>&1; then
                print_error "Host $host is not responding to ping"
            fi
        fi
    done
}

# Troubleshooting: Load Balancing Algorithm Issues
troubleshoot_load_balancing_algorithm() {
    print_header "Load Balancing Algorithm Issues"
    
    print_step "Checking Nginx upstream configuration..."
    if command_exists nginx; then
        local nginx_config=$(nginx -T 2>/dev/null)
        if [ -n "$nginx_config" ]; then
            local upstream_blocks=$(echo "$nginx_config" | grep -A 10 "upstream")
            if [ -n "$upstream_blocks" ]; then
                print_status "Nginx upstream configuration found:"
                echo "$upstream_blocks"
                
                # Check for load balancing method
                if echo "$nginx_config" | grep -q "least_conn"; then
                    print_status "Using least connections algorithm"
                elif echo "$nginx_config" | grep -q "ip_hash"; then
                    print_status "Using IP hash algorithm (session persistence)"
                elif echo "$nginx_config" | grep -q "hash"; then
                    print_status "Using consistent hash algorithm"
                else
                    print_status "Using default round robin algorithm"
                fi
            else
                print_warning "No upstream configuration found in Nginx"
            fi
        fi
    fi
    
    print_step "Checking HAProxy backend configuration..."
    if [ -f "/etc/haproxy/haproxy.cfg" ]; then
        local haproxy_config=$(cat /etc/haproxy/haproxy.cfg)
        local backend_blocks=$(echo "$haproxy_config" | grep -A 10 "backend")
        if [ -n "$backend_blocks" ]; then
            print_status "HAProxy backend configuration found:"
            echo "$backend_blocks"
            
            # Check for load balancing method
            if echo "$haproxy_config" | grep -q "balance roundrobin"; then
                print_status "Using round robin algorithm"
            elif echo "$haproxy_config" | grep -q "balance leastconn"; then
                print_status "Using least connections algorithm"
            elif echo "$haproxy_config" | grep -q "balance source"; then
                print_status "Using source IP algorithm"
            else
                print_warning "No balance method specified in HAProxy"
            fi
        else
            print_warning "No backend configuration found in HAProxy"
        fi
    else
        print_warning "HAProxy configuration file not found"
    fi
}

# Troubleshooting: Health Check Issues
troubleshoot_health_checks() {
    print_header "Health Check Issues"
    
    print_step "Checking Nginx health check configuration..."
    if command_exists nginx; then
        local nginx_config=$(nginx -T 2>/dev/null)
        if [ -n "$nginx_config" ]; then
            # Check for health check parameters
            if echo "$nginx_config" | grep -q "max_fails"; then
                print_status "Nginx health checks configured with max_fails"
                echo "$nginx_config" | grep "max_fails"
            else
                print_warning "No max_fails configured in Nginx"
            fi
            
            if echo "$nginx_config" | grep -q "fail_timeout"; then
                print_status "Nginx health checks configured with fail_timeout"
                echo "$nginx_config" | grep "fail_timeout"
            else
                print_warning "No fail_timeout configured in Nginx"
            fi
            
            if echo "$nginx_config" | grep -q "proxy_next_upstream"; then
                print_status "Nginx proxy_next_upstream configured"
                echo "$nginx_config" | grep "proxy_next_upstream"
            else
                print_warning "No proxy_next_upstream configured in Nginx"
            fi
        fi
    fi
    
    print_step "Checking HAProxy health check configuration..."
    if [ -f "/etc/haproxy/haproxy.cfg" ]; then
        local haproxy_config=$(cat /etc/haproxy/haproxy.cfg)
        
        if echo "$haproxy_config" | grep -q "option httpchk"; then
            print_status "HAProxy HTTP health checks configured"
            echo "$haproxy_config" | grep "option httpchk"
        else
            print_warning "No HTTP health checks configured in HAProxy"
        fi
        
        if echo "$haproxy_config" | grep -q "http-check"; then
            print_status "HAProxy http-check configured"
            echo "$haproxy_config" | grep "http-check"
        else
            print_warning "No http-check configured in HAProxy"
        fi
        
        if echo "$haproxy_config" | grep -q "check"; then
            print_status "HAProxy check parameter configured"
            echo "$haproxy_config" | grep "check"
        else
            print_warning "No check parameter configured in HAProxy"
        fi
    fi
    
    print_step "Testing health check endpoints..."
    local health_endpoints=("/health" "/health.html" "/api/health" "/status")
    
    for endpoint in "${health_endpoints[@]}"; do
        print_step "Testing $endpoint..."
        if command_exists curl; then
            local response=$(run_with_timeout 5 curl -s -o /dev/null -w "%{http_code}" "http://localhost$endpoint" 2>/dev/null)
            if [ "$response" = "200" ]; then
                print_status "$endpoint is accessible (200)"
            else
                print_warning "$endpoint returned $response"
            fi
        fi
    done
}

# Troubleshooting: Session Persistence Issues
troubleshoot_session_persistence() {
    print_header "Session Persistence Issues"
    
    print_step "Checking Nginx session persistence configuration..."
    if command_exists nginx; then
        local nginx_config=$(nginx -T 2>/dev/null)
        if [ -n "$nginx_config" ]; then
            if echo "$nginx_config" | grep -q "ip_hash"; then
                print_status "IP hash session persistence configured in Nginx"
            else
                print_warning "No IP hash session persistence configured in Nginx"
            fi
            
            if echo "$nginx_config" | grep -q "proxy_cookie"; then
                print_status "Cookie-based session persistence configured in Nginx"
            else
                print_warning "No cookie-based session persistence configured in Nginx"
            fi
        fi
    fi
    
    print_step "Checking HAProxy session persistence configuration..."
    if [ -f "/etc/haproxy/haproxy.cfg" ]; then
        local haproxy_config=$(cat /etc/haproxy/haproxy.cfg)
        
        if echo "$haproxy_config" | grep -q "cookie"; then
            print_status "Cookie-based session persistence configured in HAProxy"
            echo "$haproxy_config" | grep "cookie"
        else
            print_warning "No cookie-based session persistence configured in HAProxy"
        fi
        
        if echo "$haproxy_config" | grep -q "balance source"; then
            print_status "Source IP-based session persistence configured in HAProxy"
        else
            print_warning "No source IP-based session persistence configured in HAProxy"
        fi
    fi
    
    print_step "Testing session persistence..."
    if command_exists curl; then
        print_step "Testing session consistency..."
        local responses=()
        for i in {1..5}; do
            local response=$(run_with_timeout 5 curl -s "http://localhost/" 2>/dev/null)
            responses+=("$response")
        done
        
        # Check if all responses are the same (indicating session persistence)
        local first_response="${responses[0]}"
        local all_same=true
        for response in "${responses[@]}"; do
            if [ "$response" != "$first_response" ]; then
                all_same=false
                break
            fi
        done
        
        if [ "$all_same" = true ]; then
            print_status "Session persistence is working (all requests served by same server)"
        else
            print_warning "Session persistence may not be working (requests served by different servers)"
        fi
    fi
}

# Troubleshooting: Performance Issues
troubleshoot_performance() {
    print_header "Performance Issues"
    
    print_step "Checking system resources..."
    
    # Check CPU usage
    print_step "CPU usage:"
    top -bn1 | grep "Cpu(s)" || uptime
    
    # Check memory usage
    print_step "Memory usage:"
    free -h
    
    # Check disk usage
    print_step "Disk usage:"
    df -h
    
    print_step "Checking load balancer processes..."
    
    # Check Nginx processes
    if command_exists nginx; then
        local nginx_processes=$(pgrep nginx | wc -l)
        print_status "Nginx processes: $nginx_processes"
        
        if [ "$nginx_processes" -gt 0 ]; then
            print_step "Nginx process details:"
            ps aux | grep nginx | grep -v grep
        fi
    fi
    
    # Check HAProxy processes
    if command_exists haproxy; then
        local haproxy_processes=$(pgrep haproxy | wc -l)
        print_status "HAProxy processes: $haproxy_processes"
        
        if [ "$haproxy_processes" -gt 0 ]; then
            print_step "HAProxy process details:"
            ps aux | grep haproxy | grep -v grep
        fi
    fi
    
    print_step "Checking network connections..."
    
    # Check active connections
    if command_exists ss; then
        print_step "Active connections on port 80:"
        ss -tuna | grep :80 | wc -l
        
        print_step "Active connections on port 443:"
        ss -tuna | grep :443 | wc -l
        
        print_step "Connection states:"
        ss -tuna | awk '{print $1}' | sort | uniq -c | sort -nr
    fi
    
    print_step "Checking network interface statistics..."
    if [ -f "/proc/net/dev" ]; then
        print_step "Network interface statistics:"
        cat /proc/net/dev | head -5
    fi
    
    print_step "Running performance tests..."
    if command_exists ab; then
        print_step "Running Apache Bench test..."
        ab -n 100 -c 10 http://localhost/ > /tmp/ab-results.txt 2>&1
        if [ -f "/tmp/ab-results.txt" ]; then
            print_status "Performance test completed. Results:"
            grep -E "(Requests per second|Time per request|Transfer rate)" /tmp/ab-results.txt
        fi
    else
        print_warning "Apache Bench (ab) not available for performance testing"
    fi
}

# Troubleshooting: SSL/TLS Issues
troubleshoot_ssl_tls() {
    print_header "SSL/TLS Issues"
    
    print_step "Checking SSL/TLS configuration..."
    
    if command_exists nginx; then
        local nginx_config=$(nginx -T 2>/dev/null)
        if [ -n "$nginx_config" ]; then
            if echo "$nginx_config" | grep -q "ssl"; then
                print_status "SSL/TLS configuration found in Nginx"
                echo "$nginx_config" | grep -A 5 -B 5 "ssl"
            else
                print_warning "No SSL/TLS configuration found in Nginx"
            fi
        fi
    fi
    
    print_step "Testing SSL/TLS connectivity..."
    if command_exists openssl; then
        print_step "Testing SSL connection to localhost:443..."
        if run_with_timeout 10 openssl s_client -connect localhost:443 -servername localhost </dev/null 2>/dev/null | grep -q "CONNECTED"; then
            print_status "SSL connection successful"
            
            print_step "SSL certificate details:"
            run_with_timeout 10 openssl s_client -connect localhost:443 -servername localhost </dev/null 2>/dev/null | openssl x509 -noout -text | grep -E "(Subject:|Issuer:|Not Before:|Not After:)"
        else
            print_error "SSL connection failed"
        fi
    else
        print_warning "OpenSSL not available for SSL testing"
    fi
    
    print_step "Testing HTTPS with curl..."
    if command_exists curl; then
        local https_response=$(run_with_timeout 10 curl -s -o /dev/null -w "%{http_code}" "https://localhost/" 2>/dev/null)
        if [ "$https_response" = "200" ]; then
            print_status "HTTPS request successful (200)"
        else
            print_warning "HTTPS request returned $https_response"
        fi
    fi
}

# Troubleshooting: Log Analysis
analyze_logs() {
    print_header "Log Analysis"
    
    print_step "Analyzing Nginx error logs..."
    if [ -f "/var/log/nginx/error.log" ]; then
        print_step "Recent Nginx errors:"
        tail -20 /var/log/nginx/error.log
    else
        print_warning "Nginx error log not found"
    fi
    
    print_step "Analyzing Nginx access logs..."
    if [ -f "/var/log/nginx/access.log" ]; then
        print_step "Recent Nginx access logs:"
        tail -10 /var/log/nginx/access.log
    else
        print_warning "Nginx access log not found"
    fi
    
    print_step "Analyzing HAProxy logs..."
    if [ -f "/var/log/haproxy.log" ]; then
        print_step "Recent HAProxy logs:"
        tail -20 /var/log/haproxy.log
    else
        print_warning "HAProxy log not found"
    fi
    
    print_step "Analyzing system logs..."
    print_step "Recent system messages:"
    journalctl --no-pager -n 20
    
    print_step "Recent kernel messages:"
    dmesg | tail -10
}

# Generate troubleshooting report
generate_report() {
    print_header "Generating Troubleshooting Report"
    
    local report_file="/tmp/load-balancer-troubleshoot-report.txt"
    
    {
        echo "Load Balancer Troubleshooting Report"
        echo "Generated: $(date)"
        echo "Hostname: $(hostname)"
        echo "OS: $(uname -a)"
        echo "=========================================="
        echo
        
        echo "=== System Information ==="
        uptime
        free -h
        df -h
        echo
        
        echo "=== Load Balancer Status ==="
        if command_exists nginx; then
            systemctl status nginx --no-pager
        fi
        if command_exists haproxy; then
            systemctl status haproxy --no-pager
        fi
        echo
        
        echo "=== Network Connections ==="
        ss -tuna | grep -E ":(80|443|8080)" | head -10
        echo
        
        echo "=== Process Information ==="
        ps aux | grep -E "(nginx|haproxy)" | grep -v grep
        echo
        
        echo "=== Configuration Files ==="
        if [ -f "/etc/nginx/nginx.conf" ]; then
            echo "Nginx configuration:"
            nginx -T 2>/dev/null | head -20
        fi
        if [ -f "/etc/haproxy/haproxy.cfg" ]; then
            echo "HAProxy configuration:"
            head -20 /etc/haproxy/haproxy.cfg
        fi
        
    } > "$report_file"
    
    print_status "Troubleshooting report generated: $report_file"
    print_step "Report contents:"
    cat "$report_file"
}

# Main troubleshooting menu
show_troubleshoot_menu() {
    echo
    print_header "Load Balancer Troubleshooting Menu"
    echo "1. Load Balancer Startup Issues"
    echo "2. Backend Server Connectivity"
    echo "3. Load Balancing Algorithm Issues"
    echo "4. Health Check Issues"
    echo "5. Session Persistence Issues"
    echo "6. Performance Issues"
    echo "7. SSL/TLS Issues"
    echo "8. Log Analysis"
    echo "9. Generate Troubleshooting Report"
    echo "10. Run All Troubleshooting Checks"
    echo "0. Exit"
    echo
}

# Main function
main() {
    print_header "Load Balancer Troubleshooting Guide"
    print_status "Welcome to the Load Balancer Troubleshooting Guide!"
    print_status "This guide will help you diagnose and fix common load balancer issues."
    
    # Check if running in container
    if check_container; then
        print_status "Running in container environment"
    else
        print_warning "Not running in container - some checks may not work properly"
    fi
    
    while true; do
        show_troubleshoot_menu
        read -p "Select a troubleshooting option (0-10): " choice
        
        case $choice in
            1)
                troubleshoot_load_balancer_startup
                ;;
            2)
                troubleshoot_backend_connectivity
                ;;
            3)
                troubleshoot_load_balancing_algorithm
                ;;
            4)
                troubleshoot_health_checks
                ;;
            5)
                troubleshoot_session_persistence
                ;;
            6)
                troubleshoot_performance
                ;;
            7)
                troubleshoot_ssl_tls
                ;;
            8)
                analyze_logs
                ;;
            9)
                generate_report
                ;;
            10)
                troubleshoot_load_balancer_startup
                troubleshoot_backend_connectivity
                troubleshoot_load_balancing_algorithm
                troubleshoot_health_checks
                troubleshoot_session_persistence
                troubleshoot_performance
                troubleshoot_ssl_tls
                analyze_logs
                generate_report
                ;;
            0)
                print_status "Exiting Troubleshooting Guide"
                exit 0
                ;;
            *)
                print_error "Invalid option. Please select 0-10."
                ;;
        esac
        
        echo
        read -p "Press Enter to continue..."
    done
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

