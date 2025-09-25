# Wireshark Network Protocol Analyzer

## Overview

Wireshark is the world's most widely used network protocol analyzer. It lets you see what's happening on your network at a microscopic level and is the de facto standard across many commercial and non-profit enterprises, government agencies, and educational institutions.

## Table of Contents

- [Wireshark Fundamentals](#wireshark-fundamentals)
- [Installation and Setup](#installation-and-setup)
- [User Interface Overview](#user-interface-overview)
- [Packet Capture](#packet-capture)
- [Display Filters](#display-filters)
- [Protocol Analysis](#protocol-analysis)
- [Statistical Analysis](#statistical-analysis)
- [Advanced Features](#advanced-features)
- [Troubleshooting Networks](#troubleshooting-networks)
- [Security Analysis](#security-analysis)
- [Performance Analysis](#performance-analysis)
- [Practical Labs](#practical-labs)
- [Troubleshooting](#troubleshooting)

## Wireshark Fundamentals

### What is Wireshark?

Wireshark is a network packet analyzer that captures network packets and displays them in a human-readable format. It provides:

- **Real-time packet capture** from live network interfaces
- **Offline analysis** of previously captured packet files
- **Deep inspection** of hundreds of protocols
- **Powerful filtering** and search capabilities
- **Statistical analysis** and reporting tools

### Key Features

1. **Multi-Platform**: Runs on Windows, macOS, Linux, and Unix
2. **Live Capture**: Real-time packet capture from network interfaces
3. **Offline Analysis**: Analyze previously captured packet files
4. **Protocol Support**: Hundreds of protocols supported
5. **Powerful Filtering**: Display and capture filters
6. **Statistical Analysis**: Built-in statistics and graphs
7. **Export Capabilities**: Export to various formats
8. **Decryption Support**: Decrypt encrypted protocols

### When to Use Wireshark

- **Network Troubleshooting**: Diagnose connectivity and performance issues
- **Security Analysis**: Detect malicious traffic and attacks
- **Protocol Learning**: Understand how network protocols work
- **Performance Analysis**: Identify bottlenecks and latency issues
- **Compliance**: Monitor network traffic for compliance requirements
- **Development**: Debug network applications

## Installation and Setup

### System Requirements

#### Minimum Requirements
- **CPU**: 1 GHz processor
- **RAM**: 512 MB (1 GB recommended)
- **Storage**: 100 MB for installation
- **Network**: Network interface for packet capture

#### Recommended Requirements
- **CPU**: Multi-core processor
- **RAM**: 4 GB or more
- **Storage**: 1 GB for installation and captures
- **Network**: Gigabit network interface

### Installation Methods

#### Windows
```powershell
# Download from official website
# https://www.wireshark.org/download.html

# Or using Chocolatey
choco install wireshark

# Or using winget
winget install WiresharkFoundation.Wireshark
```

#### macOS
```bash
# Using Homebrew
brew install wireshark

# Or download from official website
# https://www.wireshark.org/download.html
```

#### Linux (Ubuntu/Debian)
```bash
# Install Wireshark
sudo apt-get update
sudo apt-get install wireshark

# Add user to wireshark group for packet capture
sudo usermod -a -G wireshark $USER

# Log out and back in for group changes to take effect
```

#### Linux (CentOS/RHEL/Fedora)
```bash
# Install Wireshark
sudo yum install wireshark
# or
sudo dnf install wireshark

# Add user to wireshark group
sudo usermod -a -G wireshark $USER
```

### Initial Configuration

#### 1. Interface Selection
- **Identify available interfaces**: `ip link show` (Linux) or `ifconfig` (macOS)
- **Choose appropriate interface**: Usually `eth0`, `wlan0`, or `en0`
- **Consider promiscuous mode**: Captures all packets, not just destined to your machine

#### 2. Capture Permissions
```bash
# Linux: Add user to wireshark group
sudo usermod -a -G wireshark $USER

# Or run with sudo (not recommended for GUI)
sudo wireshark

# macOS: Grant permissions in System Preferences
# System Preferences > Security & Privacy > Privacy > Full Disk Access
```

#### 3. Basic Settings
- **Capture buffer size**: Default is usually sufficient
- **Capture file size**: Set appropriate limits for long captures
- **Capture file format**: PCAPNG (recommended) or PCAP

## User Interface Overview

### Main Window Components

#### 1. Menu Bar
- **File**: Open, save, export, and print functions
- **Edit**: Find, preferences, and configuration
- **View**: Display options and zoom controls
- **Go**: Navigation between packets
- **Capture**: Start/stop capture and interface selection
- **Analyze**: Display filters and follow streams
- **Statistics**: Various statistical analysis tools
- **Telephony**: Voice and video analysis tools
- **Wireless**: Wireless network analysis
- **Tools**: Additional tools and utilities
- **Help**: Documentation and support

#### 2. Toolbar
- **Interface Selection**: Choose capture interface
- **Start/Stop Capture**: Control packet capture
- **Capture Options**: Configure capture settings
- **Display Filter**: Apply display filters
- **Colorize**: Enable/disable packet coloring
- **Zoom**: Adjust packet list size

#### 3. Packet List Pane
- **No.**: Packet number in capture
- **Time**: Timestamp of packet
- **Source**: Source IP address
- **Destination**: Destination IP address
- **Protocol**: Highest layer protocol
- **Length**: Packet length in bytes
- **Info**: Summary information about packet

#### 4. Packet Details Pane
- **Protocol Tree**: Hierarchical view of packet contents
- **Expandable Fields**: Click to expand/collapse sections
- **Field Information**: Details about selected field
- **Right-click Menu**: Additional options for fields

#### 5. Packet Bytes Pane
- **Hex Dump**: Hexadecimal representation of packet
- **ASCII View**: ASCII representation of packet data
- **Highlighting**: Selected field highlighted in both views

### Navigation and Selection

#### Packet Navigation
- **Up/Down Arrows**: Move between packets
- **Page Up/Down**: Move by page
- **Home/End**: Go to first/last packet
- **Ctrl+G**: Go to specific packet number
- **Ctrl+F**: Find packets

#### Field Selection
- **Click**: Select field in protocol tree
- **Double-click**: Follow protocol stream
- **Right-click**: Context menu with options
- **Ctrl+Click**: Add to display filter

## Packet Capture

### Starting a Capture

#### 1. Interface Selection
```
Capture → Options → Select Interface
```
- **Available Interfaces**: List of network interfaces
- **Traffic**: Real-time traffic indicator
- **Link-layer Header**: Type of link-layer protocol
- **Capture Filter**: Pre-capture filtering

#### 2. Capture Options
```
Capture → Options → Capture Options
```
- **Interface**: Select capture interface
- **Promiscuous Mode**: Capture all packets (recommended)
- **Capture Filter**: BPF filter for pre-capture filtering
- **File**: Save capture to file
- **Ring Buffer**: Rotate capture files
- **Stop Conditions**: Automatic stop conditions

#### 3. Capture Filters
```bash
# Common capture filters
host 192.168.1.100          # Traffic to/from specific host
net 192.168.1.0/24          # Traffic to/from network
port 80                     # Traffic on specific port
tcp port 80                 # TCP traffic on port 80
udp port 53                 # DNS traffic
icmp                        # ICMP traffic only
not broadcast               # Exclude broadcast traffic
```

### Capture Best Practices

#### 1. Interface Selection
- **Wired vs Wireless**: Wired interfaces typically more reliable
- **Promiscuous Mode**: Enable for complete packet capture
- **Interface Speed**: Match capture to network speed

#### 2. Filtering Strategy
- **Pre-capture Filtering**: Use capture filters to reduce noise
- **Post-capture Filtering**: Use display filters for analysis
- **Combination**: Use both for optimal performance

#### 3. Storage Management
- **File Size Limits**: Set appropriate file size limits
- **Ring Buffer**: Use for continuous monitoring
- **Compression**: Enable for long-term storage

## Display Filters

### Filter Syntax

#### Basic Syntax
```
protocol.field operator value
```

#### Operators
- **==**: Equal to
- **!=**: Not equal to
- **>**: Greater than
- **<**: Less than
- **>=**: Greater than or equal
- **<=**: Less than or equal
- **contains**: Contains substring
- **matches**: Regular expression match

#### Logical Operators
- **and**: Logical AND
- **or**: Logical OR
- **not**: Logical NOT
- **in**: Value in list

### Common Display Filters

#### IP Filters
```bash
# IP address filters
ip.addr == 192.168.1.100
ip.src == 192.168.1.100
ip.dst == 192.168.1.100
ip.addr == 192.168.1.0/24

# IP version filters
ip.version == 4
ip.version == 6
```

#### Protocol Filters
```bash
# Protocol filters
tcp
udp
icmp
arp
dns
http
https
ftp
ssh
telnet
```

#### Port Filters
```bash
# Port filters
tcp.port == 80
udp.port == 53
tcp.srcport == 80
tcp.dstport == 443
tcp.port in {80, 443, 8080}
```

#### Advanced Filters
```bash
# Complex filters
tcp and ip.addr == 192.168.1.100
http and http.request.method == "GET"
dns and dns.flags.response == 0
tcp.flags.syn == 1 and tcp.flags.ack == 0
```

### Filter Examples by Use Case

#### Web Traffic Analysis
```bash
# HTTP traffic
http

# HTTPS traffic
tls or ssl

# Web requests only
http.request

# Specific website
http.host contains "example.com"

# POST requests
http.request.method == "POST"
```

#### Network Troubleshooting
```bash
# Connection issues
tcp.flags.reset == 1

# Slow connections
tcp.analysis.retransmission

# DNS issues
dns and dns.flags.response == 0

# ICMP errors
icmp.type == 3
```

#### Security Analysis
```bash
# Suspicious traffic
tcp.port == 23 or tcp.port == 21

# Large packets
frame.len > 1500

# Unusual protocols
not (tcp or udp or icmp or arp)

# Failed connections
tcp.flags.reset == 1 and tcp.flags.syn == 1
```

## Protocol Analysis

### OSI Model Analysis

#### Layer 1 (Physical)
- **Ethernet**: Frame structure, MAC addresses
- **WiFi**: 802.11 frames, signal strength
- **PPP**: Point-to-point protocol

#### Layer 2 (Data Link)
- **Ethernet**: MAC addresses, VLAN tags
- **ARP**: Address resolution protocol
- **STP**: Spanning tree protocol

#### Layer 3 (Network)
- **IP**: IP addresses, fragmentation
- **ICMP**: Ping, traceroute, error messages
- **IGMP**: Multicast group management

#### Layer 4 (Transport)
- **TCP**: Connection-oriented, reliable
- **UDP**: Connectionless, fast
- **SCTP**: Stream control transmission protocol

#### Layer 5-7 (Session/Presentation/Application)
- **HTTP/HTTPS**: Web traffic
- **DNS**: Domain name resolution
- **FTP**: File transfer
- **SSH**: Secure shell
- **SMTP**: Email

### Deep Packet Inspection

#### TCP Analysis
```bash
# TCP connection establishment
tcp.flags.syn == 1 and tcp.flags.ack == 0

# TCP connection teardown
tcp.flags.fin == 1

# TCP retransmissions
tcp.analysis.retransmission

# TCP window size
tcp.window_size

# TCP sequence numbers
tcp.seq
tcp.ack
```

#### HTTP Analysis
```bash
# HTTP requests
http.request

# HTTP responses
http.response

# HTTP methods
http.request.method == "GET"
http.request.method == "POST"

# HTTP status codes
http.response.code == 200
http.response.code == 404

# HTTP headers
http.user_agent
http.referer
```

#### DNS Analysis
```bash
# DNS queries
dns and dns.flags.response == 0

# DNS responses
dns and dns.flags.response == 1

# DNS record types
dns.qry.type == 1    # A record
dns.qry.type == 28   # AAAA record
dns.qry.type == 15   # MX record

# DNS response codes
dns.flags.rcode == 0  # No error
dns.flags.rcode == 3  # NXDOMAIN
```

## Statistical Analysis

### Built-in Statistics

#### 1. Protocol Hierarchy
```
Statistics → Protocol Hierarchy
```
- **Protocol Distribution**: Percentage of each protocol
- **Byte Count**: Total bytes per protocol
- **Packet Count**: Total packets per protocol

#### 2. Conversations
```
Statistics → Conversations
```
- **Endpoint Statistics**: Traffic between specific hosts
- **Protocol Statistics**: Traffic by protocol
- **Byte/Packet Counts**: Volume statistics

#### 3. I/O Graphs
```
Statistics → I/O Graphs
```
- **Time-based Analysis**: Traffic over time
- **Multiple Filters**: Compare different traffic types
- **Custom Intervals**: Adjustable time intervals

#### 4. Flow Graph
```
Statistics → Flow Graph
```
- **Connection Flow**: Visual representation of connections
- **Sequence Numbers**: TCP sequence analysis
- **Timing Information**: Connection timing

### Advanced Statistics

#### 1. Expert Information
```
Analyze → Expert Information
```
- **Warnings**: Potential issues
- **Notes**: Informational messages
- **Errors**: Protocol errors
- **Chats**: Normal communication

#### 2. Service Response Time
```
Statistics → Service Response Time
```
- **HTTP Response Time**: Web server response times
- **DNS Response Time**: DNS server response times
- **SMB Response Time**: File server response times

#### 3. TCP Stream Analysis
```
Statistics → TCP Stream Graphs
```
- **Time Sequence**: TCP sequence over time
- **Throughput**: Data transfer rate
- **Round Trip Time**: Network latency

## Advanced Features

### Follow Streams

#### TCP Streams
```
Analyze → Follow → TCP Stream
```
- **Bidirectional**: Both directions of communication
- **Unidirectional**: Single direction only
- **Raw Data**: Binary data view
- **ASCII Data**: Text data view

#### UDP Streams
```
Analyze → Follow → UDP Stream
```
- **UDP Communication**: Connectionless protocol analysis
- **DNS Queries**: DNS request/response pairs
- **DHCP Communication**: DHCP client/server exchange

### Decryption Support

#### SSL/TLS Decryption
```
Edit → Preferences → Protocols → TLS
```
- **RSA Keys**: Private key files
- **Pre-master Secrets**: Log files
- **Session Keys**: Key log files

#### WEP/WPA Decryption
```
Edit → Preferences → Protocols → IEEE 802.11
```
- **WEP Keys**: Static WEP keys
- **WPA Passphrases**: WPA/WPA2 passphrases
- **Key Management**: Dynamic key management

### Custom Protocols

#### Protocol Dissectors
- **Lua Scripts**: Custom protocol parsing
- **C Plugins**: High-performance dissectors
- **Built-in**: Hundreds of supported protocols

#### Custom Fields
- **Field Definitions**: Define custom protocol fields
- **Display Filters**: Use custom fields in filters
- **Statistics**: Include custom fields in statistics

## Troubleshooting Networks

### Common Network Issues

#### 1. Connectivity Problems
```bash
# No response to ping
icmp.type == 3

# DNS resolution issues
dns and dns.flags.response == 0

# ARP problems
arp and arp.opcode == 1

# DHCP issues
dhcp and dhcp.option.dhcp == 1
```

#### 2. Performance Issues
```bash
# TCP retransmissions
tcp.analysis.retransmission

# TCP window size problems
tcp.window_size < 1000

# Large packets
frame.len > 1500

# Duplicate packets
tcp.analysis.duplicate_ack
```

#### 3. Security Issues
```bash
# Port scans
tcp.flags.syn == 1 and tcp.flags.ack == 0

# Failed connections
tcp.flags.reset == 1

# Unusual traffic patterns
not (tcp or udp or icmp or arp)

# Large data transfers
tcp.len > 1000
```

### Diagnostic Workflow

#### 1. Capture Strategy
- **Duration**: Capture for sufficient time
- **Filtering**: Use appropriate filters
- **Multiple Interfaces**: Capture from different points

#### 2. Analysis Approach
- **Top-down**: Start with high-level protocols
- **Bottom-up**: Start with low-level protocols
- **Time-based**: Analyze chronological sequence

#### 3. Documentation
- **Screenshots**: Capture important findings
- **Notes**: Document observations
- **Export**: Save relevant packets

## Security Analysis

### Threat Detection

#### 1. Network Scanning
```bash
# Port scans
tcp.flags.syn == 1 and tcp.flags.ack == 0

# Host discovery
arp and arp.opcode == 1

# Service enumeration
tcp.flags.syn == 1 and tcp.flags.ack == 1
```

#### 2. Malicious Traffic
```bash
# Suspicious protocols
tcp.port == 23 or tcp.port == 21

# Unusual patterns
frame.len > 1500 and tcp.port == 80

# Failed authentication
tcp.port == 22 and tcp.flags.reset == 1
```

#### 3. Data Exfiltration
```bash
# Large data transfers
tcp.len > 1000

# Unusual protocols
not (tcp.port in {80, 443, 53, 25, 110, 143})

# Encrypted traffic
tls or ssl
```

### Incident Response

#### 1. Evidence Collection
- **Full Packet Capture**: Complete network traffic
- **Filtered Capture**: Specific traffic of interest
- **Metadata**: Packet timestamps and sizes

#### 2. Analysis Techniques
- **Timeline Analysis**: Chronological event reconstruction
- **Correlation**: Cross-reference multiple sources
- **Pattern Recognition**: Identify attack patterns

#### 3. Reporting
- **Executive Summary**: High-level findings
- **Technical Details**: Detailed analysis
- **Evidence**: Supporting packet captures

## Performance Analysis

### Network Performance Metrics

#### 1. Latency Analysis
```bash
# Round-trip time
tcp.analysis.ack_rtt

# One-way delay
tcp.time_delta

# Jitter
tcp.analysis.ack_lost_segment
```

#### 2. Throughput Analysis
```bash
# Data transfer rate
tcp.len

# Window size
tcp.window_size

# Congestion control
tcp.analysis.retransmission
```

#### 3. Error Analysis
```bash
# Packet loss
tcp.analysis.lost_segment

# Duplicate packets
tcp.analysis.duplicate_ack

# Out-of-order packets
tcp.analysis.out_of_order
```

### Application Performance

#### 1. HTTP Performance
```bash
# Response time
http.time

# Request/response pairs
http.request and http.response

# Status codes
http.response.code
```

#### 2. DNS Performance
```bash
# Query time
dns.time

# Response codes
dns.flags.rcode

# Record types
dns.qry.type
```

## Practical Labs

### Lab 1: Basic Packet Capture
```bash
# Start Wireshark
wireshark

# Select interface
Capture → Options → Select Interface

# Start capture
Click "Start" button

# Generate traffic
ping google.com

# Stop capture
Click "Stop" button
```

### Lab 2: Display Filters
```bash
# Filter by IP address
ip.addr == 192.168.1.100

# Filter by protocol
tcp

# Filter by port
tcp.port == 80

# Complex filter
tcp and ip.addr == 192.168.1.100 and tcp.port == 80
```

### Lab 3: Protocol Analysis
```bash
# Analyze HTTP traffic
http

# Follow TCP stream
Right-click → Follow → TCP Stream

# Analyze DNS queries
dns

# Analyze ARP traffic
arp
```

### Lab 4: Statistical Analysis
```bash
# Protocol hierarchy
Statistics → Protocol Hierarchy

# Conversations
Statistics → Conversations

# I/O graphs
Statistics → I/O Graphs
```

### Lab 5: Troubleshooting
```bash
# Find connection issues
tcp.flags.reset == 1

# Analyze retransmissions
tcp.analysis.retransmission

# Check DNS issues
dns and dcp.flags.response == 0
```

## Troubleshooting

### Common Issues

#### 1. No Packets Captured
**Symptoms**: Empty packet list
**Causes**:
- Wrong interface selected
- No network traffic
- Insufficient permissions
- Capture filter too restrictive

**Solutions**:
```bash
# Check interface selection
Capture → Options → Select Interface

# Verify permissions
sudo usermod -a -G wireshark $USER

# Check capture filter
Capture → Options → Capture Filter

# Generate test traffic
ping google.com
```

#### 2. Performance Issues
**Symptoms**: Slow capture, dropped packets
**Causes**:
- High network load
- Insufficient system resources
- Inefficient filters

**Solutions**:
```bash
# Use capture filters
host 192.168.1.100

# Increase buffer size
Edit → Preferences → Capture

# Close unnecessary applications
# Use dedicated capture machine
```

#### 3. Display Issues
**Symptoms**: Packets not displaying correctly
**Causes**:
- Corrupted capture file
- Unsupported protocol
- Display filter issues

**Solutions**:
```bash
# Check file integrity
File → Properties

# Disable display filters
Clear display filter

# Update Wireshark
# Check protocol support
```

### Best Practices

#### 1. Capture Planning
- **Define objectives**: What are you trying to analyze?
- **Choose appropriate interface**: Wired vs wireless
- **Set capture filters**: Reduce noise
- **Plan storage**: Sufficient disk space

#### 2. Analysis Methodology
- **Start broad**: Look at overall traffic patterns
- **Narrow down**: Use filters to focus
- **Document findings**: Take notes and screenshots
- **Verify conclusions**: Cross-check with other tools

#### 3. Performance Optimization
- **Use capture filters**: Reduce processing load
- **Limit capture size**: Prevent memory issues
- **Close unnecessary applications**: Free up resources
- **Use dedicated hardware**: For high-speed networks

---

## Next Steps

1. **Practice**: Use the provided lab scripts to gain hands-on experience
2. **Analysis**: Use Wireshark to analyze real network traffic
3. **Troubleshooting**: Practice diagnosing network issues
4. **Security**: Learn to identify security threats

For hands-on practice, run:
```bash
# Interactive Wireshark lab
./wireshark-lab.sh

# Wireshark packet analysis
python3 wireshark-analyzer.py

# Troubleshooting guide
./wireshark-troubleshoot.sh
```
