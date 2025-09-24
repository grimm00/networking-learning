# Nmap Quick Reference Guide

Quick reference for common nmap commands and techniques.

## 🎯 Basic Commands

### Host Discovery
```bash
# Ping scan (host discovery only)
nmap -sn 192.168.1.0/24

# ARP ping scan (local networks)
nmap -PR 192.168.1.0/24

# TCP SYN ping
nmap -PS 192.168.1.0/24

# UDP ping
nmap -PU 192.168.1.0/24

# ICMP ping
nmap -PE 192.168.1.0/24
```

### Port Scanning
```bash
# TCP SYN scan (default)
nmap -sS 192.168.1.1

# TCP connect scan
nmap -sT 192.168.1.1

# UDP scan
nmap -sU 192.168.1.1

# Scan specific ports
nmap -p 22,80,443 192.168.1.1

# Scan port ranges
nmap -p 1-1000 192.168.1.1

# Scan top ports
nmap --top-ports 1000 192.168.1.1
```

### Service Detection
```bash
# Service detection
nmap -sV 192.168.1.1

# Aggressive scan (service + OS detection)
nmap -A 192.168.1.1

# Version detection with intensity
nmap -sV --version-intensity 9 192.168.1.1
```

### OS Detection
```bash
# OS detection
nmap -O 192.168.1.1

# OS detection with guessing
nmap -O --osscan-guess 192.168.1.1
```

## 🔧 NSE Scripts

### Script Categories
```bash
# Safe scripts
nmap --script safe 192.168.1.1

# Discovery scripts
nmap --script discovery 192.168.1.1

# Vulnerability scripts
nmap --script vuln 192.168.1.1

# Authentication scripts
nmap --script auth 192.168.1.1

# Brute force scripts
nmap --script brute 192.168.1.1
```

### Common Scripts
```bash
# SSL/TLS enumeration
nmap --script ssl-enum-ciphers -p 443 192.168.1.1

# HTTP enumeration
nmap --script http-enum 192.168.1.1

# SMB enumeration
nmap --script smb-enum-shares 192.168.1.1

# DNS enumeration
nmap --script dns-brute 192.168.1.1

# MySQL enumeration
nmap --script mysql-enum 192.168.1.1
```

## ⚡ Timing and Performance

### Timing Templates
```bash
# Timing templates (T0 = slowest, T5 = fastest)
nmap -T0 192.168.1.1  # Paranoid
nmap -T1 192.168.1.1  # Sneaky
nmap -T2 192.168.1.1  # Polite
nmap -T3 192.168.1.1  # Normal (default)
nmap -T4 192.168.1.1  # Aggressive
nmap -T5 192.168.1.1  # Insane
```

### Performance Options
```bash
# Reduce retries
nmap --max-retries 1 192.168.1.1

# Set scan delay
nmap --scan-delay 100ms 192.168.1.1

# Parallel host scanning
nmap --min-parallelism 10 192.168.1.0/24
```

## 🛡️ Stealth and Evasion

### Packet Fragmentation
```bash
# Fragment packets
nmap -f 192.168.1.1

# Fragment with specific size
nmap -f --mtu 8 192.168.1.1
```

### Decoy Scans
```bash
# Use decoy IPs
nmap -D decoy1,decoy2,ME 192.168.1.1

# Randomize decoy order
nmap -D RND:10 192.168.1.1
```

### Source Spoofing
```bash
# Spoof source IP
nmap -S 192.168.1.100 192.168.1.1

# Use different source port
nmap --source-port 53 192.168.1.1
```

### Firewall Evasion
```bash
# TCP ACK scan
nmap -sA 192.168.1.1

# TCP FIN scan
nmap -sF 192.168.1.1

# TCP NULL scan
nmap -sN 192.168.1.1

# TCP XMAS scan
nmap -sX 192.168.1.1
```

## 📊 Output Formats

### Output Options
```bash
# Normal output
nmap 192.168.1.1

# Verbose output
nmap -v 192.168.1.1

# Extra verbose
nmap -vv 192.168.1.1

# Quiet mode
nmap -q 192.168.1.1
```

### File Output
```bash
# Normal output to file
nmap -oN results.txt 192.168.1.1

# XML output
nmap -oX results.xml 192.168.1.1

# Grepable output
nmap -oG results.grep 192.168.1.1

# All formats
nmap -oA results 192.168.1.1
```

## 🎯 Common Scan Patterns

### Quick Network Scan
```bash
# Discover hosts and scan top ports
nmap -sn --top-ports 1000 192.168.1.0/24
```

### Web Server Scan
```bash
# Scan common web ports
nmap -p 80,443,8080,8443 -sV 192.168.1.1

# HTTP enumeration
nmap --script http-enum,http-headers 192.168.1.1
```

### Database Scan
```bash
# MySQL scan
nmap -p 3306 --script mysql-enum 192.168.1.1

# PostgreSQL scan
nmap -p 5432 --script pgsql-brute 192.168.1.1
```

### Security Scan
```bash
# Vulnerability scan
nmap --script vuln 192.168.1.1

# SSL/TLS scan
nmap --script ssl-* -p 443 192.168.1.1
```

## 🔍 Port States

| State | Description |
|-------|-------------|
| `open` | Port is open and accepting connections |
| `closed` | Port is closed (not listening) |
| `filtered` | Port is filtered by firewall |
| `unfiltered` | Port is accessible but state unknown |
| `open\|filtered` | Port is open or filtered |
| `closed\|filtered` | Port is closed or filtered |

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

### File Transfer
- **21**: FTP
- **22**: SSH/SFTP
- **23**: Telnet

### Database Services
- **3306**: MySQL
- **5432**: PostgreSQL
- **1433**: Microsoft SQL Server
- **1521**: Oracle

### Network Services
- **53**: DNS
- **67/68**: DHCP
- **123**: NTP
- **161**: SNMP

## 🚨 Security Considerations

### Legal Use
- ✅ Scan your own networks
- ✅ Authorized penetration testing
- ✅ Security assessment with permission
- ❌ Scan networks without permission
- ❌ Attempt unauthorized access

### Best Practices
- Always get permission before scanning
- Use appropriate timing (avoid business hours)
- Document all authorized scans
- Respect rate limits
- Follow responsible disclosure

## 🛠️ Troubleshooting

### Permission Issues
```bash
# Use TCP connect scan instead of SYN
nmap -sT 192.168.1.1

# Run with sudo for raw sockets
sudo nmap -sS 192.168.1.1
```

### Slow Scans
```bash
# Increase timing template
nmap -T4 192.168.1.1

# Reduce retries
nmap --max-retries 1 192.168.1.1

# Limit ports
nmap --top-ports 1000 192.168.1.1
```

### Firewall Blocking
```bash
# Use different scan types
nmap -sA 192.168.1.1  # ACK scan
nmap -sF 192.168.1.1  # FIN scan

# Fragment packets
nmap -f 192.168.1.1

# Use decoys
nmap -D decoy1,decoy2,ME 192.168.1.1
```

## 📚 Useful Resources

- [Nmap Official Documentation](https://nmap.org/book/)
- [NSE Script Reference](https://nmap.org/nsedoc/)
- [Nmap Network Scanning Book](https://nmap.org/book/)
- [Nmap Online Scanner](https://nmap.online/)

---

**Remember**: Always use nmap responsibly and only on networks you own or have explicit permission to scan!
