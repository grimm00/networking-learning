# Wireshark Quick Reference

## Essential Commands

### Basic Capture
```bash
# Capture on specific interface
tshark -i eth0

# Capture with count limit
tshark -i any -c 100

# Capture with time limit
tshark -i any -a duration:60

# Capture to file
tshark -i any -w capture.pcap

# Read from file
tshark -r capture.pcap
```

### Display Filters
```bash
# IP address filters
ip.addr == 192.168.1.100
ip.src == 192.168.1.100
ip.dst == 192.168.1.100

# Protocol filters
tcp
udp
icmp
arp
dns
http
https

# Port filters
tcp.port == 80
udp.port == 53
tcp.srcport == 80
tcp.dstport == 443

# Complex filters
tcp and ip.addr == 192.168.1.100
http and http.request.method == "GET"
dns and dns.flags.response == 0
```

### Capture Filters (BPF)
```bash
# Host filters
host 192.168.1.100
src host 192.168.1.100
dst host 192.168.1.100

# Network filters
net 192.168.1.0/24
src net 192.168.1.0/24
dst net 192.168.1.0/24

# Port filters
port 80
src port 80
dst port 80

# Protocol filters
tcp
udp
icmp
arp

# Complex filters
tcp port 80 and host 192.168.1.100
not broadcast and not multicast
```

## Common Display Filters

### IP and Network
```bash
# IP version
ip.version == 4
ip.version == 6

# IP addresses
ip.addr == 192.168.1.100
ip.src == 192.168.1.100
ip.dst == 192.168.1.100
ip.addr == 192.168.1.0/24

# IP options
ip.opt.type == 7
ip.frag_offset > 0
ip.ttl < 64
```

### TCP Analysis
```bash
# TCP flags
tcp.flags.syn == 1
tcp.flags.ack == 1
tcp.flags.fin == 1
tcp.flags.rst == 1
tcp.flags.urg == 1
tcp.flags.psh == 1

# TCP connection states
tcp.flags.syn == 1 and tcp.flags.ack == 0  # SYN
tcp.flags.syn == 1 and tcp.flags.ack == 1  # SYN-ACK
tcp.flags.fin == 1                          # FIN
tcp.flags.rst == 1                          # RST

# TCP analysis
tcp.analysis.retransmission
tcp.analysis.duplicate_ack
tcp.analysis.keep_alive
tcp.analysis.keep_alive_ack
tcp.analysis.zero_window
tcp.analysis.window_update
```

### UDP Analysis
```bash
# UDP ports
udp.port == 53
udp.srcport == 53
udp.dstport == 53

# UDP length
udp.length > 1000
udp.length < 100
```

### ICMP Analysis
```bash
# ICMP types
icmp.type == 0   # Echo Reply
icmp.type == 3   # Destination Unreachable
icmp.type == 8   # Echo Request
icmp.type == 11  # Time Exceeded

# ICMP codes
icmp.code == 0   # Network Unreachable
icmp.code == 1   # Host Unreachable
icmp.code == 3   # Port Unreachable
```

### DNS Analysis
```bash
# DNS queries
dns and dns.flags.response == 0
dns.qry.name contains "google"
dns.qry.type == 1    # A record
dns.qry.type == 28   # AAAA record
dns.qry.type == 15   # MX record

# DNS responses
dns and dns.flags.response == 1
dns.resp.name contains "google"
dns.flags.rcode == 0  # No error
dns.flags.rcode == 3  # NXDOMAIN
```

### HTTP Analysis
```bash
# HTTP requests
http.request
http.request.method == "GET"
http.request.method == "POST"
http.request.uri contains "login"
http.host contains "example.com"

# HTTP responses
http.response
http.response.code == 200
http.response.code == 404
http.response.code == 500

# HTTP headers
http.user_agent
http.referer
http.cookie
http.authorization
```

### HTTPS/TLS Analysis
```bash
# TLS handshake
tls.handshake.type == 1   # Client Hello
tls.handshake.type == 2   # Server Hello
tls.handshake.type == 11  # Certificate
tls.handshake.type == 16  # Client Key Exchange

# TLS versions
tls.record.version == 0x0301  # TLS 1.0
tls.record.version == 0x0302  # TLS 1.1
tls.record.version == 0x0303  # TLS 1.2
tls.record.version == 0x0304  # TLS 1.3

# TLS cipher suites
tls.handshake.ciphersuite
```

### DHCP Analysis
```bash
# DHCP messages
dhcp.option.dhcp == 1   # DISCOVER
dhcp.option.dhcp == 2   # OFFER
dhcp.option.dhcp == 3   # REQUEST
dhcp.option.dhcp == 4   # ACK
dhcp.option.dhcp == 5   # NAK

# DHCP options
dhcp.option.router
dhcp.option.domain_name_server
dhcp.option.lease_time
dhcp.option.subnet_mask
```

## Statistical Analysis

### Protocol Hierarchy
```bash
# Show protocol distribution
tshark -r capture.pcap -T fields -e frame.protocols | tr ',' '\n' | sort | uniq -c | sort -nr
```

### Conversations
```bash
# Show conversations
tshark -r capture.pcap -T fields -e ip.src -e ip.dst | sort | uniq -c | sort -nr
```

### Top Talkers
```bash
# Show top talkers by packets
tshark -r capture.pcap -T fields -e ip.src | sort | uniq -c | sort -nr

# Show top talkers by bytes
tshark -r capture.pcap -T fields -e ip.src -e frame.len | awk '{sum[$1]+=$2} END {for (i in sum) print sum[i], i}' | sort -nr
```

### Packet Size Analysis
```bash
# Show packet size distribution
tshark -r capture.pcap -T fields -e frame.len | sort -n | uniq -c | sort -nr
```

## Troubleshooting Filters

### Connection Issues
```bash
# TCP resets
tcp.flags.rst == 1

# Failed connections
tcp.flags.syn == 1 and tcp.flags.ack == 0 and tcp.flags.rst == 1

# Retransmissions
tcp.analysis.retransmission

# Duplicate ACKs
tcp.analysis.duplicate_ack
```

### Performance Issues
```bash
# Large packets
frame.len > 1500

# Small packets
frame.len < 64

# TCP window size issues
tcp.window_size < 1000

# TCP zero window
tcp.analysis.zero_window
```

### Security Issues
```bash
# Suspicious ports
tcp.port in {23, 21, 135, 139, 445, 1433, 3389}

# Port scans
tcp.flags.syn == 1 and tcp.flags.ack == 0

# Failed authentication
tcp.port == 22 and tcp.flags.rst == 1

# Unusual traffic patterns
not (tcp or udp or icmp or arp)
```

## Export and Analysis

### Export to Different Formats
```bash
# Export to CSV
tshark -r capture.pcap -T fields -e frame.number -e ip.src -e ip.dst -e frame.protocols -E header=y -E separator=, > output.csv

# Export to JSON
tshark -r capture.pcap -T json > output.json

# Export to XML
tshark -r capture.pcap -T pdml > output.xml

# Export specific fields
tshark -r capture.pcap -T fields -e frame.number -e ip.src -e ip.dst -e tcp.port -e http.request.method
```

### Follow Streams
```bash
# Follow TCP stream
tshark -r capture.pcap -T fields -e tcp.stream | sort -n | uniq

# Follow UDP stream
tshark -r capture.pcap -T fields -e udp.stream | sort -n | uniq
```

### Extract Files
```bash
# Extract HTTP objects
tshark -r capture.pcap --export-objects http,/path/to/output/

# Extract FTP files
tshark -r capture.pcap --export-objects ftp,/path/to/output/
```

## Performance Optimization

### Capture Optimization
```bash
# Use capture filters
tshark -i any -f "host 192.168.1.100" -w capture.pcap

# Limit packet size
tshark -i any -s 96 -w capture.pcap

# Use ring buffer
tshark -i any -b filesize:100000 -b files:10 -w capture.pcap
```

### Analysis Optimization
```bash
# Use display filters early
tshark -r capture.pcap -Y "tcp and ip.addr == 192.168.1.100"

# Limit output
tshark -r capture.pcap -c 100

# Use specific fields
tshark -r capture.pcap -T fields -e frame.number -e ip.src -e ip.dst
```

## Common Use Cases

### Web Traffic Analysis
```bash
# HTTP traffic
tshark -r capture.pcap -Y "http"

# HTTPS traffic
tshark -r capture.pcap -Y "tls or ssl"

# Specific website
tshark -r capture.pcap -Y "http.host contains 'example.com'"

# POST requests
tshark -r capture.pcap -Y "http.request.method == 'POST'"
```

### Network Troubleshooting
```bash
# ICMP errors
tshark -r capture.pcap -Y "icmp.type == 3"

# DNS issues
tshark -r capture.pcap -Y "dns and dns.flags.response == 0"

# ARP issues
tshark -r capture.pcap -Y "arp"

# DHCP issues
tshark -r capture.pcap -Y "dhcp"
```

### Security Analysis
```bash
# Port scans
tshark -r capture.pcap -Y "tcp.flags.syn == 1 and tcp.flags.ack == 0"

# Failed connections
tshark -r capture.pcap -Y "tcp.flags.rst == 1"

# Large data transfers
tshark -r capture.pcap -Y "frame.len > 1500"

# Suspicious protocols
tshark -r capture.pcap -Y "tcp.port in {23, 21, 135, 139, 445}"
```

## Keyboard Shortcuts (GUI)

### Navigation
- **Up/Down Arrow**: Move between packets
- **Page Up/Down**: Move by page
- **Home/End**: Go to first/last packet
- **Ctrl+G**: Go to specific packet number
- **Ctrl+F**: Find packets

### Analysis
- **Ctrl+Shift+F**: Find in packet details
- **Ctrl+E**: Follow stream
- **Ctrl+Shift+E**: Follow stream (reverse)
- **Ctrl+Alt+Shift+F**: Find next
- **Ctrl+Alt+Shift+B**: Find previous

### Display
- **Ctrl+Plus**: Zoom in
- **Ctrl+Minus**: Zoom out
- **Ctrl+0**: Reset zoom
- **Ctrl+Shift+C**: Colorize packets
- **Ctrl+Shift+H**: Hide/show packet bytes

### Capture
- **Ctrl+E**: Start/stop capture
- **Ctrl+K**: Capture options
- **Ctrl+Shift+K**: Restart capture
- **Ctrl+Shift+E**: Stop capture

## File Formats

### Supported Input Formats
- **PCAP**: Traditional packet capture format
- **PCAPNG**: Next generation packet capture format
- **PEF**: Peek format
- **Snoop**: Sun snoop format
- **NetMon**: Microsoft NetMon format
- **DMP**: Microsoft DMP format

### Supported Output Formats
- **PCAP**: Traditional packet capture format
- **PCAPNG**: Next generation packet capture format
- **CSV**: Comma-separated values
- **JSON**: JavaScript Object Notation
- **XML**: Extensible Markup Language
- **PDML**: Packet Details Markup Language
- **PSML**: Packet Summary Markup Language

## Best Practices

### Capture Planning
1. **Define objectives**: What are you trying to analyze?
2. **Choose appropriate interface**: Wired vs wireless
3. **Set capture filters**: Reduce noise
4. **Plan storage**: Sufficient disk space
5. **Consider duration**: How long to capture?

### Analysis Methodology
1. **Start broad**: Look at overall traffic patterns
2. **Narrow down**: Use filters to focus
3. **Document findings**: Take notes and screenshots
4. **Verify conclusions**: Cross-check with other tools

### Performance Optimization
1. **Use capture filters**: Reduce processing load
2. **Limit capture size**: Prevent memory issues
3. **Close unnecessary applications**: Free up resources
4. **Use dedicated hardware**: For high-speed networks

### Security Considerations
1. **Be aware of sensitive data**: Some packets may contain passwords
2. **Use appropriate permissions**: Don't capture as root unnecessarily
3. **Secure capture files**: Protect captured data
4. **Follow privacy policies**: Respect user privacy

## Troubleshooting

### Common Issues
1. **No packets captured**: Check interface selection and permissions
2. **Performance issues**: Use capture filters and optimize settings
3. **Display issues**: Check file integrity and protocol support
4. **Permission errors**: Add user to wireshark group or use sudo

### Diagnostic Commands
```bash
# Check interface status
ip link show

# Check permissions
groups
ls -l /usr/bin/tshark

# Test capture
tshark -i any -c 1 -f "icmp"

# Check disk space
df -h

# Check memory usage
free -h
```

### Getting Help
- **Wireshark Documentation**: https://www.wireshark.org/docs/
- **User Guide**: https://www.wireshark.org/docs/wsug_html/
- **Developer Guide**: https://www.wireshark.org/docs/wsdg_html/
- **Sample Captures**: https://wiki.wireshark.org/SampleCaptures
- **Display Filters**: https://wiki.wireshark.org/DisplayFilters
