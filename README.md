# Networking Learning Project

A comprehensive hands-on project for learning computer networking concepts through practical exercises and simulations.

## Project Structure

```
networking/
├── README.md                           # This file
├── 01-basics/                         # Basic networking concepts
│   ├── ping-traceroute/               # Network connectivity tools
│   ├── network-interfaces/            # Interface configuration
│   └── basic-commands/                # Essential networking commands
├── 02-protocols/                      # Network protocols
│   ├── tcp-udp/                       # Transport layer protocols
│   ├── http-https/                    # Application layer protocols
│   ├── dns/                          # Domain Name System
│   └── dhcp/                         # Dynamic Host Configuration Protocol
├── 03-docker-networks/                # Container networking
│   ├── bridge-networks/               # Docker bridge networks
│   ├── overlay-networks/              # Multi-host networking
│   └── custom-networks/               # Custom network configurations
├── 04-network-analysis/               # Network monitoring and analysis
│   ├── wireshark/                     # Packet capture and analysis
│   ├── tcpdump/                       # Command-line packet capture
│   └── netstat-ss/                    # Network statistics
├── 05-security/                       # Network security
│   ├── firewalls/                     # Firewall configuration
│   ├── vpn/                          # Virtual Private Networks
│   └── ssl-tls/                      # Encryption protocols
├── 06-advanced/                       # Advanced networking topics
│   ├── routing/                       # Static and dynamic routing
│   ├── load-balancing/                # Load balancing techniques
│   └── monitoring/                    # Network monitoring tools
├── tools/                            # Utility scripts and tools
│   ├── network-scanner.py            # Network discovery tool
│   ├── bandwidth-test.py             # Bandwidth testing
│   └── port-scanner.py               # Port scanning utility
├── docker-compose.yml                # Docker services for network simulation
├── container-practice.sh             # Containerized practice script
├── CONTAINER_PRACTICE.md             # Container practice guide
└── requirements.txt                  # Python dependencies
```

## 🚀 Quick Start

### One-Command Installation
**Cross-platform installation script:**

```bash
# Clone the repository
git clone https://github.com/your-username/networking-learning.git
cd networking-learning

# Run automated installation
./install.sh
```

### Containerized Practice (Recommended)
**Perfect for safe learning during meetings or training sessions!**

```bash
# Start the networking practice environment
./container-practice.sh start

# Enter practice container
./container-practice.sh enter

# Run practice exercises
./container-practice.sh exercises
```

**Why Use Containers?**
- ✅ **Safe Environment**: Practice without affecting your host system
- ✅ **Meeting-Safe**: Learn during Zoom sessions without risk
- ✅ **Easy Reset**: Just restart containers to clean state
- ✅ **Full Tools**: All networking tools pre-installed
- ✅ **Cross-Platform**: Works on macOS, Linux, and Windows

### Local Development Setup
**For development and local testing:**

```bash
# Run setup script
./setup.sh

# Or manually install dependencies
pip3 install -r requirements.txt
```

**System Requirements:**
- **Python**: 3.8+ with pip
- **Memory**: 2GB RAM (4GB recommended)
- **Storage**: 1GB free space
- **Network**: Internet connection for package downloads
- **Platform**: macOS 10.15+, Linux (Ubuntu 20.04+), Windows 10+ (WSL2)

### Platform-Specific Installation

#### macOS
```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install python3 docker docker-compose wireshark tcpdump nmap

# Clone and setup
git clone https://github.com/your-username/networking-learning.git
cd networking-learning
./install.sh
```

#### Linux (Ubuntu/Debian)
```bash
# Install dependencies
sudo apt update
sudo apt install -y python3 python3-pip docker.io docker-compose

# Clone and setup
git clone https://github.com/your-username/networking-learning.git
cd networking-learning
./install.sh
```

#### Windows (WSL2)
```bash
# Install WSL2
wsl --install

# In WSL2 Ubuntu terminal:
sudo apt update
sudo apt install -y python3 python3-pip docker.io docker-compose

# Clone and setup
git clone https://github.com/your-username/networking-learning.git
cd networking-learning
./install.sh
```

**See `INSTALLATION.md` for detailed installation instructions.**

## Learning Path

### Phase 1: Fundamentals (Week 1-2)
- Start with `01-basics/` to understand core concepts
- Practice with ping, traceroute, and basic commands
- Learn about network interfaces and configuration

### Phase 2: Protocols (Week 3-4)
- Dive into `02-protocols/` to understand how data travels
- Practice with TCP/UDP, HTTP/HTTPS, DNS, and DHCP
- Use packet capture tools to see protocols in action

### Phase 3: Container Networking (Week 5-6)
- Explore `03-docker-networks/` for modern networking
- Learn about bridge, overlay, and custom networks
- Practice with Docker Compose for multi-container setups

### Phase 4: Analysis & Security (Week 7-8)
- Use `04-network-analysis/` tools for troubleshooting
- Implement security measures in `05-security/`
- Learn about firewalls, VPNs, and encryption

### Phase 5: Advanced Topics (Week 9-10)
- Master `06-advanced/` concepts like routing and load balancing
- Build monitoring solutions
- Create complex network topologies

## Quick Start

1. **Prerequisites**
   ```bash
   # Install required tools
   brew install docker docker-compose wireshark tcpdump nmap
   
   # Install Python dependencies
   pip install -r requirements.txt
   ```

2. **Start with basics**
   ```bash
   cd 01-basics/ping-traceroute
   ./run-exercises.sh
   ```

3. **Launch network simulation**
   ```bash
   docker-compose up -d
   ```

## Tools & Technologies

- **Docker & Docker Compose**: Container networking simulation
- **Wireshark**: Packet analysis and protocol inspection
- **tcpdump**: Command-line packet capture
- **nmap**: Network discovery and port scanning
- **Python**: Custom networking tools and utilities
- **Linux networking tools**: ping, traceroute, netstat, ss, ip

## Learning Objectives

By the end of this project, you will understand:

- ✅ How data flows through networks (OSI model)
- ✅ TCP/IP protocol stack and common protocols
- ✅ Network addressing (IPv4/IPv6, subnets, routing)
- ✅ Container networking concepts
- ✅ Network security principles
- ✅ Troubleshooting and monitoring techniques
- ✅ Modern networking architectures

## Contributing

This is a personal learning project. Feel free to add your own exercises and experiments!

## Resources

- [Computer Networks: A Systems Approach](https://book.systemsapproach.org/)
- [Wireshark User's Guide](https://www.wireshark.org/docs/wsug_html/)
- [Docker Networking Documentation](https://docs.docker.com/network/)
- [RFC Standards](https://www.rfc-editor.org/rfc-index.html)
