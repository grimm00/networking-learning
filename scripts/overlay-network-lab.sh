#!/bin/bash
# Overlay Networks Lab Exercises
# Comprehensive hands-on exercises for learning Docker Swarm overlay networking

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Lab configuration
LAB_DIR="/tmp/overlay-networks-lab"
SWARM_DIR="$LAB_DIR/swarm"
NETWORKS_DIR="$LAB_DIR/networks"
SERVICES_DIR="$LAB_DIR/services"
SCRIPTS_DIR="$LAB_DIR/scripts"

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

# Function to check if running in container
check_container() {
    if [ -f /.dockerenv ] || [ -n "${DOCKER_CONTAINER:-}" ]; then
        return 0
    else
        return 1
    fi
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to setup lab environment
setup_lab_environment() {
    print_header "Setting Up Overlay Networks Lab Environment"
    
    # Create lab directories
    mkdir -p "$LAB_DIR"/{swarm,networks,services,scripts,logs}
    mkdir -p "$SWARM_DIR"/{managers,workers}
    mkdir -p "$NETWORKS_DIR"/{overlay,bridge}
    mkdir -p "$SERVICES_DIR"/{web,api,database}
    
    print_status "Lab directories created"
    
    # Check if Docker is available
    if command -v docker >/dev/null 2>&1; then
        print_status "Docker is available"
        USE_DOCKER=true
    else
        print_warning "Docker not available, using local setup"
        USE_DOCKER=false
    fi
    
    # Check if Docker Swarm is available
    if docker info --format '{{.Swarm.LocalNodeState}}' 2>/dev/null | grep -q "active"; then
        print_status "Docker Swarm is active"
        SWARM_AVAILABLE=true
    else
        print_warning "Docker Swarm not initialized"
        SWARM_AVAILABLE=false
    fi
    
    # Check if curl is available
    if command -v curl >/dev/null 2>&1; then
        print_status "curl is available"
        CURL_AVAILABLE=true
    else
        print_warning "curl not available"
        CURL_AVAILABLE=false
    fi
}

# Exercise 1: Basic Swarm Setup
exercise_1_swarm_setup() {
    print_header "Exercise 1: Basic Swarm Setup"
    
    if [ "$USE_DOCKER" = true ]; then
        print_step "Initializing Docker Swarm..."
        
        # Initialize Swarm
        docker swarm init --advertise-addr 127.0.0.1 2>/dev/null || print_warning "Swarm already initialized"
        
        print_status "Docker Swarm initialized"
        
        # Get join tokens
        print_step "Getting join tokens..."
        MANAGER_TOKEN=$(docker swarm join-token manager -q)
        WORKER_TOKEN=$(docker swarm join-token worker -q)
        
        echo "Manager Token: $MANAGER_TOKEN"
        echo "Worker Token: $WORKER_TOKEN"
        
        # Save tokens to files
        echo "$MANAGER_TOKEN" > "$SWARM_DIR/managers/join-token"
        echo "$WORKER_TOKEN" > "$SWARM_DIR/workers/join-token"
        
        # Check Swarm status
        print_step "Checking Swarm status..."
        docker node ls
        
        # Get Swarm info
        print_step "Getting Swarm information..."
        docker info --format '{{.Swarm.Cluster.ID}}' > "$SWARM_DIR/cluster-id"
        docker info --format '{{.Swarm.Nodes}}' > "$SWARM_DIR/node-count"
        
        print_status "Swarm setup complete"
        
    else
        print_warning "Docker not available for this exercise"
        print_status "Please install Docker to run this exercise"
    fi
}

# Exercise 2: Overlay Network Creation
exercise_2_overlay_networks() {
    print_header "Exercise 2: Overlay Network Creation"
    
    if [ "$USE_DOCKER" = true ] && [ "$SWARM_AVAILABLE" = true ]; then
        print_step "Creating overlay networks..."
        
        # Create basic overlay network
        docker network create \
            --driver overlay \
            --attachable \
            basic-overlay
        
        print_status "Basic overlay network created"
        
        # Create encrypted overlay network
        docker network create \
            --driver overlay \
            --attachable \
            --encrypted \
            encrypted-overlay
        
        print_status "Encrypted overlay network created"
        
        # Create custom subnet overlay network
        docker network create \
            --driver overlay \
            --attachable \
            --subnet 10.0.1.0/24 \
            --ip-range 10.0.1.0/24 \
            custom-overlay
        
        print_status "Custom subnet overlay network created"
        
        # List overlay networks
        print_step "Listing overlay networks..."
        docker network ls --filter driver=overlay
        
        # Inspect networks
        print_step "Inspecting overlay networks..."
        for network in basic-overlay encrypted-overlay custom-overlay; do
            echo "Network: $network"
            docker network inspect $network --format '{{.Driver}} {{.Scope}} {{.Options}}'
        done
        
        # Save network information
        docker network ls --filter driver=overlay --format '{{.Name}}' > "$NETWORKS_DIR/overlay/network-list"
        
        print_status "Overlay network creation complete"
        
    else
        print_warning "Docker Swarm not available for this exercise"
    fi
}

# Exercise 3: Service Deployment
exercise_3_service_deployment() {
    print_header "Exercise 3: Service Deployment"
    
    if [ "$USE_DOCKER" = true ] && [ "$SWARM_AVAILABLE" = true ]; then
        print_step "Deploying services on overlay networks..."
        
        # Deploy web service
        docker service create \
            --name web-service \
            --network basic-overlay \
            --replicas 3 \
            --publish 80:80 \
            nginx:alpine
        
        print_status "Web service deployed"
        
        # Deploy API service
        docker service create \
            --name api-service \
            --network encrypted-overlay \
            --replicas 2 \
            --publish 8080:8080 \
            httpd:alpine
        
        print_status "API service deployed"
        
        # Deploy database service
        docker service create \
            --name db-service \
            --network custom-overlay \
            --replicas 1 \
            --publish 5432:5432 \
            postgres:13-alpine
        
        print_status "Database service deployed"
        
        # Check service status
        print_step "Checking service status..."
        docker service ls
        
        # Check service tasks
        print_step "Checking service tasks..."
        for service in web-service api-service db-service; do
            echo "Service: $service"
            docker service ps $service --format '{{.Name}} {{.Node}} {{.CurrentState}}'
        done
        
        # Save service information
        docker service ls --format '{{.Name}} {{.Replicas}} {{.Image}}' > "$SERVICES_DIR/service-list"
        
        print_status "Service deployment complete"
        
    else
        print_warning "Docker Swarm not available for this exercise"
    fi
}

# Exercise 4: Service Discovery
exercise_4_service_discovery() {
    print_header "Exercise 4: Service Discovery"
    
    if [ "$USE_DOCKER" = true ] && [ "$SWARM_AVAILABLE" = true ]; then
        print_step "Testing service discovery..."
        
        # Create a test container on the overlay network
        docker run -d --name test-container --network basic-overlay alpine:latest sleep 3600
        
        print_status "Test container created"
        
        # Test DNS resolution
        print_step "Testing DNS resolution..."
        docker exec test-container nslookup web-service
        
        # Test service connectivity
        print_step "Testing service connectivity..."
        docker exec test-container wget -qO- http://web-service/ | head -5
        
        # Test cross-network communication
        print_step "Testing cross-network communication..."
        docker run --rm --network encrypted-overlay alpine:latest wget -qO- http://api-service/ | head -5
        
        # Test database connectivity
        print_step "Testing database connectivity..."
        docker run --rm --network custom-overlay postgres:13-alpine pg_isready -h db-service -p 5432
        
        # Clean up test container
        docker rm -f test-container
        
        print_status "Service discovery testing complete"
        
    else
        print_warning "Docker Swarm not available for this exercise"
    fi
}

# Exercise 5: Load Balancing
exercise_5_load_balancing() {
    print_header "Exercise 5: Load Balancing"
    
    if [ "$USE_DOCKER" = true ] && [ "$SWARM_AVAILABLE" = true ]; then
        print_step "Testing load balancing..."
        
        # Scale web service
        docker service scale web-service=5
        
        print_status "Web service scaled to 5 replicas"
        
        # Test load balancing
        print_step "Testing load balancing..."
        for i in {1..10}; do
            echo "Request $i:"
            curl -s http://localhost/ | grep -o "Server: [^<]*" || echo "No response"
            sleep 1
        done
        
        # Check service distribution
        print_step "Checking service distribution..."
        docker service ps web-service --format '{{.Node}} {{.CurrentState}}'
        
        # Test health checks
        print_step "Testing health checks..."
        docker service inspect web-service --format '{{.Spec.TaskTemplate.ContainerSpec.Healthcheck}}'
        
        # Test rolling updates
        print_step "Testing rolling updates..."
        docker service update --image nginx:latest web-service
        
        # Wait for update to complete
        sleep 10
        
        # Check update status
        docker service ps web-service --format '{{.Name}} {{.Image}} {{.CurrentState}}'
        
        print_status "Load balancing testing complete"
        
    else
        print_warning "Docker Swarm not available for this exercise"
    fi
}

# Exercise 6: Network Security
exercise_6_network_security() {
    print_header "Exercise 6: Network Security"
    
    if [ "$USE_DOCKER" = true ] && [ "$SWARM_AVAILABLE" = true ]; then
        print_step "Testing network security..."
        
        # Check network encryption
        print_step "Checking network encryption..."
        for network in basic-overlay encrypted-overlay custom-overlay; do
            echo "Network: $network"
            docker network inspect $network --format '{{.Options.encrypted}}'
        done
        
        # Test network isolation
        print_step "Testing network isolation..."
        
        # Create containers on different networks
        docker run -d --name test-basic --network basic-overlay alpine:latest sleep 3600
        docker run -d --name test-encrypted --network encrypted-overlay alpine:latest sleep 3600
        docker run -d --name test-custom --network custom-overlay alpine:latest sleep 3600
        
        # Test cross-network connectivity (should fail)
        print_step "Testing cross-network connectivity..."
        docker exec test-basic ping -c 1 test-encrypted || echo "Cross-network ping failed (expected)"
        docker exec test-basic ping -c 1 test-custom || echo "Cross-network ping failed (expected)"
        
        # Test same-network connectivity (should succeed)
        print_step "Testing same-network connectivity..."
        docker exec test-basic ping -c 1 web-service || echo "Same-network ping failed"
        
        # Clean up test containers
        docker rm -f test-basic test-encrypted test-custom
        
        # Test service constraints
        print_step "Testing service constraints..."
        docker service create \
            --name constrained-service \
            --network basic-overlay \
            --constraint 'node.role==worker' \
            --replicas 1 \
            alpine:latest sleep 3600
        
        # Check constraint compliance
        docker service ps constrained-service --format '{{.Node}} {{.CurrentState}}'
        
        # Clean up constrained service
        docker service rm constrained-service
        
        print_status "Network security testing complete"
        
    else
        print_warning "Docker Swarm not available for this exercise"
    fi
}

# Exercise 7: High Availability
exercise_7_high_availability() {
    print_header "Exercise 7: High Availability"
    
    if [ "$USE_DOCKER" = true ] && [ "$SWARM_AVAILABLE" = true ]; then
        print_step "Testing high availability..."
        
        # Create HA service
        docker service create \
            --name ha-service \
            --network encrypted-overlay \
            --replicas 3 \
            --update-parallelism 1 \
            --update-delay 10s \
            --rollback-parallelism 1 \
            --rollback-delay 5s \
            --restart-condition on-failure \
            --restart-delay 5s \
            --restart-max-attempts 3 \
            --health-cmd "curl -f http://localhost/ || exit 1" \
            --health-interval 30s \
            --health-timeout 10s \
            --health-retries 3 \
            nginx:alpine
        
        print_status "HA service created"
        
        # Check HA service status
        print_step "Checking HA service status..."
        docker service ps ha-service --format '{{.Name}} {{.Node}} {{.CurrentState}}'
        
        # Test service resilience
        print_step "Testing service resilience..."
        
        # Simulate node failure by stopping a service task
        TASK_ID=$(docker service ps ha-service --format '{{.ID}}' | head -1)
        if [ -n "$TASK_ID" ]; then
            echo "Simulating task failure for task: $TASK_ID"
            # Note: In a real scenario, you would stop the container or node
            # For this lab, we'll just check the service status
        fi
        
        # Check service recovery
        print_step "Checking service recovery..."
        sleep 5
        docker service ps ha-service --format '{{.Name}} {{.CurrentState}}'
        
        # Test rolling updates
        print_step "Testing rolling updates..."
        docker service update --image nginx:latest ha-service
        
        # Wait for update
        sleep 15
        
        # Check update status
        docker service ps ha-service --format '{{.Name}} {{.Image}} {{.CurrentState}}'
        
        print_status "High availability testing complete"
        
    else
        print_warning "Docker Swarm not available for this exercise"
    fi
}

# Exercise 8: Microservices Architecture
exercise_8_microservices() {
    print_header "Exercise 8: Microservices Architecture"
    
    if [ "$USE_DOCKER" = true ] && [ "$SWARM_AVAILABLE" = true ]; then
        print_step "Deploying microservices architecture..."
        
        # Create microservices overlay network
        docker network create \
            --driver overlay \
            --attachable \
            --encrypted \
            microservices-overlay
        
        print_status "Microservices overlay network created"
        
        # Deploy user service
        docker service create \
            --name user-service \
            --network microservices-overlay \
            --replicas 2 \
            --constraint 'node.role==worker' \
            alpine:latest sleep 3600
        
        print_status "User service deployed"
        
        # Deploy order service
        docker service create \
            --name order-service \
            --network microservices-overlay \
            --replicas 2 \
            --constraint 'node.role==worker' \
            alpine:latest sleep 3600
        
        print_status "Order service deployed"
        
        # Deploy payment service
        docker service create \
            --name payment-service \
            --network microservices-overlay \
            --replicas 2 \
            --constraint 'node.role==worker' \
            alpine:latest sleep 3600
        
        print_status "Payment service deployed"
        
        # Deploy API gateway
        docker service create \
            --name api-gateway \
            --network microservices-overlay \
            --replicas 2 \
            --publish 80:80 \
            nginx:alpine
        
        print_status "API gateway deployed"
        
        # Test microservices communication
        print_step "Testing microservices communication..."
        
        # Create test container
        docker run -d --name microservices-test --network microservices-overlay alpine:latest sleep 3600
        
        # Test service discovery
        docker exec microservices-test nslookup user-service
        docker exec microservices-test nslookup order-service
        docker exec microservices-test nslookup payment-service
        docker exec microservices-test nslookup api-gateway
        
        # Test service connectivity
        docker exec microservices-test ping -c 1 user-service
        docker exec microservices-test ping -c 1 order-service
        docker exec microservices-test ping -c 1 payment-service
        docker exec microservices-test ping -c 1 api-gateway
        
        # Clean up test container
        docker rm -f microservices-test
        
        # Check microservices status
        print_step "Checking microservices status..."
        docker service ls --filter name=user-service --filter name=order-service --filter name=payment-service --filter name=api-gateway
        
        print_status "Microservices architecture deployment complete"
        
    else
        print_warning "Docker Swarm not available for this exercise"
    fi
}

# Exercise 9: Overlay Network Analysis
exercise_9_network_analysis() {
    print_header "Exercise 9: Overlay Network Analysis"
    
    print_step "Running overlay network analysis..."
    
    # Use the overlay network analyzer if available
    if [ -f "/usr/local/bin/overlay-network-analyzer.py" ] || [ -f "./overlay-network-analyzer.py" ]; then
        if [ -f "./overlay-network-analyzer.py" ]; then
            python3 ./overlay-network-analyzer.py --all
        else
            python3 /usr/local/bin/overlay-network-analyzer.py --all
        fi
    else
        print_warning "Overlay network analyzer not available"
        print_status "Manual analysis:"
        
        # Check Swarm status
        if docker info --format '{{.Swarm.LocalNodeState}}' 2>/dev/null | grep -q "active"; then
            print_status "Docker Swarm status:"
            docker node ls
        fi
        
        # Check overlay networks
        print_status "Overlay networks:"
        docker network ls --filter driver=overlay
        
        # Check services
        print_status "Swarm services:"
        docker service ls
        
        # Check service tasks
        print_status "Service tasks:"
        for service in $(docker service ls --format '{{.Name}}'); do
            echo "Service: $service"
            docker service ps $service --format '{{.Name}} {{.Node}} {{.CurrentState}}'
        done
    fi
}

# Cleanup function
cleanup_lab() {
    print_header "Cleaning Up Lab Environment"
    
    if [ "$USE_DOCKER" = true ] && [ "$SWARM_AVAILABLE" = true ]; then
        print_status "Removing services..."
        
        # Remove services
        docker service rm web-service api-service db-service ha-service user-service order-service payment-service api-gateway constrained-service 2>/dev/null || true
        
        print_status "Removing networks..."
        
        # Remove overlay networks
        docker network rm basic-overlay encrypted-overlay custom-overlay microservices-overlay 2>/dev/null || true
        
        print_status "Cleaning up containers..."
        
        # Remove any remaining containers
        docker container prune -f 2>/dev/null || true
        
        print_status "Services and networks removed"
    fi
    
    # Remove lab directory
    if [ -d "$LAB_DIR" ]; then
        rm -rf "$LAB_DIR"
        print_status "Lab directory removed"
    fi
    
    print_status "Cleanup complete"
}

# Main menu
show_menu() {
    echo
    print_header "Overlay Networks Lab Menu"
    echo "1. Setup Lab Environment"
    echo "2. Exercise 1: Basic Swarm Setup"
    echo "3. Exercise 2: Overlay Network Creation"
    echo "4. Exercise 3: Service Deployment"
    echo "5. Exercise 4: Service Discovery"
    echo "6. Exercise 5: Load Balancing"
    echo "7. Exercise 6: Network Security"
    echo "8. Exercise 7: High Availability"
    echo "9. Exercise 8: Microservices Architecture"
    echo "10. Exercise 9: Overlay Network Analysis"
    echo "11. Run All Exercises"
    echo "12. Cleanup Lab Environment"
    echo "0. Exit"
    echo
}

# Main function
main() {
    print_header "Overlay Networks Lab Exercises"
    print_status "Welcome to the Overlay Networks Lab!"
    print_status "This lab will teach you Docker Swarm overlay networking through hands-on exercises."
    
    # Check if running in container
    if check_container; then
        print_status "Running in container environment"
    else
        print_warning "Not running in container - some exercises may not work properly"
    fi
    
    while true; do
        show_menu
        read -p "Select an option (0-12): " choice
        
        case $choice in
            1)
                setup_lab_environment
                ;;
            2)
                exercise_1_swarm_setup
                ;;
            3)
                exercise_2_overlay_networks
                ;;
            4)
                exercise_3_service_deployment
                ;;
            5)
                exercise_4_service_discovery
                ;;
            6)
                exercise_5_load_balancing
                ;;
            7)
                exercise_6_network_security
                ;;
            8)
                exercise_7_high_availability
                ;;
            9)
                exercise_8_microservices
                ;;
            10)
                exercise_9_network_analysis
                ;;
            11)
                setup_lab_environment
                exercise_1_swarm_setup
                exercise_2_overlay_networks
                exercise_3_service_deployment
                exercise_4_service_discovery
                exercise_5_load_balancing
                exercise_6_network_security
                exercise_7_high_availability
                exercise_8_microservices
                exercise_9_network_analysis
                ;;
            12)
                cleanup_lab
                ;;
            0)
                print_status "Exiting Overlay Networks Lab"
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
