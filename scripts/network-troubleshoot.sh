#!/bin/bash
# network-troubleshoot.sh
# Docker Network Troubleshooting Guide

echo "Docker Network Troubleshooting Guide"
echo "===================================="

# Function to check if Docker is running
check_docker() {
    if ! docker --version &> /dev/null; then
        echo "❌ Docker is not installed or not running"
        echo "Please start Docker and try again"
        exit 1
    fi
    echo "✅ Docker is available"
}

# Function to check Docker daemon status
check_docker_daemon() {
    if ! docker info &> /dev/null; then
        echo "❌ Docker daemon is not running"
        echo "Please start Docker daemon and try again"
        exit 1
    fi
    echo "✅ Docker daemon is running"
}

# Function to check network connectivity
check_network_connectivity() {
    echo -e "\n=== Network Connectivity Check ==="
    
    # Check if we can resolve DNS
    if nslookup google.com &> /dev/null; then
        echo "✅ DNS resolution working"
    else
        echo "❌ DNS resolution failed"
    fi
    
    # Check if we can ping external host
    if ping -c 1 8.8.8.8 &> /dev/null; then
        echo "✅ External connectivity working"
    else
        echo "❌ External connectivity failed"
    fi
    
    # Check local connectivity
    if ping -c 1 127.0.0.1 &> /dev/null; then
        echo "✅ Local connectivity working"
    else
        echo "❌ Local connectivity failed"
    fi
}

# Function to check Docker networks
check_docker_networks() {
    echo -e "\n=== Docker Networks Check ==="
    
    echo "Available networks:"
    docker network ls
    
    echo -e "\nNetwork details:"
    docker network ls --format "{{.Name}}" | while read network; do
        echo "Network: $network"
        docker network inspect "$network" | jq '.[0].IPAM.Config' 2>/dev/null || echo "  No IPAM config"
        echo "---"
    done
}

# Function to check running containers
check_running_containers() {
    echo -e "\n=== Running Containers Check ==="
    
    echo "Running containers:"
    docker ps --format "table {{.Names}}\t{{.Networks}}\t{{.Status}}"
    
    echo -e "\nContainer network details:"
    docker ps --format "{{.Names}}" | while read container; do
        echo "Container: $container"
        docker inspect "$container" | jq '.[0].NetworkSettings.Networks' 2>/dev/null || echo "  No network info"
        echo "---"
    done
}

# Function to check for network conflicts
check_network_conflicts() {
    echo -e "\n=== Network Conflicts Check ==="
    
    echo "Checking for subnet conflicts..."
    
    # Get all network subnets
    docker network ls --format "{{.Name}}" | while read network; do
        subnet=$(docker network inspect "$network" | jq -r '.[0].IPAM.Config[0].Subnet' 2>/dev/null)
        if [ "$subnet" != "null" ] && [ -n "$subnet" ]; then
            echo "Network $network: $subnet"
        fi
    done
    
    echo -e "\nChecking for port conflicts..."
    docker ps --format "{{.Names}}\t{{.Ports}}" | grep -v "PORTS" | while read line; do
        if [[ $line == *":"* ]]; then
            echo "Port mapping: $line"
        fi
    done
}

# Function to check network performance
check_network_performance() {
    echo -e "\n=== Network Performance Check ==="
    
    echo "Network interface statistics:"
    if command -v ss &> /dev/null; then
        ss -s
    else
        netstat -s | head -20
    fi
    
    echo -e "\nDocker network statistics:"
    docker system df
    
    echo -e "\nContainer network performance test:"
    if docker ps --format "{{.Names}}" | head -1 | read test_container; then
        if [ -n "$test_container" ]; then
            echo "Testing connectivity from $test_container..."
            docker exec "$test_container" ping -c 3 8.8.8.8 2>/dev/null || echo "  Ping test failed"
        fi
    else
        echo "No running containers for performance test"
    fi
}

# Function to check for common network issues
check_common_issues() {
    echo -e "\n=== Common Network Issues Check ==="
    
    # Check for orphaned networks
    echo "Checking for orphaned networks..."
    docker network ls --format "{{.Name}}" | grep -E "^(test-|temp-|unused-)" | while read network; do
        echo "⚠️  Orphaned network found: $network"
    done
    
    # Check for containers with no networks
    echo -e "\nChecking for containers with network issues..."
    docker ps --format "{{.Names}}" | while read container; do
        network_count=$(docker inspect "$container" | jq '.[0].NetworkSettings.Networks | length' 2>/dev/null)
        if [ "$network_count" -eq 0 ]; then
            echo "⚠️  Container $container has no networks"
        fi
    done
    
    # Check for DNS issues
    echo -e "\nChecking DNS resolution..."
    docker ps --format "{{.Names}}" | head -1 | while read test_container; do
        if [ -n "$test_container" ]; then
            docker exec "$test_container" nslookup google.com 2>/dev/null || echo "⚠️  DNS resolution failed in $test_container"
        fi
    done
}

# Function to check network security
check_network_security() {
    echo -e "\n=== Network Security Check ==="
    
    echo "Checking network security configurations..."
    
    docker network ls --format "{{.Name}}" | while read network; do
        echo "Network: $network"
        
        # Check if network is internal
        internal=$(docker network inspect "$network" | jq '.[0].Internal' 2>/dev/null)
        echo "  Internal: $internal"
        
        # Check ICC settings
        icc=$(docker network inspect "$network" | jq -r '.[0].Options."com.docker.network.bridge.enable_icc"' 2>/dev/null)
        echo "  ICC enabled: $icc"
        
        # Check IP masquerading
        masq=$(docker network inspect "$network" | jq -r '.[0].Options."com.docker.network.bridge.enable_ip_masquerade"' 2>/dev/null)
        echo "  IP masquerading: $masq"
        
        echo "---"
    done
    
    echo -e "\nChecking for exposed services..."
    docker ps --format "{{.Names}}\t{{.Ports}}" | grep -E "0\.0\.0\.0|:::" | while read line; do
        echo "⚠️  Exposed service: $line"
    done
}

# Function to provide troubleshooting recommendations
provide_recommendations() {
    echo -e "\n=== Troubleshooting Recommendations ==="
    
    echo "1. Network Connectivity Issues:"
    echo "   - Check Docker daemon status: systemctl status docker"
    echo "   - Restart Docker service: systemctl restart docker"
    echo "   - Check firewall rules: iptables -L"
    echo "   - Verify network configuration: docker network inspect <network>"
    
    echo -e "\n2. Container Communication Issues:"
    echo "   - Ensure containers are on the same network"
    echo "   - Check inter-container communication settings"
    echo "   - Verify container IP addresses and routing"
    echo "   - Test with ping and nslookup commands"
    
    echo -e "\n3. Performance Issues:"
    echo "   - Use host networking for high-performance requirements"
    echo "   - Optimize MTU settings for your network"
    echo "   - Consider using overlay networks for multi-host setups"
    echo "   - Monitor network usage and optimize accordingly"
    
    echo -e "\n4. Security Issues:"
    echo "   - Use internal networks for sensitive services"
    echo "   - Disable inter-container communication where not needed"
    echo "   - Implement proper network segmentation"
    echo "   - Monitor network traffic for anomalies"
    
    echo -e "\n5. DNS Issues:"
    echo "   - Check Docker DNS configuration"
    echo "   - Verify external DNS servers"
    echo "   - Test DNS resolution from containers"
    echo "   - Consider using custom DNS servers"
}

# Function to generate diagnostic report
generate_report() {
    echo -e "\n=== Generating Diagnostic Report ==="
    
    report_file="/tmp/docker_network_diagnostic_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "Docker Network Diagnostic Report"
        echo "Generated: $(date)"
        echo "======================================"
        
        echo -e "\n=== System Information ==="
        uname -a
        docker --version
        docker info | head -20
        
        echo -e "\n=== Network Interfaces ==="
        ip addr show 2>/dev/null || ifconfig 2>/dev/null || echo "Network interface info not available"
        
        echo -e "\n=== Docker Networks ==="
        docker network ls
        docker network ls --format "{{.Name}}" | while read network; do
            echo "Network: $network"
            docker network inspect "$network" | jq '.[0]' 2>/dev/null || echo "  Inspection failed"
            echo "---"
        done
        
        echo -e "\n=== Running Containers ==="
        docker ps
        docker ps --format "{{.Names}}" | while read container; do
            echo "Container: $container"
            docker inspect "$container" | jq '.[0].NetworkSettings' 2>/dev/null || echo "  Inspection failed"
            echo "---"
        done
        
        echo -e "\n=== Network Statistics ==="
        ss -s 2>/dev/null || netstat -s 2>/dev/null || echo "Network statistics not available"
        
    } > "$report_file"
    
    echo "Diagnostic report saved to: $report_file"
}

# Function to run network tests
run_network_tests() {
    echo -e "\n=== Running Network Tests ==="
    
    echo "Creating test network..."
    docker network create --driver bridge test-network-$(date +%s) 2>/dev/null || echo "Failed to create test network"
    
    echo "Deploying test container..."
    docker run -d --name test-container-$(date +%s) --network test-network-$(date +%s) alpine:latest sleep 300 2>/dev/null || echo "Failed to deploy test container"
    
    echo "Testing network connectivity..."
    if docker ps --format "{{.Names}}" | grep test-container | head -1 | read test_container; then
        if [ -n "$test_container" ]; then
            echo "Testing from $test_container..."
            docker exec "$test_container" ping -c 3 8.8.8.8 2>/dev/null || echo "  External connectivity test failed"
            docker exec "$test_container" nslookup google.com 2>/dev/null || echo "  DNS resolution test failed"
        fi
    fi
    
    echo "Cleaning up test resources..."
    docker ps -a --format "{{.Names}}" | grep test-container | while read container; do
        docker rm -f "$container" 2>/dev/null || true
    done
    docker network ls --format "{{.Name}}" | grep test-network | while read network; do
        docker network rm "$network" 2>/dev/null || true
    done
}

# Main troubleshooting function
main() {
    echo "Starting Docker network troubleshooting..."
    echo "=========================================="
    
    # Check Docker availability
    check_docker
    check_docker_daemon
    
    # Run all checks
    check_network_connectivity
    check_docker_networks
    check_running_containers
    check_network_conflicts
    check_network_performance
    check_common_issues
    check_network_security
    
    # Run network tests
    run_network_tests
    
    # Provide recommendations
    provide_recommendations
    
    # Generate report
    generate_report
    
    echo -e "\n✅ Docker network troubleshooting analysis complete!"
    echo "Review the output above for any issues or warnings."
}

# Run main function
main "$@"
