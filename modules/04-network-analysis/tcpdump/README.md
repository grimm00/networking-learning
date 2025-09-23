# Packet Capture and Analysis with tcpdump

A comprehensive guide to packet capturing, analysis, and network troubleshooting using tcpdump and related tools.

## Table of Contents

- [Overview](#overview)
- [tcpdump Fundamentals](#tcpdump-fundamentals)
- [Basic Usage](#basic-usage)
- [Advanced Filtering](#advanced-filtering)
- [Protocol Analysis](#protocol-analysis)
- [Troubleshooting Scenarios](#troubleshooting-scenarios)
- [Performance Considerations](#performance-considerations)
- [Security and Privacy](#security-and-privacy)
- [Practical Labs](#practical-labs)
- [Tools and Scripts](#tools-and-scripts)

## Overview

### What is Packet Capture?

Packet capture is the process of intercepting and logging network traffic. It's essential for:
- **Network troubleshooting** - Diagnosing connectivity issues
- **Security analysis** - Detecting attacks and anomalies
- **Performance monitoring** - Analyzing network performance
- **Protocol analysis** - Understanding how protocols work
- **Learning** - Hands-on understanding of network communication

### Why tcpdump?

**tcpdump** is the industry-standard command-line packet analyzer:
- ✅ **Universal** - Available on all Unix-like systems
- ✅ **Powerful** - Extensive filtering and analysis capabilities
- ✅ **Lightweight** - Minimal resource usage
- ✅ **Scriptable** - Perfect for automation
- ✅ **Educational** - Shows raw packet data for learning

## tcpdump Fundamentals

### How Packet Capture Works

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Source    │───▶│   Network   │───▶│ Destination │
│   Host      │    │   Interface │    │    Host     │
└─────────────┘    └─────────────┘    └─────────────┘
                           │
                           ▼
                    ┌─────────────┐
                    │  tcpdump    │
                    │  Capture    │
                    └─────────────┘
```

### Packet Capture Modes

#### **Promiscuous Mode**
- Captures **all packets** on the network segment
- Requires root privileges
- Can see traffic not intended for your host

#### **Non-Promiscuous Mode**
- Captures only packets **intended for your host**
- Default mode for most interfaces
- Limited visibility but more secure

### Understanding Packet Headers

```
┌─────────────────────────────────────────────────────────┐
│                    Ethernet Header                       │
├─────────────────────────────────────────────────────────┤
│                    IP Header                            │
├─────────────────────────────────────────────────────────┤
│                   TCP/UDP Header                        │
├─────────────────────────────────────────────────────────┤
│                    Application Data                     │
└─────────────────────────────────────────────────────────┘
```

## Basic Usage

### Essential tcpdump Commands

#### **1. Basic Packet Capture**
```bash
# Capture all packets on default interface
sudo tcpdump

# Capture on specific interface
sudo tcpdump -i eth0

# Capture with packet count limit
sudo tcpdump -c 100

# Capture and save to file
sudo tcpdump -w capture.pcap
```

#### **2. Reading and Analyzing Captures**
```bash
# Read from file
tcpdump -r capture.pcap

# Read with verbose output
tcpdump -r capture.pcap -v

# Read with detailed output
tcpdump -r capture.pcap -vvv
```

#### **3. Output Control**
```bash
# Don't resolve hostnames (faster)
sudo tcpdump -n

# Don't resolve port names
sudo tcpdump -nn

# Show absolute sequence numbers
sudo tcpdump -S

# Show packet timestamps
sudo tcpdump -tt
```

### Common Options Explained

| Option | Description | Example |
|--------|-------------|---------|
| `-i` | Interface | `-i eth0` |
| `-c` | Count | `-c 50` |
| `-w` | Write to file | `-w file.pcap` |
| `-r` | Read from file | `-r file.pcap` |
| `-n` | No hostname resolution | `-n` |
| `-v` | Verbose | `-v`, `-vv`, `-vvv` |
| `-S` | Absolute sequence numbers | `-S` |
| `-t` | No timestamps | `-t` |
| `-tt` | Timestamp format | `-tt` |

## Advanced Filtering

### BPF (Berkeley Packet Filter) Syntax

tcpdump uses BPF for powerful packet filtering:

#### **Basic Filters**
```bash
# Filter by host
sudo tcpdump host 192.168.1.100

# Filter by network
sudo tcpdump net 192.168.1.0/24

# Filter by port
sudo tcpdump port 80
sudo tcpdump port 443

# Filter by protocol
sudo tcpdump icmp
sudo tcpdump tcp
sudo tcpdump udp
```

#### **Advanced Filters**
```bash
# Source and destination
sudo tcpdump src host 192.168.1.100
sudo tcpdump dst host 192.168.1.100

# Port ranges
sudo tcpdump portrange 1024-65535

# Multiple conditions
sudo tcpdump host 192.168.1.100 and port 80
sudo tcpdump tcp and port 80 or port 443

# Exclude traffic
sudo tcpdump not host 192.168.1.100
sudo tcpdump not port 22
```

### Complex Filter Examples

#### **HTTP Traffic Analysis**
```bash
# HTTP requests and responses
sudo tcpdump -A -s 0 'tcp port 80 and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'

# HTTP GET requests
sudo tcpdump -A -s 0 'tcp port 80 and tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x47455420'

# HTTP POST requests
sudo tcpdump -A -s 0 'tcp port 80 and tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x504f5354'
```

#### **DNS Traffic**
```bash
# DNS queries
sudo tcpdump -A -s 0 'udp port 53'

# DNS responses
sudo tcpdump -A -s 0 'udp port 53 and udp[10] & 0x80 = 0x80'
```

#### **Security Monitoring**
```bash
# Failed SSH attempts
sudo tcpdump -A 'tcp port 22 and tcp[13] & 0x04 = 0x04'

# SYN flood detection
sudo tcpdump 'tcp[tcpflags] & tcp-syn != 0 and tcp[tcpflags] & tcp-ack = 0'

# Port scanning
sudo tcpdump 'tcp[tcpflags] & tcp-syn != 0 and tcp[tcpflags] & tcp-ack = 0' -c 10
```

## Protocol Analysis

### TCP Analysis

#### **TCP Three-Way Handshake**
```bash
# Capture TCP handshake
sudo tcpdump -S -n 'tcp and host 192.168.1.100'

# Expected output:
# 192.168.1.50.12345 > 192.168.1.100.80: Flags [S], seq 1000
# 192.168.1.100.80 > 192.168.1.50.12345: Flags [S.], seq 2000, ack 1001
# 192.168.1.50.12345 > 192.168.1.100.80: Flags [.], ack 2001
```

#### **TCP Connection States**
```bash
# SYN packets (connection initiation)
sudo tcpdump 'tcp[tcpflags] & tcp-syn != 0'

# ACK packets (acknowledgments)
sudo tcpdump 'tcp[tcpflags] & tcp-ack != 0'

# FIN packets (connection termination)
sudo tcpdump 'tcp[tcpflags] & tcp-fin != 0'

# RST packets (connection reset)
sudo tcpdump 'tcp[tcpflags] & tcp-rst != 0'
```

### UDP Analysis

#### **UDP Traffic**
```bash
# All UDP traffic
sudo tcpdump udp

# DNS traffic
sudo tcpdump 'udp port 53'

# DHCP traffic
sudo tcpdump 'udp port 67 or udp port 68'
```

### ICMP Analysis

#### **ICMP Types**
```bash
# Ping (Echo Request/Reply)
sudo tcpdump icmp

# Destination Unreachable
sudo tcpdump 'icmp[0] = 3'

# Time Exceeded
sudo tcpdump 'icmp[0] = 11'

# Traceroute
sudo tcpdump 'icmp[0] = 11 or icmp[0] = 3'
```

## Troubleshooting Scenarios

### Common Network Issues

#### **1. Connectivity Problems**
```bash
# Check if packets are leaving your host
sudo tcpdump -i eth0 'host 8.8.8.8'

# Check if packets are reaching your host
sudo tcpdump -i eth0 'host 8.8.8.8 and icmp'

# Check routing issues
sudo tcpdump -i eth0 'host 192.168.1.1'
```

#### **2. DNS Resolution Issues**
```bash
# Capture DNS queries
sudo tcpdump -A 'udp port 53'

# Check DNS server responses
sudo tcpdump -A 'udp port 53 and host 8.8.8.8'

# Analyze DNS response codes
sudo tcpdump -A 'udp port 53 and udp[10] & 0x0f = 0x03'  # NXDOMAIN
```

#### **3. HTTP/HTTPS Issues**
```bash
# HTTP traffic analysis
sudo tcpdump -A -s 0 'tcp port 80'

# HTTPS traffic (encrypted, but can see handshake)
sudo tcpdump -A 'tcp port 443'

# Check SSL/TLS handshake
sudo tcpdump -A 'tcp port 443 and tcp[13] & 0x02 = 0x02'
```

#### **4. Performance Issues**
```bash
# Check for packet loss
sudo tcpdump -i eth0 'tcp[tcpflags] & tcp-rst != 0'

# Check for retransmissions
sudo tcpdump -i eth0 'tcp[tcpflags] & tcp-ack != 0' | grep -i retrans

# Monitor connection establishment time
sudo tcpdump -tt 'tcp[tcpflags] & tcp-syn != 0'
```

### Advanced Troubleshooting

#### **Network Latency Analysis**
```bash
# Capture with timestamps for latency analysis
sudo tcpdump -tt -n 'host 8.8.8.8'

# Analyze round-trip times
sudo tcpdump -tt -n 'icmp and host 8.8.8.8'
```

#### **Bandwidth Monitoring**
```bash
# Monitor traffic volume
sudo tcpdump -i eth0 -c 1000 | wc -l

# Monitor specific protocol traffic
sudo tcpdump -i eth0 'tcp port 80' -c 100
```

## Performance Considerations

### Optimizing tcpdump Performance

#### **1. Buffer Management**
```bash
# Increase buffer size
sudo tcpdump -B 4096

# Use ring buffer for continuous capture
sudo tcpdump -w capture_%Y%m%d_%H%M%S.pcap -G 3600 -W 24
```

#### **2. Filtering for Performance**
```bash
# Use specific filters to reduce overhead
sudo tcpdump 'host 192.168.1.100 and port 80'

# Avoid hostname resolution in high-traffic scenarios
sudo tcpdump -n 'tcp port 80'
```

#### **3. File Management**
```bash
# Rotate capture files
sudo tcpdump -w capture_%Y%m%d_%H%M%S.pcap -G 3600

# Limit file size
sudo tcpdump -w capture.pcap -C 100  # 100MB files
```

### Resource Usage

#### **CPU Usage**
- **High**: Unfiltered capture on busy interfaces
- **Medium**: Filtered capture with specific hosts/ports
- **Low**: Highly specific filters

#### **Disk Usage**
- **Large**: Unfiltered capture
- **Medium**: Protocol-specific capture
- **Small**: Highly filtered capture

#### **Memory Usage**
- **Buffer size**: Affects memory usage
- **Packet size**: Larger packets use more memory
- **Filter complexity**: Complex filters use more CPU

## Security and Privacy

### Legal and Ethical Considerations

#### **⚠️ Important Warnings**
- **Only capture on networks you own or have permission to monitor**
- **Respect privacy laws and regulations**
- **Be aware of data protection requirements**
- **Use captured data responsibly**

#### **Best Practices**
```bash
# Use filters to minimize data capture
sudo tcpdump 'host specific-target.com and port 80'

# Avoid capturing sensitive data
sudo tcpdump 'not (port 443 or port 22)'

# Use anonymization when possible
sudo tcpdump -w capture.pcap | anonymize_traffic.sh
```

### Data Protection

#### **Sensitive Data Handling**
- **Passwords**: Never capture in plain text
- **Personal Information**: Filter out PII
- **Financial Data**: Use encryption
- **Medical Data**: Follow HIPAA guidelines

#### **Secure Storage**
```bash
# Encrypt capture files
sudo tcpdump -w capture.pcap
gpg --symmetric capture.pcap

# Secure deletion
shred -u capture.pcap
```

## Practical Labs

### Lab 1: Basic Packet Capture

#### **Objective**
Learn basic tcpdump usage and packet analysis

#### **Steps**
```bash
# 1. Start packet capture
sudo tcpdump -i eth0 -c 10

# 2. Generate traffic (in another terminal)
ping -c 3 8.8.8.8

# 3. Analyze captured packets
# Look for ICMP packets, IP headers, timestamps
```

#### **Expected Output**
```
15:30:45.123456 IP 192.168.1.100 > 8.8.8.8: ICMP echo request, id 1234, seq 1
15:30:45.145678 IP 8.8.8.8 > 192.168.1.100: ICMP echo reply, id 1234, seq 1
```

### Lab 2: HTTP Traffic Analysis

#### **Objective**
Analyze HTTP requests and responses

#### **Steps**
```bash
# 1. Start HTTP capture
sudo tcpdump -A -s 0 'tcp port 80' -w http_capture.pcap

# 2. Make HTTP request (in another terminal)
curl -v http://httpbin.org/get

# 3. Stop capture and analyze
sudo tcpdump -r http_capture.pcap -A
```

#### **Analysis Points**
- HTTP request headers
- HTTP response headers
- TCP sequence numbers
- Connection establishment

### Lab 3: DNS Resolution Analysis

#### **Objective**
Understand DNS query and response process

#### **Steps**
```bash
# 1. Start DNS capture
sudo tcpdump -A 'udp port 53' -w dns_capture.pcap

# 2. Make DNS query (in another terminal)
nslookup google.com

# 3. Analyze DNS packets
sudo tcpdump -r dns_capture.pcap -A
```

#### **Analysis Points**
- DNS query structure
- DNS response structure
- Query types (A, AAAA, MX)
- Response codes

### Lab 4: Network Troubleshooting

#### **Objective**
Use tcpdump to diagnose network issues

#### **Scenario**
A web server is not responding to HTTP requests

#### **Steps**
```bash
# 1. Check if requests reach the server
sudo tcpdump -i eth0 'host web-server-ip and port 80'

# 2. Check if server responds
sudo tcpdump -i eth0 'host web-server-ip and tcp port 80'

# 3. Check for connection resets
sudo tcpdump -i eth0 'host web-server-ip and tcp[tcpflags] & tcp-rst != 0'

# 4. Analyze results
# Look for SYN packets without ACK responses
# Check for RST packets indicating connection refusal
```

### Lab 5: Security Monitoring

#### **Objective**
Detect potential security threats

#### **Steps**
```bash
# 1. Monitor for port scans
sudo tcpdump 'tcp[tcpflags] & tcp-syn != 0 and tcp[tcpflags] & tcp-ack = 0' -c 10

# 2. Monitor for failed SSH attempts
sudo tcpdump -A 'tcp port 22 and tcp[13] & 0x04 = 0x04'

# 3. Monitor for suspicious traffic
sudo tcpdump 'host suspicious-ip'

# 4. Analyze patterns
# Look for multiple connection attempts
# Check for unusual traffic patterns
```

## Tools and Scripts

### Automated Analysis Scripts

#### **Network Health Check**
```bash
#!/bin/bash
# network-health-check.sh

echo "=== Network Health Check ==="
echo "Starting packet capture for 60 seconds..."

# Capture network traffic
sudo tcpdump -i eth0 -c 1000 -w health_check.pcap &
TCPDUMP_PID=$!

# Wait for capture
sleep 60

# Stop capture
kill $TCPDUMP_PID

# Analyze results
echo "Analyzing captured packets..."
tcpdump -r health_check.pcap -n | head -20

# Check for errors
ERRORS=$(tcpdump -r health_check.pcap 'tcp[tcpflags] & tcp-rst != 0' | wc -l)
echo "Connection resets detected: $ERRORS"

# Cleanup
rm health_check.pcap
```

#### **Traffic Monitor**
```bash
#!/bin/bash
# traffic-monitor.sh

INTERFACE=${1:-eth0}
DURATION=${2:-300}

echo "Monitoring traffic on $INTERFACE for $DURATION seconds..."

# Start monitoring
sudo tcpdump -i $INTERFACE -c 10000 -w traffic_$(date +%Y%m%d_%H%M%S).pcap &
TCPDUMP_PID=$!

# Monitor in real-time
sudo tcpdump -i $INTERFACE -n -c 100 | while read line; do
    echo "$(date): $line"
done &

# Wait for duration
sleep $DURATION

# Stop monitoring
kill $TCPDUMP_PID

echo "Traffic monitoring completed."
```

### Analysis Tools

#### **Packet Statistics**
```bash
#!/bin/bash
# packet-stats.sh

PCAP_FILE=${1:-capture.pcap}

echo "=== Packet Statistics for $PCAP_FILE ==="

# Total packets
TOTAL=$(tcpdump -r $PCAP_FILE -n | wc -l)
echo "Total packets: $TOTAL"

# Protocol breakdown
echo "Protocol breakdown:"
tcpdump -r $PCAP_FILE -n | awk '{print $1}' | sort | uniq -c | sort -nr

# Top talkers
echo "Top talkers:"
tcpdump -r $PCAP_FILE -n | awk '{print $3}' | cut -d. -f1-4 | sort | uniq -c | sort -nr | head -10

# Port usage
echo "Port usage:"
tcpdump -r $PCAP_FILE -n | awk '{print $5}' | cut -d. -f5 | sort | uniq -c | sort -nr | head -10
```

## Quick Reference

### Essential Commands
```bash
# Basic capture
sudo tcpdump -i eth0 -c 100

# Save to file
sudo tcpdump -w capture.pcap

# Read from file
tcpdump -r capture.pcap

# Filter by host
sudo tcpdump host 192.168.1.100

# Filter by port
sudo tcpdump port 80

# Filter by protocol
sudo tcpdump tcp
sudo tcpdump udp
sudo tcpdump icmp

# Verbose output
sudo tcpdump -vvv

# No hostname resolution
sudo tcpdump -n
```

### Common Filters
```bash
# HTTP traffic
sudo tcpdump 'tcp port 80'

# HTTPS traffic
sudo tcpdump 'tcp port 443'

# DNS traffic
sudo tcpdump 'udp port 53'

# SSH traffic
sudo tcpdump 'tcp port 22'

# Ping traffic
sudo tcpdump 'icmp'

# Specific host
sudo tcpdump 'host 192.168.1.100'

# Source host
sudo tcpdump 'src host 192.168.1.100'

# Destination host
sudo tcpdump 'dst host 192.168.1.100'
```

### Troubleshooting Filters
```bash
# Connection issues
sudo tcpdump 'tcp[tcpflags] & tcp-syn != 0'

# Failed connections
sudo tcpdump 'tcp[tcpflags] & tcp-rst != 0'

# DNS problems
sudo tcpdump 'udp port 53'

# HTTP problems
sudo tcpdump 'tcp port 80'

# Network latency
sudo tcpdump -tt 'icmp'
```

---

## Next Steps

1. **Practice**: Start with basic captures and gradually add filters
2. **Analyze**: Use captured data to understand network behavior
3. **Troubleshoot**: Apply packet capture to real network issues
4. **Automate**: Create scripts for common analysis tasks
5. **Security**: Learn to detect and analyze security threats

Remember: **Packet capture is a powerful tool - use it responsibly and ethically!**
