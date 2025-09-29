# Overlay Networks Quick Reference

## Essential Commands

### Docker Swarm Management
```bash
# Initialize Swarm
docker swarm init --advertise-addr <ip>

# Join Swarm as manager
docker swarm join --token <manager-token> <manager-ip>:2377

# Join Swarm as worker
docker swarm join --token <worker-token> <manager-ip>:2377

# Leave Swarm
docker swarm leave

# Get join tokens
docker swarm join-token manager
docker swarm join-token worker

# Check Swarm status
docker node ls
docker info --format '{{.Swarm.LocalNodeState}}'
```

### Overlay Network Management
```bash
# Create basic overlay network
docker network create --driver overlay --attachable <name>

# Create encrypted overlay network
docker network create --driver overlay --attachable --encrypted <name>

# Create custom subnet overlay network
docker network create --driver overlay --attachable --subnet 10.0.1.0/24 <name>

# List overlay networks
docker network ls --filter driver=overlay

# Inspect overlay network
docker network inspect <network>

# Remove overlay network
docker network rm <network>
```

### Service Management
```bash
# Create service on overlay network
docker service create --name <name> --network <network> <image>

# Create service with replicas
docker service create --name <name> --network <network> --replicas 3 <image>

# Create service with published ports
docker service create --name <name> --network <network> --publish 80:80 <image>

# Create service with health checks
docker service create --name <name> --network <network> --health-cmd "curl -f http://localhost/" <image>

# Scale service
docker service scale <service>=<replicas>

# Update service
docker service update --image <new-image> <service>

# Remove service
docker service rm <service>

# List services
docker service ls

# Inspect service
docker service inspect <service>

# Check service tasks
docker service ps <service>

# View service logs
docker service logs <service>
```

### Stack Management
```bash
# Deploy stack from compose file
docker stack deploy -c docker-compose.yml <stack>

# List stacks
docker stack ls

# List stack services
docker stack services <stack>

# List stack tasks
docker stack ps <stack>

# Remove stack
docker stack rm <stack>
```

## Common Use Cases

### Basic Swarm Setup
```bash
# Initialize Swarm
docker swarm init --advertise-addr 192.168.1.10

# Create overlay network
docker network create --driver overlay --attachable my-overlay

# Deploy service
docker service create --name web --network my-overlay --replicas 3 nginx
```

### Encrypted Overlay Network
```bash
# Create encrypted network
docker network create --driver overlay --encrypted secure-net

# Deploy service on encrypted network
docker service create --name secure-web --network secure-net nginx
```

### Service with Health Checks
```bash
# Create service with health checks
docker service create \
  --name web \
  --network overlay-net \
  --health-cmd "curl -f http://localhost/ || exit 1" \
  --health-interval 30s \
  --health-timeout 10s \
  --health-retries 3 \
  nginx
```

### High Availability Service
```bash
# Create HA service
docker service create \
  --name ha-web \
  --network overlay-net \
  --replicas 5 \
  --update-parallelism 1 \
  --update-delay 10s \
  --rollback-parallelism 1 \
  --rollback-delay 5s \
  --restart-condition on-failure \
  --restart-delay 5s \
  --restart-max-attempts 3 \
  nginx
```

### Service with Constraints
```bash
# Create service with constraints
docker service create \
  --name web \
  --network overlay-net \
  --constraint 'node.role==worker' \
  --constraint 'node.labels.zone==us-east-1' \
  nginx
```

### Service with Placement Preferences
```bash
# Create service with placement preferences
docker service create \
  --name web \
  --network overlay-net \
  --placement-pref 'spread=node.labels.zone' \
  nginx
```

## Docker Compose Examples

### Basic Overlay Network
```yaml
version: '3.8'

services:
  web:
    image: nginx
    networks:
      - overlay-net
    deploy:
      replicas: 3
      placement:
        constraints:
          - node.role==worker

networks:
  overlay-net:
    driver: overlay
    attachable: true
```

### Encrypted Overlay Network
```yaml
version: '3.8'

services:
  web:
    image: nginx
    networks:
      - secure-net
    deploy:
      replicas: 3

networks:
  secure-net:
    driver: overlay
    attachable: true
    encrypted: true
```

### Multi-Service Stack
```yaml
version: '3.8'

services:
  web:
    image: nginx
    networks:
      - frontend
      - backend
    deploy:
      replicas: 3
      placement:
        constraints:
          - node.role==worker
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3

  api:
    image: api:latest
    networks:
      - backend
    deploy:
      replicas: 3
      placement:
        constraints:
          - node.role==worker

  database:
    image: postgres:13
    networks:
      - backend
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.labels.database==true

networks:
  frontend:
    driver: overlay
    attachable: true
  backend:
    driver: overlay
    attachable: true
    encrypted: true
```

## Troubleshooting Commands

### Check Swarm Status
```bash
# Check Swarm status
docker info --format '{{.Swarm.LocalNodeState}}'

# Check node status
docker node ls

# Check node details
docker node inspect <node>

# Check Swarm info
docker info --format '{{.Swarm.Cluster.ID}}'
docker info --format '{{.Swarm.Nodes}}'
docker info --format '{{.Swarm.Managers}}'
```

### Check Overlay Networks
```bash
# List overlay networks
docker network ls --filter driver=overlay

# Inspect overlay network
docker network inspect <network>

# Check network connectivity
docker run --rm --network <network> alpine ping -c 1 <service>
```

### Check Services
```bash
# List services
docker service ls

# Check service tasks
docker service ps <service>

# Check service logs
docker service logs <service>

# Check service details
docker service inspect <service>
```

### Check Service Discovery
```bash
# Test DNS resolution
docker run --rm --network <network> alpine nslookup <service>

# Test service connectivity
docker run --rm --network <network> alpine ping -c 1 <service>

# Test HTTP connectivity
docker run --rm --network <network> alpine wget -qO- http://<service>/
```

### Check Load Balancing
```bash
# Test load balancing
for i in {1..10}; do
  curl -s http://localhost:<port>/
  sleep 0.1
done

# Check service distribution
docker service ps <service> --format '{{.Node}} {{.CurrentState}}'
```

### Check Performance
```bash
# Check system resources
free -h
top -bn1 | grep "Cpu(s)"
df -h

# Check Docker system usage
docker system df

# Check network interfaces
ip addr show

# Check Docker daemon info
docker info --format '{{.ServerVersion}} {{.ContainersRunning}} {{.ContainersPaused}} {{.ContainersStopped}}'
```

## Best Practices

### Network Security
- **Enable encryption** on all overlay networks
- **Use network segmentation** for service isolation
- **Implement proper access controls** for service communication
- **Monitor network traffic** for security threats
- **Regular security audits** of network configurations

### Service Management
- **Use health checks** for automatic failover
- **Configure proper constraints** for service placement
- **Implement rolling updates** for zero-downtime deployments
- **Monitor service health** continuously
- **Use placement preferences** for load distribution

### Performance Optimization
- **Monitor network performance** continuously
- **Use encrypted networks** for secure communication
- **Implement proper resource constraints** for services
- **Optimize service placement** for better performance
- **Use placement preferences** for load distribution

### High Availability
- **Use multiple manager nodes** for high availability
- **Implement proper health checks** for services
- **Configure rolling updates** for zero-downtime deployments
- **Use placement constraints** for service distribution
- **Monitor cluster health** continuously

## Common Issues and Solutions

### Swarm Not Initialized
**Problem**: Docker Swarm not initialized
**Solution**: 
```bash
docker swarm init --advertise-addr <ip>
```

### No Overlay Networks
**Problem**: No overlay networks found
**Solution**:
```bash
docker network create --driver overlay --attachable <name>
```

### Service Discovery Not Working
**Problem**: Services not discoverable by name
**Solution**:
- Check if services are on the same overlay network
- Verify DNS resolution: `docker run --rm --network <network> alpine nslookup <service>`
- Check service health: `docker service ps <service>`

### Load Balancing Issues
**Problem**: Load balancing not working properly
**Solution**:
- Check service replicas: `docker service ls`
- Verify service distribution: `docker service ps <service>`
- Test load balancing: `curl http://localhost:<port>/`

### Network Connectivity Issues
**Problem**: Containers cannot communicate across hosts
**Solution**:
- Check overlay network configuration: `docker network inspect <network>`
- Verify firewall rules and port accessibility
- Test network connectivity: `docker run --rm --network <network> alpine ping -c 1 <service>`

### Service Scaling Issues
**Problem**: Services not scaling properly
**Solution**:
- Check node resources: `docker node inspect <node>`
- Verify service constraints: `docker service inspect <service>`
- Check service logs: `docker service logs <service>`

### Security Issues
**Problem**: Unencrypted communication
**Solution**:
- Enable network encryption: `docker network create --driver overlay --encrypted <name>`
- Implement proper access controls
- Configure security policies

## Performance Tips

### Network Performance
- **Use encrypted networks** for secure communication
- **Implement proper MTU settings** for overlay networks
- **Monitor network performance** continuously
- **Use placement preferences** for load distribution
- **Optimize service placement** for better performance

### Service Performance
- **Implement health checks** for automatic failover
- **Configure proper resource constraints** for services
- **Use rolling updates** for zero-downtime deployments
- **Monitor service health** continuously
- **Use placement constraints** for service distribution

### Cluster Performance
- **Use multiple manager nodes** for high availability
- **Implement proper health checks** for services
- **Configure rolling updates** for zero-downtime deployments
- **Use placement constraints** for service distribution
- **Monitor cluster health** continuously

## Monitoring Commands

### Swarm Monitoring
```bash
# Monitor Swarm status
watch -n 1 'docker node ls'

# Monitor services
watch -n 1 'docker service ls'

# Monitor service tasks
watch -n 1 'docker service ps <service>'
```

### Network Monitoring
```bash
# Monitor overlay networks
watch -n 1 'docker network ls --filter driver=overlay'

# Monitor network connectivity
watch -n 1 'docker run --rm --network <network> alpine ping -c 1 <service>'
```

### Performance Monitoring
```bash
# Monitor system resources
watch -n 1 'free -h && top -bn1 | grep "Cpu(s)"'

# Monitor Docker system usage
watch -n 1 'docker system df'

# Monitor network interfaces
watch -n 1 'ip addr show'
```

---

**Quick Reference**: Essential commands and best practices for Docker Swarm overlay networking
