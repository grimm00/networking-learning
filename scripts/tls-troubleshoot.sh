#!/bin/bash

# TLS/SSL Troubleshooting Script
# Comprehensive diagnostic tool for TLS/SSL issues

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
HOSTNAME=""
PORT=443
TIMEOUT=10
VERBOSE=false
OUTPUT_DIR="output"

# Functions
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
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Usage function
usage() {
    echo "Usage: $0 [OPTIONS] HOSTNAME"
    echo ""
    echo "TLS/SSL Troubleshooting Tool"
    echo ""
    echo "Options:"
    echo "  -p, --port PORT        Port number (default: 443)"
    echo "  -t, --timeout SECONDS  Connection timeout (default: 10)"
    echo "  -v, --verbose          Verbose output"
    echo "  -o, --output DIR       Output directory (default: output)"
    echo "  -h, --help             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 google.com"
    echo "  $0 -p 8443 -v example.com"
    echo "  $0 --timeout 30 --output results badssl.com"
    echo ""
    echo "Tests performed:"
    echo "  • Basic connectivity"
    echo "  • TLS handshake"
    echo "  • Certificate validation"
    echo "  • Protocol version support"
    echo "  • Cipher suite analysis"
    echo "  • Security headers"
    echo "  • Certificate chain verification"
}

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
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
        *)
            if [ -z "$HOSTNAME" ]; then
                HOSTNAME="$1"
            else
                echo "Multiple hostnames specified. Please provide only one."
                exit 1
            fi
            shift
            ;;
    esac
done

# Check if hostname is provided
if [ -z "$HOSTNAME" ]; then
    echo "Error: Hostname is required"
    usage
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Test basic connectivity
test_connectivity() {
    print_header "Testing Basic Connectivity"
    
    print_info "Testing TCP connection to $HOSTNAME:$PORT..."
    
    if timeout $TIMEOUT bash -c "echo > /dev/tcp/$HOSTNAME/$PORT" 2>/dev/null; then
        print_success "TCP connection successful"
        return 0
    else
        print_error "TCP connection failed"
        return 1
    fi
}

# Test TLS handshake
test_tls_handshake() {
    print_header "Testing TLS Handshake"
    
    print_info "Testing TLS connection with OpenSSL..."
    
    # Test with different TLS versions
    local tls_versions=("tls1_2" "tls1_3")
    local handshake_success=false
    
    for version in "${tls_versions[@]}"; do
        print_info "Testing $version..."
        
        if echo | timeout $TIMEOUT openssl s_client -connect "$HOSTNAME:$PORT" \
            -servername "$HOSTNAME" -"$version" -quiet 2>/dev/null | grep -q "Verify return code"; then
            print_success "$version handshake successful"
            handshake_success=true
        else
            print_warning "$version handshake failed or not supported"
        fi
    done
    
    if [ "$handshake_success" = true ]; then
        return 0
    else
        print_error "No TLS handshake successful"
        return 1
    fi
}

# Analyze certificate
analyze_certificate() {
    print_header "Analyzing Certificate"
    
    print_info "Retrieving certificate information..."
    
    # Get certificate details
    local cert_info=$(echo | timeout $TIMEOUT openssl s_client -connect "$HOSTNAME:$PORT" \
        -servername "$HOSTNAME" 2>/dev/null | openssl x509 -noout -text 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$cert_info" ]; then
        print_success "Certificate retrieved successfully"
        
        # Extract key information
        local subject=$(echo "$cert_info" | grep "Subject:" | head -1)
        local issuer=$(echo "$cert_info" | grep "Issuer:" | head -1)
        local not_before=$(echo "$cert_info" | grep "Not Before:" | head -1)
        local not_after=$(echo "$cert_info" | grep "Not After:" | head -1)
        local serial=$(echo "$cert_info" | grep "Serial Number:" | head -1)
        
        echo "  Subject: $subject"
        echo "  Issuer: $issuer"
        echo "  Valid From: $not_before"
        echo "  Valid Until: $not_after"
        echo "  Serial: $serial"
        
        # Check expiration
        local expiry_date=$(echo "$not_after" | sed 's/.*Not After: *//')
        if [ -n "$expiry_date" ]; then
            local days_until_expiry=$(($(date -d "$expiry_date" +%s) - $(date +%s))) / 86400
            if [ $days_until_expiry -lt 0 ]; then
                print_error "Certificate is EXPIRED ($(($days_until_expiry * -1)) days ago)"
            elif [ $days_until_expiry -lt 30 ]; then
                print_warning "Certificate expires in $days_until_expiry days"
            else
                print_success "Certificate valid for $days_until_expiry days"
            fi
        fi
        
        # Save certificate to file
        echo | timeout $TIMEOUT openssl s_client -connect "$HOSTNAME:$PORT" \
            -servername "$HOSTNAME" 2>/dev/null | openssl x509 -out "$OUTPUT_DIR/${HOSTNAME}_cert.pem" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            print_success "Certificate saved to $OUTPUT_DIR/${HOSTNAME}_cert.pem"
        fi
        
    else
        print_error "Failed to retrieve certificate"
        return 1
    fi
}

# Test certificate chain
test_certificate_chain() {
    print_header "Testing Certificate Chain"
    
    print_info "Verifying certificate chain..."
    
    # Test certificate verification
    if echo | timeout $TIMEOUT openssl s_client -connect "$HOSTNAME:$PORT" \
        -servername "$HOSTNAME" -verify_return_error 2>/dev/null | grep -q "Verify return code: 0"; then
        print_success "Certificate chain verification successful"
    else
        print_warning "Certificate chain verification failed or incomplete"
        
        # Get verification details
        local verify_output=$(echo | timeout $TIMEOUT openssl s_client -connect "$HOSTNAME:$PORT" \
            -servername "$HOSTNAME" 2>/dev/null | grep "Verify return code")
        
        if [ -n "$verify_output" ]; then
            echo "  $verify_output"
        fi
    fi
}

# Analyze cipher suites
analyze_cipher_suites() {
    print_header "Analyzing Cipher Suites"
    
    print_info "Enumerating supported cipher suites..."
    
    # Check if nmap is available
    if command -v nmap >/dev/null 2>&1; then
        print_info "Using nmap for cipher suite analysis..."
        
        local nmap_output=$(nmap --script ssl-enum-ciphers -p "$PORT" "$HOSTNAME" 2>/dev/null)
        
        if [ $? -eq 0 ]; then
            # Count cipher suites by protocol
            local tls12_ciphers=$(echo "$nmap_output" | grep -c "TLSv1.2" || echo "0")
            local tls13_ciphers=$(echo "$nmap_output" | grep -c "TLSv1.3" || echo "0")
            local weak_ciphers=$(echo "$nmap_output" | grep -c -E "(RC4|DES|MD5|EXPORT|NULL)" || echo "0")
            
            print_success "Cipher suite analysis completed"
            echo "  TLS 1.2 ciphers: $tls12_ciphers"
            echo "  TLS 1.3 ciphers: $tls13_ciphers"
            echo "  Weak ciphers: $weak_ciphers"
            
            # Save detailed output
            echo "$nmap_output" > "$OUTPUT_DIR/${HOSTNAME}_ciphers.txt"
            print_success "Cipher details saved to $OUTPUT_DIR/${HOSTNAME}_ciphers.txt"
            
        else
            print_warning "Nmap cipher analysis failed"
        fi
    else
        print_warning "Nmap not available, skipping cipher analysis"
        print_info "Install nmap for detailed cipher suite analysis"
    fi
}

# Test security headers
test_security_headers() {
    print_header "Testing Security Headers"
    
    print_info "Checking security headers..."
    
    # Check if curl is available
    if command -v curl >/dev/null 2>&1; then
        local headers=$(curl -s -I -k "https://$HOSTNAME" --connect-timeout $TIMEOUT 2>/dev/null)
        
        if [ $? -eq 0 ]; then
            print_success "Headers retrieved successfully"
            
            # Check for important security headers
            local hsts=$(echo "$headers" | grep -i "strict-transport-security" || echo "")
            local csp=$(echo "$headers" | grep -i "content-security-policy" || echo "")
            local xfo=$(echo "$headers" | grep -i "x-frame-options" || echo "")
            local xcto=$(echo "$headers" | grep -i "x-content-type-options" || echo "")
            
            if [ -n "$hsts" ]; then
                print_success "HSTS header present"
            else
                print_warning "HSTS header missing"
            fi
            
            if [ -n "$csp" ]; then
                print_success "CSP header present"
            else
                print_warning "CSP header missing"
            fi
            
            if [ -n "$xfo" ]; then
                print_success "X-Frame-Options header present"
            else
                print_warning "X-Frame-Options header missing"
            fi
            
            if [ -n "$xcto" ]; then
                print_success "X-Content-Type-Options header present"
            else
                print_warning "X-Content-Type-Options header missing"
            fi
            
            # Save headers
            echo "$headers" > "$OUTPUT_DIR/${HOSTNAME}_headers.txt"
            print_success "Headers saved to $OUTPUT_DIR/${HOSTNAME}_headers.txt"
            
        else
            print_error "Failed to retrieve headers"
        fi
    else
        print_warning "Curl not available, skipping header analysis"
    fi
}

# Test TLS configuration
test_tls_configuration() {
    print_header "Testing TLS Configuration"
    
    print_info "Testing TLS configuration with testssl.sh..."
    
    # Check if testssl.sh is available
    if command -v testssl.sh >/dev/null 2>&1; then
        print_info "Running comprehensive TLS test..."
        
        # Run testssl.sh with basic options
        testssl.sh --connect-timeout $TIMEOUT "$HOSTNAME:$PORT" > "$OUTPUT_DIR/${HOSTNAME}_testssl.txt" 2>&1
        
        if [ $? -eq 0 ]; then
            print_success "TLS configuration test completed"
            print_success "Results saved to $OUTPUT_DIR/${HOSTNAME}_testssl.txt"
        else
            print_warning "TLS configuration test had issues"
        fi
    else
        print_warning "testssl.sh not available"
        print_info "Install testssl.sh for comprehensive TLS testing"
        print_info "  git clone https://github.com/drwetter/testssl.sh.git"
    fi
}

# Generate summary report
generate_summary() {
    print_header "TLS Troubleshooting Summary"
    
    echo "Hostname: $HOSTNAME"
    echo "Port: $PORT"
    echo "Timestamp: $(date)"
    echo "Output Directory: $OUTPUT_DIR"
    echo ""
    
    echo "Files generated:"
    if [ -f "$OUTPUT_DIR/${HOSTNAME}_cert.pem" ]; then
        echo "  ✅ Certificate: ${HOSTNAME}_cert.pem"
    fi
    if [ -f "$OUTPUT_DIR/${HOSTNAME}_ciphers.txt" ]; then
        echo "  ✅ Cipher analysis: ${HOSTNAME}_ciphers.txt"
    fi
    if [ -f "$OUTPUT_DIR/${HOSTNAME}_headers.txt" ]; then
        echo "  ✅ Security headers: ${HOSTNAME}_headers.txt"
    fi
    if [ -f "$OUTPUT_DIR/${HOSTNAME}_testssl.txt" ]; then
        echo "  ✅ TLS configuration: ${HOSTNAME}_testssl.txt"
    fi
    
    echo ""
    echo "Next steps:"
    echo "  1. Review generated files for detailed analysis"
    echo "  2. Check certificate expiration and chain validity"
    echo "  3. Verify cipher suite security"
    echo "  4. Implement missing security headers"
    echo "  5. Consider TLS 1.3 migration if not already implemented"
}

# Main execution
main() {
    print_header "TLS/SSL Troubleshooting Tool"
    echo "Target: $HOSTNAME:$PORT"
    echo "Timeout: ${TIMEOUT}s"
    echo "Output: $OUTPUT_DIR"
    echo ""
    
    # Run tests
    test_connectivity
    test_tls_handshake
    analyze_certificate
    test_certificate_chain
    analyze_cipher_suites
    test_security_headers
    test_tls_configuration
    
    # Generate summary
    generate_summary
    
    print_success "TLS troubleshooting completed!"
}

# Run main function
main
