#!/bin/bash

# HTTP/HTTPS Troubleshooting Script
# Comprehensive tool for diagnosing HTTP issues

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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to test basic connectivity
test_connectivity() {
    local url=$1
    
    print_header "Testing Basic Connectivity"
    
    # Extract hostname and port
    if [[ $url =~ ^https?://([^:/]+)(:([0-9]+))? ]]; then
        hostname="${BASH_REMATCH[1]}"
        port="${BASH_REMATCH[3]:-80}"
        if [[ $url == https://* ]]; then
            port="${BASH_REMATCH[3]:-443}"
        fi
    else
        print_error "Invalid URL format"
        return 1
    fi
    
    echo "Hostname: $hostname"
    echo "Port: $port"
    
    # Test DNS resolution
    echo -e "\n🔍 DNS Resolution:"
    if nslookup "$hostname" >/dev/null 2>&1; then
        print_success "DNS resolution successful"
        nslookup "$hostname" | grep -A1 "Name:"
    else
        print_error "DNS resolution failed"
        return 1
    fi
    
    # Test port connectivity
    echo -e "\n🔌 Port Connectivity:"
    if timeout 5 bash -c "echo >/dev/tcp/$hostname/$port" 2>/dev/null; then
        print_success "Port $port is open"
    else
        print_error "Port $port is closed or filtered"
        return 1
    fi
}

# Function to test HTTP response
test_http_response() {
    local url=$1
    
    print_header "Testing HTTP Response"
    
    if command_exists curl; then
        echo "Using curl for HTTP testing..."
        
        # Basic request
        echo -e "\n📤 Basic Request:"
        if curl -s -o /dev/null -w "HTTP Code: %{http_code}\nTotal Time: %{time_total}s\n" "$url"; then
            print_success "HTTP request successful"
        else
            print_error "HTTP request failed"
        fi
        
        # Verbose request
        echo -e "\n📋 Verbose Request Details:"
        curl -v "$url" 2>&1 | head -20
        
        # Headers only
        echo -e "\n📋 Response Headers:"
        curl -I "$url" 2>/dev/null || print_error "Failed to get headers"
        
    else
        print_warning "curl not available, trying wget..."
        if command_exists wget; then
            wget --spider -S "$url" 2>&1 | head -10
        else
            print_error "Neither curl nor wget available"
        fi
    fi
}

# Function to test HTTPS/SSL
test_https_ssl() {
    local url=$1
    
    if [[ $url != https://* ]]; then
        print_warning "URL is not HTTPS, skipping SSL test"
        return
    fi
    
    print_header "Testing HTTPS/SSL"
    
    # Extract hostname and port
    if [[ $url =~ ^https://([^:/]+)(:([0-9]+))? ]]; then
        hostname="${BASH_REMATCH[1]}"
        port="${BASH_REMATCH[3]:-443}"
    else
        print_error "Invalid HTTPS URL format"
        return 1
    fi
    
    # Test SSL connection
    echo -e "\n🔐 SSL Connection Test:"
    if command_exists openssl; then
        if echo | openssl s_client -connect "$hostname:$port" -servername "$hostname" 2>/dev/null | grep -q "Verify return code: 0"; then
            print_success "SSL certificate is valid"
        else
            print_warning "SSL certificate issues detected"
        fi
        
        # Get certificate details
        echo -e "\n📜 Certificate Details:"
        echo | openssl s_client -connect "$hostname:$port" -servername "$hostname" 2>/dev/null | openssl x509 -noout -text | head -20
        
        # Check certificate expiry
        echo -e "\n⏰ Certificate Expiry:"
        expiry=$(echo | openssl s_client -connect "$hostname:$port" -servername "$hostname" 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2)
        echo "Expires: $expiry"
        
    else
        print_warning "OpenSSL not available for SSL testing"
    fi
}

# Function to test HTTP methods
test_http_methods() {
    local url=$1
    
    print_header "Testing HTTP Methods"
    
    if ! command_exists curl; then
        print_warning "curl not available for method testing"
        return
    fi
    
    methods=("GET" "POST" "PUT" "DELETE" "HEAD" "OPTIONS")
    
    for method in "${methods[@]}"; do
        echo -n "Testing $method: "
        if curl -s -o /dev/null -w "%{http_code}" -X "$method" "$url" >/dev/null 2>&1; then
            status_code=$(curl -s -o /dev/null -w "%{http_code}" -X "$method" "$url")
            if [[ $status_code -lt 400 ]]; then
                print_success "$method: $status_code"
            else
                print_warning "$method: $status_code"
            fi
        else
            print_error "$method: Failed"
        fi
    done
}

# Function to test performance
test_performance() {
    local url=$1
    local iterations=${2:-5}
    
    print_header "Performance Test ($iterations iterations)"
    
    if ! command_exists curl; then
        print_warning "curl not available for performance testing"
        return
    fi
    
    times=()
    
    for ((i=1; i<=iterations; i++)); do
        echo -n "Iteration $i: "
        
        start_time=$(date +%s%3N)
        if curl -s -o /dev/null "$url" >/dev/null 2>&1; then
            end_time=$(date +%s%3N)
            duration=$((end_time - start_time))
            times+=($duration)
            print_success "${duration}ms"
        else
            print_error "Failed"
        fi
    done
    
    if [ ${#times[@]} -gt 0 ]; then
        sum=0
        for time in "${times[@]}"; do
            sum=$((sum + time))
        done
        avg=$((sum / ${#times[@]}))
        
        min=${times[0]}
        max=${times[0]}
        for time in "${times[@]}"; do
            if [ $time -lt $min ]; then min=$time; fi
            if [ $time -gt $max ]; then max=$time; fi
        done
        
        echo -e "\n📊 Performance Summary:"
        echo "  Average: ${avg}ms"
        echo "  Minimum: ${min}ms"
        echo "  Maximum: ${max}ms"
    fi
}

# Function to test redirects
test_redirects() {
    local url=$1
    
    print_header "Testing Redirects"
    
    if ! command_exists curl; then
        print_warning "curl not available for redirect testing"
        return
    fi
    
    echo "Testing redirects for: $url"
    
    # Follow redirects and show the chain
    curl -L -v "$url" 2>&1 | grep -E "(< HTTP|< Location|> GET|> Host)" | head -20
}

# Function to test headers
test_headers() {
    local url=$1
    
    print_header "Testing HTTP Headers"
    
    if ! command_exists curl; then
        print_warning "curl not available for header testing"
        return
    fi
    
    echo "Request Headers:"
    curl -v "$url" 2>&1 | grep ">" | head -10
    
    echo -e "\nResponse Headers:"
    curl -I "$url" 2>/dev/null || print_error "Failed to get headers"
}

# Function to show help
show_help() {
    echo "HTTP/HTTPS Troubleshooting Script"
    echo ""
    echo "Usage: $0 [OPTIONS] URL"
    echo ""
    echo "Options:"
    echo "  -c, --connectivity    Test basic connectivity"
    echo "  -r, --response        Test HTTP response"
    echo "  -s, --ssl            Test HTTPS/SSL (if HTTPS URL)"
    echo "  -m, --methods        Test different HTTP methods"
    echo "  -p, --performance N  Run performance test (N iterations)"
    echo "  -d, --redirects      Test redirect handling"
    echo "  -h, --headers        Test HTTP headers"
    echo "  -a, --all            Run all tests"
    echo "  --help               Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 http://example.com"
    echo "  $0 -a https://example.com"
    echo "  $0 -p 10 http://example.com"
    echo "  $0 -s -m https://example.com"
}

# Main function
main() {
    local url=""
    local connectivity=false
    local response=false
    local ssl=false
    local methods=false
    local performance=0
    local redirects=false
    local headers=false
    local all=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--connectivity)
                connectivity=true
                shift
                ;;
            -r|--response)
                response=true
                shift
                ;;
            -s|--ssl)
                ssl=true
                shift
                ;;
            -m|--methods)
                methods=true
                shift
                ;;
            -p|--performance)
                performance="$2"
                shift 2
                ;;
            -d|--redirects)
                redirects=true
                shift
                ;;
            -h|--headers)
                headers=true
                shift
                ;;
            -a|--all)
                all=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            -*)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                if [ -z "$url" ]; then
                    url="$1"
                else
                    echo "Multiple URLs specified"
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Check if URL is provided
    if [ -z "$url" ]; then
        echo "Error: URL is required"
        show_help
        exit 1
    fi
    
    # If no specific tests selected, run basic tests
    if [ "$all" = false ] && [ "$connectivity" = false ] && [ "$response" = false ] && [ "$ssl" = false ] && [ "$methods" = false ] && [ "$performance" -eq 0 ] && [ "$redirects" = false ] && [ "$headers" = false ]; then
        connectivity=true
        response=true
        if [[ $url == https://* ]]; then
            ssl=true
        fi
    fi
    
    # Run selected tests
    if [ "$all" = true ] || [ "$connectivity" = true ]; then
        test_connectivity "$url"
    fi
    
    if [ "$all" = true ] || [ "$response" = true ]; then
        test_http_response "$url"
    fi
    
    if [ "$all" = true ] || [ "$ssl" = true ]; then
        test_https_ssl "$url"
    fi
    
    if [ "$all" = true ] || [ "$methods" = true ]; then
        test_http_methods "$url"
    fi
    
    if [ "$all" = true ] || [ "$performance" -gt 0 ]; then
        test_performance "$url" "$performance"
    fi
    
    if [ "$all" = true ] || [ "$redirects" = true ]; then
        test_redirects "$url"
    fi
    
    if [ "$all" = true ] || [ "$headers" = true ]; then
        test_headers "$url"
    fi
    
    print_success "HTTP troubleshooting complete for $url"
}

# Run main function with all arguments
main "$@"
