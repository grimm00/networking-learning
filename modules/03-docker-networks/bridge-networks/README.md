# Docker Bridge Networks

Learn about Docker's default bridge networking and how to create custom bridge networks.

## What You'll Learn

- Docker's default bridge network
- Creating custom bridge networks
- Container communication within networks
- Network isolation and security
- Port mapping and exposure

## Exercises

### Exercise 1: Default Bridge Network

```bash
# Start the learning environment
docker-compose up -d

# List existing networks
docker network ls

# Inspect the default bridge network
docker network inspect bridge

# Check container network configuration
docker inspect web-server
```

### Exercise 2: Custom Bridge Networks

```bash
# Create a custom bridge network
docker network create --driver bridge learning-network

# Create containers on the custom network
docker run -d --name test-container-1 --network learning-network alpine sleep 3600
docker run -d --name test-container-2 --network learning-network alpine sleep 3600

# Test connectivity between containers
docker exec test-container-1 ping test-container-2
docker exec test-container-2 ping test-container-1
```

### Exercise 3: Network Isolation

```bash
# Create isolated networks
docker network create --driver bridge network-a
docker network create --driver bridge network-b

# Add containers to different networks
docker run -d --name container-a --network network-a alpine sleep 3600
docker run -d --name container-b --network network-b alpine sleep 3600

# Test isolation (should fail)
docker exec container-a ping container-b
```

## Understanding Bridge Networks

### Default Bridge Network
- All containers without explicit network assignment
- Containers can communicate by IP address
- No automatic DNS resolution between containers
- Ports must be explicitly exposed

### Custom Bridge Networks
- Automatic DNS resolution between containers
- Better isolation and security
- Easy container discovery
- Built-in load balancing

## Network Commands

```bash
# List networks
docker network ls

# Create network
docker network create [OPTIONS] NETWORK

# Inspect network
docker network inspect NETWORK

# Connect container to network
docker network connect NETWORK CONTAINER

# Disconnect container from network
docker network disconnect NETWORK CONTAINER

# Remove network
docker network rm NETWORK
```

## Practical Examples

### Example 1: Web Application Stack
```bash
# Create application network
docker network create app-network

# Start database
docker run -d --name db --network app-network -e POSTGRES_PASSWORD=secret postgres

# Start web application
docker run -d --name web --network app-network -p 8080:80 nginx

# Test connectivity
docker exec web ping db
```

### Example 2: Microservices Communication
```bash
# Create microservices network
docker network create microservices

# Start multiple services
docker run -d --name api --network microservices nginx
docker run -d --name frontend --network microservices nginx
docker run -d --name database --network microservices postgres

# Test service discovery
docker exec api nslookup frontend
docker exec frontend nslookup api
```

## Troubleshooting

### Common Issues
1. **Containers can't communicate**: Check if they're on the same network
2. **DNS resolution fails**: Verify custom network configuration
3. **Port not accessible**: Check port mapping and firewall rules
4. **Network not found**: Ensure network exists before connecting containers

### Debugging Commands
```bash
# Check container network configuration
docker inspect CONTAINER | grep -A 20 "NetworkSettings"

# Test connectivity
docker exec CONTAINER ping TARGET

# Check DNS resolution
docker exec CONTAINER nslookup TARGET

# Monitor network traffic
docker exec CONTAINER netstat -tuln
```

## Advanced Topics

### Network Security
- Use custom networks for isolation
- Implement network policies
- Monitor network traffic
- Use secrets management

### Performance Optimization
- Choose appropriate network drivers
- Optimize container placement
- Monitor network metrics
- Use network compression

## Lab Exercises

Run the included scripts for hands-on practice:

```bash
./bridge-network-lab.sh    # Basic bridge network exercises
./isolation-lab.sh         # Network isolation testing
./troubleshooting-lab.sh   # Common issues and solutions
```
