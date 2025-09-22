#!/bin/bash

# DNS Troubleshooting Script
# Comprehensive DNS diagnostic tool

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

# Function to test DNS resolution
test_dns_resolution() {
    local domain=$1
    local dns_server=$2
    
    print_header "Testing DNS Resolution for $domain"
    
    if [ -n "$dns_server" ]; then
        echo "Using DNS server: $dns_server"
        dig @$dns_server $domain +short
    else
        echo "Using system DNS servers"
        dig $domain +short
    fi
}

# Function to check DNS configuration
check_dns_config() {
    print_header "DNS Configuration Check"
    
    echo "📋 /etc/resolv.conf:"
    if [ -f /etc/resolv.conf ]; then
        cat /etc/resolv.conf
    else
        print_warning "/etc/resolv.conf not found"
    fi
    
    echo -e "\n📋 /etc/hosts:"
    if [ -f /etc/hosts ]; then
        cat /etc/hosts
    else
        print_warning "/etc/hosts not found"
    fi
    
    # Check systemd-resolved if available
    if command_exists systemctl; then
        echo -e "\n📋 systemd-resolved status:"
        if systemctl is-active --quiet systemd-resolved; then
            print_success "systemd-resolved is active"
            resolvectl status 2>/dev/null || echo "resolvectl not available"
        else
            print_warning "systemd-resolved is not active"
        fi
    fi
}

# Function to test different DNS servers
test_dns_servers() {
    local domain=$1
    
    print_header "Testing Different DNS Servers"
    
    local servers=(
        "8.8.8.8:Google DNS"
        "1.1.1.1:Cloudflare"
        "9.9.9.9:Quad9"
        "208.67.222.222:OpenDNS"
    )
    
    for server_info in "${servers[@]}"; do
        IFS=':' read -r server name <<< "$server_info"
        echo -e "\n${BLUE}$name ($server):${NC}"
        
        if dig @$server $domain +short >/dev/null 2>&1; then
            result=$(dig @$server $domain +short)
            print_success "Resolved: $result"
        else
            print_error "Failed to resolve"
        fi
    done
}

# Function to trace DNS resolution
trace_dns() {
    local domain=$1
    
    print_header "Tracing DNS Resolution for $domain"
    
    if command_exists dig; then
        dig +trace $domain
    else
        print_error "dig command not found"
    fi
}

# Function to check specific record types
check_record_types() {
    local domain=$1
    
    print_header "Checking DNS Record Types for $domain"
    
    local record_types=("A" "AAAA" "MX" "NS" "TXT" "SOA" "CNAME")
    
    for record_type in "${record_types[@]}"; do
        echo -e "\n${BLUE}$record_type Record:${NC}"
        if dig $domain $record_type +short >/dev/null 2>&1; then
            result=$(dig $domain $record_type +short)
            if [ -n "$result" ]; then
                print_success "$result"
            else
                print_warning "No $record_type record found"
            fi
        else
            print_error "Failed to query $record_type record"
        fi
    done
}

# Function to check DNSSEC
check_dnssec() {
    local domain=$1
    
    print_header "Checking DNSSEC Support for $domain"
    
    if command_exists dig; then
        if dig +dnssec $domain >/dev/null 2>&1; then
            print_success "DNSSEC is supported"
            dig +dnssec $domain | grep -E "(RRSIG|DNSKEY)" || echo "No DNSSEC records found"
        else
            print_warning "DNSSEC not supported or not configured"
        fi
    else
        print_error "dig command not found"
    fi
}

# Function to test DNS performance
test_dns_performance() {
    local domain=$1
    local iterations=${2:-5}
    
    print_header "DNS Performance Test ($iterations iterations)"
    
    local times=()
    
    for ((i=1; i<=iterations; i++)); do
        echo -n "Iteration $i: "
        
        start_time=$(date +%s%3N)
        if dig $domain +short >/dev/null 2>&1; then
            end_time=$(date +%s%3N)
            duration=$((end_time - start_time))
            times+=($duration)
            echo "${duration}ms"
        else
            echo "Failed"
        fi
    done
    
    if [ ${#times[@]} -gt 0 ]; then
        local sum=0
        for time in "${times[@]}"; do
            sum=$((sum + time))
        done
        local avg=$((sum / ${#times[@]}))
        
        local min=${times[0]}
        local max=${times[0]}
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

# Function to check DNS cache
check_dns_cache() {
    print_header "DNS Cache Check"
    
    if command_exists systemctl; then
        if systemctl is-active --quiet systemd-resolved; then
            echo "systemd-resolved cache statistics:"
            resolvectl statistics 2>/dev/null || echo "Cache statistics not available"
        else
            print_warning "systemd-resolved not active"
        fi
    fi
    
    if command_exists nscd; then
        if systemctl is-active --quiet nscd; then
            echo -e "\nnscd cache statistics:"
            nscd -g 2>/dev/null || echo "nscd statistics not available"
        else
            print_warning "nscd not active"
        fi
    fi
}

# Function to flush DNS cache
flush_dns_cache() {
    print_header "Flushing DNS Cache"
    
    if command_exists systemctl; then
        if systemctl is-active --quiet systemd-resolved; then
            print_success "Flushing systemd-resolved cache"
            resolvectl flush-caches 2>/dev/null || print_warning "Failed to flush systemd-resolved cache"
        fi
    fi
    
    if command_exists nscd; then
        if systemctl is-active --quiet nscd; then
            print_success "Flushing nscd cache"
            systemctl restart nscd 2>/dev/null || print_warning "Failed to restart nscd"
        fi
    fi
    
    print_success "DNS cache flush complete"
}

# Function to show help
show_help() {
    echo "DNS Troubleshooting Script"
    echo ""
    echo "Usage: $0 [OPTIONS] DOMAIN"
    echo ""
    echo "Options:"
    echo "  -s, --server SERVER    Use specific DNS server"
    echo "  -t, --trace           Trace DNS resolution path"
    echo "  -r, --records         Check all record types"
    echo "  -d, --dnssec          Check DNSSEC support"
    echo "  -p, --performance N   Run performance test (N iterations)"
    echo "  -c, --cache           Check DNS cache status"
    echo "  -f, --flush           Flush DNS cache"
    echo "  -a, --all             Run all tests"
    echo "  -h, --help            Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 google.com"
    echo "  $0 -s 8.8.8.8 google.com"
    echo "  $0 -t -r google.com"
    echo "  $0 -a google.com"
}

# Main function
main() {
    local domain=""
    local dns_server=""
    local trace=false
    local records=false
    local dnssec=false
    local performance=0
    local cache=false
    local flush=false
    local all=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--server)
                dns_server="$2"
                shift 2
                ;;
            -t|--trace)
                trace=true
                shift
                ;;
            -r|--records)
                records=true
                shift
                ;;
            -d|--dnssec)
                dnssec=true
                shift
                ;;
            -p|--performance)
                performance="$2"
                shift 2
                ;;
            -c|--cache)
                cache=true
                shift
                ;;
            -f|--flush)
                flush=true
                shift
                ;;
            -a|--all)
                all=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            -*)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                if [ -z "$domain" ]; then
                    domain="$1"
                else
                    echo "Multiple domains specified"
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Check if domain is provided
    if [ -z "$domain" ]; then
        echo "Error: Domain is required"
        show_help
        exit 1
    fi
    
    # Check required commands
    if ! command_exists dig; then
        print_error "dig command not found. Please install dnsutils package."
        exit 1
    fi
    
    # Run tests based on options
    if [ "$all" = true ]; then
        check_dns_config
        test_dns_resolution "$domain" "$dns_server"
        test_dns_servers "$domain"
        trace_dns "$domain"
        check_record_types "$domain"
        check_dnssec "$domain"
        test_dns_performance "$domain" 5
        check_dns_cache
    else
        check_dns_config
        test_dns_resolution "$domain" "$dns_server"
        
        if [ "$trace" = true ]; then
            trace_dns "$domain"
        fi
        
        if [ "$records" = true ]; then
            check_record_types "$domain"
        fi
        
        if [ "$dnssec" = true ]; then
            check_dnssec "$domain"
        fi
        
        if [ "$performance" -gt 0 ]; then
            test_dns_performance "$domain" "$performance"
        fi
        
        if [ "$cache" = true ]; then
            check_dns_cache
        fi
        
        if [ "$flush" = true ]; then
            flush_dns_cache
        fi
    fi
    
    print_success "DNS troubleshooting complete for $domain"
}

# Run main function with all arguments
main "$@"
