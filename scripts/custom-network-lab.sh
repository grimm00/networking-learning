#!/bin/bash
# custom-network-lab.sh
# Comprehensive Custom Docker Networks Lab Exercises

echo "Starting Custom Docker Networks Lab Exercises..."

# Function to check if Docker is running
check_docker() {
    if ! docker --version &> /dev/null; then
        echo "❌ Docker is not installed or not running"
        echo "Please start Docker and try again"
        exit 1
    fi
    echo "✅ Docker is available"
}

# Function to cleanup networks
cleanup_networks() {
    echo "Cleaning up test networks..."
    docker network ls --format "{{.Name}}" | grep -E "^(test-|lab-|exercise-)" | while read network; do
        docker network rm "$network" 2>/dev/null || true
    done
}

# Function to cleanup containers
cleanup_containers() {
    echo "Cleaning up test containers..."
    docker ps -a --format "{{.Names}}" | grep -E "^(test-|lab-|exercise-)" | while read container; do
        docker rm -f "$container" 2>/dev/null || true
    done
}

# Check Docker availability
check_docker

# --- Exercise 1: Basic Custom Network Creation ---
echo -e "\n--- Exercise 1: Basic Custom Network Creation ---"
echo "Goal: Learn to create and manage custom Docker networks"
echo "Steps:"
echo "1. Create a custom bridge network with specific subnet"
echo "2. Deploy containers on the custom network"
echo "3. Test inter-container communication"
echo "4. Compare with default bridge network behavior"

read -p "Press Enter to start Exercise 1..."

echo "Creating custom network..."
docker network create --driver bridge --subnet=192.168.100.0/24 --gateway=192.168.100.1 test-network-1

echo "Deploying containers on custom network..."
docker run -d --name test-web --network test-network-1 nginx:alpine
docker run -d --name test-app --network test-network-1 alpine:latest sleep 3600

echo "Testing inter-container communication..."
docker exec test-web ping -c 3 test-app

echo "Checking network configuration..."
docker network inspect test-network-1

echo "Exercise 1 complete! Press Enter to continue to Exercise 2..."
read -p "Press Enter to continue..."

# --- Exercise 2: Multi-Tier Architecture ---
echo -e "\n--- Exercise 2: Multi-Tier Architecture ---"
echo "Goal: Design and implement a multi-tier container architecture"
echo "Steps:"
echo "1. Create separate networks for frontend, application, and database tiers"
echo "2. Deploy services on appropriate network tiers"
echo "3. Configure inter-tier communication"
echo "4. Test network isolation and security"

read -p "Press Enter to start Exercise 2..."

echo "Creating multi-tier networks..."
docker network create --driver bridge --subnet=10.1.0.0/24 frontend-net
docker network create --driver bridge --subnet=10.2.0.0/24 application-net
docker network create --driver bridge --subnet=10.3.0.0/24 database-net

echo "Deploying frontend tier..."
docker run -d --name test-frontend --network frontend-net nginx:alpine

echo "Deploying application tier..."
docker run -d --name test-app1 --network frontend-net --network application-net alpine:latest sleep 3600
docker run -d --name test-app2 --network frontend-net --network application-net alpine:latest sleep 3600

echo "Deploying database tier..."
docker run -d --name test-database --network application-net --network database-net postgres:alpine

echo "Testing inter-tier communication..."
echo "Frontend to Application:"
docker exec test-frontend ping -c 2 test-app1

echo "Application to Database:"
docker exec test-app1 ping -c 2 test-database

echo "Testing isolation (should fail):"
echo "Frontend to Database (should fail):"
docker exec test-frontend ping -c 2 test-database || echo "✅ Isolation working - frontend cannot reach database directly"

echo "Exercise 2 complete! Press Enter to continue to Exercise 3..."
read -p "Press Enter to continue..."

# --- Exercise 3: Network Security Implementation ---
echo -e "\n--- Exercise 3: Network Security Implementation ---"
echo "Goal: Implement network security and access control"
echo "Steps:"
echo "1. Create internal networks for sensitive services"
echo "2. Implement network access policies"
echo "3. Test security isolation"
echo "4. Monitor network access patterns"

read -p "Press Enter to start Exercise 3..."

echo "Creating secure networks..."
docker network create --driver bridge --internal secure-db-net
docker network create --driver bridge --subnet=172.20.0.0/24 --opt com.docker.network.bridge.enable_icc=false restricted-net

echo "Deploying secure services..."
docker run -d --name test-secure-db --network secure-db-net postgres:alpine
docker run -d --name test-restricted-app --network restricted-net alpine:latest sleep 3600

echo "Testing security isolation..."
echo "Internal network test (should fail external access):"
docker exec test-secure-db ping -c 2 8.8.8.8 || echo "✅ Internal network working - no external access"

echo "ICC disabled test:"
docker run -d --name test-icc-test --network restricted-net alpine:latest sleep 3600
docker exec test-restricted-app ping -c 2 test-icc-test || echo "✅ ICC disabled - containers cannot communicate"

echo "Exercise 3 complete! Press Enter to continue to Exercise 4..."
read -p "Press Enter to continue..."

# --- Exercise 4: Performance Optimization ---
echo -e "\n--- Exercise 4: Performance Optimization ---"
echo "Goal: Optimize network performance for containerized applications"
echo "Steps:"
echo "1. Compare different network drivers"
echo "2. Optimize network configuration parameters"
echo "3. Test performance under different loads"
echo "4. Implement bandwidth management"

read -p "Press Enter to start Exercise 4..."

echo "Creating performance test networks..."
docker network create --driver bridge --opt com.docker.network.driver.mtu=9000 high-perf-net
docker network create --driver host host-perf-net

echo "Deploying performance test containers..."
docker run -d --name test-perf-bridge --network high-perf-net alpine:latest sleep 3600
docker run -d --name test-perf-host --network host-perf-net alpine:latest sleep 3600

echo "Testing network performance..."
echo "Bridge network performance test:"
time docker exec test-perf-bridge ping -c 10 8.8.8.8

echo "Host network performance test:"
time docker exec test-perf-host ping -c 10 8.8.8.8

echo "Comparing network configurations..."
echo "Bridge network MTU:"
docker network inspect high-perf-net | jq '.[0].Options."com.docker.network.driver.mtu"'

echo "Exercise 4 complete! Press Enter to continue to Exercise 5..."
read -p "Press Enter to continue..."

# --- Exercise 5: Advanced Network Drivers ---
echo -e "\n--- Exercise 5: Advanced Network Drivers ---"
echo "Goal: Explore advanced network drivers and use cases"
echo "Steps:"
echo "1. Implement Macvlan networks for direct physical access"
echo "2. Configure IPvlan networks for VLAN support"
echo "3. Test overlay networks for multi-host communication"
echo "4. Compare performance and isolation characteristics"

read -p "Press Enter to start Exercise 5..."

echo "Note: Advanced network drivers require specific system configurations"
echo "This exercise demonstrates the concepts with available drivers"

echo "Creating overlay network (requires Docker Swarm)..."
if docker swarm init --advertise-addr 127.0.0.1 &>/dev/null; then
    docker network create --driver overlay test-overlay-net
    echo "Overlay network created successfully"
    
    echo "Deploying service on overlay network..."
    docker service create --name test-overlay-service --network test-overlay-net alpine:latest sleep 3600
    
    echo "Checking overlay network..."
    docker network ls | grep overlay
    
    # Cleanup swarm
    docker swarm leave --force &>/dev/null || true
else
    echo "Docker Swarm not available - skipping overlay network test"
fi

echo "Creating custom bridge with advanced options..."
docker network create \
  --driver bridge \
  --subnet=192.168.200.0/24 \
  --gateway=192.168.200.1 \
  --opt com.docker.network.bridge.name=br-custom \
  --opt com.docker.network.bridge.enable_icc=true \
  --opt com.docker.network.bridge.enable_ip_masquerade=true \
  test-advanced-net

echo "Deploying container on advanced network..."
docker run -d --name test-advanced --network test-advanced-net alpine:latest sleep 3600

echo "Checking advanced network configuration..."
docker network inspect test-advanced-net | jq '.[0].Options'

echo "Exercise 5 complete! Press Enter to continue to Exercise 6..."
read -p "Press Enter to continue..."

# --- Exercise 6: Network Troubleshooting ---
echo -e "\n--- Exercise 6: Network Troubleshooting ---"
echo "Goal: Practice troubleshooting complex network issues"
echo "Steps:"
echo "1. Simulate network connectivity problems"
echo "2. Diagnose network performance issues"
echo "3. Troubleshoot security and access control problems"
echo "4. Implement solutions and verify fixes"

read -p "Press Enter to start Exercise 6..."

echo "Creating problematic network scenario..."
docker network create --driver bridge --subnet=192.168.50.0/24 problematic-net

echo "Deploying containers with connectivity issues..."
docker run -d --name test-problem1 --network problematic-net alpine:latest sleep 3600
docker run -d --name test-problem2 --network problematic-net alpine:latest sleep 3600

echo "Simulating connectivity problem..."
echo "Testing connectivity between containers..."
docker exec test-problem1 ping -c 3 test-problem2

echo "Checking network configuration..."
docker network inspect problematic-net

echo "Diagnosing network issues..."
echo "Container IP addresses:"
docker inspect test-problem1 | jq '.[0].NetworkSettings.Networks.problematic-net.IPAddress'
docker inspect test-problem2 | jq '.[0].NetworkSettings.Networks.problematic-net.IPAddress'

echo "Network routing:"
docker exec test-problem1 ip route show

echo "Testing DNS resolution..."
docker exec test-problem1 nslookup test-problem2

echo "Implementing solution (network restart)..."
docker network disconnect problematic-net test-problem1
docker network connect problematic-net test-problem1

echo "Verifying fix..."
docker exec test-problem1 ping -c 3 test-problem2

echo "Exercise 6 complete! Press Enter to finish..."
read -p "Press Enter to finish..."

# --- Cleanup ---
echo -e "\n--- Cleanup ---"
echo "Cleaning up all test resources..."

cleanup_containers
cleanup_networks

echo "Custom Docker Networks Lab Exercises Complete!"
echo "You've learned:"
echo "✅ Basic custom network creation and management"
echo "✅ Multi-tier architecture design and implementation"
echo "✅ Network security and access control"
echo "✅ Performance optimization techniques"
echo "✅ Advanced network drivers and configurations"
echo "✅ Network troubleshooting and problem resolution"
