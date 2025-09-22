#!/bin/bash

# SSH Troubleshooting Script
# Comprehensive SSH diagnostics and troubleshooting tool

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
HOST=""
PORT=22
USERNAME=""
KEY_FILE=""
TIMEOUT=10
VERBOSE=false
COMPREHENSIVE=false
SECURITY=false
PERFORMANCE=false
TEST_COUNT=5

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
    echo "SSH Troubleshooting Script"
    echo ""
    echo "Usage: $0 [OPTIONS] HOST"
    echo ""
    echo "Options:"
    echo "  -p, --port PORT        SSH port (default: 22)"
    echo "  -u, --user USER        Username for testing"
    echo "  -k, --key KEYFILE      SSH private key file"
    echo "  -t, --timeout SECONDS  Connection timeout (default: 10)"
    echo "  -v, --verbose          Verbose output"
    echo "  -a, --all              Comprehensive analysis"
    echo "  -s, --security         Security-focused analysis"
    echo "  -p, --performance      Performance testing"
    echo "  -c, --count NUM        Number of performance tests (default: 5)"
    echo "  -h, --help             Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 -u myuser -k ~/.ssh/id_rsa example.com"
    echo "  $0 -a -s -p 2222 user@hostname"
    echo "  $0 --performance --count 10 myserver.com"
}

# Function to check dependencies
check_dependencies() {
    local missing_deps=()
    
    # Check for required commands
    for cmd in ssh ssh-keygen nmap telnet; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        print_info "Install with: apt-get install openssh-client nmap telnet"
        exit 1
    fi
}

# Function to test basic connectivity
test_connectivity() {
    print_header "Testing Basic Connectivity"
    
    # Test if host is reachable
    print_info "Testing host reachability..."
    if ping -c 1 -W 3 "$HOST" >/dev/null 2>&1; then
        print_success "Host is reachable via ping"
    else
        print_warning "Host is not reachable via ping (may be filtered)"
    fi
    
    # Test SSH port
    print_info "Testing SSH port $PORT..."
    if timeout "$TIMEOUT" bash -c "echo > /dev/tcp/$HOST/$PORT" 2>/dev/null; then
        print_success "SSH port $PORT is open"
    else
        print_error "SSH port $PORT is closed or filtered"
        return 1
    fi
    
    # Test with telnet
    print_info "Testing with telnet..."
    if timeout "$TIMEOUT" telnet "$HOST" "$PORT" 2>/dev/null | grep -q "SSH"; then
        print_success "SSH service detected via telnet"
    else
        print_warning "SSH service not detected via telnet"
    fi
}

# Function to detect SSH service
detect_ssh_service() {
    print_header "SSH Service Detection"
    
    # Get SSH banner
    print_info "Retrieving SSH banner..."
    local banner
    banner=$(timeout "$TIMEOUT" bash -c "exec 3<>/dev/tcp/$HOST/$PORT; cat <&3" 2>/dev/null | head -1)
    
    if [ -n "$banner" ]; then
        print_success "SSH Banner: $banner"
        
        # Parse version
        if echo "$banner" | grep -q "SSH-1"; then
            print_warning "SSH-1 detected (deprecated and insecure)"
        elif echo "$banner" | grep -q "SSH-2"; then
            print_success "SSH-2 detected (current standard)"
        else
            print_warning "Unknown SSH version"
        fi
        
        # Extract software info
        local software
        software=$(echo "$banner" | sed -n 's/.*SSH-[0-9.]*-\(.*\)/\1/p')
        if [ -n "$software" ]; then
            print_info "Software: $software"
        fi
    else
        print_error "Could not retrieve SSH banner"
    fi
}

# Function to test SSH connection
test_ssh_connection() {
    print_header "SSH Connection Testing"
    
    if [ -z "$USERNAME" ]; then
        print_warning "No username provided, skipping connection test"
        return
    fi
    
    print_info "Testing SSH connection as $USERNAME@$HOST:$PORT"
    
    # Test with verbose output
    if [ "$VERBOSE" = true ]; then
        print_info "Running SSH with verbose output..."
        timeout "$TIMEOUT" ssh -v -o ConnectTimeout="$TIMEOUT" -o BatchMode=yes "$USERNAME@$HOST" -p "$PORT" "echo 'Connection successful'" 2>&1 || true
    else
        # Test basic connection
        if timeout "$TIMEOUT" ssh -o ConnectTimeout="$TIMEOUT" -o BatchMode=yes "$USERNAME@$HOST" -p "$PORT" "echo 'Connection successful'" >/dev/null 2>&1; then
            print_success "SSH connection successful"
        else
            print_error "SSH connection failed"
            
            # Try with key if provided
            if [ -n "$KEY_FILE" ] && [ -f "$KEY_FILE" ]; then
                print_info "Trying with key file: $KEY_FILE"
                if timeout "$TIMEOUT" ssh -i "$KEY_FILE" -o ConnectTimeout="$TIMEOUT" -o BatchMode=yes "$USERNAME@$HOST" -p "$PORT" "echo 'Connection successful'" >/dev/null 2>&1; then
                    print_success "SSH connection successful with key"
                else
                    print_error "SSH connection failed even with key"
                fi
            fi
        fi
    fi
}

# Function to analyze SSH configuration
analyze_ssh_config() {
    print_header "SSH Configuration Analysis"
    
    # Check client configuration
    if [ -f ~/.ssh/config ]; then
        print_info "Found SSH client config: ~/.ssh/config"
        
        # Check for host-specific config
        if grep -q "^Host $HOST" ~/.ssh/config 2>/dev/null; then
            print_success "Host-specific configuration found"
            print_info "Configuration for $HOST:"
            awk "/^Host $HOST/,/^Host /" ~/.ssh/config | grep -v "^Host " | sed 's/^/  /'
        else
            print_info "No host-specific configuration found"
        fi
    else
        print_info "No SSH client config found"
    fi
    
    # Check known hosts
    if [ -f ~/.ssh/known_hosts ]; then
        print_info "Checking known hosts..."
        if grep -q "$HOST" ~/.ssh/known_hosts 2>/dev/null; then
            print_success "Host found in known_hosts"
            
            # Show host key fingerprint
            local fingerprint
            fingerprint=$(ssh-keygen -l -f ~/.ssh/known_hosts 2>/dev/null | grep "$HOST" | awk '{print $2}')
            if [ -n "$fingerprint" ]; then
                print_info "Host key fingerprint: $fingerprint"
            fi
        else
            print_warning "Host not found in known_hosts"
        fi
    else
        print_info "No known_hosts file found"
    fi
}

# Function to test SSH keys
test_ssh_keys() {
    print_header "SSH Key Analysis"
    
    if [ -n "$KEY_FILE" ]; then
        if [ -f "$KEY_FILE" ]; then
            print_info "Analyzing key file: $KEY_FILE"
            
            # Check key file permissions
            local perms
            perms=$(stat -c "%a" "$KEY_FILE" 2>/dev/null || stat -f "%OLp" "$KEY_FILE" 2>/dev/null)
            if [ "$perms" = "600" ]; then
                print_success "Key file permissions are correct (600)"
            else
                print_warning "Key file permissions should be 600, got $perms"
            fi
            
            # Get key information
            print_info "Key information:"
            ssh-keygen -l -f "$KEY_FILE" 2>/dev/null | sed 's/^/  /'
            
            # Test key with SSH
            if [ -n "$USERNAME" ]; then
                print_info "Testing key authentication..."
                if timeout "$TIMEOUT" ssh -i "$KEY_FILE" -o ConnectTimeout="$TIMEOUT" -o BatchMode=yes "$USERNAME@$HOST" -p "$PORT" "echo 'Key authentication successful'" >/dev/null 2>&1; then
                    print_success "Key authentication successful"
                else
                    print_error "Key authentication failed"
                fi
            fi
        else
            print_error "Key file not found: $KEY_FILE"
        fi
    else
        print_info "No key file specified"
        
        # Check for default keys
        print_info "Checking for default SSH keys..."
        for key in ~/.ssh/id_rsa ~/.ssh/id_ecdsa ~/.ssh/id_ed25519; do
            if [ -f "$key" ]; then
                print_info "Found key: $key"
                ssh-keygen -l -f "$key" 2>/dev/null | sed 's/^/  /'
            fi
        done
    fi
}

# Function to perform security analysis
security_analysis() {
    print_header "Security Analysis"
    
    # Check supported algorithms
    print_info "Checking supported algorithms..."
    
    # Ciphers
    print_info "Supported ciphers:"
    ssh -Q cipher 2>/dev/null | head -10 | sed 's/^/  /'
    
    # MACs
    print_info "Supported MACs:"
    ssh -Q mac 2>/dev/null | head -10 | sed 's/^/  /'
    
    # Key exchange
    print_info "Supported key exchange algorithms:"
    ssh -Q kex 2>/dev/null | head -10 | sed 's/^/  /'
    
    # Public key algorithms
    print_info "Supported public key algorithms:"
    ssh -Q key 2>/dev/null | head -10 | sed 's/^/  /'
    
    # Check for weak algorithms
    print_info "Checking for weak algorithms..."
    local weak_found=false
    
    # Check for weak ciphers
    if ssh -Q cipher 2>/dev/null | grep -q -E "(des|3des|arcfour|blowfish)"; then
        print_warning "Weak ciphers detected"
        weak_found=true
    fi
    
    # Check for weak MACs
    if ssh -Q mac 2>/dev/null | grep -q -E "(md5|sha1)"; then
        print_warning "Weak MACs detected"
        weak_found=true
    fi
    
    if [ "$weak_found" = false ]; then
        print_success "No obvious weak algorithms detected"
    fi
}

# Function to perform performance testing
performance_test() {
    print_header "Performance Testing"
    
    print_info "Running $TEST_COUNT connection tests..."
    
    local times=()
    local successful=0
    
    for i in $(seq 1 "$TEST_COUNT"); do
        print_info "Test $i/$TEST_COUNT..."
        
        local start_time
        start_time=$(date +%s.%N)
        
        if timeout "$TIMEOUT" ssh -o ConnectTimeout="$TIMEOUT" -o BatchMode=yes "$USERNAME@$HOST" -p "$PORT" "echo 'test'" >/dev/null 2>&1; then
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
        
        print_success "Performance Results:"
        print_info "  Successful connections: $successful/$TEST_COUNT"
        print_info "  Average time: ${avg}s"
        print_info "  Minimum time: ${min}s"
        print_info "  Maximum time: ${max}s"
    else
        print_error "No successful connections for performance testing"
    fi
}

# Function to check SSH logs
check_ssh_logs() {
    print_header "SSH Log Analysis"
    
    # Check system logs for SSH activity
    print_info "Checking system logs for SSH activity..."
    
    # Try different log locations
    local log_files=("/var/log/auth.log" "/var/log/secure" "/var/log/messages" "/var/log/syslog")
    
    for log_file in "${log_files[@]}"; do
        if [ -f "$log_file" ]; then
            print_info "Found log file: $log_file"
            
            # Show recent SSH activity
            if grep -q "sshd" "$log_file" 2>/dev/null; then
                print_info "Recent SSH activity:"
                grep "sshd" "$log_file" 2>/dev/null | tail -5 | sed 's/^/  /'
            else
                print_info "No SSH activity found in $log_file"
            fi
            break
        fi
    done
}

# Function to provide troubleshooting recommendations
provide_recommendations() {
    print_header "Troubleshooting Recommendations"
    
    print_info "Common SSH issues and solutions:"
    echo ""
    echo "1. Connection Refused:"
    echo "   - Check if SSH service is running: systemctl status ssh"
    echo "   - Check if port is open: nmap -p 22 $HOST"
    echo "   - Verify firewall settings"
    echo ""
    echo "2. Authentication Failed:"
    echo "   - Check username and password"
    echo "   - Verify SSH key permissions: chmod 600 ~/.ssh/id_rsa"
    echo "   - Check server logs: tail -f /var/log/auth.log"
    echo ""
    echo "3. Host Key Verification Failed:"
    echo "   - Remove old host key: ssh-keygen -R $HOST"
    echo "   - Accept new host key: ssh -o StrictHostKeyChecking=no $USERNAME@$HOST"
    echo ""
    echo "4. Permission Denied:"
    echo "   - Check user permissions on server"
    echo "   - Verify SSH configuration: sshd -T"
    echo "   - Check authorized_keys file permissions"
    echo ""
    echo "5. Timeout Issues:"
    echo "   - Check network connectivity: ping $HOST"
    echo "   - Increase timeout: ssh -o ConnectTimeout=30 $USERNAME@$HOST"
    echo "   - Check for firewall blocking"
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
            -u|--user)
                USERNAME="$2"
                shift 2
                ;;
            -k|--key)
                KEY_FILE="$2"
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
                if [ -z "$HOST" ]; then
                    HOST="$1"
                else
                    print_error "Multiple hosts specified"
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Check if host is provided
    if [ -z "$HOST" ]; then
        print_error "Host is required"
        show_usage
        exit 1
    fi
    
    # Check dependencies
    check_dependencies
    
    # Start analysis
    print_header "SSH Troubleshooting Analysis"
    print_info "Target: $HOST:$PORT"
    if [ -n "$USERNAME" ]; then
        print_info "Username: $USERNAME"
    fi
    if [ -n "$KEY_FILE" ]; then
        print_info "Key file: $KEY_FILE"
    fi
    echo ""
    
    # Basic connectivity test
    test_connectivity
    
    # SSH service detection
    detect_ssh_service
    
    # SSH connection test
    test_ssh_connection
    
    # Configuration analysis
    analyze_ssh_config
    
    # Key analysis
    test_ssh_keys
    
    # Security analysis
    if [ "$SECURITY" = true ] || [ "$COMPREHENSIVE" = true ]; then
        security_analysis
    fi
    
    # Performance testing
    if [ "$PERFORMANCE" = true ] || [ "$COMPREHENSIVE" = true ]; then
        if [ -n "$USERNAME" ]; then
            performance_test
        else
            print_warning "Username required for performance testing"
        fi
    fi
    
    # Log analysis
    if [ "$COMPREHENSIVE" = true ]; then
        check_ssh_logs
    fi
    
    # Provide recommendations
    provide_recommendations
    
    print_success "SSH troubleshooting analysis complete!"
}

# Run main function
main "$@"
