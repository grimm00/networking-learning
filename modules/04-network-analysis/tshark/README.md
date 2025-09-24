# Tshark Packet Analysis Module

Tshark is the command-line version of Wireshark, providing powerful packet capture and analysis capabilities. This module covers comprehensive tshark usage for network analysis, protocol inspection, and troubleshooting.

## 📚 Learning Objectives

By the end of this module, you will understand:
- Basic tshark syntax and capture options
- Packet filtering and display filters
- Protocol analysis and decoding
- Statistical analysis and reporting
- Advanced capture techniques
- Troubleshooting network issues
- Security analysis and forensics
- Performance monitoring and optimization

## 🔍 Tshark Fundamentals

### What is Tshark?
Tshark (Terminal Wireshark) is a command-line network protocol analyzer that can:
- **Capture packets**: Live capture from network interfaces
- **Analyze protocols**: Decode and display packet contents
- **Filter traffic**: Apply capture and display filters
- **Generate statistics**: Create reports and summaries
- **Export data**: Save captures in various formats
- **Troubleshoot networks**: Diagnose connectivity and performance issues

### Installation and Basic Usage

```bash
# Check if tshark is installed
tshark --version

# Basic syntax
tshark [options] [capture filter]

# List available interfaces
tshark -D

# Capture packets
tshark -i interface
```

## 🎯 Basic Capture and Analysis

### 1. Interface Selection and Basic Capture

**List Available Interfaces**
```bash
# List all capture interfaces
tshark -D

# Show interface details
tshark -i any -c 0
```

**Basic Packet Capture**
```bash
# Capture on specific interface
tshark -i eth0

# Capture on any interface
tshark -i any

# Capture limited number of packets
tshark -i any -c 10

# Capture with timeout
tshark -i any -a duration:30
```

**Educational Context**: Interface selection is crucial for effective packet capture. The `-i` option specifies which network interface to monitor, while `-c` limits the number of packets captured.

### 2. Capture Filters

**Basic Capture Filters**
```bash
# Capture only HTTP traffic
tshark -i any -f "port 80"

# Capture only specific host
tshark -i any -f "host 192.168.1.1"

# Capture only TCP traffic
tshark -i any -f "tcp"

# Capture only UDP traffic
tshark -i any -f "udp"

# Capture specific protocol
tshark -i any -f "icmp"
```

**Advanced Capture Filters**
```bash
# Capture traffic between two hosts
tshark -i any -f "host 192.168.1.1 and host 192.168.1.2"

# Capture specific port range
tshark -i any -f "portrange 80-90"

# Capture broadcast traffic
tshark -i any -f "broadcast"

# Capture multicast traffic
tshark -i any -f "multicast"
```

**Educational Context**: Capture filters are applied at the kernel level and reduce the amount of data processed, making captures more efficient. They use BPF (Berkeley Packet Filter) syntax.

### 3. Display Filters

**Basic Display Filters**
```bash
# Show only HTTP packets
tshark -i any -Y "http"

# Show only specific IP
tshark -i any -Y "ip.addr == 192.168.1.1"

# Show only TCP packets
tshark -i any -Y "tcp"

# Show only packets with errors
tshark -i any -Y "tcp.flags.reset == 1"
```

**Advanced Display Filters**
```bash
# Show HTTP requests only
tshark -i any -Y "http.request"

# Show DNS queries
tshark -i any -Y "dns.flags.response == 0"

# Show packets with specific port
tshark -i any -Y "tcp.port == 80"

# Show packets with specific protocol
tshark -i any -Y "tcp.analysis.flags"
```

**Educational Context**: Display filters are applied after capture and allow for detailed analysis of captured packets. They use Wireshark's display filter syntax.

## 🔧 Protocol Analysis

### 1. HTTP Analysis

**HTTP Traffic Capture**
```bash
# Capture HTTP traffic
tshark -i any -f "port 80" -Y "http"

# Show HTTP requests and responses
tshark -i any -Y "http.request or http.response"

# Show HTTP headers
tshark -i any -Y "http" -T fields -e http.host -e http.request.uri

# Show HTTP status codes
tshark -i any -Y "http.response" -T fields -e http.response.code
```

**Educational Context**: HTTP analysis helps understand web traffic patterns, identify performance issues, and debug web applications.

### 2. DNS Analysis

**DNS Traffic Analysis**
```bash
# Capture DNS traffic
tshark -i any -f "port 53" -Y "dns"

# Show DNS queries
tshark -i any -Y "dns.flags.response == 0"

# Show DNS responses
tshark -i any -Y "dns.flags.response == 1"

# Show specific DNS record types
tshark -i any -Y "dns.qry.type == 1"  # A records
```

**Educational Context**: DNS analysis is crucial for troubleshooting name resolution issues and understanding how applications resolve hostnames.

### 3. TCP Analysis

**TCP Connection Analysis**
```bash
# Show TCP handshake
tshark -i any -Y "tcp.flags.syn == 1 or tcp.flags.ack == 1"

# Show TCP connection establishment
tshark -i any -Y "tcp.flags.syn == 1 and tcp.flags.ack == 0"

# Show TCP connection termination
tshark -i any -Y "tcp.flags.fin == 1"

# Show TCP retransmissions
tshark -i any -Y "tcp.analysis.retransmission"
```

**Educational Context**: TCP analysis helps identify connection issues, performance problems, and network congestion.

## 📊 Statistical Analysis

### 1. Protocol Statistics

**Protocol Distribution**
```bash
# Show protocol statistics
tshark -i any -q -z io,phs

# Show conversation statistics
tshark -i any -q -z conv,tcp

# Show endpoint statistics
tshark -i any -q -z endpoints,ip

# Show service response time
tshark -i any -q -z rtt,tcp
```

**Educational Context**: Statistical analysis provides insights into network usage patterns, performance metrics, and traffic distribution.

### 2. Custom Statistics

**Custom Analysis**
```bash
# Show HTTP status code distribution
tshark -i any -Y "http" -q -z http,tree

# Show DNS query types
tshark -i any -Y "dns" -q -z dns,tree

# Show TCP flags distribution
tshark -i any -Y "tcp" -q -z tcp,flags
```

### 3. Export and Reporting

**Export Data**
```bash
# Export to CSV
tshark -i any -T fields -e frame.number -e ip.src -e ip.dst -E header=y -E separator=, > output.csv

# Export to JSON
tshark -i any -T json > output.json

# Export to XML
tshark -i any -T pdml > output.xml

# Export specific fields
tshark -i any -T fields -e frame.time -e ip.src -e ip.dst -e tcp.port
```

## 🛠️ Advanced Techniques

### 1. Capture to File

**File Capture**
```bash
# Capture to pcap file
tshark -i any -w capture.pcap

# Capture with ring buffer
tshark -i any -w capture.pcap -b filesize:1000000 -b files:5

# Capture with time limit
tshark -i any -w capture.pcap -a duration:60

# Read from pcap file
tshark -r capture.pcap
```

### 2. Real-time Analysis

**Live Analysis**
```bash
# Real-time protocol analysis
tshark -i any -Y "http" -T fields -e http.host -e http.request.uri

# Real-time statistics
tshark -i any -q -z io,stat,1

# Real-time error detection
tshark -i any -Y "tcp.analysis.flags"
```

### 3. Performance Monitoring

**Network Performance**
```bash
# Monitor bandwidth usage
tshark -i any -q -z io,stat,1

# Monitor packet loss
tshark -i any -Y "tcp.analysis.retransmission"

# Monitor connection times
tshark -i any -q -z rtt,tcp
```

## 🔍 Troubleshooting Common Issues

### 1. Network Connectivity

**Connection Problems**
```bash
# Check for connection resets
tshark -i any -Y "tcp.flags.reset == 1"

# Check for connection timeouts
tshark -i any -Y "tcp.analysis.retransmission"

# Check for DNS resolution issues
tshark -i any -Y "dns.flags.response == 0"
```

### 2. Performance Issues

**Performance Analysis**
```bash
# Check for slow connections
tshark -i any -q -z rtt,tcp

# Check for packet loss
tshark -i any -Y "tcp.analysis.lost_segment"

# Check for duplicate packets
tshark -i any -Y "tcp.analysis.duplicate_ack"
```

### 3. Security Analysis

**Security Monitoring**
```bash
# Check for suspicious traffic
tshark -i any -Y "tcp.flags.syn == 1 and tcp.flags.ack == 0"

# Check for port scans
tshark -i any -Y "tcp.flags.syn == 1" -q -z conv,tcp

# Check for malformed packets
tshark -i any -Y "tcp.analysis.flags"
```

## 📋 Common Tshark Commands Reference

### Basic Capture
```bash
# List interfaces
tshark -D

# Capture on interface
tshark -i interface

# Capture with filter
tshark -i interface -f "filter"

# Capture with display filter
tshark -i interface -Y "display_filter"
```

### File Operations
```bash
# Read from file
tshark -r file.pcap

# Write to file
tshark -i interface -w file.pcap

# Read with filter
tshark -r file.pcap -Y "filter"
```

### Output Formats
```bash
# Default format
tshark -i interface

# Fields format
tshark -i interface -T fields -e field1 -e field2

# JSON format
tshark -i interface -T json

# XML format
tshark -i interface -T pdml
```

### Statistics
```bash
# Protocol hierarchy
tshark -i interface -q -z io,phs

# Conversations
tshark -i interface -q -z conv,tcp

# Endpoints
tshark -i interface -q -z endpoints,ip

# HTTP statistics
tshark -i interface -q -z http,tree
```

## 🚨 Security and Ethical Considerations

### Legal and Ethical Use
**✅ Appropriate Uses:**
- Analyzing your own network traffic
- Authorized network troubleshooting
- Security assessment with permission
- Educational purposes in controlled environments
- Performance monitoring and optimization

**❌ Inappropriate Uses:**
- Capturing traffic without authorization
- Analyzing other people's private data
- Bypassing security controls
- Unauthorized network monitoring
- Violating privacy laws or regulations

### Best Practices
1. **Get Permission**: Always obtain proper authorization before capturing traffic
2. **Use Filters**: Apply appropriate filters to minimize data collection
3. **Secure Storage**: Protect captured data with proper encryption
4. **Data Retention**: Follow data retention policies
5. **Privacy Protection**: Anonymize sensitive data when possible

## 🛠️ Troubleshooting Common Issues

### Permission Issues
```bash
# Run with sudo for raw socket access
sudo tshark -i any

# Add user to wireshark group
sudo usermod -a -G wireshark $USER
```

### Interface Issues
```bash
# List available interfaces
tshark -D

# Check interface status
ip link show

# Test interface
tshark -i interface -c 1
```

### Filter Issues
```bash
# Test capture filter
tshark -i any -f "port 80" -c 1

# Test display filter
tshark -i any -Y "http" -c 1

# Check filter syntax
tshark -i any -f "invalid_filter"
```

## 📚 Learning Exercises

### Exercise 1: Basic Packet Capture
```bash
# 1. List available interfaces
tshark -D

# 2. Capture 10 packets
tshark -i any -c 10

# 3. Capture HTTP traffic only
tshark -i any -f "port 80" -c 10
```

### Exercise 2: Protocol Analysis
```bash
# 1. Analyze HTTP traffic
tshark -i any -Y "http" -c 20

# 2. Analyze DNS traffic
tshark -i any -Y "dns" -c 10

# 3. Analyze TCP handshake
tshark -i any -Y "tcp.flags.syn == 1" -c 5
```

### Exercise 3: Statistical Analysis
```bash
# 1. Show protocol statistics
tshark -i any -q -z io,phs

# 2. Show conversation statistics
tshark -i any -q -z conv,tcp

# 3. Show HTTP statistics
tshark -i any -q -z http,tree
```

### Exercise 4: File Operations
```bash
# 1. Capture to file
tshark -i any -w exercise.pcap -c 50

# 2. Read from file
tshark -r exercise.pcap

# 3. Export to CSV
tshark -r exercise.pcap -T fields -e frame.number -e ip.src -e ip.dst > output.csv
```

## 🔗 Additional Resources

### Documentation
- [Tshark Manual](https://www.wireshark.org/docs/man-pages/tshark.html)
- [Wireshark Display Filters](https://www.wireshark.org/docs/dfref/)
- [BPF Capture Filters](https://www.wireshark.org/docs/man-pages/pcap-filter.html)

### Learning Resources
- [Wireshark University](https://www.wireshark.org/learn/)
- [Packet Analysis with Wireshark](https://www.wireshark.org/docs/)
- [Network Protocol Analysis](https://www.wireshark.org/docs/wsug_html/)

---

**Remember**: Always use tshark responsibly and only on networks you own or have explicit permission to monitor. Packet capture can reveal sensitive information and should be used ethically and legally.
