# Container Requirements and Setup

This document outlines the system packages and Python dependencies required for the networking learning environment.

## System Packages (Ubuntu/Debian)

The containerized environment requires the following system packages:

### Core Networking Tools
```bash
# Network configuration and analysis
iproute2              # Modern network configuration (ip command)
net-tools             # Legacy networking tools (ifconfig, netstat, route)
traceroute            # Network path tracing
iputils-ping          # Ping utility
tcpdump               # Packet capture and analysis
curl                  # HTTP client
wget                  # File downloader
dnsutils              # DNS utilities (dig, nslookup, host)
nmap                  # Network scanner
iptables              # Firewall management
```

### Development and Runtime
```bash
# Python environment
python3               # Python 3 interpreter
python3-pip           # Python package manager
python3-dev           # Python development headers
build-essential       # Compilation tools (gcc, make, etc.)
```

### Additional Tools
```bash
# System utilities
openssl               # SSL/TLS tools
ca-certificates       # SSL certificate authorities
```

## Python Dependencies

Install Python packages using pip:

```bash
# Install from requirements.txt
pip install -r requirements.txt

# Or install individual packages
pip install requests urllib3 scapy psutil netifaces matplotlib plotly click rich tabulate
```

## Docker Compose Configuration

The `docker-compose.yml` automatically installs these packages:

```yaml
net-practice:
  image: ubuntu:22.04
  command: |
    bash -c "
      apt-get update &&
      apt-get install -y iproute2 net-tools traceroute iputils-ping tcpdump curl wget dnsutils nmap iptables net-tools python3 python3-pip &&
      tail -f /dev/null
    "
```

## Container Capabilities

The container requires specific capabilities for networking operations:

```yaml
cap_add:
  - NET_ADMIN          # Network administration (routing, interfaces)
  - NET_RAW            # Raw network access (ping, traceroute)
  - SYS_ADMIN          # System administration (some networking tools)
privileged: true       # Full system access for advanced networking
```

## Volume Mounts

Required volume mounts for the containerized environment:

```yaml
volumes:
  - ./01-basics/basic-commands:/commands    # Basic networking commands
  - ./tools:/tools                          # Additional tools
  - ./scripts:/scripts                      # All Python and shell scripts
```

## Verification

To verify the container environment is properly set up:

```bash
# Check system packages
docker exec net-practice which ip ping traceroute curl dig nmap

# Check Python packages
docker exec net-practice python3 -c "import requests, scapy, psutil; print('Python packages OK')"

# Test networking tools
docker exec net-practice ping -c 1 8.8.8.8
docker exec net-practice dig google.com
docker exec net-practice python3 /scripts/dns-analyzer.py google.com
```

## Troubleshooting

### Missing Packages
If a tool is not found:
```bash
# Check if package is installed
docker exec net-practice which [tool-name]

# Install missing package
docker exec net-practice apt-get update && apt-get install -y [package-name]
```

### Python Import Errors
If Python scripts fail with import errors:
```bash
# Check Python packages
docker exec net-practice pip list

# Install missing package
docker exec net-practice pip install [package-name]

# Install all requirements
docker exec net-practice pip install -r /scripts/requirements.txt
```

### Permission Issues
If networking tools fail due to permissions:
```bash
# Check container capabilities
docker inspect net-practice | grep -A 10 "CapAdd"

# Restart with proper capabilities
docker-compose down && docker-compose up -d
```

## Performance Considerations

### Container Resources
- **Memory**: Minimum 512MB, recommended 1GB
- **CPU**: 1-2 cores for basic operations
- **Storage**: ~500MB for packages and tools

### Network Access
- Container needs internet access for:
  - Package installation
  - DNS resolution testing
  - External network connectivity tests
  - Python package downloads

## Security Notes

### Container Privileges
The container runs with elevated privileges (`privileged: true`) to allow:
- Raw network access for ping/traceroute
- Network interface management
- Firewall rule manipulation
- Packet capture operations

### Network Isolation
- Container uses custom bridge networks
- Isolated from host network for safety
- Can be safely used for learning without affecting host system

## Updates and Maintenance

### Updating Packages
```bash
# Update system packages
docker exec net-practice apt-get update && apt-get upgrade -y

# Update Python packages
docker exec net-practice pip install --upgrade -r requirements.txt
```

### Rebuilding Container
```bash
# Rebuild with latest packages
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

This setup provides a complete, safe, and isolated environment for learning networking concepts and practicing with real networking tools.
