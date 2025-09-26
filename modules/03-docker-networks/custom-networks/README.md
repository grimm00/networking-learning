# Custom Docker Networks

## What You'll Learn

This module covers advanced Docker networking concepts, focusing on custom network creation, management, and optimization. You'll learn to:
- **Create and manage custom Docker networks** for isolated container communication
- **Design multi-tier network architectures** with proper segmentation
- **Implement network security** and access control policies
- **Optimize network performance** for containerized applications
- **Troubleshoot complex network issues** in containerized environments

## Key Concepts

### Docker Network Types
- **Bridge Networks**: Default isolated networks for single-host containers
- **Custom Bridge Networks**: User-defined networks with advanced features
- **Host Networks**: Containers sharing the host's network stack
- **Overlay Networks**: Multi-host networks for Docker Swarm
- **Macvlan Networks**: Containers with MAC addresses on physical networks
- **IPvlan Networks**: Containers sharing MAC addresses with VLAN support

### Network Isolation and Security
- **Network Segmentation**: Isolating different application tiers
- **Access Control**: Controlling inter-container communication
- **Security Policies**: Implementing network-level security measures
- **Traffic Filtering**: Managing network traffic flow and restrictions

### Performance Optimization
- **Network Drivers**: Choosing optimal network drivers for different use cases
- **Bandwidth Management**: Controlling network resource allocation
- **Latency Optimization**: Minimizing network delays in container communication
- **Load Distribution**: Efficient traffic distribution across containers

## Detailed Explanations

### Custom Bridge Networks Deep Dive

#### Creating Custom Networks
```bash
# Create a custom bridge network
docker network create --driver bridge my-custom-network

# Create with specific subnet
docker network create --driver bridge --subnet=192.168.100.0/24 my-subnet-network

# Create with custom gateway
docker network create --driver bridge --subnet=192.168.100.0/24 --gateway=192.168.100.1 my-gateway-network

# Create with IP range
docker network create --driver bridge --subnet=192.168.100.0/24 --ip-range=192.168.100.128/25 my-range-network
```

#### Advanced Network Configuration
```bash
# Create network with custom options
docker network create \
  --driver bridge \
  --subnet=10.0.0.0/16 \
  --ip-range=10.0.240.0/20 \
  --gateway=10.0.0.1 \
  --opt com.docker.network.bridge.name=br-custom \
  --opt com.docker.network.bridge.enable_icc=true \
  --opt com.docker.network.bridge.enable_ip_masquerade=true \
  --opt com.docker.network.bridge.host_binding_ipv4=0.0.0.0 \
  --opt com.docker.network.driver.mtu=1500 \
  custom-production-network
```

#### Network Options Explained
- **`--subnet`**: Define the network subnet (CIDR notation)
- **`--ip-range`**: Specify IP address range for container allocation
- **`--gateway`**: Set the network gateway IP address
- **`--opt com.docker.network.bridge.name`**: Custom bridge interface name
- **`--opt com.docker.network.bridge.enable_icc`**: Enable inter-container communication
- **`--opt com.docker.network.bridge.enable_ip_masquerade`**: Enable IP masquerading
- **`--opt com.docker.network.bridge.host_binding_ipv4`**: Host binding IP for port mapping
- **`--opt com.docker.network.driver.mtu`**: Maximum Transmission Unit size

### Multi-Tier Network Architecture

#### Web Application Architecture
```
┌─────────────────────────────────────────────────────────────────┐
│                    Multi-Tier Container Network                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐    ┌─────────────────┐                   │
│  │   Web Tier      │    │   Load Balancer  │                   │
│  │   (nginx)       │◄───┤   (haproxy)      │                   │
│  │   Port: 80       │    │   Port: 8080     │                   │
│  └─────────────────┘    └─────────────────┘                   │
│           │                       │                             │
│           │                       │                             │
│  ┌─────────────────┐    ┌─────────────────┐                   │
│  │   App Tier       │    │   App Tier       │                   │
│  │   (nodejs)       │    │   (python)       │                   │
│  │   Port: 3000      │    │   Port: 5000     │                   │
│  └─────────────────┘    └─────────────────┘                   │
│           │                       │                             │
│           └───────────┬───────────┘                             │
│                       │                                         │
│  ┌─────────────────┐    ┌─────────────────┐                   │
│  │   Database      │    │   Cache          │                   │
│  │   (postgres)    │    │   (redis)        │                   │
│  │   Port: 5432     │    │   Port: 6379     │                   │
│  └─────────────────┘    └─────────────────┘                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

Network Segmentation:
• Frontend Network: Load balancer and web servers
• Application Network: App servers and web servers
• Backend Network: App servers, database, and cache
• Management Network: Monitoring and logging services
```

#### Implementation Example
```bash
# Create network tiers
docker network create --driver bridge --subnet=10.1.0.0/24 frontend-network
docker network create --driver bridge --subnet=10.2.0.0/24 application-network
docker network create --driver bridge --subnet=10.3.0.0/24 backend-network
docker network create --driver bridge --subnet=10.4.0.0/24 management-network

# Deploy load balancer
docker run -d --name haproxy \
  --network frontend-network \
  -p 8080:8080 \
  haproxy:latest

# Deploy web servers
docker run -d --name web1 \
  --network frontend-network \
  --network application-network \
  nginx:latest

docker run -d --name web2 \
  --network frontend-network \
  --network application-network \
  nginx:latest

# Deploy application servers
docker run -d --name app1 \
  --network application-network \
  --network backend-network \
  node:latest

docker run -d --name app2 \
  --network application-network \
  --network backend-network \
  python:latest

# Deploy backend services
docker run -d --name database \
  --network backend-network \
  postgres:latest

docker run -d --name cache \
  --network backend-network \
  redis:latest
```

### Network Security and Access Control

#### Network Isolation Strategies
```bash
# Create isolated networks for different services
docker network create --driver bridge --internal database-network
docker network create --driver bridge --internal cache-network
docker network create --driver bridge web-network

# Internal networks prevent external access
# Only containers on the same network can communicate
```

#### Access Control Implementation
```bash
# Create networks with specific access policies
docker network create \
  --driver bridge \
  --subnet=192.168.10.0/24 \
  --opt com.docker.network.bridge.enable_icc=false \
  isolated-network

# Disable inter-container communication
# Containers can only communicate with external networks
```

#### Security Best Practices
```bash
# Use network labels for security policies
docker network create \
  --driver bridge \
  --label "security.level=high" \
  --label "environment=production" \
  secure-network

# Implement network policies
docker network create \
  --driver bridge \
  --opt com.docker.network.bridge.enable_ip_masquerade=false \
  --opt com.docker.network.bridge.enable_icc=false \
  restricted-network
```

### Advanced Network Drivers

#### Macvlan Networks
```bash
# Create Macvlan network for direct physical network access
docker network create \
  --driver macvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  --opt parent=eth0 \
  macvlan-network

# Containers get direct MAC addresses on physical network
docker run -d --name macvlan-container \
  --network macvlan-network \
  --ip=192.168.1.100 \
  nginx:latest
```

#### IPvlan Networks
```bash
# Create IPvlan network for VLAN support
docker network create \
  --driver ipvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  --opt parent=eth0.100 \
  ipvlan-network

# Containers share MAC address but have different IPs
docker run -d --name ipvlan-container1 \
  --network ipvlan-network \
  --ip=192.168.1.101 \
  nginx:latest

docker run -d --name ipvlan-container2 \
  --network ipvlan-network \
  --ip=192.168.1.102 \
  nginx:latest
```

### Network Performance Optimization

#### Driver Selection Guidelines
```bash
# Bridge networks - Default choice for most use cases
docker network create --driver bridge standard-network

# Host networks - Maximum performance, no isolation
docker network create --driver host high-performance-network

# Macvlan networks - Direct physical network access
docker network create --driver macvlan --opt parent=eth0 direct-network

# Overlay networks - Multi-host communication
docker network create --driver overlay swarm-network
```

#### Performance Tuning
```bash
# Optimize network performance
docker network create \
  --driver bridge \
  --opt com.docker.network.driver.mtu=9000 \
  --opt com.docker.network.bridge.enable_icc=true \
  --opt com.docker.network.bridge.enable_ip_masquerade=true \
  optimized-network

# Jumbo frames for high-throughput applications
# Enable inter-container communication
# Enable IP masquerading for external access
```

#### Bandwidth Management
```bash
# Create network with bandwidth limits
docker network create \
  --driver bridge \
  --opt com.docker.network.bridge.enable_icc=true \
  --opt com.docker.network.driver.mtu=1500 \
  bandwidth-limited-network

# Use external tools for bandwidth control
# tc (traffic control) for advanced bandwidth management
```

## Practical Examples

### E-commerce Application Network
```bash
#!/bin/bash
# E-commerce application with custom networks

# Create network tiers
echo "Creating network tiers..."
docker network create --driver bridge --subnet=10.1.0.0/24 frontend-net
docker network create --driver bridge --subnet=10.2.0.0/24 api-net
docker network create --driver bridge --subnet=10.3.0.0/24 database-net
docker network create --driver bridge --subnet=10.4.0.0/24 cache-net

# Deploy frontend services
echo "Deploying frontend services..."
docker run -d --name nginx-lb \
  --network frontend-net \
  -p 80:80 \
  nginx:latest

docker run -d --name web-app1 \
  --network frontend-net \
  --network api-net \
  nginx:latest

docker run -d --name web-app2 \
  --network frontend-net \
  --network api-net \
  nginx:latest

# Deploy API services
echo "Deploying API services..."
docker run -d --name api-server1 \
  --network api-net \
  --network database-net \
  --network cache-net \
  node:latest

docker run -d --name api-server2 \
  --network api-net \
  --network database-net \
  --network cache-net \
  node:latest

# Deploy backend services
echo "Deploying backend services..."
docker run -d --name postgres-db \
  --network database-net \
  postgres:latest

docker run -d --name redis-cache \
  --network cache-net \
  redis:latest

echo "E-commerce application deployed with custom networks!"
```

### Microservices Architecture
```bash
#!/bin/bash
# Microservices with service-specific networks

# Create service networks
docker network create --driver bridge user-service-net
docker network create --driver bridge order-service-net
docker network create --driver bridge payment-service-net
docker network create --driver bridge notification-service-net
docker network create --driver bridge shared-database-net

# Deploy user service
docker run -d --name user-service \
  --network user-service-net \
  --network shared-database-net \
  user-service:latest

# Deploy order service
docker run -d --name order-service \
  --network order-service-net \
  --network shared-database-net \
  --network user-service-net \
  order-service:latest

# Deploy payment service
docker run -d --name payment-service \
  --network payment-service-net \
  --network shared-database-net \
  --network order-service-net \
  payment-service:latest

# Deploy notification service
docker run -d --name notification-service \
  --network notification-service-net \
  --network user-service-net \
  --network order-service-net \
  --network payment-service-net \
  notification-service:latest

# Deploy shared database
docker run -d --name shared-database \
  --network shared-database-net \
  postgres:latest
```

### Development Environment
```bash
#!/bin/bash
# Development environment with isolated networks

# Create development networks
docker network create --driver bridge dev-frontend-net
docker network create --driver bridge dev-backend-net
docker network create --driver bridge dev-database-net
docker network create --driver bridge dev-tools-net

# Deploy development services
docker run -d --name dev-web \
  --network dev-frontend-net \
  -p 3000:3000 \
  web-dev:latest

docker run -d --name dev-api \
  --network dev-frontend-net \
  --network dev-backend-net \
  -p 8000:8000 \
  api-dev:latest

docker run -d --name dev-database \
  --network dev-backend-net \
  --network dev-database-net \
  -p 5432:5432 \
  postgres:latest

docker run -d --name dev-tools \
  --network dev-tools-net \
  --network dev-backend-net \
  --network dev-database-net \
  tools:latest

echo "Development environment ready!"
```

## Advanced Usage Patterns

### Network Automation Scripts
```bash
#!/bin/bash
# Automated network management

create_network_tier() {
    local tier_name=$1
    local subnet=$2
    local gateway=$3
    
    echo "Creating $tier_name network..."
    docker network create \
        --driver bridge \
        --subnet=$subnet \
        --gateway=$gateway \
        --opt com.docker.network.bridge.enable_icc=true \
        --opt com.docker.network.bridge.enable_ip_masquerade=true \
        $tier_name
    
    echo "$tier_name network created successfully!"
}

# Create multiple network tiers
create_network_tier "web-tier" "10.1.0.0/24" "10.1.0.1"
create_network_tier "app-tier" "10.2.0.0/24" "10.2.0.1"
create_network_tier "db-tier" "10.3.0.0/24" "10.3.0.1"
create_network_tier "cache-tier" "10.4.0.0/24" "10.4.0.1"
```

### Network Monitoring Scripts
```bash
#!/bin/bash
# Network monitoring and analysis

monitor_networks() {
    echo "=== Docker Network Status ==="
    docker network ls
    
    echo -e "\n=== Network Details ==="
    for network in $(docker network ls --format "{{.Name}}" | grep -v "bridge\|host\|none"); do
        echo "Network: $network"
        docker network inspect $network | jq '.[0].IPAM.Config'
        echo "Containers:"
        docker network inspect $network | jq '.[0].Containers'
        echo "---"
    done
}

analyze_network_traffic() {
    echo "=== Network Traffic Analysis ==="
    for network in $(docker network ls --format "{{.Name}}" | grep -v "bridge\|host\|none"); do
        echo "Analyzing $network..."
        docker network inspect $network | jq '.[0].Containers | length' | xargs echo "Active containers:"
    done
}

# Run monitoring
monitor_networks
analyze_network_traffic
```

### Network Security Scripts
```bash
#!/bin/bash
# Network security analysis

check_network_security() {
    echo "=== Network Security Analysis ==="
    
    for network in $(docker network ls --format "{{.Name}}" | grep -v "bridge\|host\|none"); do
        echo "Checking $network..."
        
        # Check if ICC is enabled
        icc_enabled=$(docker network inspect $network | jq '.[0].Options."com.docker.network.bridge.enable_icc"')
        echo "  Inter-container communication: $icc_enabled"
        
        # Check if IP masquerading is enabled
        masq_enabled=$(docker network inspect $network | jq '.[0].Options."com.docker.network.bridge.enable_ip_masquerade"')
        echo "  IP masquerading: $masq_enabled"
        
        # Check network isolation
        internal=$(docker network inspect $network | jq '.[0].Internal')
        echo "  Internal network: $internal"
        
        echo "---"
    done
}

audit_network_access() {
    echo "=== Network Access Audit ==="
    
    # Check for containers with multiple network access
    docker ps --format "table {{.Names}}\t{{.Networks}}" | while read line; do
        if [[ $line == *","* ]]; then
            echo "Multi-network container: $line"
        fi
    done
}

# Run security checks
check_network_security
audit_network_access
```

## Troubleshooting Common Issues

### Network Connectivity Problems
**Symptoms:**
- Containers cannot communicate with each other
- External network access fails
- DNS resolution issues

**Diagnosis:**
```bash
# Check network configuration
docker network inspect <network_name>

# Test connectivity between containers
docker exec <container1> ping <container2_ip>

# Check DNS resolution
docker exec <container> nslookup <hostname>

# Verify network routes
docker exec <container> ip route show
```

**Solutions:**
- Verify network configuration and subnet settings
- Check firewall rules and security policies
- Ensure containers are on the same network
- Verify DNS configuration and external connectivity

### Performance Issues
**Symptoms:**
- Slow network communication between containers
- High latency in container-to-container traffic
- Bandwidth limitations

**Diagnosis:**
```bash
# Check network driver and options
docker network inspect <network_name>

# Monitor network traffic
docker exec <container> netstat -i

# Test network performance
docker exec <container> ping -c 10 <target_ip>

# Check MTU settings
docker network inspect <network_name> | jq '.[0].Options."com.docker.network.driver.mtu"'
```

**Solutions:**
- Optimize network driver selection
- Adjust MTU settings for better performance
- Use host networking for high-performance requirements
- Implement bandwidth management and QoS policies

### Security Issues
**Symptoms:**
- Unauthorized network access
- Containers accessing restricted networks
- Network isolation failures

**Diagnosis:**
```bash
# Check network security policies
docker network inspect <network_name>

# Verify container network membership
docker inspect <container> | jq '.[0].NetworkSettings.Networks'

# Check for network policy violations
docker ps --format "table {{.Names}}\t{{.Networks}}"
```

**Solutions:**
- Implement proper network segmentation
- Use internal networks for sensitive services
- Disable inter-container communication where not needed
- Implement network access control policies

## Lab Exercises

### Exercise 1: Basic Custom Network Creation
**Goal**: Learn to create and manage custom Docker networks
**Steps**:
1. Create a custom bridge network with specific subnet
2. Deploy containers on the custom network
3. Test inter-container communication
4. Compare with default bridge network behavior

### Exercise 2: Multi-Tier Architecture
**Goal**: Design and implement a multi-tier container architecture
**Steps**:
1. Create separate networks for frontend, application, and database tiers
2. Deploy services on appropriate network tiers
3. Configure inter-tier communication
4. Test network isolation and security

### Exercise 3: Network Security Implementation
**Goal**: Implement network security and access control
**Steps**:
1. Create internal networks for sensitive services
2. Implement network access policies
3. Test security isolation
4. Monitor network access patterns

### Exercise 4: Performance Optimization
**Goal**: Optimize network performance for containerized applications
**Steps**:
1. Compare different network drivers
2. Optimize network configuration parameters
3. Test performance under different loads
4. Implement bandwidth management

### Exercise 5: Advanced Network Drivers
**Goal**: Explore advanced network drivers and use cases
**Steps**:
1. Implement Macvlan networks for direct physical access
2. Configure IPvlan networks for VLAN support
3. Test overlay networks for multi-host communication
4. Compare performance and isolation characteristics

### Exercise 6: Network Troubleshooting
**Goal**: Practice troubleshooting complex network issues
**Steps**:
1. Simulate network connectivity problems
2. Diagnose network performance issues
3. Troubleshoot security and access control problems
4. Implement solutions and verify fixes

## Quick Reference

### Essential Commands
```bash
# Network creation
docker network create --driver bridge <network_name>
docker network create --driver bridge --subnet=<subnet> <network_name>
docker network create --driver bridge --subnet=<subnet> --gateway=<gateway> <network_name>

# Network management
docker network ls
docker network inspect <network_name>
docker network rm <network_name>

# Container network operations
docker run --network <network_name> <image>
docker network connect <network_name> <container>
docker network disconnect <network_name> <container>

# Network analysis
docker network inspect <network_name> | jq '.[0].Containers'
docker network inspect <network_name> | jq '.[0].IPAM.Config'
```

### Common Use Cases
```bash
# Create isolated network for database
docker network create --driver bridge --internal database-net

# Create network with specific IP range
docker network create --driver bridge --subnet=192.168.100.0/24 --ip-range=192.168.100.128/25 app-net

# Connect container to multiple networks
docker network connect frontend-net web-container
docker network connect backend-net web-container

# Create high-performance network
docker network create --driver host high-perf-net
```

### Performance Tips
- **Use bridge networks** for most use cases
- **Use host networks** for maximum performance
- **Use Macvlan networks** for direct physical access
- **Optimize MTU settings** for high-throughput applications
- **Implement network segmentation** for security and performance
- **Monitor network usage** and optimize based on traffic patterns

## Security Considerations

### Network Security Best Practices
- **Implement network segmentation** to isolate different application tiers
- **Use internal networks** for sensitive services that don't need external access
- **Disable inter-container communication** where not required
- **Implement access control policies** to restrict network access
- **Monitor network traffic** for suspicious activity
- **Use encrypted networks** for sensitive data transmission

### Common Security Issues
- **Over-privileged networks** with unnecessary access
- **Insufficient network isolation** between different services
- **Missing access control** policies
- **Unencrypted network communication** for sensitive data
- **Inadequate network monitoring** and logging

### Security Monitoring
- **Regular network audits** to check for policy violations
- **Monitor network access patterns** for anomalies
- **Implement network intrusion detection** systems
- **Log network events** for security analysis
- **Regular security updates** for network components

## Additional Learning Resources

### Recommended Reading
- **Docker Networking Documentation**: Official Docker networking guide
- **Container Network Interface (CNI)**: Kubernetes networking specification
- **Network Namespaces**: Linux network isolation concepts
- **VXLAN**: Virtual Extensible LAN for overlay networks

### Online Tools
- **Docker Desktop**: GUI for Docker network management
- **Portainer**: Web-based Docker management interface
- **Weave Net**: Container networking solution
- **Calico**: Network policy and security platform

### Video Tutorials
- **Docker Networking Deep Dive**: Advanced networking concepts
- **Container Network Security**: Security best practices
- **Multi-Host Container Networking**: Overlay network implementation

---

**Next Steps**: Practice with the lab exercises and explore the analyzer tools to deepen your understanding of custom Docker networks and advanced container networking concepts.
