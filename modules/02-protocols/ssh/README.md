# SSH (Secure Shell) Protocol Deep Dive

A comprehensive guide to understanding SSH protocols through hands-on analysis, testing, and troubleshooting.

## What You'll Learn

- **SSH Fundamentals**: Protocol architecture, handshake process, encryption
- **Authentication Methods**: Password, key-based, certificate-based authentication
- **Security Features**: Encryption algorithms, host verification, key management
- **Connection Management**: Port forwarding, tunneling, multiplexing
- **Troubleshooting**: Common issues, debugging techniques, security analysis
- **Advanced Features**: SSH agents, config management, automation

## SSH Protocol Overview

### What is SSH?
SSH (Secure Shell) is a cryptographic network protocol for operating network services securely over an unsecured network. It provides:

- **Secure Remote Access**: Encrypted command-line access to remote systems
- **File Transfer**: Secure file copying (SCP, SFTP)
- **Port Forwarding**: Secure tunneling of other protocols
- **X11 Forwarding**: Secure GUI application forwarding

### SSH Protocol Versions

#### SSH-1 (Deprecated)
- **Security Issues**: Weak encryption, vulnerable to attacks
- **Status**: Not recommended for use
- **Key Exchange**: RSA only

#### SSH-2 (Current Standard)
- **Security**: Strong encryption, multiple algorithms
- **Features**: Multiple authentication methods, compression, multiplexing
- **Key Exchange**: Diffie-Hellman, ECDH, Curve25519

### SSH Architecture

```
┌─────────────────┐    SSH Connection    ┌─────────────────┐
│   SSH Client    │◄────────────────────►│   SSH Server    │
│                 │                      │                 │
│ • Authentication│                      │ • User Auth     │
│ • Encryption    │                      │ • Access Control│
│ • Compression   │                      │ • Command Exec  │
│ • Port Forward  │                      │ • File Transfer │
└─────────────────┘                      └─────────────────┘
```

## SSH Handshake Process

### 1. TCP Connection
```bash
# SSH typically uses port 22
telnet example.com 22
```

### 2. Protocol Version Exchange
```
Client → Server: SSH-2.0-OpenSSH_8.9p1
Server → Client: SSH-2.0-OpenSSH_8.9p1
```

### 3. Key Exchange (KEX)
- **Algorithm Negotiation**: Both sides agree on encryption algorithms
- **Key Generation**: Generate shared secret using Diffie-Hellman
- **Host Key Verification**: Verify server identity

### 4. Authentication
- **Password Authentication**: Username/password
- **Public Key Authentication**: RSA, ECDSA, Ed25519 keys
- **Certificate Authentication**: X.509 certificates

### 5. Service Request
- **Shell Access**: Interactive command line
- **SFTP**: Secure file transfer
- **Port Forwarding**: Tunneling other protocols

## SSH Commands and Usage

### Basic SSH Connection
```bash
# Basic connection
ssh username@hostname

# Specify port
ssh -p 2222 username@hostname

# Specify key file
ssh -i ~/.ssh/id_rsa username@hostname

# Verbose output (debugging)
ssh -v username@hostname
ssh -vv username@hostname  # More verbose
ssh -vvv username@hostname # Maximum verbosity
```

### SSH Key Management
```bash
# Generate RSA key (2048-bit)
ssh-keygen -t rsa -b 2048 -C "your_email@example.com"

# Generate ECDSA key (256-bit)
ssh-keygen -t ecdsa -b 256 -C "your_email@example.com"

# Generate Ed25519 key (recommended)
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy public key to server
ssh-copy-id username@hostname

# List keys in SSH agent
ssh-add -l

# Add key to SSH agent
ssh-add ~/.ssh/id_rsa
```

### Port Forwarding
```bash
# Local port forwarding
ssh -L 8080:localhost:80 username@hostname

# Remote port forwarding
ssh -R 8080:localhost:80 username@hostname

# Dynamic port forwarding (SOCKS proxy)
ssh -D 1080 username@hostname
```

### File Transfer
```bash
# SCP - Secure Copy
scp file.txt username@hostname:/path/to/destination/
scp username@hostname:/path/to/file.txt ./

# SFTP - Secure File Transfer Protocol
sftp username@hostname
sftp> get file.txt
sftp> put file.txt
sftp> ls
sftp> quit

# rsync over SSH
rsync -avz -e ssh /local/path/ username@hostname:/remote/path/
```

## SSH Configuration

### Client Configuration (~/.ssh/config)
```bash
# Global settings
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
    TCPKeepAlive yes
    Compression yes

# Specific host configuration
Host myserver
    HostName 192.168.1.100
    User myusername
    Port 2222
    IdentityFile ~/.ssh/id_rsa
    ForwardAgent yes
    LocalForward 8080 localhost:80
```

### Server Configuration (/etc/ssh/sshd_config)
```bash
# Port and protocol
Port 22
Protocol 2

# Authentication
PasswordAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys

# Security settings
PermitRootLogin no
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2

# Logging
SyslogFacility AUTH
LogLevel INFO
```

## SSH Security Features

### Encryption Algorithms
```bash
# Check supported algorithms
ssh -Q cipher        # Encryption algorithms
ssh -Q mac          # Message authentication codes
ssh -Q kex          # Key exchange algorithms
ssh -Q key          # Public key algorithms
```

### Host Key Verification
```bash
# Check known hosts
ssh-keygen -l -f ~/.ssh/known_hosts

# Remove host from known_hosts
ssh-keygen -R hostname

# Verify host key fingerprint
ssh-keyscan hostname
```

### Security Best Practices
1. **Use Strong Keys**: Ed25519 or RSA 4096-bit minimum
2. **Disable Root Login**: Use sudo instead
3. **Change Default Port**: Reduce automated attacks
4. **Use Key Authentication**: Disable password auth when possible
5. **Regular Updates**: Keep SSH client/server updated
6. **Monitor Logs**: Watch for suspicious activity

## SSH Analysis Tools

### Python SSH Analyzer
Comprehensive SSH analysis tool with detailed reporting:

```bash
# Basic analysis
python ssh-analyzer.py user@hostname

# Security analysis
python ssh-analyzer.py -s user@hostname

# Performance testing
python ssh-analyzer.py -p 10 user@hostname

# Key analysis
python ssh-analyzer.py -k ~/.ssh/id_rsa
```

### Shell Troubleshooting Script
Advanced SSH troubleshooting and diagnostics:

```bash
# Basic troubleshooting
./ssh-troubleshoot.sh user@hostname

# Comprehensive analysis
./ssh-troubleshoot.sh -a user@hostname

# Security testing
./ssh-troubleshoot.sh -s user@hostname

# Performance testing
./ssh-troubleshoot.sh -p 10 user@hostname
```

## Common SSH Issues and Solutions

### Connection Refused
```bash
# Check if SSH service is running
systemctl status ssh
systemctl start ssh

# Check if port is open
nmap -p 22 hostname
telnet hostname 22
```

### Authentication Failed
```bash
# Check SSH logs
tail -f /var/log/auth.log

# Test with verbose output
ssh -vvv username@hostname

# Check key permissions
ls -la ~/.ssh/
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
```

### Host Key Verification Failed
```bash
# Remove old host key
ssh-keygen -R hostname

# Accept new host key
ssh -o StrictHostKeyChecking=no username@hostname
```

### Permission Denied
```bash
# Check user permissions
id username
groups username

# Check SSH configuration
sudo sshd -T | grep -i permit
```

## Lab Exercises

### Exercise 1: Basic SSH Setup
1. Generate SSH key pair
2. Configure SSH client
3. Test connection with verbose output
4. Analyze connection process

### Exercise 2: Security Analysis
1. Scan SSH service for vulnerabilities
2. Test different authentication methods
3. Analyze encryption algorithms
4. Check host key verification

### Exercise 3: Port Forwarding
1. Set up local port forwarding
2. Test remote port forwarding
3. Configure dynamic port forwarding
4. Verify tunnel functionality

### Exercise 4: Troubleshooting
1. Simulate common SSH issues
2. Use debugging techniques
3. Analyze SSH logs
4. Implement solutions

## Tools and Resources

### Command Line Tools
- `ssh` - SSH client
- `sshd` - SSH daemon
- `ssh-keygen` - Key generation
- `ssh-copy-id` - Key distribution
- `ssh-agent` - Key management
- `scp` - Secure copy
- `sftp` - Secure file transfer
- `ssh-add` - Add keys to agent

### Analysis Tools
- `nmap` - Port scanning
- `telnet` - Connection testing
- `tcpdump` - Packet capture
- `wireshark` - Protocol analysis
- `ssh-audit` - Security auditing

### Configuration Files
- `~/.ssh/config` - Client configuration
- `~/.ssh/known_hosts` - Host keys
- `~/.ssh/authorized_keys` - Public keys
- `/etc/ssh/sshd_config` - Server configuration
- `/var/log/auth.log` - Authentication logs

## Advanced SSH Features

### SSH Multiplexing
```bash
# Master connection
ssh -M -S /tmp/ssh_master user@hostname

# Reuse connection
ssh -S /tmp/ssh_master user@hostname
```

### SSH Agent Forwarding
```bash
# Enable agent forwarding
ssh -A user@hostname

# Or in config
Host *
    ForwardAgent yes
```

### SSH Config Inheritance
```bash
Host *.example.com
    User admin
    Port 2222

Host server1.example.com
    HostName 192.168.1.100
    # Inherits User and Port from above
```

This comprehensive SSH module provides everything you need to understand, configure, troubleshoot, and secure SSH connections in your networking environment!
