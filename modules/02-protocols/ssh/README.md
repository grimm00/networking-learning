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

The SSH handshake is a complex multi-step process that establishes a secure, encrypted connection between client and server. Understanding this process is crucial for troubleshooting and security analysis.

### 1. TCP Connection Establishment
```bash
# SSH typically uses port 22
telnet example.com 22

# Check if SSH service is running
nmap -p 22 example.com
ss -tlnp | grep :22
```

**What happens:**
- Client initiates TCP connection to server port 22
- Three-way handshake (SYN, SYN-ACK, ACK)
- Connection established, ready for SSH protocol

### 2. Protocol Version Exchange
```
Client → Server: SSH-2.0-OpenSSH_8.9p1
Server → Client: SSH-2.0-OpenSSH_8.9p1
```

**Packet Analysis:**
```
0000   45 00 00 3c 12 34 40 00 40 06 7a 8b c0 a8 01 64
0010   c0 a8 01 01 00 16 00 16 12 34 56 78 90 ab cd ef
0020   50 18 20 00 00 00 00 00 53 53 48 2d 32 2e 30 2d
0030   4f 70 65 6e 53 53 48 5f 38 2e 39 70 31 0d 0a
```

**Key Points:**
- Both sides must support same SSH version
- Version string format: `SSH-<version>-<software>`
- Carriage return + line feed (`\r\n`) terminates version string
- If versions don't match, connection is terminated

### 3. Key Exchange (KEX) - The Heart of SSH Security

#### 3.1 Algorithm Negotiation
```
Client → Server: SSH_MSG_KEXINIT
Server → Client: SSH_MSG_KEXINIT
```

**Negotiated Algorithms:**
- **Key Exchange**: `diffie-hellman-group14-sha256`
- **Host Key**: `ssh-rsa`, `ecdsa-sha2-nistp256`, `ssh-ed25519`
- **Cipher**: `aes128-ctr`, `aes256-ctr`, `chacha20-poly1305@openssh.com`
- **MAC**: `hmac-sha2-256`, `hmac-sha2-512`
- **Compression**: `none`, `zlib@openssh.com`

#### 3.2 Diffie-Hellman Key Exchange
```
Client → Server: SSH_MSG_KEXDH_INIT (client's public key)
Server → Client: SSH_MSG_KEXDH_REPLY (server's public key + host key)
```

**Mathematical Process:**
1. **Client generates**: Private key `a`, Public key `A = g^a mod p`
2. **Server generates**: Private key `b`, Public key `B = g^b mod p`
3. **Shared secret**: `K = B^a mod p = A^b mod p`
4. **Session keys derived**: Encryption, MAC, and IV keys

#### 3.3 Host Key Verification
```
Server → Client: Host key fingerprint
Client: Verify against known_hosts or prompt user
```

**Host Key Types:**
- **RSA**: `ssh-rsa` (2048+ bits recommended)
- **ECDSA**: `ecdsa-sha2-nistp256/384/521`
- **Ed25519**: `ssh-ed25519` (recommended)

**Verification Methods:**
```bash
# Check host key fingerprint
ssh-keyscan -t rsa example.com
ssh-keygen -l -f ~/.ssh/known_hosts

# Verify specific host
ssh-keygen -l -f ~/.ssh/known_hosts -F example.com
```

### 4. Authentication Phase

#### 4.1 Service Request
```
Client → Server: SSH_MSG_SERVICE_REQUEST (ssh-userauth)
Server → Client: SSH_MSG_SERVICE_ACCEPT
```

#### 4.2 Authentication Methods

**Password Authentication:**
```
Client → Server: SSH_MSG_USERAUTH_REQUEST (password)
Server → Client: SSH_MSG_USERAUTH_SUCCESS/FAILURE
```

**Public Key Authentication:**
```
Client → Server: SSH_MSG_USERAUTH_REQUEST (publickey)
Server → Client: SSH_MSG_USERAUTH_PK_OK
Client → Server: SSH_MSG_USERAUTH_REQUEST (publickey + signature)
Server → Client: SSH_MSG_USERAUTH_SUCCESS/FAILURE
```

**Certificate Authentication:**
```
Client → Server: SSH_MSG_USERAUTH_REQUEST (certificate)
Server → Client: SSH_MSG_USERAUTH_SUCCESS/FAILURE
```

### 5. Service Request and Channel Management

#### 5.1 Service Request
```
Client → Server: SSH_MSG_SERVICE_REQUEST (ssh-connection)
Server → Client: SSH_MSG_SERVICE_ACCEPT
```

#### 5.2 Channel Opening
```
Client → Server: SSH_MSG_CHANNEL_OPEN (session)
Server → Client: SSH_MSG_CHANNEL_OPEN_CONFIRMATION
```

**Channel Types:**
- **Session**: Interactive shell, command execution
- **Direct TCP**: Port forwarding
- **Forwarded TCP**: Remote port forwarding
- **X11**: X11 forwarding

### 6. Detailed Handshake Timeline

```
Time    Client Action                    Server Action
----    -------------                    -------------
0ms     TCP SYN                          TCP SYN-ACK
1ms     TCP ACK                          TCP ACK
2ms     SSH-2.0-OpenSSH_8.9p1           SSH-2.0-OpenSSH_8.9p1
3ms     SSH_MSG_KEXINIT                  SSH_MSG_KEXINIT
4ms     SSH_MSG_KEXDH_INIT               SSH_MSG_KEXDH_REPLY
5ms     Host key verification            Wait for verification
6ms     SSH_MSG_SERVICE_REQUEST          SSH_MSG_SERVICE_ACCEPT
7ms     SSH_MSG_USERAUTH_REQUEST         SSH_MSG_USERAUTH_SUCCESS
8ms     SSH_MSG_SERVICE_REQUEST          SSH_MSG_SERVICE_ACCEPT
9ms     SSH_MSG_CHANNEL_OPEN             SSH_MSG_CHANNEL_OPEN_CONFIRMATION
10ms    Ready for data transfer          Ready for data transfer
```

### 7. Packet Capture Analysis

#### 7.1 Using tcpdump
```bash
# Capture SSH handshake
sudo tcpdump -i any -w ssh_handshake.pcap port 22

# Analyze with tshark
tshark -r ssh_handshake.pcap -Y "ssh"
```

#### 7.2 Using Wireshark
1. **Filter**: `ssh`
2. **Follow TCP Stream**: Right-click → Follow → TCP Stream
3. **SSH Protocol**: Analyze each message type
4. **Key Exchange**: Look for KEX messages
5. **Authentication**: Trace auth messages

#### 7.3 Common Handshake Issues

**Connection Timeout:**
- Check firewall rules
- Verify SSH service is running
- Test network connectivity

**Version Mismatch:**
- Client/server SSH versions incompatible
- Check supported protocols

**Key Exchange Failure:**
- No common algorithms
- Check cipher compatibility
- Verify system time synchronization

**Authentication Failure:**
- Wrong credentials
- Key not in authorized_keys
- Permission issues

### 8. Security Considerations

#### 8.1 Algorithm Strength
```bash
# Check supported algorithms
ssh -Q cipher        # Encryption algorithms
ssh -Q mac          # Message authentication codes
ssh -Q kex          # Key exchange algorithms
ssh -Q key          # Public key algorithms

# Test specific algorithms
ssh -c aes256-ctr user@hostname
ssh -m hmac-sha2-256 user@hostname
```

#### 8.2 Perfect Forward Secrecy
- Each session uses unique keys
- Compromised long-term keys don't affect past sessions
- Keys are derived from ephemeral Diffie-Hellman

#### 8.3 Replay Protection
- Sequence numbers prevent replay attacks
- MAC ensures message integrity
- Timestamps prevent old message replay

## SSH Protocol Deep Dive

Understanding the SSH protocol at the packet level is essential for advanced troubleshooting, security analysis, and performance optimization.

### SSH Packet Structure

#### Basic Packet Format
```
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Packet Length (4 bytes)                    |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
| Padding Length |                                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Payload Data (variable)                    |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Random Padding (variable)                  |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    MAC (variable)                             |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

**Field Descriptions:**
- **Packet Length**: Total packet size (excluding MAC)
- **Padding Length**: Length of random padding
- **Payload Data**: Actual SSH message content
- **Random Padding**: Random bytes for security
- **MAC**: Message Authentication Code

#### SSH Message Types

**Transport Layer Messages:**
- `SSH_MSG_DISCONNECT` (1): Connection termination
- `SSH_MSG_IGNORE` (2): Ignore message
- `SSH_MSG_UNIMPLEMENTED` (3): Unimplemented feature
- `SSH_MSG_DEBUG` (4): Debug information
- `SSH_MSG_SERVICE_REQUEST` (5): Service request
- `SSH_MSG_SERVICE_ACCEPT` (6): Service acceptance
- `SSH_MSG_KEXINIT` (20): Key exchange initialization
- `SSH_MSG_NEWKEYS` (21): New keys notification

**User Authentication Messages:**
- `SSH_MSG_USERAUTH_REQUEST` (50): Authentication request
- `SSH_MSG_USERAUTH_FAILURE` (51): Authentication failure
- `SSH_MSG_USERAUTH_SUCCESS` (52): Authentication success
- `SSH_MSG_USERAUTH_BANNER` (53): Authentication banner

**Connection Protocol Messages:**
- `SSH_MSG_GLOBAL_REQUEST` (80): Global request
- `SSH_MSG_REQUEST_SUCCESS` (81): Request success
- `SSH_MSG_REQUEST_FAILURE` (82): Request failure
- `SSH_MSG_CHANNEL_OPEN` (90): Channel open
- `SSH_MSG_CHANNEL_OPEN_CONFIRMATION` (91): Channel confirmation
- `SSH_MSG_CHANNEL_OPEN_FAILURE` (92): Channel failure
- `SSH_MSG_CHANNEL_WINDOW_ADJUST` (93): Window adjustment
- `SSH_MSG_CHANNEL_DATA` (94): Channel data
- `SSH_MSG_CHANNEL_EXTENDED_DATA` (95): Extended data
- `SSH_MSG_CHANNEL_EOF` (96): End of file
- `SSH_MSG_CHANNEL_CLOSE` (97): Channel close
- `SSH_MSG_CHANNEL_REQUEST` (98): Channel request
- `SSH_MSG_CHANNEL_SUCCESS` (99): Channel success
- `SSH_MSG_CHANNEL_FAILURE` (100): Channel failure

### Channel Management

#### Channel Lifecycle
```
Client                    Server
------                    ------
SSH_MSG_CHANNEL_OPEN  →   SSH_MSG_CHANNEL_OPEN_CONFIRMATION
SSH_MSG_CHANNEL_DATA  →   SSH_MSG_CHANNEL_DATA
SSH_MSG_CHANNEL_EOF   →   SSH_MSG_CHANNEL_EOF
SSH_MSG_CHANNEL_CLOSE →   SSH_MSG_CHANNEL_CLOSE
```

#### Channel Types and Usage

**Session Channel:**
- Interactive shell access
- Command execution
- Most common channel type

**Direct TCP Channel:**
- Local port forwarding
- Direct connection to remote service

**Forwarded TCP Channel:**
- Remote port forwarding
- Server forwards connection to client

**X11 Channel:**
- X11 forwarding
- GUI application forwarding

#### Flow Control and Windowing

**Window Size Management:**
```
Initial Window: 2^32 - 1 bytes (4GB)
Window Adjustment: SSH_MSG_CHANNEL_WINDOW_ADJUST
Data Flow: Only when window > 0
```

**Flow Control Example:**
```
Client Window: 65536 bytes
Data Sent: 32768 bytes
Remaining Window: 32768 bytes
When window < threshold: Send SSH_MSG_CHANNEL_WINDOW_ADJUST
```

### SSH Over Different Transports

#### SSH over TCP (Standard)
- **Port**: 22 (default)
- **Reliability**: TCP guarantees delivery
- **Ordering**: TCP ensures packet order
- **Congestion Control**: TCP handles congestion

#### SSH over UDP (Experimental)
- **Port**: 22 (same port)
- **Reliability**: Application-layer reliability
- **Ordering**: Application-layer ordering
- **Congestion Control**: Application-layer control

#### SSH over TLS (SSH over HTTPS)
- **Port**: 443 (HTTPS port)
- **Tunneling**: SSH tunneled through HTTPS
- **Firewall Bypass**: Appears as HTTPS traffic
- **Proxy Support**: Works through HTTP proxies

### Advanced SSH Features

#### SSH Multiplexing
```bash
# Master connection
ssh -M -S /tmp/ssh_master user@hostname

# Reuse connection
ssh -S /tmp/ssh_master user@hostname

# Check multiplexing status
ssh -O check -S /tmp/ssh_master user@hostname
```

**Benefits:**
- Faster connection establishment
- Reduced server load
- Shared authentication
- Connection pooling

#### SSH Agent Forwarding
```bash
# Enable agent forwarding
ssh -A user@hostname

# Or in config
Host *
    ForwardAgent yes
```

**Security Considerations:**
- Agent socket forwarded to remote host
- Remote host can use local keys
- Only forward to trusted hosts
- Use `-o ForwardAgent=no` for untrusted hosts

#### SSH Config Inheritance
```bash
# Global settings
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
    TCPKeepAlive yes

# Domain-specific settings
Host *.example.com
    User admin
    Port 2222
    IdentityFile ~/.ssh/id_rsa

# Host-specific settings
Host server1.example.com
    HostName 192.168.1.100
    LocalForward 8080 localhost:80
    # Inherits User, Port, IdentityFile from above
```

### Performance Analysis

#### Connection Timing
```bash
# Measure connection time
time ssh user@hostname 'echo "Connected"'

# Verbose timing
ssh -vvv user@hostname 2>&1 | grep -E "(time|ms|seconds)"
```

#### Bandwidth Testing
```bash
# Test upload speed
dd if=/dev/zero bs=1M count=100 | ssh user@hostname 'cat > /dev/null'

# Test download speed
ssh user@hostname 'dd if=/dev/zero bs=1M count=100' | cat > /dev/null
```

#### Latency Analysis
```bash
# Ping test
ping -c 10 hostname

# SSH connection time
for i in {1..10}; do
    time ssh -o ConnectTimeout=5 user@hostname 'echo "test"'
done
```

### Security Analysis

#### Algorithm Strength Testing
```bash
# Test cipher strength
ssh -c aes256-ctr user@hostname

# Test MAC strength
ssh -m hmac-sha2-256 user@hostname

# Test key exchange
ssh -o KexAlgorithms=diffie-hellman-group14-sha256 user@hostname
```

#### Vulnerability Assessment
```bash
# Check for weak algorithms
ssh -Q cipher | grep -E "(des|rc4|md5)"

# Test for protocol downgrade
ssh -o Protocol=1 user@hostname

# Check for weak keys
ssh-keygen -l -f ~/.ssh/known_hosts | grep -E "(1024|512)"
```

#### Log Analysis
```bash
# Monitor SSH connections
tail -f /var/log/auth.log | grep ssh

# Analyze failed connections
grep "Failed password" /var/log/auth.log | tail -20

# Check for brute force attacks
grep "Failed password" /var/log/auth.log | awk '{print $11}' | sort | uniq -c | sort -nr
```

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

## Real-World SSH Scenarios

Understanding SSH in production environments requires knowledge of complex network topologies, security requirements, and performance considerations.

### Enterprise SSH Architecture

#### Jump Hosts (Bastion Servers)
```bash
# Jump host configuration
Host jump-server
    HostName bastion.company.com
    User admin
    Port 2222
    IdentityFile ~/.ssh/jump_key

# Target server through jump host
Host internal-server
    HostName 10.0.1.100
    User admin
    ProxyJump jump-server
    IdentityFile ~/.ssh/internal_key
```

**Benefits:**
- Single point of access control
- Centralized logging and monitoring
- Reduced attack surface
- Simplified firewall rules

#### SSH Key Management
```bash
# Centralized key management
Host *.company.com
    User admin
    IdentityFile ~/.ssh/company_key
    CertificateFile ~/.ssh/company_key-cert.pub

# Personal keys for development
Host dev-*
    User developer
    IdentityFile ~/.ssh/dev_key
    ForwardAgent yes
```

### SSH in Container Environments

#### Docker SSH
```dockerfile
# Dockerfile with SSH
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:password' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
```

#### Kubernetes SSH
```yaml
# SSH service in Kubernetes
apiVersion: v1
kind: Service
metadata:
  name: ssh-service
spec:
  selector:
    app: ssh-server
  ports:
    - protocol: TCP
      port: 22
      targetPort: 22
  type: LoadBalancer
```

#### SSH in CI/CD Pipelines
```yaml
# GitHub Actions SSH example
- name: Deploy to server
  uses: appleboy/ssh-action@v0.1.5
  with:
    host: ${{ secrets.HOST }}
    username: ${{ secrets.USERNAME }}
    key: ${{ secrets.SSH_KEY }}
    script: |
      cd /var/www/app
      git pull origin main
      npm install
      npm run build
```

### SSH Performance Optimization

#### High-Latency Networks
```bash
# Optimize for high latency
Host high-latency
    HostName remote-server.com
    User admin
    ServerAliveInterval 30
    ServerAliveCountMax 3
    TCPKeepAlive yes
    Compression yes
    CompressionLevel 6
    ControlMaster auto
    ControlPath ~/.ssh/control-%h-%p-%r
    ControlPersist 10m
```

#### Bandwidth-Limited Connections
```bash
# Optimize for low bandwidth
Host low-bandwidth
    HostName remote-server.com
    User admin
    Compression yes
    CompressionLevel 9
    Cipher aes128-ctr
    MACs hmac-sha1
    ServerAliveInterval 60
    ServerAliveCountMax 2
```

#### Connection Multiplexing
```bash
# Master connection for multiple sessions
Host *
    ControlMaster auto
    ControlPath ~/.ssh/control-%h-%p-%r
    ControlPersist 10m
    ServerAliveInterval 30
    ServerAliveCountMax 3
```

### SSH Security Hardening

#### Server Hardening
```bash
# /etc/ssh/sshd_config
Port 2222
Protocol 2
PermitRootLogin no
MaxAuthTries 3
MaxSessions 10
ClientAliveInterval 300
ClientAliveCountMax 2
LoginGraceTime 60
AllowUsers admin developer
DenyUsers guest
PasswordAuthentication no
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
PermitEmptyPasswords no
X11Forwarding no
AllowTcpForwarding no
GatewayPorts no
PermitTunnel no
ChrootDirectory /home/%u
ForceCommand internal-sftp
```

#### Client Security
```bash
# ~/.ssh/config security settings
Host *
    StrictHostKeyChecking yes
    UserKnownHostsFile ~/.ssh/known_hosts
    VerifyHostKeyDNS yes
    VisualHostKey yes
    LogLevel VERBOSE
    IdentitiesOnly yes
    PasswordAuthentication no
    ChallengeResponseAuthentication no
    GSSAPIAuthentication no
    UseRoaming no
```

### SSH Monitoring and Alerting

#### Connection Monitoring
```bash
# Monitor SSH connections
#!/bin/bash
# ssh-monitor.sh
while true; do
    CONNECTIONS=$(ss -tn | grep :22 | wc -l)
    if [ $CONNECTIONS -gt 10 ]; then
        echo "High SSH connection count: $CONNECTIONS" | mail -s "SSH Alert" admin@company.com
    fi
    sleep 60
done
```

#### Failed Login Detection
```bash
# Detect brute force attacks
#!/bin/bash
# ssh-brute-force-detector.sh
tail -f /var/log/auth.log | grep "Failed password" | while read line; do
    IP=$(echo $line | awk '{print $11}')
    COUNT=$(grep "Failed password.*$IP" /var/log/auth.log | wc -l)
    if [ $COUNT -gt 5 ]; then
        echo "Brute force attack from $IP" | mail -s "SSH Attack" admin@company.com
        iptables -A INPUT -s $IP -j DROP
    fi
done
```

#### Performance Monitoring
```bash
# SSH performance monitoring
#!/bin/bash
# ssh-performance.sh
for host in server1 server2 server3; do
    START_TIME=$(date +%s%N)
    ssh $host 'echo "test"' > /dev/null 2>&1
    END_TIME=$(date +%s%N)
    DURATION=$((($END_TIME - $START_TIME) / 1000000))
    echo "$host: ${DURATION}ms"
done
```

### SSH Troubleshooting Scenarios

#### Scenario 1: Connection Timeout
**Problem**: SSH connection times out after 30 seconds
**Diagnosis**:
```bash
# Check network connectivity
ping -c 4 hostname
telnet hostname 22

# Check SSH service
systemctl status ssh
netstat -tlnp | grep :22

# Check firewall
iptables -L | grep 22
ufw status | grep 22
```

**Solutions**:
- Check firewall rules
- Verify SSH service is running
- Test network connectivity
- Check for port conflicts

#### Scenario 2: Authentication Failure
**Problem**: "Permission denied (publickey)" error
**Diagnosis**:
```bash
# Check key permissions
ls -la ~/.ssh/
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# Test with verbose output
ssh -vvv user@hostname

# Check server logs
tail -f /var/log/auth.log
```

**Solutions**:
- Fix key permissions
- Verify key is in authorized_keys
- Check server configuration
- Test with password authentication

#### Scenario 3: Slow Connection
**Problem**: SSH connection is very slow
**Diagnosis**:
```bash
# Test network latency
ping -c 10 hostname
traceroute hostname

# Test with different ciphers
ssh -c aes128-ctr user@hostname
ssh -c aes256-ctr user@hostname

# Check compression
ssh -C user@hostname
```

**Solutions**:
- Use faster cipher
- Enable compression
- Check network latency
- Optimize server configuration

#### Scenario 4: Port Forwarding Issues
**Problem**: Local port forwarding not working
**Diagnosis**:
```bash
# Check if port is in use
netstat -tlnp | grep :8080
lsof -i :8080

# Test with verbose output
ssh -vvv -L 8080:localhost:80 user@hostname

# Check server configuration
grep -i "allowtcpforwarding" /etc/ssh/sshd_config
```

**Solutions**:
- Check port availability
- Verify server allows port forwarding
- Test with different ports
- Check firewall rules

### SSH Automation and Scripting

#### Automated Key Distribution
```bash
#!/bin/bash
# distribute-keys.sh
for host in server1 server2 server3; do
    ssh-copy-id -i ~/.ssh/id_rsa.pub user@$host
done
```

#### Bulk Command Execution
```bash
#!/bin/bash
# bulk-command.sh
COMMAND="uptime"
for host in server1 server2 server3; do
    echo "=== $host ==="
    ssh user@$host "$COMMAND"
done
```

#### Configuration Synchronization
```bash
#!/bin/bash
# sync-config.sh
for host in server1 server2 server3; do
    scp /etc/nginx/nginx.conf user@$host:/tmp/
    ssh user@$host "sudo mv /tmp/nginx.conf /etc/nginx/ && sudo systemctl reload nginx"
done
```

## Lab Exercises

### Exercise 1: Basic SSH Setup and Analysis

#### Step 1: Generate SSH Key Pair
```bash
# Generate Ed25519 key (recommended)
ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/lab_key

# Generate RSA key (alternative)
ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f ~/.ssh/lab_rsa

# List generated keys
ls -la ~/.ssh/
```

#### Step 2: Configure SSH Client
```bash
# Create SSH config
cat > ~/.ssh/config << EOF
Host lab-server
    HostName localhost
    User root
    Port 22
    IdentityFile ~/.ssh/lab_key
    ServerAliveInterval 30
    ServerAliveCountMax 3
    LogLevel VERBOSE
EOF
```

#### Step 3: Test Connection with Verbose Output
```bash
# Test connection with maximum verbosity
ssh -vvv lab-server

# Expected output analysis:
# - Version exchange
# - Key exchange process
# - Authentication method
# - Channel establishment
```

#### Step 4: Analyze Connection Process
```bash
# Capture SSH handshake
sudo tcpdump -i any -w ssh_handshake.pcap port 22

# In another terminal, connect
ssh lab-server

# Analyze with tshark
tshark -r ssh_handshake.pcap -Y "ssh"
```

**Learning Outcomes:**
- Understand SSH key generation
- Learn client configuration
- Analyze handshake process
- Practice packet capture

### Exercise 2: Security Analysis and Hardening

#### Step 1: Scan SSH Service for Vulnerabilities
```bash
# Use nmap to scan SSH service
nmap -sV -p 22 localhost

# Check for weak ciphers
nmap --script ssh2-enum-algos -p 22 localhost

# Test for common vulnerabilities
nmap --script ssh-hostkey -p 22 localhost
```

#### Step 2: Test Different Authentication Methods
```bash
# Test password authentication
ssh -o PreferredAuthentications=password lab-server

# Test public key authentication
ssh -o PreferredAuthentications=publickey lab-server

# Test certificate authentication (if configured)
ssh -o PreferredAuthentications=certificate lab-server
```

#### Step 3: Analyze Encryption Algorithms
```bash
# Check supported ciphers
ssh -Q cipher

# Test specific cipher
ssh -c aes256-ctr lab-server

# Check MAC algorithms
ssh -Q mac

# Test specific MAC
ssh -m hmac-sha2-256 lab-server
```

#### Step 4: Check Host Key Verification
```bash
# Check known hosts
ssh-keygen -l -f ~/.ssh/known_hosts

# Verify specific host
ssh-keygen -l -f ~/.ssh/known_hosts -F localhost

# Test host key verification
ssh -o StrictHostKeyChecking=ask lab-server
```

**Learning Outcomes:**
- Learn security scanning techniques
- Understand authentication methods
- Analyze encryption strength
- Practice host key verification

### Exercise 3: Port Forwarding and Tunneling

#### Step 1: Set Up Local Port Forwarding
```bash
# Forward local port 8080 to remote port 80
ssh -L 8080:localhost:80 lab-server

# Test the tunnel
curl http://localhost:8080

# Check active tunnels
netstat -tlnp | grep :8080
```

#### Step 2: Test Remote Port Forwarding
```bash
# Forward remote port 8080 to local port 80
ssh -R 8080:localhost:80 lab-server

# On remote server, test
curl http://localhost:8080
```

#### Step 3: Configure Dynamic Port Forwarding
```bash
# Set up SOCKS proxy
ssh -D 1080 lab-server

# Configure browser to use SOCKS proxy
# Test web browsing through tunnel
curl --socks5 localhost:1080 http://example.com
```

#### Step 4: Verify Tunnel Functionality
```bash
# Check tunnel status
ss -tlnp | grep :8080
ss -tlnp | grep :1080

# Test tunnel performance
time curl http://localhost:8080
time curl --socks5 localhost:1080 http://example.com
```

**Learning Outcomes:**
- Master port forwarding techniques
- Understand tunneling concepts
- Practice SOCKS proxy setup
- Learn tunnel troubleshooting

### Exercise 4: Advanced Troubleshooting

#### Step 1: Simulate Common SSH Issues
```bash
# Simulate connection timeout
ssh -o ConnectTimeout=1 lab-server

# Simulate authentication failure
ssh -o PreferredAuthentications=none lab-server

# Simulate host key verification failure
ssh -o StrictHostKeyChecking=yes nonexistent-host
```

#### Step 2: Use Debugging Techniques
```bash
# Enable maximum verbosity
ssh -vvv lab-server 2>&1 | tee ssh_debug.log

# Analyze debug output
grep -E "(debug|error|failed)" ssh_debug.log

# Check system logs
sudo tail -f /var/log/auth.log | grep ssh
```

#### Step 3: Analyze SSH Logs
```bash
# Check SSH daemon logs
sudo journalctl -u ssh -f

# Analyze failed connections
grep "Failed password" /var/log/auth.log | tail -20

# Check for brute force attacks
grep "Failed password" /var/log/auth.log | awk '{print $11}' | sort | uniq -c | sort -nr
```

#### Step 4: Implement Solutions
```bash
# Fix key permissions
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# Update known hosts
ssh-keygen -R localhost

# Test connection after fixes
ssh lab-server
```

**Learning Outcomes:**
- Practice troubleshooting techniques
- Learn log analysis
- Understand common issues
- Implement solutions

### Exercise 5: Performance Optimization

#### Step 1: Measure Baseline Performance
```bash
# Measure connection time
time ssh lab-server 'echo "test"'

# Measure bandwidth
dd if=/dev/zero bs=1M count=100 | ssh lab-server 'cat > /dev/null'

# Measure latency
ping -c 10 localhost
```

#### Step 2: Test Different Ciphers
```bash
# Test fast cipher
time ssh -c aes128-ctr lab-server 'echo "test"'

# Test secure cipher
time ssh -c aes256-ctr lab-server 'echo "test"'

# Compare performance
for cipher in aes128-ctr aes256-ctr chacha20-poly1305@openssh.com; do
    echo "Testing $cipher"
    time ssh -c $cipher lab-server 'echo "test"'
done
```

#### Step 3: Test Compression
```bash
# Test without compression
time ssh -o Compression=no lab-server 'dd if=/dev/zero bs=1M count=10'

# Test with compression
time ssh -o Compression=yes lab-server 'dd if=/dev/zero bs=1M count=10'

# Test different compression levels
for level in 1 6 9; do
    echo "Testing compression level $level"
    time ssh -o Compression=yes -o CompressionLevel=$level lab-server 'dd if=/dev/zero bs=1M count=10'
done
```

#### Step 4: Optimize Configuration
```bash
# Create optimized config
cat > ~/.ssh/config << EOF
Host lab-server
    HostName localhost
    User root
    Port 22
    IdentityFile ~/.ssh/lab_key
    Compression yes
    CompressionLevel 6
    Cipher aes128-ctr
    MACs hmac-sha1
    ServerAliveInterval 30
    ServerAliveCountMax 3
    ControlMaster auto
    ControlPath ~/.ssh/control-%h-%p-%r
    ControlPersist 10m
EOF

# Test optimized connection
time ssh lab-server 'echo "test"'
```

**Learning Outcomes:**
- Learn performance measurement
- Understand cipher impact
- Practice compression tuning
- Master configuration optimization

### Exercise 6: Security Hardening

#### Step 1: Server Hardening
```bash
# Backup original config
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Apply security hardening
sudo tee -a /etc/ssh/sshd_config << EOF
# Security hardening
PermitRootLogin no
MaxAuthTries 3
MaxSessions 10
ClientAliveInterval 300
ClientAliveCountMax 2
LoginGraceTime 60
PasswordAuthentication no
PubkeyAuthentication yes
PermitEmptyPasswords no
X11Forwarding no
AllowTcpForwarding no
GatewayPorts no
PermitTunnel no
EOF

# Restart SSH service
sudo systemctl restart ssh
```

#### Step 2: Client Hardening
```bash
# Create secure client config
cat > ~/.ssh/config << EOF
Host *
    StrictHostKeyChecking yes
    UserKnownHostsFile ~/.ssh/known_hosts
    VerifyHostKeyDNS yes
    VisualHostKey yes
    LogLevel VERBOSE
    IdentitiesOnly yes
    PasswordAuthentication no
    ChallengeResponseAuthentication no
    GSSAPIAuthentication no
    UseRoaming no
EOF
```

#### Step 3: Test Security Configuration
```bash
# Test hardened connection
ssh lab-server

# Verify security settings
ssh -o PreferredAuthentications=password lab-server  # Should fail
ssh -o PreferredAuthentications=publickey lab-server  # Should succeed
```

#### Step 4: Monitor Security
```bash
# Monitor failed attempts
sudo tail -f /var/log/auth.log | grep "Failed password"

# Check for suspicious activity
grep "Failed password" /var/log/auth.log | awk '{print $11}' | sort | uniq -c | sort -nr

# Monitor successful connections
grep "Accepted" /var/log/auth.log | tail -10
```

**Learning Outcomes:**
- Learn server hardening
- Understand client security
- Practice security testing
- Master security monitoring

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

## Quick Reference

### SSH Command Cheat Sheet

#### Basic Commands
```bash
# Connect to server
ssh user@hostname

# Connect with specific port
ssh -p 2222 user@hostname

# Connect with specific key
ssh -i ~/.ssh/key user@hostname

# Connect with verbose output
ssh -v user@hostname    # Verbose
ssh -vv user@hostname   # More verbose
ssh -vvv user@hostname  # Maximum verbosity
```

#### Port Forwarding
```bash
# Local port forwarding
ssh -L 8080:localhost:80 user@hostname

# Remote port forwarding
ssh -R 8080:localhost:80 user@hostname

# Dynamic port forwarding (SOCKS proxy)
ssh -D 1080 user@hostname

# Background port forwarding
ssh -f -N -L 8080:localhost:80 user@hostname
```

#### File Transfer
```bash
# Copy file to server
scp file.txt user@hostname:/path/

# Copy file from server
scp user@hostname:/path/file.txt ./

# Copy directory
scp -r directory/ user@hostname:/path/

# SFTP interactive
sftp user@hostname

# rsync over SSH
rsync -avz -e ssh /local/path/ user@hostname:/remote/path/
```

#### Key Management
```bash
# Generate key
ssh-keygen -t ed25519 -C "email@example.com"

# Copy key to server
ssh-copy-id user@hostname

# Add key to agent
ssh-add ~/.ssh/id_rsa

# List keys in agent
ssh-add -l

# Remove key from agent
ssh-add -d ~/.ssh/id_rsa
```

### Common SSH Configuration

#### Client Config (~/.ssh/config)
```bash
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
    TCPKeepAlive yes
    Compression yes
    ControlMaster auto
    ControlPath ~/.ssh/control-%h-%p-%r
    ControlPersist 10m

Host myserver
    HostName 192.168.1.100
    User admin
    Port 2222
    IdentityFile ~/.ssh/myserver_key
    LocalForward 8080 localhost:80
```

#### Server Config (/etc/ssh/sshd_config)
```bash
Port 22
Protocol 2
PermitRootLogin no
MaxAuthTries 3
MaxSessions 10
ClientAliveInterval 300
ClientAliveCountMax 2
PasswordAuthentication no
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
```

### Troubleshooting Quick Fixes

#### Connection Issues
```bash
# Test connectivity
ping hostname
telnet hostname 22

# Check SSH service
systemctl status ssh
systemctl start ssh

# Check firewall
iptables -L | grep 22
ufw status | grep 22
```

#### Authentication Issues
```bash
# Fix key permissions
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
chmod 700 ~/.ssh

# Test with verbose output
ssh -vvv user@hostname

# Check server logs
tail -f /var/log/auth.log
```

#### Host Key Issues
```bash
# Remove host from known_hosts
ssh-keygen -R hostname

# Check host key fingerprint
ssh-keyscan -t rsa hostname

# Accept new host key
ssh -o StrictHostKeyChecking=no user@hostname
```

### Security Checklist

#### Server Security
- [ ] Change default port (22 → 2222)
- [ ] Disable root login
- [ ] Disable password authentication
- [ ] Enable public key authentication
- [ ] Set up fail2ban
- [ ] Regular security updates
- [ ] Monitor logs for attacks

#### Client Security
- [ ] Use strong keys (Ed25519 or RSA 4096+)
- [ ] Enable host key verification
- [ ] Use SSH agent
- [ ] Regular key rotation
- [ ] Secure key storage
- [ ] Monitor connection logs

### Performance Optimization

#### High Latency Networks
```bash
Host high-latency
    ServerAliveInterval 30
    ServerAliveCountMax 3
    TCPKeepAlive yes
    Compression yes
    CompressionLevel 6
    ControlMaster auto
    ControlPath ~/.ssh/control-%h-%p-%r
    ControlPersist 10m
```

#### Low Bandwidth Networks
```bash
Host low-bandwidth
    Compression yes
    CompressionLevel 9
    Cipher aes128-ctr
    MACs hmac-sha1
    ServerAliveInterval 60
    ServerAliveCountMax 2
```

### Useful One-Liners

```bash
# Test SSH connection
ssh -o ConnectTimeout=5 user@hostname 'echo "Connected"'

# Check SSH version
ssh -V

# List supported algorithms
ssh -Q cipher
ssh -Q mac
ssh -Q kex
ssh -Q key

# Test specific cipher
ssh -c aes256-ctr user@hostname

# Monitor SSH connections
ss -tlnp | grep :22

# Check active tunnels
netstat -tlnp | grep :8080

# Kill SSH connection
ssh -O exit user@hostname
```

This comprehensive SSH module provides everything you need to understand, configure, troubleshoot, and secure SSH connections in your networking environment!
