# Tshark Quick Reference

## Basic Commands

### Interface Management
```bash
# List available interfaces
tshark -D

# Show interface details
tshark -i any -c 0
```

### Basic Capture
```bash
# Capture on specific interface
tshark -i eth0

# Capture on any interface
tshark -i any

# Capture limited packets
tshark -i any -c 100

# Capture with timeout
tshark -i any -a duration:30
```

### Capture Filters (BPF Syntax)
```bash
# Port filters
tshark -i any -f "port 80"
tshark -i any -f "portrange 80-90"

# Host filters
tshark -i any -f "host 192.168.1.1"
tshark -i any -f "src host 192.168.1.1"
tshark -i any -f "dst host 192.168.1.1"

# Protocol filters
tshark -i any -f "tcp"
tshark -i any -f "udp"
tshark -i any -f "icmp"

# Network filters
tshark -i any -f "net 192.168.1.0/24"
tshark -i any -f "broadcast"
tshark -i any -f "multicast"

# Complex filters
tshark -i any -f "host 192.168.1.1 and port 80"
tshark -i any -f "tcp and port 80"
tshark -i any -f "udp and port 53"
```

### Display Filters (Wireshark Syntax)
```bash
# Protocol filters
tshark -i any -Y "http"
tshark -i any -Y "dns"
tshark -i any -Y "tcp"
tshark -i any -Y "udp"
tshark -i any -Y "icmp"

# IP filters
tshark -i any -Y "ip.addr == 192.168.1.1"
tshark -i any -Y "ip.src == 192.168.1.1"
tshark -i any -Y "ip.dst == 192.168.1.1"

# Port filters
tshark -i any -Y "tcp.port == 80"
tshark -i any -Y "udp.port == 53"
tshark -i any -Y "tcp.srcport == 80"

# HTTP filters
tshark -i any -Y "http.request"
tshark -i any -Y "http.response"
tshark -i any -Y "http.host == example.com"
tshark -i any -Y "http.request.uri contains login"

# DNS filters
tshark -i any -Y "dns.flags.response == 0"
tshark -i any -Y "dns.flags.response == 1"
tshark -i any -Y "dns.qry.name == example.com"

# TCP filters
tshark -i any -Y "tcp.flags.syn == 1"
tshark -i any -Y "tcp.flags.ack == 1"
tshark -i any -Y "tcp.flags.reset == 1"
tshark -i any -Y "tcp.analysis.retransmission"
```

## File Operations

### Capture to File
```bash
# Basic capture to file
tshark -i any -w capture.pcap

# Capture with ring buffer
tshark -i any -w capture.pcap -b filesize:1000000 -b files:5

# Capture with time limit
tshark -i any -w capture.pcap -a duration:60

# Capture with packet limit
tshark -i any -w capture.pcap -c 1000
```

### Read from File
```bash
# Read pcap file
tshark -r capture.pcap

# Read with display filter
tshark -r capture.pcap -Y "http"

# Read with capture filter
tshark -r capture.pcap -f "port 80"
```

### Export Formats
```bash
# Export to CSV
tshark -r capture.pcap -T fields -e frame.number -e ip.src -e ip.dst -E header=y -E separator=, > output.csv

# Export to JSON
tshark -r capture.pcap -T json > output.json

# Export to XML
tshark -r capture.pcap -T pdml > output.xml

# Export specific fields
tshark -r capture.pcap -T fields -e frame.time -e ip.src -e ip.dst -e tcp.port
```

## Statistical Analysis

### Protocol Statistics
```bash
# Protocol hierarchy
tshark -i any -q -z io,phs

# Conversations
tshark -i any -q -z conv,tcp
tshark -i any -q -z conv,udp
tshark -i any -q -z conv,ip

# Endpoints
tshark -i any -q -z endpoints,ip
tshark -i any -q -z endpoints,tcp
tshark -i any -q -z endpoints,udp

# Service response time
tshark -i any -q -z rtt,tcp
```

### Custom Statistics
```bash
# HTTP statistics
tshark -i any -q -z http,tree

# DNS statistics
tshark -i any -q -z dns,tree

# TCP flags
tshark -i any -q -z tcp,flags

# IO statistics
tshark -i any -q -z io,stat,1

# Protocol breakdown
tshark -i any -q -z ptype,tree
```

## Advanced Features

### Real-time Analysis
```bash
# Real-time protocol analysis
tshark -i any -Y "http" -T fields -e http.host -e http.request.uri

# Real-time statistics
tshark -i any -q -z io,stat,1

# Real-time error detection
tshark -i any -Y "tcp.analysis.flags"
```

### Performance Monitoring
```bash
# Bandwidth monitoring
tshark -i any -q -z io,stat,1

# Packet loss detection
tshark -i any -Y "tcp.analysis.retransmission"

# Connection time analysis
tshark -i any -q -z rtt,tcp
```

### Security Analysis
```bash
# Suspicious traffic
tshark -i any -Y "tcp.flags.syn == 1 and tcp.flags.ack == 0"

# Port scan detection
tshark -i any -Y "tcp.flags.syn == 1" -q -z conv,tcp

# Connection resets
tshark -i any -Y "tcp.flags.reset == 1"

# Malformed packets
tshark -i any -Y "tcp.analysis.flags"
```

## Common Use Cases

### Web Traffic Analysis
```bash
# HTTP requests and responses
tshark -i any -Y "http"

# HTTP headers
tshark -i any -Y "http" -T fields -e http.host -e http.request.uri

# HTTP status codes
tshark -i any -Y "http.response" -T fields -e http.response.code

# HTTPS traffic
tshark -i any -Y "ssl"
```

### DNS Analysis
```bash
# DNS queries
tshark -i any -Y "dns.flags.response == 0"

# DNS responses
tshark -i any -Y "dns.flags.response == 1"

# Specific DNS record types
tshark -i any -Y "dns.qry.type == 1"  # A records
tshark -i any -Y "dns.qry.type == 28" # AAAA records
```

### Network Troubleshooting
```bash
# Connection issues
tshark -i any -Y "tcp.flags.reset == 1"

# Performance issues
tshark -i any -Y "tcp.analysis.retransmission"

# DNS resolution issues
tshark -i any -Y "dns"

# ICMP errors
tshark -i any -Y "icmp"
```

## Output Options

### Field Selection
```bash
# Specific fields
tshark -i any -T fields -e frame.number -e ip.src -e ip.dst -e tcp.port

# Time fields
tshark -i any -T fields -e frame.time -e frame.time_relative

# Protocol fields
tshark -i any -T fields -e frame.protocols -e ip.proto -e tcp.flags
```

### Output Formatting
```bash
# Tab-separated
tshark -i any -T fields -e field1 -e field2

# Comma-separated
tshark -i any -T fields -e field1 -e field2 -E separator=,

# JSON format
tshark -i any -T json

# XML format
tshark -i any -T pdml
```

## Troubleshooting

### Common Issues
```bash
# Permission denied
sudo tshark -i any

# Interface not found
tshark -D  # List available interfaces

# Filter syntax error
tshark -i any -f "invalid_filter"  # Check syntax

# No packets captured
tshark -i any -c 1  # Test basic capture
```

### Debug Options
```bash
# Verbose output
tshark -i any -V

# Debug mode
tshark -i any -d

# Show capture info
tshark -i any -c 1 -v
```

## Tips and Tricks

### Efficient Capturing
```bash
# Use capture filters for efficiency
tshark -i any -f "port 80"  # More efficient than display filter

# Limit packet count
tshark -i any -c 100  # Stop after 100 packets

# Use time limits
tshark -i any -a duration:30  # Stop after 30 seconds
```

### Analysis Tips
```bash
# Combine filters
tshark -i any -f "port 80" -Y "http.request"

# Use statistics for overview
tshark -i any -q -z io,phs

# Export for further analysis
tshark -i any -T json > analysis.json
```

### Performance Tips
```bash
# Use ring buffers for long captures
tshark -i any -w capture.pcap -b filesize:1000000 -b files:5

# Use display filters for analysis
tshark -r capture.pcap -Y "http"  # More efficient than capture filter

# Limit output fields
tshark -i any -T fields -e ip.src -e ip.dst  # Only specific fields
```

---

**Note**: Always ensure you have proper permissions to capture network traffic and follow local laws and regulations regarding network monitoring.
