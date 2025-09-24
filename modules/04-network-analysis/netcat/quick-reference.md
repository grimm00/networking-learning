# Netcat Quick Reference Guide

Quick reference for common netcat commands and techniques.

## 🎯 Basic Commands

### Connectivity Testing
```bash
# Test if port is open
nc -v -z hostname port

# Test multiple ports
nc -v -z hostname 80 443 22

# Test port range
nc -v -z hostname 80-90

# Test UDP port
nc -u -v -z hostname 53
```

### Interactive Connection
```bash
# Connect to service
nc hostname port

# Connect with verbose output
nc -v hostname port

# Connect with timeout
nc -w 5 hostname port
```

### File Transfer
```bash
# Send file
nc -l -p 1234 < file.txt
nc hostname 1234 > file.txt

# Receive file
nc -l -p 1234 > file.txt
nc hostname 1234 < file.txt
```

## 🔧 Common Options

### Basic Options
- `-v` - Verbose output
- `-z` - Zero I/O mode (scanning)
- `-u` - UDP mode
- `-w timeout` - Timeout in seconds
- `-l` - Listen mode
- `-p port` - Specify local port
- `-s addr` - Specify source address

### Advanced Options
- `-k` - Keep listening after disconnect
- `-n` - Don't resolve hostnames
- `-r` - Randomize ports
- `-i interval` - Delay between connections
- `-C` - Send CRLF as line ending
- `-t` - Answer TELNET negotiation

## 🌐 Port Scanning

### Basic Port Scan
```bash
# Scan single port
nc -v -z hostname 80

# Scan multiple ports
nc -v -z hostname 22 80 443

# Scan port range
nc -v -z hostname 80-90

# Scan UDP ports
nc -u -v -z hostname 53 67 123
```

### Advanced Scanning
```bash
# Scan with timeout
nc -w 1 -v -z hostname 80-90

# Scan from specific source port
nc -p 1234 -v -z hostname 80

# Scan with delay
nc -i 1 -v -z hostname 80-90
```

## 🔗 Service Testing

### HTTP Testing
```bash
# Test HTTP connection
nc hostname 80

# Send HTTP request
echo -e "GET / HTTP/1.1\r\nHost: hostname\r\n\r\n" | nc hostname 80

# Test HTTPS (basic)
nc hostname 443
```

### SMTP Testing
```bash
# Test SMTP connection
nc hostname 25

# Send SMTP commands
echo -e "EHLO test.com\r\nQUIT\r\n" | nc hostname 25
```

### SSH Testing
```bash
# Test SSH connection
nc hostname 22

# Test SSH with timeout
nc -w 5 hostname 22
```

## 📁 File Transfer

### Basic File Transfer
```bash
# Send file (receiver)
nc -l -p 1234 > received_file.txt

# Send file (sender)
nc hostname 1234 < file_to_send.txt
```

### Advanced File Transfer
```bash
# Send with verbose output
nc -v -l -p 1234 > received_file.txt
nc -v hostname 1234 < file_to_send.txt

# Send with timeout
nc -w 10 hostname 1234 < file_to_send.txt
```

### Directory Transfer
```bash
# Send directory
tar -czf - directory/ | nc -l -p 1234
nc hostname 1234 | tar -xzf -

# Send with compression
gzip -c file.txt | nc -l -p 1234
nc hostname 1234 | gunzip -c > file.txt
```

## 💬 Chat and Communication

### Simple Chat
```bash
# Start chat server
nc -l -p 1234

# Connect to chat
nc hostname 1234
```

### Persistent Chat Server
```bash
# Keep server running
nc -k -l -p 1234

# Connect multiple times
nc hostname 1234
```

### UDP Chat
```bash
# UDP chat server
nc -u -l -p 1234

# UDP chat client
nc -u hostname 1234
```

## 🔧 Server Mode

### Basic Server
```bash
# Listen on port
nc -l -p 1234

# Listen with verbose output
nc -v -l -p 1234

# Listen on specific interface
nc -l -p 1234 -s 192.168.1.100
```

### Advanced Server
```bash
# Keep server running
nc -k -l -p 1234

# Server with timeout
nc -w 30 -l -p 1234

# Server with specific protocol
nc -u -l -p 1234
```

## 🛠️ Network Debugging

### Connection Testing
```bash
# Test with timeout
nc -w 5 hostname port

# Test with verbose output
nc -v hostname port

# Test from specific source port
nc -p 1234 hostname port
```

### Protocol Testing
```bash
# Test HTTP
echo -e "GET / HTTP/1.1\r\nHost: hostname\r\n\r\n" | nc hostname 80

# Test SMTP
echo -e "EHLO test.com\r\nQUIT\r\n" | nc hostname 25

# Test FTP
echo -e "USER anonymous\r\nQUIT\r\n" | nc hostname 21
```

### Port Forwarding
```bash
# Simple port forward
nc -l -p 8080 -c "nc hostname 80"

# UDP port forward
nc -u -l -p 8080 -c "nc -u hostname 80"
```

## 🔍 Common Use Cases

### Quick Port Check
```bash
# Check if web server is running
nc -v -z hostname 80

# Check if SSH is available
nc -v -z hostname 22

# Check if database is running
nc -v -z hostname 3306
```

### Service Interaction
```bash
# Interact with HTTP server
nc hostname 80
# Type: GET / HTTP/1.1
#       Host: hostname
#       (blank line)

# Interact with SMTP server
nc hostname 25
# Type: EHLO test.com
#       QUIT
```

### File Sharing
```bash
# Share a file quickly
nc -l -p 1234 < important_file.txt

# Download from another machine
nc hostname 1234 > downloaded_file.txt
```

### Network Troubleshooting
```bash
# Test if port is reachable
nc -v -z hostname port

# Test with different timeout
nc -w 1 -v -z hostname port

# Test UDP connectivity
nc -u -v -z hostname port
```

## 🚨 Security Considerations

### Safe Usage
- Only use on networks you own or have permission to test
- Be careful with file transfers (no encryption)
- Don't use for sensitive data without additional security
- Use in controlled environments for learning

### Common Security Uses
- Port scanning for security assessment
- Testing firewall rules
- Network connectivity troubleshooting
- Service availability testing

## 📋 Common Ports

### Web Services
- **80**: HTTP
- **443**: HTTPS
- **8080**: HTTP (alternative)
- **8443**: HTTPS (alternative)

### Email Services
- **25**: SMTP
- **110**: POP3
- **143**: IMAP
- **993**: IMAPS
- **995**: POP3S

### System Services
- **22**: SSH
- **23**: Telnet
- **53**: DNS
- **67/68**: DHCP
- **123**: NTP

### Database Services
- **3306**: MySQL
- **5432**: PostgreSQL
- **1433**: Microsoft SQL Server
- **1521**: Oracle

## 🛠️ Troubleshooting

### Connection Issues
```bash
# Check if service is running
nc -v -z hostname port

# Try with timeout
nc -w 5 hostname port

# Check UDP
nc -u -v -z hostname port
```

### File Transfer Issues
```bash
# Check if receiver is running
nc -v -z hostname port

# Try with verbose output
nc -v hostname port < file.txt

# Check file permissions
ls -la file.txt
```

### Server Issues
```bash
# Check if port is in use
netstat -tulpn | grep port

# Try different port
nc -l -p 1235

# Check firewall
iptables -L
```

---

**Remember**: Always use netcat responsibly and only on networks you own or have explicit permission to test!
