#!/bin/bash

# TLS/SSL Interactive Learning Lab
# Hands-on exercises for TLS/SSL concepts

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Lab directory
LAB_DIR="tls-lab"
mkdir -p "$LAB_DIR"

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

print_step() {
    echo -e "${CYAN}📋 $1${NC}"
}

wait_for_user() {
    echo ""
    read -p "Press Enter to continue..."
    echo ""
}

# Lab 1: Certificate Authority Creation
lab_create_ca() {
    print_header "Lab 1: Creating a Certificate Authority"
    
    print_step "In this lab, we'll create our own Certificate Authority (CA)"
    print_info "This is useful for testing and internal certificates"
    
    wait_for_user
    
    print_step "Step 1: Generate CA private key (4096-bit RSA)"
    echo "Command: openssl genrsa -out $LAB_DIR/ca.key 4096"
    openssl genrsa -out "$LAB_DIR/ca.key" 4096
    print_success "CA private key generated"
    
    wait_for_user
    
    print_step "Step 2: Generate CA certificate (self-signed)"
    echo "Command: openssl req -new -x509 -key $LAB_DIR/ca.key -out $LAB_DIR/ca.crt -days 3650 -subj '/C=US/ST=Lab/L=TLSLab/O=TLS Learning/OU=CA/CN=TLS Lab CA'"
    openssl req -new -x509 -key "$LAB_DIR/ca.key" -out "$LAB_DIR/ca.crt" -days 3650 \
        -subj "/C=US/ST=Lab/L=TLSLab/O=TLS Learning/OU=CA/CN=TLS Lab CA"
    print_success "CA certificate generated"
    
    wait_for_user
    
    print_step "Step 3: Examine the CA certificate"
    echo "Command: openssl x509 -in $LAB_DIR/ca.crt -text -noout"
    openssl x509 -in "$LAB_DIR/ca.crt" -text -noout | head -20
    print_info "Notice the 'CA:TRUE' in the extensions, indicating this is a CA certificate"
    
    wait_for_user
}

# Lab 2: Server Certificate Generation
lab_generate_server_cert() {
    print_header "Lab 2: Generating Server Certificate"
    
    print_step "Now we'll create a server certificate signed by our CA"
    
    wait_for_user
    
    print_step "Step 1: Generate server private key"
    echo "Command: openssl genrsa -out $LAB_DIR/server.key 2048"
    openssl genrsa -out "$LAB_DIR/server.key" 2048
    print_success "Server private key generated"
    
    wait_for_user
    
    print_step "Step 2: Generate Certificate Signing Request (CSR)"
    echo "Command: openssl req -new -key $LAB_DIR/server.key -out $LAB_DIR/server.csr -subj '/C=US/ST=Lab/L=TLSLab/O=TLS Learning/OU=Server/CN=localhost'"
    openssl req -new -key "$LAB_DIR/server.key" -out "$LAB_DIR/server.csr" \
        -subj "/C=US/ST=Lab/L=TLSLab/O=TLS Learning/OU=Server/CN=localhost"
    print_success "CSR generated"
    
    wait_for_user
    
    print_step "Step 3: Examine the CSR"
    echo "Command: openssl req -in $LAB_DIR/server.csr -text -noout"
    openssl req -in "$LAB_DIR/server.csr" -text -noout | head -15
    print_info "Notice the public key and subject information in the CSR"
    
    wait_for_user
    
    print_step "Step 4: Sign the certificate with our CA"
    echo "Command: openssl x509 -req -in $LAB_DIR/server.csr -CA $LAB_DIR/ca.crt -CAkey $LAB_DIR/ca.key -out $LAB_DIR/server.crt -days 365 -CAcreateserial"
    openssl x509 -req -in "$LAB_DIR/server.csr" -CA "$LAB_DIR/ca.crt" -CAkey "$LAB_DIR/ca.key" \
        -out "$LAB_DIR/server.crt" -days 365 -CAcreateserial
    print_success "Server certificate signed by CA"
    
    wait_for_user
    
    print_step "Step 5: Verify the certificate chain"
    echo "Command: openssl verify -CAfile $LAB_DIR/ca.crt $LAB_DIR/server.crt"
    openssl verify -CAfile "$LAB_DIR/ca.crt" "$LAB_DIR/server.crt"
    print_success "Certificate chain verified"
    
    wait_for_user
}

# Lab 3: Certificate Analysis
lab_analyze_certificates() {
    print_header "Lab 3: Analyzing Certificates"
    
    print_step "Let's analyze the certificates we created"
    
    wait_for_user
    
    print_step "Step 1: Analyze CA certificate"
    echo "Command: openssl x509 -in $LAB_DIR/ca.crt -text -noout"
    echo "Key information to look for:"
    echo "  - Subject and Issuer (should be the same for CA)"
    echo "  - Validity period"
    echo "  - Key usage extensions"
    echo "  - Basic constraints (CA:TRUE)"
    openssl x509 -in "$LAB_DIR/ca.crt" -text -noout | grep -E "(Subject:|Issuer:|Not Before:|Not After:|CA:TRUE|Key Usage)"
    
    wait_for_user
    
    print_step "Step 2: Analyze server certificate"
    echo "Command: openssl x509 -in $LAB_DIR/server.crt -text -noout"
    echo "Key information to look for:"
    echo "  - Subject (server identity)"
    echo "  - Issuer (our CA)"
    echo "  - Validity period"
    echo "  - Key usage (digital signature, key encipherment)"
    openssl x509 -in "$LAB_DIR/server.crt" -text -noout | grep -E "(Subject:|Issuer:|Not Before:|Not After:|Key Usage)"
    
    wait_for_user
    
    print_step "Step 3: Compare certificate validity periods"
    echo "CA certificate validity:"
    openssl x509 -in "$LAB_DIR/ca.crt" -noout -dates
    echo "Server certificate validity:"
    openssl x509 -in "$LAB_DIR/server.crt" -noout -dates
    print_info "Notice how the server certificate expires before the CA certificate"
    
    wait_for_user
}

# Lab 4: TLS Connection Testing
lab_test_tls_connection() {
    print_header "Lab 4: Testing TLS Connections"
    
    print_step "Let's test TLS connections with our certificates"
    
    wait_for_user
    
    print_step "Step 1: Start a simple TLS server (in background)"
    echo "Command: openssl s_server -cert $LAB_DIR/server.crt -key $LAB_DIR/server.key -port 8443 -quiet &"
    openssl s_server -cert "$LAB_DIR/server.crt" -key "$LAB_DIR/server.key" -port 8443 -quiet &
    SERVER_PID=$!
    sleep 2
    print_success "TLS server started on port 8443 (PID: $SERVER_PID)"
    
    wait_for_user
    
    print_step "Step 2: Test TLS connection with our CA"
    echo "Command: echo 'Hello TLS!' | openssl s_client -connect localhost:8443 -CAfile $LAB_DIR/ca.crt -quiet"
    echo "Hello TLS!" | openssl s_client -connect localhost:8443 -CAfile "$LAB_DIR/ca.crt" -quiet
    print_success "TLS connection successful with certificate verification"
    
    wait_for_user
    
    print_step "Step 3: Test TLS connection without CA (should fail verification)"
    echo "Command: echo 'Hello TLS!' | openssl s_client -connect localhost:8443 -quiet"
    echo "Hello TLS!" | openssl s_client -connect localhost:8443 -quiet
    print_warning "Connection works but certificate verification fails"
    
    wait_for_user
    
    print_step "Step 4: Stop the TLS server"
    echo "Command: kill $SERVER_PID"
    kill $SERVER_PID 2>/dev/null || true
    print_success "TLS server stopped"
    
    wait_for_user
}

# Lab 5: Real-world Certificate Analysis
lab_analyze_real_certificates() {
    print_header "Lab 5: Analyzing Real-world Certificates"
    
    print_step "Let's analyze certificates from real websites"
    
    wait_for_user
    
    print_step "Step 1: Analyze Google's certificate"
    echo "Command: echo | openssl s_client -connect google.com:443 -servername google.com 2>/dev/null | openssl x509 -text -noout"
    echo "Key information:"
    echo "  - Certificate chain (multiple certificates)"
    echo "  - Subject Alternative Names (SAN)"
    echo "  - Extended Key Usage"
    echo "  - Certificate Transparency"
    echo | openssl s_client -connect google.com:443 -servername google.com 2>/dev/null | openssl x509 -text -noout | grep -E "(Subject:|Issuer:|Not Before:|Not After:|DNS:|Extended Key Usage)"
    
    wait_for_user
    
    print_step "Step 2: Check certificate chain"
    echo "Command: echo | openssl s_client -connect google.com:443 -servername google.com -showcerts 2>/dev/null"
    echo | openssl s_client -connect google.com:443 -servername google.com -showcerts 2>/dev/null | grep -E "(Certificate chain|depth=|Subject:|Issuer:)"
    
    wait_for_user
    
    print_step "Step 3: Analyze cipher suite"
    echo "Command: echo | openssl s_client -connect google.com:443 -servername google.com 2>/dev/null | grep -E '(Protocol|Cipher)'"
    echo | openssl s_client -connect google.com:443 -servername google.com 2>/dev/null | grep -E "(Protocol|Cipher)"
    print_info "Notice the TLS version and cipher suite used"
    
    wait_for_user
}

# Lab 6: Certificate Security Testing
lab_certificate_security() {
    print_header "Lab 6: Certificate Security Testing"
    
    print_step "Let's test certificate security and common issues"
    
    wait_for_user
    
    print_step "Step 1: Test expired certificate (badssl.com)"
    echo "Command: echo | openssl s_client -connect expired.badssl.com:443 2>/dev/null | openssl x509 -noout -dates"
    echo | openssl s_client -connect expired.badssl.com:443 2>/dev/null | openssl x509 -noout -dates
    print_warning "This certificate is expired - notice the dates"
    
    wait_for_user
    
    print_step "Step 2: Test self-signed certificate (badssl.com)"
    echo "Command: echo | openssl s_client -connect self-signed.badssl.com:443 2>/dev/null | openssl x509 -noout -subject -issuer"
    echo | openssl s_client -connect self-signed.badssl.com:443 2>/dev/null | openssl x509 -noout -subject -issuer
    print_warning "Notice how Subject and Issuer are the same (self-signed)"
    
    wait_for_user
    
    print_step "Step 3: Test wrong hostname certificate (badssl.com)"
    echo "Command: echo | openssl s_client -connect wrong.host.badssl.com:443 2>/dev/null | openssl x509 -noout -subject"
    echo | openssl s_client -connect wrong.host.badssl.com:443 2>/dev/null | openssl x509 -noout -subject
    print_warning "Certificate is for '*.badssl.com' but we're connecting to 'wrong.host.badssl.com'"
    
    wait_for_user
    
    print_step "Step 4: Test weak cipher (badssl.com)"
    echo "Command: echo | openssl s_client -connect rc4.badssl.com:443 2>/dev/null | grep Cipher"
    echo | openssl s_client -connect rc4.badssl.com:443 2>/dev/null | grep Cipher
    print_warning "RC4 cipher is considered weak and deprecated"
    
    wait_for_user
}

# Lab 7: OpenSSL Commands Reference
lab_openssl_reference() {
    print_header "Lab 7: OpenSSL Commands Reference"
    
    print_step "Common OpenSSL commands for certificate management"
    
    echo "Certificate Generation:"
    echo "  openssl genrsa -out key.pem 2048                    # Generate private key"
    echo "  openssl req -new -key key.pem -out csr.pem         # Generate CSR"
    echo "  openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 365 -nodes  # Self-signed cert"
    
    echo ""
    echo "Certificate Analysis:"
    echo "  openssl x509 -in cert.pem -text -noout              # View certificate details"
    echo "  openssl x509 -in cert.pem -noout -dates             # View validity dates"
    echo "  openssl x509 -in cert.pem -noout -subject -issuer   # View subject and issuer"
    echo "  openssl verify -CAfile ca.pem cert.pem              # Verify certificate"
    
    echo ""
    echo "TLS Connection Testing:"
    echo "  openssl s_client -connect host:port                 # Test TLS connection"
    echo "  openssl s_client -connect host:port -CAfile ca.pem  # Test with CA verification"
    echo "  openssl s_client -connect host:port -showcerts      # Show certificate chain"
    
    echo ""
    echo "Key and Certificate Conversion:"
    echo "  openssl rsa -in key.pem -outform PEM -out key.pem   # Convert key format"
    echo "  openssl x509 -in cert.pem -outform PEM -out cert.pem  # Convert cert format"
    echo "  openssl pkcs12 -export -out cert.p12 -inkey key.pem -in cert.pem  # Create PKCS#12"
    
    wait_for_user
}

# Lab cleanup
lab_cleanup() {
    print_header "Lab Cleanup"
    
    print_step "Cleaning up lab files"
    
    if [ -d "$LAB_DIR" ]; then
        echo "Removing lab directory: $LAB_DIR"
        rm -rf "$LAB_DIR"
        print_success "Lab files cleaned up"
    fi
    
    wait_for_user
}

# Main menu
show_menu() {
    echo ""
    print_header "TLS/SSL Interactive Learning Lab"
    echo "Choose a lab to run:"
    echo ""
    echo "1. Create Certificate Authority"
    echo "2. Generate Server Certificate"
    echo "3. Analyze Certificates"
    echo "4. Test TLS Connections"
    echo "5. Analyze Real-world Certificates"
    echo "6. Certificate Security Testing"
    echo "7. OpenSSL Commands Reference"
    echo "8. Run All Labs"
    echo "9. Cleanup Lab Files"
    echo "0. Exit"
    echo ""
}

# Main function
main() {
    while true; do
        show_menu
        read -p "Enter your choice (0-9): " choice
        
        case $choice in
            1)
                lab_create_ca
                ;;
            2)
                lab_generate_server_cert
                ;;
            3)
                lab_analyze_certificates
                ;;
            4)
                lab_test_tls_connection
                ;;
            5)
                lab_analyze_real_certificates
                ;;
            6)
                lab_certificate_security
                ;;
            7)
                lab_openssl_reference
                ;;
            8)
                lab_create_ca
                lab_generate_server_cert
                lab_analyze_certificates
                lab_test_tls_connection
                lab_analyze_real_certificates
                lab_certificate_security
                lab_openssl_reference
                ;;
            9)
                lab_cleanup
                ;;
            0)
                print_success "Exiting TLS Lab. Thanks for learning!"
                exit 0
                ;;
            *)
                print_error "Invalid choice. Please enter 0-9."
                ;;
        esac
    done
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    if ! command -v openssl >/dev/null 2>&1; then
        print_error "OpenSSL is required but not installed"
        print_info "Install OpenSSL:"
        print_info "  Ubuntu/Debian: sudo apt-get install openssl"
        print_info "  CentOS/RHEL: sudo yum install openssl"
        print_info "  macOS: brew install openssl"
        exit 1
    fi
    
    print_success "OpenSSL is available"
    
    # Check OpenSSL version
    local openssl_version=$(openssl version)
    print_info "OpenSSL version: $openssl_version"
    
    print_success "Prerequisites check completed"
    echo ""
}

# Run main function
check_prerequisites
main
