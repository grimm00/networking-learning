#!/bin/bash

# DNS Troubleshooting Script
# Comprehensive DNS diagnostics and testing

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

# Default values
DOMAIN="example.com"
SERVER="localhost"
TIMEOUT=5
VERBOSE=false

# Function to show help
show_help() {
    echo "DNS Troubleshooting Script"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -d, --domain DOMAIN     Domain to test (default: example.com)"
    echo "  -s, --server SERVER     DNS server to test (default: localhost)"
    echo "  -t, --timeout SECONDS   Timeout for queries (default: 5)"
    echo "  -v, --verbose           Verbose output"
    echo "  -h, --help              Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 -d google.com -s 8.8.8.8"
    echo "  $0 -d example.com -s localhost -v"
    echo "  $0 --domain internal.local --server 192.168.1.100"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--domain)
            DOMAIN="$2"
            shift 2
            ;;
        -s|--server)
            SERVER="$2"
            shift 2
            ;;
        -t|--timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Function to run DNS query
run_dns_query() {
    local query_type="$1"
    local domain="$2"
    local server="$3"
    local timeout="$4"
    
    if command -v dig >/dev/null 2>&1; then
        dig @"$server" "$domain" "$query_type" +time="$timeout" +short
    elif command -v nslookup >/dev/null 2>&1; then
        nslookup -type="$query_type" "$domain" "$server" 2>/dev/null | grep -E "^$domain|^Address:" | tail -1
    else
        print_error "Neither dig nor nslookup found"
        return 1
    fi
}

# Function to test DNS server connectivity
test_server_connectivity() {
    print_header "Testing DNS Server Connectivity"
    
    print_info "Testing server: $SERVER"
    print_info "Domain: $DOMAIN"
    print_info "Timeout: $TIMEOUT seconds"
    echo ""
    
    # Test basic connectivity
    if ping -c 1 -W "$TIMEOUT" "$SERVER" >/dev/null 2>&1; then
        print_success "Server $SERVER is reachable"
    else
        print_error "Server $SERVER is not reachable"
        return 1
    fi
    
    # Test DNS port
    if timeout "$TIMEOUT" bash -c "echo > /dev/tcp/$SERVER/53" 2>/dev/null; then
        print_success "DNS port 53 is open on $SERVER"
    else
        print_error "DNS port 53 is not accessible on $SERVER"
        return 1
    fi
}

# Function to test basic DNS resolution
test_basic_resolution() {
    print_header "Testing Basic DNS Resolution"
    
    # Test A record
    print_info "Testing A record for $DOMAIN"
    local a_record
    a_record=$(run_dns_query "A" "$DOMAIN" "$SERVER" "$TIMEOUT")
    if [ -n "$a_record" ]; then
        print_success "A record: $a_record"
    else
        print_error "No A record found for $DOMAIN"
    fi
    
    # Test AAAA record
    print_info "Testing AAAA record for $DOMAIN"
    local aaaa_record
    aaaa_record=$(run_dns_query "AAAA" "$DOMAIN" "$SERVER" "$TIMEOUT")
    if [ -n "$aaaa_record" ]; then
        print_success "AAAA record: $aaaa_record"
    else
        print_warning "No AAAA record found for $DOMAIN"
    fi
    
    # Test MX record
    print_info "Testing MX record for $DOMAIN"
    local mx_record
    mx_record=$(run_dns_query "MX" "$DOMAIN" "$SERVER" "$TIMEOUT")
    if [ -n "$mx_record" ]; then
        print_success "MX record: $mx_record"
    else
        print_warning "No MX record found for $DOMAIN"
    fi
    
    # Test NS record
    print_info "Testing NS record for $DOMAIN"
    local ns_record
    ns_record=$(run_dns_query "NS" "$DOMAIN" "$SERVER" "$TIMEOUT")
    if [ -n "$ns_record" ]; then
        print_success "NS record: $ns_record"
    else
        print_warning "No NS record found for $DOMAIN"
    fi
}

# Function to test DNS performance
test_dns_performance() {
    print_header "Testing DNS Performance"
    
    print_info "Running performance test with 10 queries..."
    
    local total_time=0
    local success_count=0
    
    for i in {1..10}; do
        local start_time=$(date +%s.%N)
        local result
        result=$(run_dns_query "A" "$DOMAIN" "$SERVER" "$TIMEOUT")
        local end_time=$(date +%s.%N)
        
        if [ -n "$result" ]; then
            local query_time=$(echo "$end_time - $start_time" | bc -l)
            total_time=$(echo "$total_time + $query_time" | bc -l)
            success_count=$((success_count + 1))
            
            if [ "$VERBOSE" = true ]; then
                print_info "Query $i: ${query_time}s - $result"
            fi
        else
            print_warning "Query $i failed"
        fi
    done
    
    if [ $success_count -gt 0 ]; then
        local avg_time=$(echo "scale=3; $total_time / $success_count" | bc -l)
        print_success "Performance test completed"
        print_info "Successful queries: $success_count/10"
        print_info "Average response time: ${avg_time}s"
    else
        print_error "All performance test queries failed"
    fi
}

# Function to test DNS recursion
test_dns_recursion() {
    print_header "Testing DNS Recursion"
    
    # Test recursive query
    print_info "Testing recursive query for $DOMAIN"
    local recursive_result
    recursive_result=$(run_dns_query "A" "$DOMAIN" "$SERVER" "$TIMEOUT")
    
    if [ -n "$recursive_result" ]; then
        print_success "Recursive query successful: $recursive_result"
    else
        print_error "Recursive query failed"
    fi
    
    # Test non-recursive query
    print_info "Testing non-recursive query for $DOMAIN"
    if command -v dig >/dev/null 2>&1; then
        local non_recursive_result
        non_recursive_result=$(dig @"$SERVER" "$DOMAIN" A +norecurse +time="$TIMEOUT" +short)
        if [ -n "$non_recursive_result" ]; then
            print_success "Non-recursive query successful: $non_recursive_result"
        else
            print_warning "Non-recursive query returned no results (expected for non-authoritative servers)"
        fi
    fi
}

# Function to test DNS security
test_dns_security() {
    print_header "Testing DNS Security"
    
    # Test DNSSEC
    print_info "Testing DNSSEC for $DOMAIN"
    if command -v dig >/dev/null 2>&1; then
        local dnssec_result
        dnssec_result=$(dig @"$SERVER" "$DOMAIN" A +dnssec +time="$TIMEOUT" 2>/dev/null | grep -c "RRSIG")
        if [ "$dnssec_result" -gt 0 ]; then
            print_success "DNSSEC is enabled ($dnssec_result signatures found)"
        else
            print_warning "DNSSEC is not enabled or not supported"
        fi
    fi
    
    # Test DNS over TLS
    print_info "Testing DNS over TLS support"
    if command -v dig >/dev/null 2>&1; then
        local dot_result
        dot_result=$(timeout "$TIMEOUT" dig @"$SERVER" "$DOMAIN" A +tls 2>/dev/null | grep -c "ANSWER:")
        if [ "$dot_result" -gt 0 ]; then
            print_success "DNS over TLS is supported"
        else
            print_warning "DNS over TLS is not supported or not configured"
        fi
    fi
}

# Function to show DNS server information
show_dns_info() {
    print_header "DNS Server Information"
    
    print_info "Server: $SERVER"
    print_info "Domain: $DOMAIN"
    print_info "Timeout: $TIMEOUT seconds"
    echo ""
    
    # Show server version (if available)
    if command -v dig >/dev/null 2>&1; then
        print_info "Server version information:"
        dig @"$SERVER" version.bind txt chaos +time="$TIMEOUT" 2>/dev/null | grep -E "version.bind|ANSWER:" || print_warning "Version information not available"
    fi
    
    # Show server statistics
    if command -v dig >/dev/null 2>&1; then
        print_info "Server statistics:"
        dig @"$SERVER" hostname.bind txt chaos +time="$TIMEOUT" 2>/dev/null | grep -E "hostname.bind|ANSWER:" || print_warning "Statistics not available"
    fi
}

# Function to run comprehensive test
run_comprehensive_test() {
    print_header "Comprehensive DNS Troubleshooting"
    print_info "Testing DNS server: $SERVER"
    print_info "Domain: $DOMAIN"
    echo ""
    
    # Run all tests
    test_server_connectivity || return 1
    echo ""
    
    show_dns_info
    echo ""
    
    test_basic_resolution
    echo ""
    
    test_dns_recursion
    echo ""
    
    test_dns_performance
    echo ""
    
    test_dns_security
    echo ""
    
    print_success "Comprehensive DNS test completed"
}

# Main execution
main() {
    print_header "DNS Troubleshooting Tool"
    
    # Check if required tools are available
    if ! command -v dig >/dev/null 2>&1 && ! command -v nslookup >/dev/null 2>&1; then
        print_error "Neither dig nor nslookup is available"
        print_info "Please install bind-utils or dnsutils package"
        exit 1
    fi
    
    # Run comprehensive test
    run_comprehensive_test
}

# Run main function
main