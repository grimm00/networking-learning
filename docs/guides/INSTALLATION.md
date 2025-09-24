# Installation Guide

This guide provides step-by-step instructions for installing and setting up the Networking Learning Project on different operating systems.

## System Requirements

### Minimum Requirements
- **Python**: 3.8 or later
- **Memory**: 2GB RAM (4GB recommended)
- **Storage**: 1GB free space
- **Network**: Internet connection for package downloads

### Supported Operating Systems
- ✅ **macOS** (10.15+)
- ✅ **Linux** (Ubuntu 20.04+, CentOS 8+, Debian 11+)
- ✅ **Windows** (Windows 10+ with WSL2)
- ✅ **Docker** (any platform with Docker support)

## Quick Installation

### Option 1: Containerized Setup (Recommended)
**Best for: Safe learning, meetings, training sessions**

```bash
# Clone the repository
git clone https://github.com/your-username/networking-learning.git
cd networking-learning

# Start containerized environment
./container-practice.sh start

# Enter the learning environment
./container-practice.sh enter
```

### Option 2: Local Installation
**Best for: Development, customization, offline use**

```bash
# Clone the repository
git clone https://github.com/your-username/networking-learning.git
cd networking-learning

# Run automated setup
./setup.sh

# Or manual setup
pip3 install -r requirements.txt
```

## Platform-Specific Installation

### macOS Installation

#### Prerequisites
```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required tools
brew install python3 docker docker-compose wireshark tcpdump nmap
```

#### Installation Steps
```bash
# Clone repository
git clone https://github.com/your-username/networking-learning.git
cd networking-learning

# Run setup
./setup.sh

# Verify installation
python3 scripts/interface-analyzer.py --help
```

#### macOS-Specific Notes
- **Network Tools**: Some tools may require `sudo` for raw network access
- **Firewall**: macOS may prompt for network permissions
- **Docker**: Requires Docker Desktop for containerized environment

### Linux Installation

#### Ubuntu/Debian
```bash
# Update package list
sudo apt update

# Install system dependencies
sudo apt install -y python3 python3-pip python3-venv \
    iproute2 net-tools traceroute iputils-ping \
    tcpdump curl wget dnsutils nmap \
    docker.io docker-compose

# Clone and setup
git clone https://github.com/your-username/networking-learning.git
cd networking-learning
./setup.sh
```

#### CentOS/RHEL/Fedora
```bash
# Install system dependencies
sudo yum install -y python3 python3-pip \
    iproute2 net-tools traceroute iputils \
    tcpdump curl wget bind-utils nmap \
    docker docker-compose

# Clone and setup
git clone https://github.com/your-username/networking-learning.git
cd networking-learning
./setup.sh
```

#### Linux-Specific Notes
- **Permissions**: Some networking tools require `sudo` or `CAP_NET_RAW`
- **SELinux**: May need to configure SELinux policies for networking tools
- **Firewall**: Ensure firewall allows necessary network traffic

### Windows Installation

#### Using WSL2 (Recommended)
```bash
# Install WSL2 and Ubuntu
wsl --install

# In WSL2 Ubuntu terminal:
sudo apt update
sudo apt install -y python3 python3-pip \
    iproute2 net-tools traceroute iputils-ping \
    tcpdump curl wget dnsutils nmap

# Clone and setup
git clone https://github.com/your-username/networking-learning.git
cd networking-learning
./setup.sh
```

#### Native Windows (Advanced)
```powershell
# Install Python 3.8+
# Download from https://python.org

# Install dependencies
pip install -r requirements.txt

# Note: Some networking tools may not be available on Windows
# Consider using WSL2 or Docker for full functionality
```

#### Windows-Specific Notes
- **WSL2**: Recommended for full Linux networking tools
- **Docker Desktop**: Required for containerized environment
- **Permissions**: Some tools may require administrator privileges

## Docker Installation

### Docker Desktop Setup
```bash
# Install Docker Desktop
# macOS: Download from https://docker.com
# Linux: Follow distribution-specific instructions
# Windows: Download Docker Desktop

# Verify installation
docker --version
docker-compose --version
```

### Containerized Environment
```bash
# Clone repository
git clone https://github.com/your-username/networking-learning.git
cd networking-learning

# Start containerized environment
./container-practice.sh start

# Verify container is running
docker ps

# Enter learning environment
./container-practice.sh enter
```

## Verification and Testing

### Test Installation
```bash
# Test Python scripts
python3 scripts/interface-analyzer.py --help
python3 scripts/dns-analyzer.py --help
python3 scripts/http-analyzer.py --help

# Test containerized environment
./container-practice.sh test

# Test networking tools
ping -c 1 8.8.8.8
traceroute -m 5 8.8.8.8
```

### Verify Dependencies
```bash
# Check Python packages
python3 -c "import requests, scapy, psutil; print('✅ Python packages OK')"

# Check system tools
which ping traceroute curl dig nmap
echo "✅ System tools OK"

# Check Docker (if using containers)
docker --version
echo "✅ Docker OK"
```

## Troubleshooting

### Common Issues

#### Python Import Errors
```bash
# Reinstall Python packages
pip3 install --upgrade -r requirements.txt

# Check Python version
python3 --version  # Should be 3.8+

# Use virtual environment
python3 -m venv venv
source venv/bin/activate  # Linux/macOS
pip install -r requirements.txt
```

#### Permission Errors
```bash
# Linux: Add user to networking groups
sudo usermod -a -G netdev $USER

# macOS: Grant network permissions in System Preferences

# Windows: Run as administrator or use WSL2
```

#### Docker Issues
```bash
# Restart Docker service
sudo systemctl restart docker  # Linux
# Or restart Docker Desktop

# Check Docker permissions
docker ps  # Should work without sudo

# Rebuild containers
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

#### Network Tool Failures
```bash
# Check if tools are installed
which ping traceroute curl dig nmap

# Install missing tools
# Ubuntu/Debian:
sudo apt install iputils-ping traceroute curl dnsutils nmap

# macOS:
brew install iproute2mac tcpdump nmap

# CentOS/RHEL:
sudo yum install iputils traceroute curl bind-utils nmap
```

### Platform-Specific Issues

#### macOS Issues
- **Network permissions**: Grant permissions in System Preferences > Security & Privacy
- **Homebrew**: Ensure Homebrew is up to date: `brew update`
- **Python**: Use `python3` instead of `python`

#### Linux Issues
- **SELinux**: May block networking tools: `sudo setsebool -P use_nfs_home_dirs 1`
- **Firewall**: Configure iptables or firewalld as needed
- **Capabilities**: Some tools need `CAP_NET_RAW`: `sudo setcap cap_net_raw+ep /bin/ping`

#### Windows Issues
- **WSL2**: Ensure WSL2 is enabled: `wsl --set-default-version 2`
- **Docker**: Enable WSL2 integration in Docker Desktop settings
- **Path**: Ensure Python and pip are in PATH

## Advanced Configuration

### Custom Python Environment
```bash
# Create virtual environment
python3 -m venv networking-env
source networking-env/bin/activate  # Linux/macOS
# networking-env\Scripts\activate  # Windows

# Install dependencies
pip install -r requirements.txt

# Deactivate when done
deactivate
```

### Custom Docker Configuration
```bash
# Modify docker-compose.yml for custom setup
# Add additional volumes, environment variables, or services

# Build custom image
docker build -t networking-learning:custom .

# Use custom image in docker-compose.yml
```

### Development Setup
```bash
# Install development dependencies
pip install -r requirements.txt
pip install pytest black flake8

# Run tests
pytest tests/

# Format code
black scripts/

# Lint code
flake8 scripts/
```

## Uninstallation

### Automated Uninstall (Recommended)

The easiest way to remove the project is using the built-in uninstall script:

```bash
# Remove project components (keeps Git repository)
./bin/uninstall.sh

# Remove everything including Git repository
./bin/uninstall.sh --git

# Skip confirmation prompt
./bin/uninstall.sh --force
```

The uninstaller will automatically:
- Stop and remove all Docker containers, images, networks, and volumes
- Remove the Python virtual environment
- Clean up build artifacts and temporary files
- Optionally remove the Git repository

### Manual Uninstall

If you prefer to remove components manually:

#### Remove Python Packages
```bash
# Remove virtual environment
rm -rf venv/

# Remove global packages (not recommended)
pip3 uninstall -r requirements.txt
```

#### Remove Docker Containers
```bash
# Stop and remove containers
docker-compose down

# Remove images
docker rmi networking-learning_net-practice

# Remove volumes (optional)
docker volume prune
```

### Remove System Tools
```bash
# macOS
brew uninstall python3 docker docker-compose wireshark tcpdump nmap

# Ubuntu/Debian
sudo apt remove python3 python3-pip docker.io docker-compose

# CentOS/RHEL
sudo yum remove python3 python3-pip docker docker-compose
```

## Support and Resources

### Getting Help
- **Issues**: Create an issue on GitHub
- **Documentation**: Check the `admin/` directory for detailed documentation
- **Community**: Join networking learning communities

### Additional Resources
- **Docker Documentation**: https://docs.docker.com/
- **Python Documentation**: https://docs.python.org/3/
- **Networking Tools**: Check individual tool documentation

### Contributing
- Fork the repository
- Create a feature branch
- Make your changes
- Submit a pull request

This installation guide ensures the Networking Learning Project can be easily installed and used on any supported platform.
