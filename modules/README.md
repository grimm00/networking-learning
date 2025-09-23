# Learning Modules

This directory contains all the learning modules for the networking project. Each module focuses on specific networking concepts and includes hands-on exercises, documentation, and tools.

## 📚 Available Modules

### **01-basics/** - Basic Networking Concepts
- **ping-traceroute/**: Network connectivity tools
- **network-interfaces/**: Interface configuration and analysis
- **ipv4-addressing/**: IPv4 addressing and subnetting
- **osi-model/**: OSI model analysis and protocol identification
- **basic-commands/**: Essential networking commands

### **02-protocols/** - Network Protocols
- **tcp-udp/**: Transport layer protocols
- **http-https/**: Application layer protocols
- **dns/**: Domain Name System
- **ssh/**: Secure Shell
- **ntp/**: Network Time Protocol
- **dhcp/**: Dynamic Host Configuration Protocol

### **03-docker-networks/** - Container Networking
- **bridge-networks/**: Docker bridge networks
- **overlay-networks/**: Multi-host networking
- **custom-networks/**: Custom network configurations

### **04-network-analysis/** - Network Monitoring and Analysis
- **wireshark/**: Packet capture and analysis
- **tcpdump/**: Command-line packet capture
- **netstat-ss/**: Network statistics

### **05-dns-server/** - DNS Server Configuration
- **coredns-configs/**: CoreDNS configuration files
- **zones/**: DNS zone files
- **dns-lab.sh**: Interactive DNS lab
- **DOCKER_EXPLAINED.md**: Docker setup explanation
- **README.md**: DNS server documentation

### **06-http-servers/** - HTTP Server Management
- **nginx-configs/**: Nginx configuration files
- **apache-configs/**: Apache configuration files
- **html/**: Sample web content
- **ssl-certs/**: SSL certificate examples
- **http-lab.sh**: Interactive HTTP server lab
- **docker-compose.yml**: HTTP server containers
- **DOCKER_EXPLAINED.md**: Docker setup explanation
- **README.md**: HTTP server documentation
- **quick-reference.md**: Quick reference guide

### **06-security/** - Network Security
- **firewalls/**: Firewall configuration
- **vpn/**: Virtual Private Networks
- **ssl-tls/**: Encryption protocols

### **07-advanced/** - Advanced Networking Topics
- **routing/**: Static and dynamic routing
- **load-balancing/**: Load balancing techniques
- **monitoring/**: Network monitoring tools

## 🚀 Getting Started

### **Using Module Management Scripts**
```bash
# Check status of all modules
./bin/check-ports.sh

# Start specific modules
./bin/start-module.sh dns start
./bin/start-module.sh http start

# Check module status
./bin/start-module.sh dns status
./bin/start-module.sh http status
```

### **Direct Module Access**
```bash
# Navigate to specific modules
cd modules/05-dns-server
cd modules/06-http-servers

# Start module services
docker-compose up -d

# Run interactive labs
./dns-lab.sh
./http-lab.sh
```

## 📖 Learning Path

1. **Start with Basics** (01-basics/)
   - Learn fundamental networking concepts
   - Practice with basic commands
   - Understand network interfaces

2. **Explore Protocols** (02-protocols/)
   - Study different network protocols
   - Practice protocol analysis
   - Learn protocol-specific tools

3. **Container Networking** (03-docker-networks/)
   - Understand container networking
   - Practice with Docker networks
   - Learn network isolation

4. **Network Analysis** (04-network-analysis/)
   - Learn packet capture techniques
   - Practice network monitoring
   - Analyze network traffic

5. **Server Configuration** (05-dns-server/, 06-http-servers/)
   - Configure DNS servers
   - Set up web servers
   - Practice server management

6. **Security** (06-security/)
   - Learn network security concepts
   - Practice firewall configuration
   - Understand encryption

7. **Advanced Topics** (07-advanced/)
   - Study advanced networking
   - Practice complex configurations
   - Learn enterprise networking

## 🔧 Module Structure

Each module typically includes:
- **README.md**: Comprehensive documentation
- **DOCKER_EXPLAINED.md**: Docker setup explanations (where applicable)
- **docker-compose.yml**: Container configurations (where applicable)
- **Scripts**: Interactive labs and tools
- **Configs**: Configuration examples
- **Quick Reference**: Command references

## 💡 Tips for Learning

- **Start Simple**: Begin with basic concepts before moving to advanced topics
- **Hands-On Practice**: Use the interactive labs and tools
- **Read Documentation**: Each module has comprehensive documentation
- **Experiment**: Try modifying configurations and see what happens
- **Use Containers**: The containerized environment is safe for experimentation

## 🆘 Getting Help

- Check the main [README.md](../README.md) for project overview
- Read [DOCKER_EXPLAINED.md](../DOCKER_EXPLAINED.md) for Docker concepts
- Use `./bin/check-ports.sh` to diagnose port conflicts
- Check individual module documentation for specific help

Happy learning! 🎉
