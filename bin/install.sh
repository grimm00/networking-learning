#!/bin/bash

# Cross-platform installation script for Networking Learning Project
# Supports macOS, Linux, and WSL2

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Platform detection
detect_platform() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        PLATFORM="macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        PLATFORM="linux"
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]]; then
        PLATFORM="windows"
    else
        PLATFORM="unknown"
    fi
}

# Print functions
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

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check Python installation
check_python() {
    print_header "Checking Python Installation"
    
    if command_exists python3; then
        python_version=$(python3 --version 2>&1)
        print_success "Python found: $python_version"
        
        # Check if version is 3.8+
        version=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
        major=$(echo "$version" | cut -d. -f1)
        minor=$(echo "$version" | cut -d. -f2)
        
        if [[ $major -gt 3 ]] || [[ $major -eq 3 && $minor -ge 8 ]]; then
            print_success "Python version is compatible (3.8+)"
        else
            print_error "Python 3.8+ required, found $version"
            exit 1
        fi
    else
        print_error "Python 3 not found. Please install Python 3.8 or later."
        print_platform_instructions
        exit 1
    fi
    
    if command_exists pip3; then
        pip_version=$(pip3 --version 2>&1)
        print_success "pip found: $pip_version"
    else
        print_error "pip3 not found. Please install pip3."
        exit 1
    fi
}

# Install system dependencies based on platform
install_system_deps() {
    print_header "Installing System Dependencies"
    
    case $PLATFORM in
        "macos")
            install_macos_deps
            ;;
        "linux")
            install_linux_deps
            ;;
        "windows")
            install_windows_deps
            ;;
        *)
            print_warning "Unknown platform: $OSTYPE"
            print_warning "Please install dependencies manually"
            ;;
    esac
}

# macOS dependencies
install_macos_deps() {
    print_header "Installing macOS Dependencies"
    
    if command_exists brew; then
        print_success "Homebrew found"
        
        # Install required tools
        brew_packages=("python3" "docker" "docker-compose" "wireshark" "tcpdump" "nmap")
        
        for package in "${brew_packages[@]}"; do
            if brew list "$package" >/dev/null 2>&1; then
                print_success "$package already installed"
            else
                print_warning "Installing $package..."
                brew install "$package" || print_warning "Failed to install $package"
            fi
        done
    else
        print_warning "Homebrew not found. Please install Homebrew first:"
        echo "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        print_warning "Then run this script again."
        exit 1
    fi
}

# Linux dependencies
install_linux_deps() {
    print_header "Installing Linux Dependencies"
    
    # Detect package manager
    if command_exists apt; then
        install_debian_deps
    elif command_exists yum; then
        install_rhel_deps
    elif command_exists dnf; then
        install_fedora_deps
    else
        print_warning "Unknown package manager. Please install dependencies manually."
    fi
}

# Debian/Ubuntu dependencies
install_debian_deps() {
    print_warning "Installing Debian/Ubuntu dependencies..."
    
    sudo apt update
    sudo apt install -y \
        python3 python3-pip python3-venv \
        iproute2 net-tools traceroute iputils-ping \
        tcpdump curl wget dnsutils nmap \
        docker.io docker-compose
    
    print_success "Debian/Ubuntu dependencies installed"
}

# RHEL/CentOS dependencies
install_rhel_deps() {
    print_warning "Installing RHEL/CentOS dependencies..."
    
    sudo yum install -y \
        python3 python3-pip \
        iproute2 net-tools traceroute iputils \
        tcpdump curl wget bind-utils nmap \
        docker docker-compose
    
    print_success "RHEL/CentOS dependencies installed"
}

# Fedora dependencies
install_fedora_deps() {
    print_warning "Installing Fedora dependencies..."
    
    sudo dnf install -y \
        python3 python3-pip \
        iproute2 net-tools traceroute iputils \
        tcpdump curl wget bind-utils nmap \
        docker docker-compose
    
    print_success "Fedora dependencies installed"
}

# Windows dependencies
install_windows_deps() {
    print_header "Windows Installation"
    
    print_warning "Windows detected. For best experience, use WSL2:"
    echo "1. Install WSL2: wsl --install"
    echo "2. Install Ubuntu from Microsoft Store"
    echo "3. Run this script in WSL2 Ubuntu terminal"
    echo ""
    print_warning "For native Windows installation:"
    echo "1. Install Python 3.8+ from https://python.org"
    echo "2. Install Docker Desktop from https://docker.com"
    echo "3. Run: pip install -r requirements.txt"
    
    exit 0
}

# Install Python dependencies
install_python_deps() {
    print_header "Installing Python Dependencies"
    
    if [ -f "requirements.txt" ]; then
        print_success "Found requirements.txt"
        
        # Create virtual environment if it doesn't exist
        if [ ! -d "venv" ]; then
            print_warning "Creating virtual environment..."
            python3 -m venv venv
        fi
        
        # Activate virtual environment
        source venv/bin/activate
        
        # Upgrade pip
        pip install --upgrade pip
        
        # Install requirements
        pip install -r requirements.txt
        
        print_success "Python dependencies installed"
    else
        print_error "requirements.txt not found"
        exit 1
    fi
}

# Test installation
test_installation() {
    print_header "Testing Installation"
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Test Python scripts
    if python3 scripts/interface-analyzer.py --help >/dev/null 2>&1; then
        print_success "Interface analyzer working"
    else
        print_warning "Interface analyzer test failed"
    fi
    
    if python3 scripts/dns-analyzer.py --help >/dev/null 2>&1; then
        print_success "DNS analyzer working"
    else
        print_warning "DNS analyzer test failed"
    fi
    
    if python3 scripts/http-analyzer.py --help >/dev/null 2>&1; then
        print_success "HTTP analyzer working"
    else
        print_warning "HTTP analyzer test failed"
    fi
    
    if python3 scripts/tcpdump-analyzer.py --help >/dev/null 2>&1; then
        print_success "TCP dump analyzer working"
    else
        print_warning "TCP dump analyzer test failed"
    fi
    
    # Test system tools
    tools=("ping" "traceroute" "curl" "dig" "nmap")
    for tool in "${tools[@]}"; do
        if command_exists "$tool"; then
            print_success "$tool found"
        else
            print_warning "$tool not found"
        fi
    done
}

# Print platform-specific instructions
print_platform_instructions() {
    case $PLATFORM in
        "macos")
            echo "macOS Installation:"
            echo "1. Install Homebrew: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            echo "2. Install Python: brew install python3"
            echo "3. Run this script again"
            ;;
        "linux")
            echo "Linux Installation:"
            echo "Ubuntu/Debian: sudo apt install python3 python3-pip"
            echo "CentOS/RHEL: sudo yum install python3 python3-pip"
            echo "Fedora: sudo dnf install python3 python3-pip"
            ;;
        "windows")
            echo "Windows Installation:"
            echo "1. Install WSL2: wsl --install"
            echo "2. Install Ubuntu from Microsoft Store"
            echo "3. Run this script in WSL2"
            ;;
    esac
}

# Print usage information
print_usage() {
    print_header "Installation Complete!"
    echo ""
    echo "You can now:"
    echo "  - Run Python scripts: python3 scripts/[script-name].py"
    echo "  - Use containerized environment: ./bin/container-practice.sh start"
    echo "  - Enter container: ./bin/container-practice.sh enter"
    echo ""
    echo "For containerized practice (recommended):"
    echo "  ./bin/container-practice.sh start"
    echo "  ./bin/container-practice.sh enter"
    echo ""
    echo "For local development:"
    echo "  source venv/bin/activate  # Activate virtual environment"
    echo "  python3 scripts/interface-analyzer.py --help"
    echo ""
    echo "Available tools:"
    echo "  - Interface analysis: python3 scripts/interface-analyzer.py"
    echo "  - DNS analysis: python3 scripts/dns-analyzer.py"
    echo "  - HTTP analysis: python3 scripts/http-analyzer.py"
    echo "  - Packet capture: python3 scripts/tcpdump-analyzer.py"
    echo "  - Interactive labs: ./04-network-analysis/tcpdump/tcpdump-lab.sh"
    echo ""
    echo "Documentation:"
    echo "  - README.md - Project overview"
    echo "  - docs/guides/INSTALLATION.md - Detailed installation guide"
    echo "  - docs/guides/ - User guides"
    echo "  - admin/ - Technical documentation"
}

# Main installation function
main() {
    print_header "Networking Learning Project Installation"
    echo "Platform: $OSTYPE"
    
    detect_platform
    print_success "Detected platform: $PLATFORM"
    
    check_python
    install_system_deps
    install_python_deps
    test_installation
    print_usage
}

# Check if running as root (not recommended)
if [[ $EUID -eq 0 ]]; then
    print_warning "Running as root is not recommended"
    print_warning "Please run as a regular user"
    exit 1
fi

# Run main function
main "$@"
