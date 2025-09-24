# Nmap Network Scanner Module

Network Mapper (nmap) is a powerful network discovery and security auditing tool. This module covers comprehensive nmap usage, from basic network discovery to advanced security scanning techniques.

## 📚 Learning Objectives

By the end of this module, you will understand:
- Basic nmap syntax and common scan types
- Host discovery and port scanning techniques
- Service detection and version enumeration
- OS detection and fingerprinting
- NSE (Nmap Scripting Engine) usage
- Advanced scanning techniques and evasion
- Output formats and result interpretation
- Security implications and ethical considerations

## 🔍 Nmap Fundamentals

### What is Nmap?
Nmap (Network Mapper) is a free and open-source network scanner used to:
- Discover hosts and services on a computer network
- Identify open ports and running services
- Detect operating systems and service versions
- Perform security vulnerability assessments
- Map network topology and architecture

### Installation and Basic Usage

```bash
# Check if nmap is installed
nmap --version

# Basic syntax
nmap [scan type] [options] <target>

# Simple host discovery
nmap -sn 192.168.1.0/24

# Basic port scan
nmap 192.168.1.1
```

## 🎯 Scan Types and Techniques

### 1. Host Discovery Scans

**Purpose**: Determine which hosts are alive on a network

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

**Educational Context**: Host discovery is the first step in network reconnaissance. It helps identify active devices without performing port scans, making it faster and less intrusive.

### 2. Port Scanning Techniques

**TCP SYN Scan (Default)**
```bash
# SYN scan (stealthy, fast)
nmap -sS 192.168.1.1

# Scan specific ports
nmap -p 22,80,443 192.168.1.1

# Scan port ranges
nmap -p 1-1000 192.168.1.1

# Scan top ports
nmap --top-ports 1000 192.168.1.1
```

**TCP Connect Scan**
```bash
# Connect scan (complete TCP handshake)
nmap -sT 192.168.1.1
```

**UDP Scan**
```bash
# UDP scan (slower, but necessary for UDP services)
nmap -sU 192.168.1.1

# UDP scan on specific ports
nmap -sU -p 53,67,123,161 192.168.1.1
```

**Educational Context**: Different scan types have different characteristics:
- **SYN scan**: Fast, stealthy, doesn't complete TCP handshake
- **Connect scan**: Slower, completes full handshake, more detectable
- **UDP scan**: Necessary for UDP services, slower than TCP scans

### 3. Service Detection and Version Enumeration

```bash
# Service detection
nmap -sV 192.168.1.1

# Aggressive service detection
nmap -A 192.168.1.1

# Version detection with intensity
nmap -sV --version-intensity 9 192.168.1.1

# Light version detection
nmap -sV --version-intensity 0 192.168.1.1
```

**Educational Context**: Service detection helps identify what applications are running on open ports, which is crucial for security assessment and network documentation.

### 4. OS Detection and Fingerprinting

```bash
# OS detection
nmap -O 192.168.1.1

# Aggressive OS detection
nmap -A 192.168.1.1

# OS detection with verbose output
nmap -O -v 192.168.1.1
```

**Educational Context**: OS detection uses TCP/IP stack fingerprinting to identify the operating system of target hosts. This information is valuable for targeted attacks and security hardening.

## 🔧 NSE (Nmap Scripting Engine)

The NSE allows users to write scripts to automate a wide variety of networking tasks.

### Script Categories

```bash
# List all available scripts
nmap --script-help all

# Run scripts by category
nmap --script vuln 192.168.1.1
nmap --script safe 192.168.1.1
nmap --script auth 192.168.1.1
nmap --script discovery 192.168.1.1
```

### Common Script Examples

```bash
# SSL/TLS enumeration
nmap --script ssl-enum-ciphers -p 443 192.168.1.1

# HTTP enumeration
nmap --script http-enum 192.168.1.1

# SMB enumeration
nmap --script smb-enum-shares 192.168.1.1

# DNS enumeration
nmap --script dns-brute 192.168.1.1

# Vulnerability scanning
nmap --script vuln 192.168.1.1
```

**Educational Context**: NSE scripts extend nmap's functionality significantly. They can perform complex tasks like vulnerability detection, service enumeration, and protocol-specific attacks.

## 📊 Output Formats and Options

### Output Formats

```bash
# Normal output (default)
nmap 192.168.1.1

# Verbose output
nmap -v 192.168.1.1

# Extra verbose
nmap -vv 192.168.1.1

# Save to file
nmap -oN scan_results.txt 192.168.1.1

# XML output
nmap -oX scan_results.xml 192.168.1.1

# Grepable output
nmap -oG scan_results.grep 192.168.1.1

# All formats
nmap -oA scan_results 192.168.1.1
```

### Timing and Performance

```bash
# Timing templates
nmap -T0 192.168.1.1  # Paranoid (slowest)
nmap -T1 192.168.1.1  # Sneaky
nmap -T2 192.168.1.1  # Polite
nmap -T3 192.168.1.1  # Normal (default)
nmap -T4 192.168.1.1  # Aggressive
nmap -T5 192.168.1.1  # Insane (fastest)

# Custom timing
nmap --max-retries 1 --scan-delay 100ms 192.168.1.1
```

**Educational Context**: Timing controls help balance speed vs. stealth. Faster scans are more detectable but complete quicker, while slower scans are stealthier but take longer.

## 🛡️ Advanced Scanning Techniques

### Stealth and Evasion

```bash
# Fragment packets
nmap -f 192.168.1.1

# Use decoy IPs
nmap -D decoy1,decoy2,ME 192.168.1.1

# Spoof source IP
nmap -S 192.168.1.100 192.168.1.1

# Randomize target order
nmap --randomize-hosts 192.168.1.0/24

# Slow scan
nmap --scan-delay 1s 192.168.1.1
```

### Firewall and IDS Evasion

```bash
# Use different source ports
nmap --source-port 53 192.168.1.1

# TCP ACK scan (bypass stateful firewalls)
nmap -sA 192.168.1.1

# TCP FIN scan
nmap -sF 192.168.1.1

# TCP NULL scan
nmap -sN 192.168.1.1

# TCP XMAS scan
nmap -sX 192.168.1.1
```

**Educational Context**: Evasion techniques help bypass firewalls and intrusion detection systems. These techniques are important for penetration testing and security assessment.

## 🔍 Practical Scanning Scenarios

### 1. Network Discovery

```bash
# Discover all hosts on local network
nmap -sn 192.168.1.0/24

# Discover hosts with specific ports open
nmap -sn --script discovery 192.168.1.0/24

# Ping sweep with different techniques
nmap -sn -PE -PS80,443 192.168.1.0/24
```

### 2. Port Scanning

```bash
# Quick port scan
nmap --top-ports 1000 192.168.1.1

# Comprehensive port scan
nmap -p- 192.168.1.1

# Service detection
nmap -sV -sC 192.168.1.1

# UDP and TCP scan
nmap -sS -sU 192.168.1.1
```

### 3. Vulnerability Assessment

```bash
# Basic vulnerability scan
nmap --script vuln 192.168.1.1

# SSL/TLS assessment
nmap --script ssl-enum-ciphers,ssl-cert 192.168.1.1

# Web application scan
nmap --script http-enum,http-headers 192.168.1.1

# Database scan
nmap --script mysql-enum,mysql-brute 192.168.1.1
```

### 4. Network Mapping

```bash
# Traceroute
nmap --traceroute 192.168.1.1

# Network topology
nmap -sn --script discovery 192.168.1.0/24

# Service enumeration
nmap -sV --script discovery 192.168.1.0/24
```

## 📋 Common Nmap Commands Reference

### Basic Commands
```bash
# Host discovery
nmap -sn 192.168.1.0/24

# Port scan
nmap 192.168.1.1

# Service detection
nmap -sV 192.168.1.1

# OS detection
nmap -O 192.168.1.1

# Aggressive scan
nmap -A 192.168.1.1
```

### Advanced Commands
```bash
# Stealth scan
nmap -sS -f 192.168.1.1

# UDP scan
nmap -sU 192.168.1.1

# Script scan
nmap --script vuln 192.168.1.1

# Custom timing
nmap -T4 --max-retries 1 192.168.1.1

# Output to file
nmap -oA results 192.168.1.1
```

## 🚨 Security and Ethical Considerations

### Legal and Ethical Use

**✅ Appropriate Uses:**
- Scanning your own networks
- Authorized penetration testing
- Security assessment with permission
- Network troubleshooting and documentation
- Educational purposes in controlled environments

**❌ Inappropriate Uses:**
- Scanning networks without permission
- Attempting to access unauthorized systems
- Disrupting network services
- Violating terms of service
- Illegal hacking activities

### Best Practices

1. **Always Get Permission**: Never scan networks you don't own or have explicit permission to scan
2. **Use Appropriate Timing**: Avoid aggressive scans during business hours
3. **Document Everything**: Keep records of authorized scans and results
4. **Respect Rate Limits**: Don't overwhelm target systems
5. **Follow Responsible Disclosure**: Report vulnerabilities through proper channels

### Legal Considerations

- **Computer Fraud and Abuse Act (CFAA)**: Prohibits unauthorized access to computer systems
- **Local Laws**: Different countries have different laws regarding network scanning
- **Terms of Service**: Many networks prohibit scanning in their ToS
- **Professional Ethics**: Follow industry standards and ethical guidelines

## 🛠️ Troubleshooting Common Issues

### Permission Denied Errors

```bash
# Error: Permission denied for raw sockets
# Solution: Run with sudo or as root
sudo nmap -sS 192.168.1.1

# Alternative: Use TCP connect scan
nmap -sT 192.168.1.1
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
nmap -sN 192.168.1.1  # NULL scan

# Fragment packets
nmap -f 192.168.1.1

# Use decoys
nmap -D decoy1,decoy2,ME 192.168.1.1
```

## 📚 Learning Exercises

### Exercise 1: Basic Network Discovery
```bash
# 1. Discover all hosts on your local network
nmap -sn 192.168.1.0/24

# 2. Identify which hosts are running web servers
nmap -p 80,443 192.168.1.0/24

# 3. Perform service detection on discovered hosts
nmap -sV 192.168.1.1
```

### Exercise 2: Port Scanning Techniques
```bash
# 1. Compare different scan types
nmap -sS 192.168.1.1  # SYN scan
nmap -sT 192.168.1.1  # Connect scan
nmap -sU 192.168.1.1  # UDP scan

# 2. Analyze timing differences
time nmap -T0 192.168.1.1  # Slow
time nmap -T5 192.168.1.1  # Fast
```

### Exercise 3: Service Enumeration
```bash
# 1. Identify web services
nmap --script http-enum 192.168.1.1

# 2. Check SSL/TLS configuration
nmap --script ssl-enum-ciphers -p 443 192.168.1.1

# 3. Enumerate SMB shares
nmap --script smb-enum-shares 192.168.1.1
```

### Exercise 4: Vulnerability Assessment
```bash
# 1. Run vulnerability scripts
nmap --script vuln 192.168.1.1

# 2. Check for common web vulnerabilities
nmap --script http-vuln-* 192.168.1.1

# 3. Assess SSL/TLS security
nmap --script ssl-* 192.168.1.1
```

## 🔗 Additional Resources

### Documentation
- [Nmap Official Documentation](https://nmap.org/book/)
- [NSE Script Reference](https://nmap.org/nsedoc/)
- [Nmap Network Scanning Book](https://nmap.org/book/)

### Online Tools
- [Nmap Online](https://nmap.online/) - Online nmap scanner
- [Nmap Script Database](https://nmap.org/nsedoc/) - NSE script documentation

### Learning Resources
- [Nmap Tutorial](https://nmap.org/book/toc.html)
- [NSE Scripting Tutorial](https://nmap.org/book/nse-tutorial.html)
- [Advanced Nmap Techniques](https://nmap.org/book/man-bypass-firewalls-ids.html)

---

**Remember**: Always use nmap responsibly and only on networks you own or have explicit permission to scan. Network scanning can be considered intrusive and may violate laws or terms of service if done without authorization.
