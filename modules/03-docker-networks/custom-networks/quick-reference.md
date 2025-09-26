# Custom Docker Networks Quick Reference

## Essential Commands

### Network Creation
```bash
# Basic custom network
docker network create --driver bridge <network_name>

# Network with specific subnet
docker network create --driver bridge --subnet=192.168.100.0/24 <network_name>

# Network with gateway
docker network create --driver bridge --subnet=192.168.100.0/24 --gateway=192.168.100.1 <network_name>

# Network with IP range
docker network create --driver bridge --subnet=192.168.100.0/24 --ip-range=192.168.100.128/25 <network_name>

# Internal network (no external access)
docker network create --driver bridge --internal <network_name>

# Network with custom options
docker network create \
  --driver bridge \
  --subnet=10.0.0.0/16 \
  --opt com.docker.network.bridge.enable_icc=false \
  --opt com.docker.network.driver.mtu=9000 \
  <network_name>
```

### Network Management
```bash
# List networks
docker network ls

# Inspect network
docker network inspect <network_name>

# Remove network
docker network rm <network_name>

# Remove unused networks
docker network prune
```

### Container Network Operations
```bash
# Run container on specific network
docker run --network <network_name> <image>

# Connect container to network
docker network connect <network_name> <container>

# Disconnect container from network
docker network disconnect <network_name> <container>

# Run container on multiple networks
docker run --network <network1> --network <network2> <image>
```

## Network Drivers

### Bridge Networks
```bash
# Default bridge network
docker network create --driver bridge <network_name>

# Custom bridge with options
docker network create \
  --driver bridge \
  --subnet=192.168.1.0/24 \
  --opt com.docker.network.bridge.name=br-custom \
  --opt com.docker.network.bridge.enable_icc=true \
  --opt com.docker.network.bridge.enable_ip_masquerade=true \
  <network_name>
```

### Host Networks
```bash
# Host network (maximum performance)
docker network create --driver host <network_name>

# Run container with host networking
docker run --network host <image>
```

### Overlay Networks
```bash
# Overlay network (multi-host)
docker network create --driver overlay <network_name>

# Overlay with encryption
docker network create --driver overlay --opt encrypted <network_name>
```

### Macvlan Networks
```bash
# Macvlan network (direct physical access)
docker network create \
  --driver macvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  --opt parent=eth0 \
  <network_name>
```

### IPvlan Networks
```bash
# IPvlan network (VLAN support)
docker network create \
  --driver ipvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  --opt parent=eth0.100 \
  <network_name>
```

## Common Use Cases

### Multi-Tier Architecture
```bash
# Create tier networks
docker network create --driver bridge --subnet=10.1.0.0/24 frontend-net
docker network create --driver bridge --subnet=10.2.0.0/24 application-net
docker network create --driver bridge --subnet=10.3.0.0/24 database-net

# Deploy services
docker run -d --name web --network frontend-net nginx
docker run -d --name app --network frontend-net --network application-net node
docker run -d --name db --network application-net --network database-net postgres
```

### Secure Database Network
```bash
# Internal database network
docker network create --driver bridge --internal database-net

# Deploy database
docker run -d --name database --network database-net postgres

# Deploy app with database access
docker run -d --name app --network database-net --network application-net node
```

### High-Performance Network
```bash
# Host network for maximum performance
docker run -d --name high-perf-app --network host nginx

# Custom bridge with optimized settings
docker network create \
  --driver bridge \
  --opt com.docker.network.driver.mtu=9000 \
  --opt com.docker.network.bridge.enable_icc=true \
  high-perf-net
```

## Network Options

### Bridge Options
```bash
# Bridge interface name
--opt com.docker.network.bridge.name=br-custom

# Inter-container communication
--opt com.docker.network.bridge.enable_icc=true|false

# IP masquerading
--opt com.docker.network.bridge.enable_ip_masquerade=true|false

# Host binding IP
--opt com.docker.network.bridge.host_binding_ipv4=0.0.0.0

# MTU size
--opt com.docker.network.driver.mtu=1500
```

### Overlay Options
```bash
# Encryption
--opt encrypted=true

# Custom VXLAN ID
--opt com.docker.network.driver.vxlan.id=100

# Custom VXLAN port
--opt com.docker.network.driver.vxlan.port=4789
```

### Macvlan Options
```bash
# Parent interface
--opt parent=eth0

# Bridge mode
--opt macvlan_mode=bridge

# VLAN ID
--opt parent=eth0.100
```

## Troubleshooting Commands

### Network Diagnostics
```bash
# Check network configuration
docker network inspect <network_name>

# Test connectivity between containers
docker exec <container1> ping <container2_ip>

# Check DNS resolution
docker exec <container> nslookup <hostname>

# Verify network routes
docker exec <container> ip route show

# Check network interfaces
docker exec <container> ip addr show
```

### Performance Analysis
```bash
# Monitor network traffic
docker exec <container> netstat -i

# Test network performance
docker exec <container> ping -c 10 <target_ip>

# Check MTU settings
docker network inspect <network_name> | jq '.[0].Options."com.docker.network.driver.mtu"'

# Monitor connection states
docker exec <container> ss -tuna
```

### Security Analysis
```bash
# Check network security policies
docker network inspect <network_name>

# Verify container network membership
docker inspect <container> | jq '.[0].NetworkSettings.Networks'

# Check for network policy violations
docker ps --format "table {{.Names}}\t{{.Networks}}"

# Audit network access
docker network ls --format "{{.Name}}" | while read network; do
    echo "Network: $network"
    docker network inspect "$network" | jq '.[0].Internal'
done
```

## Performance Tips

### Driver Selection
- **Bridge**: Good for single-host, moderate overhead
- **Host**: Maximum performance, no isolation
- **Overlay**: Multi-host capable, higher overhead
- **Macvlan**: Direct physical access, low overhead
- **IPvlan**: VLAN support, moderate overhead

### Optimization Techniques
```bash
# Use host networking for high-performance requirements
docker run --network host <image>

# Optimize MTU for high-throughput applications
docker network create --opt com.docker.network.driver.mtu=9000 <network_name>

# Disable unnecessary features
docker network create --opt com.docker.network.bridge.enable_icc=false <network_name>

# Use internal networks for sensitive services
docker network create --internal <network_name>
```

### Monitoring Best Practices
```bash
# Monitor network usage
docker network ls
docker network inspect <network_name>

# Track container network changes
docker events --filter type=network

# Monitor network performance
docker stats --format "table {{.Container}}\t{{.NetIO}}"

# Check for network leaks
docker network ls --format "{{.Name}}" | grep -E "^(test-|temp-)"
```

## Security Best Practices

### Network Segmentation
```bash
# Separate networks for different tiers
docker network create --driver bridge frontend-net
docker network create --driver bridge backend-net
docker network create --driver bridge database-net

# Internal networks for sensitive services
docker network create --driver bridge --internal database-net

# Disable inter-container communication
docker network create --opt com.docker.network.bridge.enable_icc=false <network_name>
```

### Access Control
```bash
# Use network labels for security policies
docker network create --label "security.level=high" <network_name>

# Implement network policies
docker network create \
  --opt com.docker.network.bridge.enable_ip_masquerade=false \
  --opt com.docker.network.bridge.enable_icc=false \
  <network_name>

# Monitor network access
docker network inspect <network_name> | jq '.[0].Containers'
```

### Security Monitoring
```bash
# Regular network audits
docker network ls --format "{{.Name}}" | while read network; do
    docker network inspect "$network" | jq '.[0].Internal'
done

# Monitor for policy violations
docker ps --format "{{.Names}}\t{{.Networks}}" | grep -v "bridge"

# Check for exposed services
docker ps --format "{{.Names}}\t{{.Ports}}" | grep "0.0.0.0"
```

## Common Issues and Solutions

### Connectivity Issues
```bash
# Problem: Containers cannot communicate
# Solution: Check network membership
docker network inspect <network_name>
docker inspect <container> | jq '.[0].NetworkSettings.Networks'

# Problem: DNS resolution fails
# Solution: Check DNS configuration
docker exec <container> nslookup <hostname>
docker network inspect <network_name> | jq '.[0].Options'
```

### Performance Issues
```bash
# Problem: Slow network communication
# Solution: Use host networking or optimize MTU
docker run --network host <image>
docker network create --opt com.docker.network.driver.mtu=9000 <network_name>

# Problem: High latency
# Solution: Check network driver and optimize settings
docker network inspect <network_name> | jq '.[0].Driver'
```

### Security Issues
```bash
# Problem: Unauthorized network access
# Solution: Use internal networks and disable ICC
docker network create --internal <network_name>
docker network create --opt com.docker.network.bridge.enable_icc=false <network_name>

# Problem: Network isolation failures
# Solution: Implement proper network segmentation
docker network create --driver bridge --subnet=10.1.0.0/24 frontend-net
docker network create --driver bridge --subnet=10.2.0.0/24 backend-net
```

## Useful One-Liners

```bash
# List all networks with subnets
docker network ls --format "{{.Name}}" | while read network; do
    subnet=$(docker network inspect "$network" | jq -r '.[0].IPAM.Config[0].Subnet' 2>/dev/null)
    echo "$network: $subnet"
done

# Find containers on specific network
docker network inspect <network_name> | jq '.[0].Containers'

# Check network security settings
docker network ls --format "{{.Name}}" | while read network; do
    internal=$(docker network inspect "$network" | jq '.[0].Internal')
    echo "$network: Internal=$internal"
done

# Monitor network changes
docker events --filter type=network --filter event=create

# Clean up unused networks
docker network prune -f

# Check for network conflicts
docker network ls --format "{{.Name}}" | while read network; do
    docker network inspect "$network" | jq '.[0].IPAM.Config[0].Subnet'
done | sort | uniq -d
```

---

**Remember**: Always test network configurations in a development environment before applying to production. Use `docker network inspect` to verify configurations and `docker network prune` to clean up unused networks.
