# Containerized Networking Practice

This guide shows you how to practice networking commands safely in containers, perfect for learning during meetings or training sessions.

## 🚀 Quick Start

### 1. Start the Environment
```bash
# Start all containers
./container-practice.sh start

# Or use docker-compose directly
docker-compose up -d
```

### 2. Enter Practice Container
```bash
# Enter the main practice container
./container-practice.sh enter

# Or specify a different container
./container-practice.sh enter firewall-test
```

### 3. Practice Commands Safely
Once inside the container, you can run any networking command:
```bash
# Basic connectivity
ping google.com
traceroute 8.8.8.8

# Network configuration
ip addr show
ip route show
ifconfig -a

# Network statistics
netstat -tuln
ss -tuln

# Packet capture (requires privileges)
tcpdump -i any -c 10

# DNS testing
nslookup google.com
dig google.com
```

## 🏗️ Container Architecture

### Available Containers

| Container | Purpose | Tools Available |
|-----------|---------|-----------------|
| `net-practice` | Main practice environment | iproute2, net-tools, traceroute, ping, tcpdump, nmap |
| `firewall-test` | Firewall and security testing | iptables, netfilter, ufw |
| `router` | Routing and forwarding | iproute2, iptables |
| `client` | Basic client testing | Basic networking tools |
| `web-server` | HTTP/HTTPS testing | nginx |
| `database` | Database connectivity | postgres |
| `dns-server` | DNS testing | dnsmasq |

### Network Topology

```
Internet
    │
    ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Client    │    │ net-practice│    │firewall-test│
│             │    │             │    │             │
└─────────────┘    └─────────────┘    └─────────────┘
    │                   │                   │
    └───────────────────┼───────────────────┘
                        │
                   ┌─────────────┐
                   │   Router    │
                   │             │
                   └─────────────┘
                        │
    ┌───────────────────┼───────────────────┐
    │                   │                   │
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│web-server   │    │  database   │    │target-server│
│             │    │             │    │             │
└─────────────┘    └─────────────┘    └─────────────┘
```

## 🛠️ Practice Scenarios

### 1. Basic Connectivity Testing
```bash
# Enter practice container
./container-practice.sh enter

# Test basic connectivity
ping 8.8.8.8
ping google.com
traceroute 8.8.8.8

# Test local connectivity
ping web-server
ping database
ping target-server
```

### 2. Network Configuration
```bash
# Show network interfaces
ip addr show
ifconfig -a

# Show routing table
ip route show
route -n

# Show ARP table
ip neigh show
arp -a
```

### 3. Service Discovery
```bash
# Test DNS resolution
nslookup google.com
dig google.com
dig @dns-server local.test

# Test HTTP services
curl http://web-server
curl http://target-server
```

### 4. Firewall Testing
```bash
# Enter firewall container
./container-practice.sh enter firewall-test

# Show iptables rules
iptables -L -n -v

# Test firewall rules
ping 8.8.8.8
telnet web-server 80
```

### 5. Packet Analysis
```bash
# Capture packets
tcpdump -i any -c 10

# Capture specific traffic
tcpdump -i any host 8.8.8.8

# Capture HTTP traffic
tcpdump -i any port 80
```

## 📋 Practice Exercises

### Exercise 1: Network Discovery
```bash
# 1. Find all network interfaces
ip addr show

# 2. Find the default gateway
ip route show | grep default

# 3. Test connectivity to gateway
ping $(ip route show | grep default | awk '{print $3}')

# 4. Trace route to external host
traceroute 8.8.8.8
```

### Exercise 2: Service Testing
```bash
# 1. Test DNS resolution
nslookup google.com
dig google.com

# 2. Test HTTP connectivity
curl -I http://web-server
curl -I http://target-server

# 3. Test database connectivity
telnet database 5432
```

### Exercise 3: Network Troubleshooting
```bash
# 1. Check if service is listening
netstat -tuln | grep :80
ss -tuln | grep :80

# 2. Check routing
ip route get 8.8.8.8

# 3. Check ARP table
ip neigh show

# 4. Test with different protocols
ping -c 3 8.8.8.8
traceroute -n 8.8.8.8
```

## 🔧 Advanced Usage

### Custom Commands
```bash
# Run specific command in container
./container-practice.sh run net-practice "ip addr show"
./container-practice.sh run firewall-test "iptables -L"
```

### Run Practice Exercises
```bash
# Run automated exercises
./container-practice.sh exercises
```

### Show Network Information
```bash
# Show container network details
./container-practice.sh info
```

## 🛡️ Safety Features

### Why Use Containers?
- **Isolated Environment**: Commands can't affect your host system
- **Safe to Experiment**: Break things without consequences
- **Meeting-Safe**: Practice during Zoom sessions without risk
- **Easy Reset**: Just restart containers to clean state
- **Reproducible**: Same environment every time

### Container Capabilities
- `NET_ADMIN`: Required for network configuration
- `NET_RAW`: Required for raw sockets (ping, traceroute)
- `SYS_ADMIN`: Required for some advanced operations
- `privileged: true`: Required for iptables and advanced networking

## 🚨 Troubleshooting

### Common Issues

**Container won't start:**
```bash
# Check Docker is running
docker info

# Check for port conflicts
netstat -tuln | grep :8080
```

**Permission denied:**
```bash
# Some commands need privileges
sudo docker exec -it net-practice bash
```

**Network connectivity issues:**
```bash
# Check container network
docker network ls
docker network inspect networking_frontend
```

**Command not found:**
```bash
# Install missing tools
apt-get update && apt-get install -y <package-name>
```

## 📚 Learning Path

1. **Start with basic connectivity** (ping, traceroute)
2. **Learn network configuration** (ip, ifconfig)
3. **Practice service discovery** (nslookup, dig)
4. **Experiment with firewalls** (iptables)
5. **Analyze network traffic** (tcpdump)
6. **Troubleshoot network issues** (systematic approach)

## 🎯 Tips for Learning

- **Start simple**: Begin with basic commands
- **Read the output**: Understand what each command shows
- **Experiment**: Try different options and parameters
- **Break things**: Learn by fixing problems
- **Use help**: `man command` or `command --help`
- **Take notes**: Document what you learn

Happy networking! 🚀
