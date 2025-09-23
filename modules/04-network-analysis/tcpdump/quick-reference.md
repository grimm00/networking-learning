# tcpdump Quick Reference

Essential tcpdump commands and filters for network analysis and troubleshooting.

## Basic Commands

### Capture Commands
```bash
# Basic capture
sudo tcpdump -i eth0

# Capture specific number of packets
sudo tcpdump -i eth0 -c 100

# Capture and save to file
sudo tcpdump -i eth0 -w capture.pcap

# Read from file
tcpdump -r capture.pcap

# Verbose output
sudo tcpdump -i eth0 -v
sudo tcpdump -i eth0 -vv
sudo tcpdump -i eth0 -vvv
```

### Output Control
```bash
# No hostname resolution (faster)
sudo tcpdump -i eth0 -n

# No port name resolution
sudo tcpdump -i eth0 -nn

# Show absolute sequence numbers
sudo tcpdump -i eth0 -S

# Show packet timestamps
sudo tcpdump -i eth0 -tt

# Show packet data
sudo tcpdump -i eth0 -A    # ASCII
sudo tcpdump -i eth0 -X    # Hex and ASCII
sudo tcpdump -i eth0 -XX   # Hex and ASCII with Ethernet header
```

## Basic Filters

### Host Filters
```bash
# Traffic to/from specific host
sudo tcpdump -i eth0 host 192.168.1.100

# Traffic from specific host
sudo tcpdump -i eth0 src host 192.168.1.100

# Traffic to specific host
sudo tcpdump -i eth0 dst host 192.168.1.100

# Traffic to/from network
sudo tcpdump -i eth0 net 192.168.1.0/24
```

### Port Filters
```bash
# Traffic on specific port
sudo tcpdump -i eth0 port 80

# Traffic on port range
sudo tcpdump -i eth0 portrange 1024-65535

# Traffic from specific port
sudo tcpdump -i eth0 src port 80

# Traffic to specific port
sudo tcpdump -i eth0 dst port 80
```

### Protocol Filters
```bash
# TCP traffic
sudo tcpdump -i eth0 tcp

# UDP traffic
sudo tcpdump -i eth0 udp

# ICMP traffic
sudo tcpdump -i eth0 icmp

# ARP traffic
sudo tcpdump -i eth0 arp
```

## Advanced Filters

### Combined Filters
```bash
# HTTP traffic to specific host
sudo tcpdump -i eth0 'host 192.168.1.100 and port 80'

# TCP traffic on port 80 or 443
sudo tcpdump -i eth0 'tcp and (port 80 or port 443)'

# Traffic from specific network to port 80
sudo tcpdump -i eth0 'src net 192.168.1.0/24 and dst port 80'
```

### Exclusion Filters
```bash
# All traffic except SSH
sudo tcpdump -i eth0 'not port 22'

# All traffic except specific host
sudo tcpdump -i eth0 'not host 192.168.1.100'

# All traffic except specific network
sudo tcpdump -i eth0 'not net 192.168.1.0/24'
```

### TCP Flags
```bash
# SYN packets (connection initiation)
sudo tcpdump -i eth0 'tcp[tcpflags] & tcp-syn != 0'

# ACK packets (acknowledgments)
sudo tcpdump -i eth0 'tcp[tcpflags] & tcp-ack != 0'

# FIN packets (connection termination)
sudo tcpdump -i eth0 'tcp[tcpflags] & tcp-fin != 0'

# RST packets (connection reset)
sudo tcpdump -i eth0 'tcp[tcpflags] & tcp-rst != 0'

# SYN-ACK packets (handshake response)
sudo tcpdump -i eth0 'tcp[tcpflags] & tcp-syn != 0 and tcp[tcpflags] & tcp-ack != 0'
```

## Common Use Cases

### Web Traffic Analysis
```bash
# HTTP traffic
sudo tcpdump -i eth0 'tcp port 80' -A

# HTTPS traffic
sudo tcpdump -i eth0 'tcp port 443'

# HTTP GET requests
sudo tcpdump -i eth0 -A 'tcp port 80 and tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x47455420'

# HTTP POST requests
sudo tcpdump -i eth0 -A 'tcp port 80 and tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x504f5354'
```

### DNS Analysis
```bash
# DNS queries
sudo tcpdump -i eth0 'udp port 53' -A

# DNS responses
sudo tcpdump -i eth0 'udp port 53 and udp[10] & 0x80 = 0x80'

# DNS to specific server
sudo tcpdump -i eth0 'udp port 53 and host 8.8.8.8'
```

### Network Troubleshooting
```bash
# Connectivity test
sudo tcpdump -i eth0 'host 8.8.8.8'

# Check for packet loss
sudo tcpdump -i eth0 'icmp and host 8.8.8.8'

# Monitor connection attempts
sudo tcpdump -i eth0 'tcp[tcpflags] & tcp-syn != 0'

# Check for connection resets
sudo tcpdump -i eth0 'tcp[tcpflags] & tcp-rst != 0'
```

### Security Monitoring
```bash
# Port scanning detection
sudo tcpdump -i eth0 'tcp[tcpflags] & tcp-syn != 0 and tcp[tcpflags] & tcp-ack = 0' -c 10

# Failed SSH attempts
sudo tcpdump -i eth0 'tcp port 22 and tcp[13] & 0x04 = 0x04'

# Suspicious traffic
sudo tcpdump -i eth0 'portrange 10000-65535'

# Monitor specific host
sudo tcpdump -i eth0 'host suspicious-ip'
```

## Performance Optimization

### Buffer Management
```bash
# Increase buffer size
sudo tcpdump -i eth0 -B 4096

# Ring buffer for continuous capture
sudo tcpdump -i eth0 -w capture_%Y%m%d_%H%M%S.pcap -G 3600 -W 24

# Limit file size
sudo tcpdump -i eth0 -w capture.pcap -C 100  # 100MB files
```

### Filtering for Performance
```bash
# Use specific filters
sudo tcpdump -i eth0 'host 192.168.1.100 and port 80'

# Avoid hostname resolution
sudo tcpdump -i eth0 -n 'tcp port 80'

# Limit packet size
sudo tcpdump -i eth0 -s 96  # Capture only first 96 bytes
```

## Analysis Commands

### Basic Statistics
```bash
# Count packets
tcpdump -r capture.pcap | wc -l

# Protocol breakdown
tcpdump -r capture.pcap -n | awk '{print $1}' | sort | uniq -c | sort -nr

# Top hosts
tcpdump -r capture.pcap -n | awk '{print $3, $5}' | sed 's/:.*//' | sort | uniq -c | sort -nr | head -10

# Port usage
tcpdump -r capture.pcap -n | awk '{print $5}' | sed 's/.*\.//' | sort | uniq -c | sort -nr | head -10
```

### Error Detection
```bash
# Check for errors
tcpdump -r capture.pcap | grep -i "error\|reset\|unreachable"

# Count RST packets
tcpdump -r capture.pcap 'tcp[tcpflags] & tcp-rst != 0' | wc -l

# Check for ICMP errors
tcpdump -r capture.pcap 'icmp[0] = 3'  # Destination Unreachable
```

## Useful Scripts

### Continuous Monitoring
```bash
#!/bin/bash
# Monitor traffic with rotation
sudo tcpdump -i eth0 -w traffic_%Y%m%d_%H%M%S.pcap -G 3600 -W 24
```

### Traffic Analysis
```bash
#!/bin/bash
# Analyze capture file
PCAP_FILE="$1"
echo "Total packets: $(tcpdump -r $PCAP_FILE | wc -l)"
echo "Protocols:"
tcpdump -r $PCAP_FILE -n | awk '{print $1}' | sort | uniq -c | sort -nr
```

### Real-time Monitoring
```bash
#!/bin/bash
# Real-time traffic monitor
sudo tcpdump -i eth0 -n -c 100 | while read line; do
    echo "$(date): $line"
done
```

## Troubleshooting Tips

### Common Issues
- **No packets captured**: Check interface name and permissions
- **Too much traffic**: Use filters to reduce noise
- **Performance issues**: Use specific filters and avoid hostname resolution
- **File too large**: Use packet size limits and file rotation

### Best Practices
- Always use filters when possible
- Use `-n` flag for better performance
- Save captures for later analysis
- Use `-A` or `-X` to see packet contents
- Monitor disk space when capturing to files

### Safety Notes
- Only capture on networks you own or have permission to monitor
- Respect privacy laws and regulations
- Use captured data responsibly
- Be aware of data protection requirements

---

## Quick Commands Reference

| Purpose | Command |
|---------|---------|
| Basic capture | `sudo tcpdump -i eth0` |
| Save to file | `sudo tcpdump -i eth0 -w file.pcap` |
| Read from file | `tcpdump -r file.pcap` |
| HTTP traffic | `sudo tcpdump -i eth0 'tcp port 80'` |
| DNS traffic | `sudo tcpdump -i eth0 'udp port 53'` |
| Ping traffic | `sudo tcpdump -i eth0 icmp` |
| Specific host | `sudo tcpdump -i eth0 'host 192.168.1.100'` |
| No resolution | `sudo tcpdump -i eth0 -n` |
| Verbose | `sudo tcpdump -i eth0 -v` |
| Show data | `sudo tcpdump -i eth0 -A` |
