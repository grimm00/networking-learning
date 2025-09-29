#!/bin/bash
# Overlay Networks Troubleshooting Guide
# Comprehensive diagnostic and troubleshooting tools for Docker Swarm overlay networks

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Troubleshooting configuration
LOG_DIR="/tmp/overlay-troubleshoot-logs"
DIAGNOSTIC_DIR="$LOG_DIR/diagnostics"
NETWORK_DIR="$LOG_DIR/networks"
SERVICE_DIR="$LOG_DIR/services"
NODE_DIR="$LOG_DIR/nodes"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

print_step() {
    echo -e "${CYAN}→ $1${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to run command and capture output
run_command() {
    local cmd="$1"
    local output_file="$2"
    
    if [ -n "$output_file" ]; then
        eval "$cmd" > "$output_file" 2>&1
        echo "Command output saved to: $output_file"
    else
        eval "$cmd"
    fi
}

# Function to setup troubleshooting environment
setup_troubleshoot_environment() {
    print_header "Setting Up Troubleshooting Environment"
    
    # Create log directories
    mkdir -p "$LOG_DIR"/{diagnostics,networks,services,nodes,logs}
    
    print_status "Troubleshooting directories created"
    
    # Check if Docker is available
    if command -v docker >/dev/null 2>&1; then
        print_status "Docker is available"
        USE_DOCKER=true
    else
        print_error "Docker not available"
        USE_DOCKER=false
        return 1
    fi
    
    # Check if Docker Swarm is available
    if docker info --format '{{.Swarm.LocalNodeState}}' 2>/dev/null | grep -q "active"; then
        print_status "Docker Swarm is active"
        SWARM_AVAILABLE=true
    else
        print_warning "Docker Swarm not initialized"
        SWARM_AVAILABLE=false
    fi
    
    print_status "Troubleshooting environment ready"
}

# Function to diagnose Swarm cluster health
diagnose_swarm_health() {
    print_header "Docker Swarm Cluster Health Diagnosis"
    
    if [ "$SWARM_AVAILABLE" = false ]; then
        print_error "Docker Swarm not available"
        return 1
    fi
    
    print_step "Checking Swarm cluster status..."
    
    # Get Swarm info
    docker info --format '{{.Swarm.LocalNodeState}}' > "$DIAGNOSTIC_DIR/swarm-status"
    docker info --format '{{.Swarm.Cluster.ID}}' > "$DIAGNOSTIC_DIR/cluster-id"
    docker info --format '{{.Swarm.Nodes}}' > "$DIAGNOSTIC_DIR/node-count"
    docker info --format '{{.Swarm.Managers}}' > "$DIAGNOSTIC_DIR/manager-count"
    
    print_status "Swarm cluster information collected"
    
    # Check node status
    print_step "Checking node status..."
    docker node ls > "$NODE_DIR/node-list"
    
    # Analyze node health
    local unhealthy_nodes=0
    local total_nodes=0
    
    while IFS= read -r line; do
        if [[ $line == *"Ready"* ]]; then
            total_nodes=$((total_nodes + 1))
        elif [[ $line == *"Down"* ]] || [[ $line == *"Unknown"* ]]; then
            unhealthy_nodes=$((unhealthy_nodes + 1))
            total_nodes=$((total_nodes + 1))
        fi
    done < "$NODE_DIR/node-list"
    
    print_status "Node health analysis:"
    print_status "  Total nodes: $total_nodes"
    print_status "  Unhealthy nodes: $unhealthy_nodes"
    
    if [ $unhealthy_nodes -gt 0 ]; then
        print_warning "Found $unhealthy_nodes unhealthy nodes"
        print_step "Unhealthy nodes:"
        grep -E "(Down|Unknown)" "$NODE_DIR/node-list" || true
    else
        print_status "All nodes are healthy"
    fi
    
    # Check manager nodes
    print_step "Checking manager nodes..."
    local manager_count=$(docker node ls --format '{{.ManagerStatus}}' | grep -c "Leader\|Reachable" || echo "0")
    print_status "Active manager nodes: $manager_count"
    
    if [ $manager_count -lt 1 ]; then
        print_error "No active manager nodes found"
    elif [ $manager_count -lt 3 ]; then
        print_warning "Only $manager_count manager nodes - consider adding more for high availability"
    else
        print_status "Manager node count is adequate for high availability"
    fi
}

# Function to diagnose overlay networks
diagnose_overlay_networks() {
    print_header "Overlay Networks Diagnosis"
    
    print_step "Collecting overlay network information..."
    
    # List overlay networks
    docker network ls --filter driver=overlay > "$NETWORK_DIR/overlay-networks"
    
    # Count overlay networks
    local overlay_count=$(grep -c "overlay" "$NETWORK_DIR/overlay-networks" || echo "0")
    print_status "Overlay networks found: $overlay_count"
    
    if [ $overlay_count -eq 0 ]; then
        print_warning "No overlay networks found"
        return 0
    fi
    
    # Inspect each overlay network
    print_step "Inspecting overlay networks..."
    while IFS= read -r line; do
        if [[ $line == *"overlay"* ]]; then
            network_name=$(echo "$line" | awk '{print $2}')
            if [ "$network_name" != "NAME" ]; then
                echo "Inspecting network: $network_name"
                docker network inspect "$network_name" > "$NETWORK_DIR/${network_name}-inspect.json"
                
                # Check network health
                local container_count=$(docker network inspect "$network_name" --format '{{len .Containers}}')
                local service_count=$(docker service ls --filter network="$network_name" --format '{{.Name}}' | wc -l)
                
                print_status "  Network: $network_name"
                print_status "    Containers: $container_count"
                print_status "    Services: $service_count"
                
                # Check encryption
                local encrypted=$(docker network inspect "$network_name" --format '{{.Options.encrypted}}')
                if [ "$encrypted" = "true" ]; then
                    print_status "    Encryption: Enabled"
                else
                    print_warning "    Encryption: Disabled"
                fi
            fi
        fi
    done < "$NETWORK_DIR/overlay-networks"
    
    print_status "Overlay network inspection complete"
}

# Function to diagnose services
diagnose_services() {
    print_header "Swarm Services Diagnosis"
    
    print_step "Collecting service information..."
    
    # List services
    docker service ls > "$SERVICE_DIR/service-list"
    
    # Count services
    local service_count=$(grep -c "overlay" "$SERVICE_DIR/service-list" 2>/dev/null || echo "0")
    if [ $service_count -eq 0 ]; then
        service_count=$(wc -l < "$SERVICE_DIR/service-list")
        service_count=$((service_count - 1)) # Subtract header line
    fi
    
    print_status "Services found: $service_count"
    
    if [ $service_count -eq 0 ]; then
        print_warning "No services found"
        return 0
    fi
    
    # Inspect each service
    print_step "Inspecting services..."
    while IFS= read -r line; do
        if [[ $line == *"overlay"* ]] || [[ $line == *"nginx"* ]] || [[ $line == *"alpine"* ]]; then
            service_name=$(echo "$line" | awk '{print $2}')
            if [ "$service_name" != "NAME" ]; then
                echo "Inspecting service: $service_name"
                docker service inspect "$service_name" > "$SERVICE_DIR/${service_name}-inspect.json"
                
                # Get service tasks
                docker service ps "$service_name" > "$SERVICE_DIR/${service_name}-tasks"
                
                # Analyze service health
                local running_tasks=$(grep -c "Running" "$SERVICE_DIR/${service_name}-tasks" || echo "0")
                local failed_tasks=$(grep -c "Failed" "$SERVICE_DIR/${service_name}-tasks" || echo "0")
                local total_tasks=$(wc -l < "$SERVICE_DIR/${service_name}-tasks")
                total_tasks=$((total_tasks - 1)) # Subtract header line
                
                print_status "  Service: $service_name"
                print_status "    Running tasks: $running_tasks"
                print_status "    Failed tasks: $failed_tasks"
                print_status "    Total tasks: $total_tasks"
                
                if [ $failed_tasks -gt 0 ]; then
                    print_warning "    Service has failed tasks"
                    print_step "    Failed tasks:"
                    grep "Failed" "$SERVICE_DIR/${service_name}-tasks" || true
                fi
                
                # Check service logs
                print_step "    Checking service logs..."
                docker service logs "$service_name" --tail 10 > "$SERVICE_DIR/${service_name}-logs" 2>&1
            fi
        fi
    done < "$SERVICE_DIR/service-list"
    
    print_status "Service inspection complete"
}

# Function to diagnose network connectivity
diagnose_network_connectivity() {
    print_header "Network Connectivity Diagnosis"
    
    print_step "Testing network connectivity..."
    
    # Test basic connectivity
    print_step "Testing basic connectivity..."
    
    # Test localhost connectivity
    if ping -c 1 127.0.0.1 >/dev/null 2>&1; then
        print_status "Localhost connectivity: OK"
    else
        print_error "Localhost connectivity: FAILED"
    fi
    
    # Test Docker daemon connectivity
    if docker info >/dev/null 2>&1; then
        print_status "Docker daemon connectivity: OK"
    else
        print_error "Docker daemon connectivity: FAILED"
    fi
    
    # Test Swarm connectivity
    if [ "$SWARM_AVAILABLE" = true ]; then
        if docker node ls >/dev/null 2>&1; then
            print_status "Swarm connectivity: OK"
        else
            print_error "Swarm connectivity: FAILED"
        fi
    fi
    
    # Test overlay network connectivity
    print_step "Testing overlay network connectivity..."
    
    # Get overlay networks
    local overlay_networks=$(docker network ls --filter driver=overlay --format '{{.Name}}' | grep -v "NAME")
    
    for network in $overlay_networks; do
        print_step "Testing network: $network"
        
        # Create test container
        local test_container="test-connectivity-$(date +%s)"
        if docker run -d --name "$test_container" --network "$network" alpine:latest sleep 30 >/dev/null 2>&1; then
            print_status "  Test container created successfully"
            
            # Test DNS resolution
            if docker exec "$test_container" nslookup google.com >/dev/null 2>&1; then
                print_status "  DNS resolution: OK"
            else
                print_warning "  DNS resolution: FAILED"
            fi
            
            # Test internet connectivity
            if docker exec "$test_container" ping -c 1 8.8.8.8 >/dev/null 2>&1; then
                print_status "  Internet connectivity: OK"
            else
                print_warning "  Internet connectivity: FAILED"
            fi
            
            # Clean up test container
            docker rm -f "$test_container" >/dev/null 2>&1
        else
            print_error "  Failed to create test container"
        fi
    done
    
    print_status "Network connectivity testing complete"
}

# Function to diagnose service discovery
diagnose_service_discovery() {
    print_header "Service Discovery Diagnosis"
    
    print_step "Testing service discovery..."
    
    # Get services
    local services=$(docker service ls --format '{{.Name}}' | grep -v "NAME")
    
    if [ -z "$services" ]; then
        print_warning "No services found for discovery testing"
        return 0
    fi
    
    # Test service discovery for each service
    for service in $services; do
        print_step "Testing service discovery for: $service"
        
        # Create test container on the same network as the service
        local service_networks=$(docker service inspect "$service" --format '{{range .Spec.TaskTemplate.ContainerSpec.Networks}}{{.Target}} {{end}}')
        
        if [ -n "$service_networks" ]; then
            for network in $service_networks; do
                print_step "  Testing on network: $network"
                
                local test_container="test-discovery-$(date +%s)"
                if docker run -d --name "$test_container" --network "$network" alpine:latest sleep 30 >/dev/null 2>&1; then
                    # Test DNS resolution
                    if docker exec "$test_container" nslookup "$service" >/dev/null 2>&1; then
                        print_status "    DNS resolution: OK"
                    else
                        print_warning "    DNS resolution: FAILED"
                    fi
                    
                    # Test service connectivity
                    if docker exec "$test_container" ping -c 1 "$service" >/dev/null 2>&1; then
                        print_status "    Service connectivity: OK"
                    else
                        print_warning "    Service connectivity: FAILED"
                    fi
                    
                    # Clean up test container
                    docker rm -f "$test_container" >/dev/null 2>&1
                else
                    print_error "    Failed to create test container"
                fi
            done
        else
            print_warning "  Service has no networks configured"
        fi
    done
    
    print_status "Service discovery testing complete"
}

# Function to diagnose load balancing
diagnose_load_balancing() {
    print_header "Load Balancing Diagnosis"
    
    print_step "Testing load balancing..."
    
    # Get services with published ports
    local services_with_ports=$(docker service ls --format '{{.Name}} {{.Ports}}' | grep -v "NAME" | grep -v "^\s*$")
    
    if [ -z "$services_with_ports" ]; then
        print_warning "No services with published ports found"
        return 0
    fi
    
    # Test load balancing for each service
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            service_name=$(echo "$line" | awk '{print $1}')
            ports=$(echo "$line" | awk '{print $2}')
            
            print_step "Testing load balancing for: $service_name"
            print_status "  Published ports: $ports"
            
            # Extract published port
            local published_port=$(echo "$ports" | grep -o '[0-9]*:[0-9]*' | head -1 | cut -d: -f1)
            
            if [ -n "$published_port" ]; then
                print_step "  Testing port: $published_port"
                
                # Test multiple requests
                local success_count=0
                local total_requests=10
                
                for i in $(seq 1 $total_requests); do
                    if curl -s "http://localhost:$published_port" >/dev/null 2>&1; then
                        success_count=$((success_count + 1))
                    fi
                    sleep 0.1
                done
                
                local success_rate=$((success_count * 100 / total_requests))
                print_status "  Success rate: $success_rate% ($success_count/$total_requests)"
                
                if [ $success_rate -lt 80 ]; then
                    print_warning "  Load balancing may have issues"
                else
                    print_status "  Load balancing appears to be working"
                fi
            else
                print_warning "  No published port found"
            fi
        fi
    done <<< "$services_with_ports"
    
    print_status "Load balancing testing complete"
}

# Function to diagnose performance issues
diagnose_performance() {
    print_header "Performance Diagnosis"
    
    print_step "Collecting performance metrics..."
    
    # System resources
    print_step "Checking system resources..."
    
    # Memory usage
    free -h > "$DIAGNOSTIC_DIR/memory-usage"
    print_status "Memory usage:"
    cat "$DIAGNOSTIC_DIR/memory-usage"
    
    # CPU usage
    top -bn1 | grep "Cpu(s)" > "$DIAGNOSTIC_DIR/cpu-usage"
    print_status "CPU usage:"
    cat "$DIAGNOSTIC_DIR/cpu-usage"
    
    # Disk usage
    df -h > "$DIAGNOSTIC_DIR/disk-usage"
    print_status "Disk usage:"
    cat "$DIAGNOSTIC_DIR/disk-usage"
    
    # Docker system info
    print_step "Checking Docker system information..."
    docker system df > "$DIAGNOSTIC_DIR/docker-system-df"
    print_status "Docker system usage:"
    cat "$DIAGNOSTIC_DIR/docker-system-df"
    
    # Network interfaces
    print_step "Checking network interfaces..."
    ip addr show > "$DIAGNOSTIC_DIR/network-interfaces"
    print_status "Network interfaces:"
    cat "$DIAGNOSTIC_DIR/network-interfaces"
    
    # Docker daemon performance
    print_step "Checking Docker daemon performance..."
    docker info --format '{{.ServerVersion}} {{.ContainersRunning}} {{.ContainersPaused}} {{.ContainersStopped}}' > "$DIAGNOSTIC_DIR/docker-daemon-info"
    print_status "Docker daemon info:"
    cat "$DIAGNOSTIC_DIR/docker-daemon-info"
    
    print_status "Performance diagnosis complete"
}

# Function to generate troubleshooting report
generate_troubleshoot_report() {
    print_header "Generating Troubleshooting Report"
    
    local report_file="$LOG_DIR/troubleshoot-report-$(date +%Y%m%d-%H%M%S).txt"
    
    {
        echo "Overlay Networks Troubleshooting Report"
        echo "Generated: $(date)"
        echo "========================================"
        echo
        
        echo "1. Swarm Cluster Health:"
        echo "----------------------"
        if [ -f "$DIAGNOSTIC_DIR/swarm-status" ]; then
            echo "Swarm Status: $(cat "$DIAGNOSTIC_DIR/swarm-status")"
        fi
        if [ -f "$DIAGNOSTIC_DIR/node-count" ]; then
            echo "Node Count: $(cat "$DIAGNOSTIC_DIR/node-count")"
        fi
        if [ -f "$DIAGNOSTIC_DIR/manager-count" ]; then
            echo "Manager Count: $(cat "$DIAGNOSTIC_DIR/manager-count")"
        fi
        echo
        
        echo "2. Overlay Networks:"
        echo "-------------------"
        if [ -f "$NETWORK_DIR/overlay-networks" ]; then
            cat "$NETWORK_DIR/overlay-networks"
        fi
        echo
        
        echo "3. Services:"
        echo "------------"
        if [ -f "$SERVICE_DIR/service-list" ]; then
            cat "$SERVICE_DIR/service-list"
        fi
        echo
        
        echo "4. System Resources:"
        echo "-------------------"
        if [ -f "$DIAGNOSTIC_DIR/memory-usage" ]; then
            echo "Memory:"
            cat "$DIAGNOSTIC_DIR/memory-usage"
        fi
        if [ -f "$DIAGNOSTIC_DIR/cpu-usage" ]; then
            echo "CPU:"
            cat "$DIAGNOSTIC_DIR/cpu-usage"
        fi
        if [ -f "$DIAGNOSTIC_DIR/disk-usage" ]; then
            echo "Disk:"
            cat "$DIAGNOSTIC_DIR/disk-usage"
        fi
        echo
        
        echo "5. Docker System:"
        echo "---------------"
        if [ -f "$DIAGNOSTIC_DIR/docker-system-df" ]; then
            cat "$DIAGNOSTIC_DIR/docker-system-df"
        fi
        echo
        
        echo "6. Network Interfaces:"
        echo "--------------------"
        if [ -f "$DIAGNOSTIC_DIR/network-interfaces" ]; then
            cat "$DIAGNOSTIC_DIR/network-interfaces"
        fi
        
    } > "$report_file"
    
    print_status "Troubleshooting report generated: $report_file"
}

# Function to provide troubleshooting recommendations
provide_recommendations() {
    print_header "Troubleshooting Recommendations"
    
    local recommendations=()
    
    # Check Swarm health
    if [ "$SWARM_AVAILABLE" = false ]; then
        recommendations+=("Initialize Docker Swarm: docker swarm init")
    fi
    
    # Check overlay networks
    local overlay_count=$(docker network ls --filter driver=overlay --format '{{.Name}}' | wc -l)
    if [ $overlay_count -eq 0 ]; then
        recommendations+=("Create overlay networks for multi-host communication")
    fi
    
    # Check services
    local service_count=$(docker service ls --format '{{.Name}}' | wc -l)
    if [ $service_count -eq 0 ]; then
        recommendations+=("Deploy services to test overlay networking")
    fi
    
    # Check node health
    local unhealthy_nodes=$(docker node ls --format '{{.Status}}' | grep -c -E "(Down|Unknown)" || echo "0")
    if [ $unhealthy_nodes -gt 0 ]; then
        recommendations+=("Investigate and fix unhealthy nodes")
    fi
    
    # Check manager nodes
    local manager_count=$(docker node ls --format '{{.ManagerStatus}}' | grep -c -E "(Leader|Reachable)" || echo "0")
    if [ $manager_count -lt 3 ]; then
        recommendations+=("Consider adding more manager nodes for high availability")
    fi
    
    # Check network encryption
    local unencrypted_networks=$(docker network ls --filter driver=overlay --format '{{.Name}}' | while read -r network; do
        if [ "$network" != "NAME" ]; then
            encrypted=$(docker network inspect "$network" --format '{{.Options.encrypted}}')
            if [ "$encrypted" != "true" ]; then
                echo "$network"
            fi
        fi
    done | wc -l)
    
    if [ $unencrypted_networks -gt 0 ]; then
        recommendations+=("Enable encryption on overlay networks for security")
    fi
    
    # Check service health
    local failed_services=$(docker service ls --format '{{.Name}}' | while read -r service; do
        if [ "$service" != "NAME" ]; then
            failed_tasks=$(docker service ps "$service" --format '{{.CurrentState}}' | grep -c "Failed" || echo "0")
            if [ $failed_tasks -gt 0 ]; then
                echo "$service"
            fi
        fi
    done | wc -l)
    
    if [ $failed_services -gt 0 ]; then
        recommendations+=("Investigate and fix failed services")
    fi
    
    # Display recommendations
    if [ ${#recommendations[@]} -gt 0 ]; then
        print_status "Recommendations:"
        for i in "${!recommendations[@]}"; do
            echo "  $((i+1)). ${recommendations[i]}"
        done
    else
        print_status "No specific recommendations - overlay network setup looks good!"
    fi
}

# Function to cleanup troubleshooting environment
cleanup_troubleshoot() {
    print_header "Cleaning Up Troubleshooting Environment"
    
    # Remove log directory
    if [ -d "$LOG_DIR" ]; then
        rm -rf "$LOG_DIR"
        print_status "Troubleshooting logs removed"
    fi
    
    # Remove any test containers
    docker container prune -f >/dev/null 2>&1 || true
    print_status "Test containers cleaned up"
    
    print_status "Troubleshooting cleanup complete"
}

# Main menu
show_menu() {
    echo
    print_header "Overlay Networks Troubleshooting Menu"
    echo "1. Setup Troubleshooting Environment"
    echo "2. Diagnose Swarm Cluster Health"
    echo "3. Diagnose Overlay Networks"
    echo "4. Diagnose Services"
    echo "5. Diagnose Network Connectivity"
    echo "6. Diagnose Service Discovery"
    echo "7. Diagnose Load Balancing"
    echo "8. Diagnose Performance"
    echo "9. Generate Troubleshooting Report"
    echo "10. Provide Recommendations"
    echo "11. Run All Diagnostics"
    echo "12. Cleanup Troubleshooting Environment"
    echo "0. Exit"
    echo
}

# Main function
main() {
    print_header "Overlay Networks Troubleshooting Guide"
    print_status "Welcome to the Overlay Networks Troubleshooting Guide!"
    print_status "This tool will help you diagnose and fix overlay network issues."
    
    while true; do
        show_menu
        read -p "Select an option (0-12): " choice
        
        case $choice in
            1)
                setup_troubleshoot_environment
                ;;
            2)
                diagnose_swarm_health
                ;;
            3)
                diagnose_overlay_networks
                ;;
            4)
                diagnose_services
                ;;
            5)
                diagnose_network_connectivity
                ;;
            6)
                diagnose_service_discovery
                ;;
            7)
                diagnose_load_balancing
                ;;
            8)
                diagnose_performance
                ;;
            9)
                generate_troubleshoot_report
                ;;
            10)
                provide_recommendations
                ;;
            11)
                setup_troubleshoot_environment
                diagnose_swarm_health
                diagnose_overlay_networks
                diagnose_services
                diagnose_network_connectivity
                diagnose_service_discovery
                diagnose_load_balancing
                diagnose_performance
                generate_troubleshoot_report
                provide_recommendations
                ;;
            12)
                cleanup_troubleshoot
                ;;
            0)
                print_status "Exiting Troubleshooting Guide"
                exit 0
                ;;
            *)
                print_error "Invalid option. Please select 0-12."
                ;;
        esac
        
        echo
        read -p "Press Enter to continue..."
    done
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
