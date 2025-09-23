#!/bin/bash

# Setup script for networking learning project
# Installs Python dependencies and sets up the environment

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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

# Check if Python 3 is installed
check_python() {
    print_header "Checking Python Installation"
    
    if command -v python3 >/dev/null 2>&1; then
        python_version=$(python3 --version)
        print_success "Python found: $python_version"
    else
        print_warning "Python 3 not found. Please install Python 3.8 or later."
        exit 1
    fi
    
    if command -v pip3 >/dev/null 2>&1; then
        pip_version=$(pip3 --version)
        print_success "pip found: $pip_version"
    else
        print_warning "pip3 not found. Please install pip3."
        exit 1
    fi
}

# Install Python dependencies
install_dependencies() {
    print_header "Installing Python Dependencies"
    
    if [ -f "requirements.txt" ]; then
        print_success "Found requirements.txt"
        pip3 install -r requirements.txt
        print_success "Python dependencies installed"
    else
        print_warning "requirements.txt not found"
        exit 1
    fi
}

# Check system dependencies
check_system_deps() {
    print_header "Checking System Dependencies"
    
    # Check for common networking tools
    tools=("curl" "wget" "ping" "traceroute" "dig" "nslookup")
    
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            print_success "$tool found"
        else
            print_warning "$tool not found - install with your package manager"
        fi
    done
}

# Test Python scripts
test_scripts() {
    print_header "Testing Python Scripts"
    
    # Test DNS analyzer
    if python3 scripts/dns-analyzer.py --help >/dev/null 2>&1; then
        print_success "DNS analyzer working"
    else
        print_warning "DNS analyzer test failed"
    fi
    
    # Test HTTP analyzer
    if python3 scripts/http-analyzer.py --help >/dev/null 2>&1; then
        print_success "HTTP analyzer working"
    else
        print_warning "HTTP analyzer test failed"
    fi
    
    # Test IPv4 calculator
    if python3 scripts/ipv4-calculator.py --help >/dev/null 2>&1; then
        print_success "IPv4 calculator working"
    else
        print_warning "IPv4 calculator test failed"
    fi
}

# Main setup function
main() {
    print_header "Networking Learning Project Setup"
    
    check_python
    install_dependencies
    check_system_deps
    test_scripts
    
    print_success "Setup complete!"
    echo ""
    echo "You can now:"
    echo "  - Run Python scripts: python3 scripts/[script-name].py"
    echo "  - Use containerized environment: ./container-practice.sh start"
    echo "  - Enter container: ./container-practice.sh enter"
    echo ""
    echo "For containerized practice (recommended):"
    echo "  ./container-practice.sh start"
    echo "  ./container-practice.sh enter"
}

# Run main function
main "$@"
