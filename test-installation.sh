#!/bin/bash

# Test script to verify Networking Learning Project installation
# Run this after installation to ensure everything works correctly

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Test function
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -n "Testing $test_name... "
    
    if eval "$test_command" >/dev/null 2>&1; then
        print_success "$test_name"
        ((TESTS_PASSED++))
    else
        print_error "$test_name"
        ((TESTS_FAILED++))
    fi
}

# Test Python installation
test_python() {
    print_header "Testing Python Installation"
    
    run_test "Python 3" "python3 --version"
    run_test "pip3" "pip3 --version"
    
    # Test Python version compatibility
    python_version=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
    if [[ $(echo "$python_version >= 3.8" | bc -l 2>/dev/null || echo "1") -eq 1 ]]; then
        print_success "Python version compatible ($python_version)"
        ((TESTS_PASSED++))
    else
        print_error "Python version incompatible ($python_version, need 3.8+)"
        ((TESTS_FAILED++))
    fi
}

# Test Python packages
test_python_packages() {
    print_header "Testing Python Packages"
    
    # Activate virtual environment if it exists
    if [ -d "venv" ]; then
        source venv/bin/activate
    fi
    
    run_test "requests" "python3 -c 'import requests'"
    run_test "scapy" "python3 -c 'import scapy'"
    run_test "psutil" "python3 -c 'import psutil'"
    run_test "netifaces" "python3 -c 'import netifaces'"
    run_test "paramiko" "python3 -c 'import paramiko'"
    run_test "rich" "python3 -c 'import rich'"
    run_test "click" "python3 -c 'import click'"
}

# Test system tools
test_system_tools() {
    print_header "Testing System Tools"
    
    run_test "ping" "ping -c 1 8.8.8.8"
    run_test "traceroute" "traceroute -m 3 8.8.8.8"
    run_test "curl" "curl -s --connect-timeout 5 https://httpbin.org/get"
    run_test "dig" "dig @8.8.8.8 google.com"
    run_test "nmap" "nmap --version"
}

# Test Python scripts
test_python_scripts() {
    print_header "Testing Python Scripts"
    
    # Activate virtual environment if it exists
    if [ -d "venv" ]; then
        source venv/bin/activate
    fi
    
    run_test "interface-analyzer" "python3 scripts/interface-analyzer.py --help"
    run_test "dns-analyzer" "python3 scripts/dns-analyzer.py --help"
    run_test "http-analyzer" "python3 scripts/http-analyzer.py --help"
    run_test "ipv4-calculator" "python3 scripts/ipv4-calculator.py --help"
    run_test "ssh-analyzer" "python3 scripts/ssh-analyzer.py --help"
    run_test "ntp-analyzer" "python3 scripts/ntp-analyzer.py --help"
}

# Test Docker (if available)
test_docker() {
    print_header "Testing Docker"
    
    if command -v docker >/dev/null 2>&1; then
        run_test "Docker" "docker --version"
        run_test "Docker Compose" "docker-compose --version"
        
        # Test if Docker daemon is running
        if docker info >/dev/null 2>&1; then
            print_success "Docker daemon running"
            ((TESTS_PASSED++))
        else
            print_warning "Docker daemon not running"
            ((TESTS_FAILED++))
        fi
    else
        print_warning "Docker not installed (optional for containerized environment)"
    fi
}

# Test containerized environment
test_container_environment() {
    print_header "Testing Container Environment"
    
    if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
        # Check if container is running
        if docker ps | grep -q "net-practice"; then
            print_success "Container environment running"
            ((TESTS_PASSED++))
            
            # Test container tools
            run_test "Container ping" "docker exec net-practice ping -c 1 8.8.8.8"
            run_test "Container Python" "docker exec net-practice python3 --version"
            run_test "Container interface-analyzer" "docker exec net-practice python3 /scripts/interface-analyzer.py --help"
        else
            print_warning "Container environment not running (run ./container-practice.sh start)"
            ((TESTS_FAILED++))
        fi
    else
        print_warning "Docker not available for container testing"
    fi
}

# Test network connectivity
test_network_connectivity() {
    print_header "Testing Network Connectivity"
    
    run_test "Internet connectivity" "ping -c 1 8.8.8.8"
    run_test "DNS resolution" "nslookup google.com"
    run_test "HTTP connectivity" "curl -s --connect-timeout 5 https://httpbin.org/get"
}

# Test file permissions
test_file_permissions() {
    print_header "Testing File Permissions"
    
    run_test "Scripts executable" "test -x scripts/interface-analyzer.py"
    run_test "Install script executable" "test -x install.sh"
    run_test "Setup script executable" "test -x setup.sh"
    run_test "Container script executable" "test -x container-practice.sh"
}

# Test project structure
test_project_structure() {
    print_header "Testing Project Structure"
    
    run_test "Requirements file" "test -f requirements.txt"
    run_test "Docker compose file" "test -f docker-compose.yml"
    run_test "Scripts directory" "test -d scripts"
    run_test "Basics directory" "test -d 01-basics"
    run_test "Protocols directory" "test -d 02-protocols"
    run_test "Admin documentation" "test -d admin"
}

# Performance test
test_performance() {
    print_header "Testing Performance"
    
    # Test script execution time
    start_time=$(date +%s.%N)
    python3 scripts/interface-analyzer.py --help >/dev/null 2>&1
    end_time=$(date +%s.%N)
    execution_time=$(echo "$end_time - $start_time" | bc)
    
    if (( $(echo "$execution_time < 2.0" | bc -l) )); then
        print_success "Script performance good (${execution_time}s)"
        ((TESTS_PASSED++))
    else
        print_warning "Script performance slow (${execution_time}s)"
        ((TESTS_FAILED++))
    fi
}

# Print test summary
print_summary() {
    print_header "Test Summary"
    
    total_tests=$((TESTS_PASSED + TESTS_FAILED))
    
    echo "Total tests: $total_tests"
    echo "Passed: $TESTS_PASSED"
    echo "Failed: $TESTS_FAILED"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        print_success "All tests passed! Installation is working correctly."
        echo ""
        echo "You can now:"
        echo "  - Run Python scripts: python3 scripts/[script-name].py"
        echo "  - Use containerized environment: ./container-practice.sh start"
        echo "  - Enter container: ./container-practice.sh enter"
        echo "  - Read documentation: cat README.md"
    else
        print_warning "Some tests failed. Please check the errors above."
        echo ""
        echo "Common solutions:"
        echo "  - Reinstall dependencies: ./install.sh"
        echo "  - Check Python version: python3 --version"
        echo "  - Check network connectivity: ping 8.8.8.8"
        echo "  - Check Docker: docker --version"
    fi
}

# Main test function
main() {
    print_header "Networking Learning Project - Installation Test"
    
    test_project_structure
    test_file_permissions
    test_python
    test_python_packages
    test_system_tools
    test_python_scripts
    test_docker
    test_container_environment
    test_network_connectivity
    test_performance
    print_summary
}

# Run main function
main "$@"
