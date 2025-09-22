#!/bin/bash

# NTP Troubleshooting Script
# Comprehensive NTP diagnostics and troubleshooting tool

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default values
SERVER=""
PORT=123
TIMEOUT=10
VERBOSE=false
COMPREHENSIVE=false
SECURITY=false
PERFORMANCE=false
TEST_COUNT=10

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

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

# Function to show usage
show_usage() {
    echo "NTP Troubleshooting Script"
    echo ""
    echo "Usage: $0 [OPTIONS] SERVER"
    echo ""
    echo "Options:"
    echo "  -p, --port PORT        NTP port (default: 123)"
    echo "  -t, --timeout SECONDS  Query timeout (default: 10)"
    echo "  -v, --verbose          Verbose output"
    echo "  -a, --all              Comprehensive analysis"
    echo "  -s, --security         Security-focused analysis"
    echo "  -p, --performance      Performance testing"
    echo "  -c, --count NUM        Number of performance tests (default: 10)"
    echo "  -h, --help             Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 pool.ntp.org"
    echo "  $0 -a -s time.google.com"
    echo "  $0 --performance --count 20 pool.ntp.org"
}

# Function to check dependencies
check_dependencies() {
    local missing_deps=()
    
    # Check for required commands
    for cmd in ntpq ntpdate; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        print_info "Install with: apt-get install ntp ntpdate"
        exit 1
    fi
}

# Function to test basic connectivity
test_connectivity() {
    print_header "Testing Basic Connectivity"
    
    # Test if server is reachable
    print_info "Testing server reachability..."
    if ping -c 1 -W 3 "$SERVER" >/dev/null 2>&1; then
        print_success "Server is reachable via ping"
    else
        print_warning "Server is not reachable via ping (may be filtered)"
    fi
    
    # Test NTP port
    print_info "Testing NTP port $PORT..."
    if timeout "$TIMEOUT" bash -c "echo > /dev/udp/$SERVER/$PORT" 2>/dev/null; then
        print_success "NTP port $PORT is open"
    else
        print_error "NTP port $PORT is closed or filtered"
        return 1
    fi
    
    # Test with telnet (UDP)
    print_info "Testing with netcat..."
    if timeout "$TIMEOUT" nc -u -z "$SERVER" "$PORT" 2>/dev/null; then
        print_success "NTP service detected via netcat"
    else
        print_warning "NTP service not detected via netcat"
    fi
}

# Function to query NTP server
query_ntp_server() {
    print_header "NTP Server Query"
    
    print_info "Querying NTP server: $SERVER:$PORT"
    
    # Test with ntpdate
    print_info "Testing with ntpdate..."
    if timeout "$TIMEOUT" ntpdate -q "$SERVER" >/dev/null 2>&1; then
        print_success "NTP query successful with ntpdate"
        
        # Get detailed information
        print_info "NTP server information:"
        timeout "$TIMEOUT" ntpdate -q "$SERVER" 2>&1 | sed 's/^/  /'
    else
        print_error "NTP query failed with ntpdate"
    fi
    
    # Test with ntpq if available
    if command -v ntpq >/dev/null 2>&1; then
        print_info "Testing with ntpq..."
        if timeout "$TIMEOUT" ntpq -p "$SERVER" >/dev/null 2>&1; then
            print_success "NTP query successful with ntpq"
            
            print_info "NTP peer information:"
            timeout "$TIMEOUT" ntpq -p "$SERVER" 2>&1 | sed 's/^/  /'
        else
            print_warning "NTP query failed with ntpq"
        fi
    fi
}

# Function to analyze NTP configuration
analyze_ntp_config() {
    print_header "NTP Configuration Analysis"
    
    # Check if NTP is running
    print_info "Checking NTP service status..."
    if systemctl is-active --quiet ntp 2>/dev/null; then
        print_success "NTP service is running"
        
        # Show NTP status
        print_info "NTP service status:"
        systemctl status ntp --no-pager -l | sed 's/^/  /'
    elif systemctl is-active --quiet chrony 2>/dev/null; then
        print_success "Chrony service is running"
        
        # Show Chrony status
        print_info "Chrony service status:"
        systemctl status chrony --no-pager -l | sed 's/^/  /'
    else
        print_warning "No NTP service running"
    fi
    
    # Check NTP configuration
    if [ -f /etc/ntp.conf ]; then
        print_info "Found NTP configuration: /etc/ntp.conf"
        
        # Show server configuration
        print_info "Configured NTP servers:"
        grep "^server" /etc/ntp.conf 2>/dev/null | sed 's/^/  /' || echo "  No servers configured"
        
        # Show access control
        print_info "Access control rules:"
        grep "^restrict" /etc/ntp.conf 2>/dev/null | sed 's/^/  /' || echo "  No access control rules"
    else
        print_info "No NTP configuration found"
    fi
    
    # Check Chrony configuration
    if [ -f /etc/chrony.conf ]; then
        print_info "Found Chrony configuration: /etc/chrony.conf"
        
        # Show server configuration
        print_info "Configured Chrony servers:"
        grep "^server\|^pool" /etc/chrony.conf 2>/dev/null | sed 's/^/  /' || echo "  No servers configured"
    fi
}

# Function to test NTP synchronization
test_ntp_sync() {
    print_header "NTP Synchronization Test"
    
    print_info "Testing time synchronization..."
    
    # Check current time status
    if command -v timedatectl >/dev/null 2>&1; then
        print_info "System time status:"
        timedatectl status | sed 's/^/  /'
    fi
    
    # Test synchronization with specific server
    print_info "Testing synchronization with $SERVER..."
    if timeout "$TIMEOUT" ntpdate -s "$SERVER" 2>/dev/null; then
        print_success "Time synchronized successfully"
    else
        print_error "Time synchronization failed"
    fi
    
    # Check NTP statistics
    if command -v ntpq >/dev/null 2>&1; then
        print_info "NTP statistics:"
        timeout "$TIMEOUT" ntpq -c "rv" 2>/dev/null | sed 's/^/  /' || echo "  No NTP statistics available"
    fi
}

# Function to perform security analysis
security_analysis() {
    print_header "Security Analysis"
    
    print_info "Checking NTP security configuration..."
    
    # Check for authentication
    if [ -f /etc/ntp.conf ]; then
        if grep -q "keys\|trustedkey\|requestkey" /etc/ntp.conf 2>/dev/null; then
            print_success "NTP authentication configured"
            print_info "Authentication settings:"
            grep "keys\|trustedkey\|requestkey" /etc/ntp.conf 2>/dev/null | sed 's/^/  /'
        else
            print_warning "No NTP authentication configured"
        fi
        
        # Check access control
        if grep -q "^restrict" /etc/ntp.conf 2>/dev/null; then
            print_success "NTP access control configured"
            print_info "Access control rules:"
            grep "^restrict" /etc/ntp.conf 2>/dev/null | sed 's/^/  /'
        else
            print_warning "No NTP access control configured"
        fi
    fi
    
    # Check for security issues
    print_info "Checking for common security issues..."
    
    # Test for NTP amplification attacks
    print_info "Testing for NTP amplification vulnerability..."
    if timeout 5 ntpdate -q "$SERVER" 2>&1 | grep -q "no server suitable"; then
        print_warning "Server may be vulnerable to amplification attacks"
    else
        print_success "Server appears to be properly configured"
    fi
}

# Function to perform performance testing
performance_test() {
    print_header "Performance Testing"
    
    print_info "Running $TEST_COUNT NTP queries..."
    
    local times=()
    local successful=0
    
    for i in $(seq 1 "$TEST_COUNT"); do
        print_info "Test $i/$TEST_COUNT..."
        
        local start_time
        start_time=$(date +%s.%N)
        
        if timeout "$TIMEOUT" ntpdate -q "$SERVER" >/dev/null 2>&1; then
            local end_time
            end_time=$(date +%s.%N)
            local duration
            duration=$(echo "$end_time - $start_time" | bc)
            times+=("$duration")
            ((successful++))
            print_success "Test $i completed in ${duration}s"
        else
            print_error "Test $i failed"
        fi
    done
    
    if [ ${#times[@]} -gt 0 ]; then
        # Calculate statistics
        local total=0
        for time in "${times[@]}"; do
            total=$(echo "$total + $time" | bc)
        done
        
        local avg
        avg=$(echo "scale=3; $total / ${#times[@]}" | bc)
        
        local min=${times[0]}
        local max=${times[0]}
        for time in "${times[@]}"; do
            if (( $(echo "$time < $min" | bc -l) )); then
                min=$time
            fi
            if (( $(echo "$time > $max" | bc -l) )); then
                max=$time
            fi
        done
        
        # Calculate jitter (standard deviation)
        local variance=0
        for time in "${times[@]}"; do
            local diff
            diff=$(echo "$time - $avg" | bc)
            local square
            square=$(echo "$diff * $diff" | bc)
            variance=$(echo "$variance + $square" | bc)
        done
        local jitter
        jitter=$(echo "scale=3; sqrt($variance / ${#times[@]})" | bc)
        
        print_success "Performance Results:"
        print_info "  Successful queries: $successful/$TEST_COUNT"
        print_info "  Average time: ${avg}s"
        print_info "  Minimum time: ${min}s"
        print_info "  Maximum time: ${max}s"
        print_info "  Jitter: ${jitter}s"
    else
        print_error "No successful queries for performance testing"
    fi
}

# Function to check NTP logs
check_ntp_logs() {
    print_header "NTP Log Analysis"
    
    print_info "Checking NTP logs..."
    
    # Check system logs for NTP activity
    local log_files=("/var/log/ntp.log" "/var/log/syslog" "/var/log/messages")
    
    for log_file in "${log_files[@]}"; do
        if [ -f "$log_file" ]; then
            print_info "Found log file: $log_file"
            
            # Show recent NTP activity
            if grep -q "ntp\|chrony" "$log_file" 2>/dev/null; then
                print_info "Recent NTP activity:"
                grep "ntp\|chrony" "$log_file" 2>/dev/null | tail -5 | sed 's/^/  /'
            else
                print_info "No NTP activity found in $log_file"
            fi
            break
        fi
    done
    
    # Check journal logs
    if command -v journalctl >/dev/null 2>&1; then
        print_info "Checking systemd journal for NTP activity..."
        journalctl -u ntp -u chrony --no-pager -n 10 2>/dev/null | sed 's/^/  /' || echo "  No NTP journal entries found"
    fi
}

# Function to provide troubleshooting recommendations
provide_recommendations() {
    print_header "Troubleshooting Recommendations"
    
    print_info "Common NTP issues and solutions:"
    echo ""
    echo "1. Time Synchronization Issues:"
    echo "   - Check if NTP service is running: systemctl status ntp"
    echo "   - Verify server accessibility: ntpdate -q $SERVER"
    echo "   - Check firewall settings for port 123/UDP"
    echo ""
    echo "2. Configuration Problems:"
    echo "   - Verify /etc/ntp.conf syntax: ntpd -t"
    echo "   - Check server configuration: grep '^server' /etc/ntp.conf"
    echo "   - Test with different servers"
    echo ""
    echo "3. Network Issues:"
    echo "   - Check network connectivity: ping $SERVER"
    echo "   - Test UDP port 123: nc -u -z $SERVER 123"
    echo "   - Check for firewall blocking"
    echo ""
    echo "4. Security Issues:"
    echo "   - Configure NTP authentication"
    echo "   - Set up access control rules"
    echo "   - Monitor for amplification attacks"
    echo ""
    echo "5. Performance Issues:"
    echo "   - Use closer NTP servers"
    echo "   - Check network latency"
    echo "   - Consider using NTP pools"
}

# Main function
main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--port)
                PORT="$2"
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
            -a|--all)
                COMPREHENSIVE=true
                shift
                ;;
            -s|--security)
                SECURITY=true
                shift
                ;;
            --performance)
                PERFORMANCE=true
                shift
                ;;
            -c|--count)
                TEST_COUNT="$2"
                shift 2
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            -*)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
            *)
                if [ -z "$SERVER" ]; then
                    SERVER="$1"
                else
                    print_error "Multiple servers specified"
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Check if server is provided
    if [ -z "$SERVER" ]; then
        print_error "Server is required"
        show_usage
        exit 1
    fi
    
    # Check dependencies
    check_dependencies
    
    # Start analysis
    print_header "NTP Troubleshooting Analysis"
    print_info "Target: $SERVER:$PORT"
    echo ""
    
    # Basic connectivity test
    test_connectivity
    
    # NTP server query
    query_ntp_server
    
    # Configuration analysis
    analyze_ntp_config
    
    # Synchronization test
    test_ntp_sync
    
    # Security analysis
    if [ "$SECURITY" = true ] || [ "$COMPREHENSIVE" = true ]; then
        security_analysis
    fi
    
    # Performance testing
    if [ "$PERFORMANCE" = true ] || [ "$COMPREHENSIVE" = true ]; then
        performance_test
    fi
    
    # Log analysis
    if [ "$COMPREHENSIVE" = true ]; then
        check_ntp_logs
    fi
    
    # Provide recommendations
    provide_recommendations
    
    print_success "NTP troubleshooting analysis complete!"
}

# Run main function
main "$@"
