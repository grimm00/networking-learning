# TCP/UDP Quick Reference

## Essential Commands

### Connection Analysis
```bash
# View all TCP connections
netstat -tuln
ss -tuln

# View all UDP connections
netstat -uln
ss -uln

# View specific connection states
ss -tuln state established
ss -tuln state listening
ss -tuln state time-wait

# View connection statistics
ss -s
netstat -s
```

### Traffic Monitoring
```bash
# Capture TCP traffic
tcpdump -i any -n tcp
tcpdump -i any -n tcp port 80

# Capture UDP traffic
tcpdump -i any -n udp
tcpdump -i any -n udp port 53

# Capture specific host traffic
tcpdump -i any -n 'host 192.168.1.100'
tcpdump -i any -n 'tcp and host 192.168.1.100'
```

### Connection Testing
```bash
# Test TCP connection
nc -v hostname port
telnet hostname port
curl -v http://hostname:port

# Test UDP connection
nc -u -v hostname port
nc -u hostname port

# Test specific services
dig @8.8.8.8 google.com          # DNS
nc -u pool.ntp.org 123          # NTP
nc -u localhost 67              # DHCP
```

### Port Scanning
```bash
# Scan TCP ports
nc -z hostname 80 443 22
for port in {1..1000}; do nc -z hostname $port; done

# Scan UDP ports
nc -u -z hostname 53 67 123
for port in 53 67 68 123 161; do nc -u -z hostname $port; done
```

## TCP Protocol

### TCP Header Fields
- **Source Port** (16 bits): Source application port
- **Destination Port** (16 bits): Destination application port
- **Sequence Number** (32 bits): Byte sequence number
- **Acknowledgment Number** (32 bits): Next expected sequence
- **Header Length** (4 bits): TCP header length in 32-bit words
- **Flags** (6 bits): SYN, ACK, FIN, RST, PSH, URG
- **Window Size** (16 bits): Receive window size
- **Checksum** (16 bits): Header and data checksum
- **Urgent Pointer** (16 bits): Points to urgent data

### TCP Connection States
- **LISTEN**: Server waiting for connections
- **SYN_SENT**: Client sent SYN, waiting for SYN-ACK
- **SYN_RECEIVED**: Server received SYN, sent SYN-ACK
- **ESTABLISHED**: Connection established, data transfer
- **FIN_WAIT_1**: Client initiated connection close
- **FIN_WAIT_2**: Client waiting for server's FIN
- **CLOSE_WAIT**: Server received FIN, waiting to close
- **LAST_ACK**: Server sent FIN, waiting for ACK
- **TIME_WAIT**: Client waiting for final ACK
- **CLOSED**: Connection closed

### TCP Three-Way Handshake
```
Client                     Server
  |                         |
  |        SYN             |
  |------------------------>|
  |                         |
  |      SYN-ACK           |
  |<------------------------|
  |                         |
  |        ACK             |
  |------------------------>|
  |                         |
  |    Data Transfer       |
  |<----------------------->|
```

### TCP Flags
- **SYN**: Synchronize sequence numbers
- **ACK**: Acknowledgment field significant
- **FIN**: No more data from sender
- **RST**: Reset the connection
- **PSH**: Push function
- **URG**: Urgent pointer field significant

## UDP Protocol

### UDP Header Fields
- **Source Port** (16 bits): Source application port
- **Destination Port** (16 bits): Destination application port
- **Length** (16 bits): UDP header and data length
- **Checksum** (16 bits): Header and data checksum
- **Data** (variable): Application data

### UDP Characteristics
- **Connectionless**: No connection establishment
- **Unreliable**: No delivery guarantees
- **Fast**: Minimal overhead
- **Simple**: Basic error checking only
- **Stateless**: No connection state maintained

### UDP Communication Flow
```
Client                     Server
  |                         |
  |        UDP Packet      |
  |------------------------>|
  |                         |
  |    (No acknowledgment) |
  |                         |
  |        UDP Packet      |
  |<------------------------|
  |                         |
```

## Common Ports

### TCP Ports
- **20**: FTP Data
- **21**: FTP Control
- **22**: SSH
- **23**: Telnet
- **25**: SMTP
- **53**: DNS (TCP)
- **80**: HTTP
- **110**: POP3
- **143**: IMAP
- **443**: HTTPS
- **993**: IMAPS
- **995**: POP3S

### UDP Ports
- **53**: DNS
- **67**: DHCP Server
- **68**: DHCP Client
- **69**: TFTP
- **123**: NTP
- **161**: SNMP
- **162**: SNMP Trap
- **514**: Syslog
- **631**: IPP (Internet Printing Protocol)

## Protocol Comparison

| Feature | TCP | UDP |
|---------|-----|-----|
| **Connection** | Connection-oriented | Connectionless |
| **Reliability** | Guaranteed delivery | Best effort |
| **Ordering** | Guaranteed order | No ordering |
| **Error Detection** | Checksum + acknowledgments | Checksum only |
| **Flow Control** | Yes (sliding window) | No |
| **Congestion Control** | Yes | No |
| **Overhead** | High | Low |
| **Speed** | Slower | Faster |
| **Use Cases** | Web, email, file transfer | Video, gaming, DNS |

## Troubleshooting Commands

### Basic Connectivity
```bash
# Test basic connectivity
ping hostname
ping -c 4 hostname

# Trace network path
traceroute hostname
tracepath hostname

# Check DNS resolution
nslookup hostname
dig hostname
```

### Service Testing
```bash
# Test HTTP service
curl -v http://hostname:port
wget --spider http://hostname:port

# Test HTTPS service
curl -v https://hostname:port
openssl s_client -connect hostname:port

# Test SSH service
ssh -v hostname
ssh -p port hostname
```

### System Analysis
```bash
# View system processes
ps aux | grep service
top
htop

# View system resources
free -h
df -h
iostat

# View network interfaces
ip link show
ip addr show
ip route show
```

## Performance Monitoring

### Network Statistics
```bash
# View network interface statistics
netstat -i
ip -s link show

# View TCP statistics
cat /proc/net/tcp
ss -s

# View UDP statistics
cat /proc/net/udp
netstat -su
```

### Real-time Monitoring
```bash
# Monitor connections
watch -n 1 'ss -tuln'
watch -n 1 'netstat -tuln'

# Monitor traffic
iftop
nethogs
bmon

# Monitor system resources
htop
iotop
```

## Security Considerations

### Firewall Rules
```bash
# View iptables rules
iptables -L -n -v
iptables -t nat -L -n -v

# View UFW rules
ufw status
ufw status verbose
```

### Port Security
```bash
# Check open ports
nmap -sS hostname
nmap -sU hostname

# Check listening services
lsof -i
netstat -tuln
ss -tuln
```

## Useful Files

### System Files
- `/proc/net/tcp`: TCP connection table
- `/proc/net/udp`: UDP connection table
- `/proc/net/netstat`: Network statistics
- `/proc/net/snmp`: SNMP statistics
- `/etc/resolv.conf`: DNS configuration
- `/etc/hosts`: Host file
- `/etc/services`: Port/service mapping

### Log Files
- `/var/log/syslog`: System log
- `/var/log/kern.log`: Kernel log
- `/var/log/auth.log`: Authentication log
- `/var/log/nginx/access.log`: Nginx access log
- `/var/log/apache2/access.log`: Apache access log

## Best Practices

### TCP Optimization
- Use appropriate window sizes
- Enable TCP window scaling
- Configure TCP congestion control
- Use keep-alive for idle connections
- Monitor TCP retransmissions

### UDP Optimization
- Implement application-level reliability
- Use appropriate packet sizes
- Handle packet loss gracefully
- Implement rate limiting
- Monitor UDP errors

### Security
- Use firewalls to restrict access
- Monitor network traffic
- Keep services updated
- Use encryption when possible
- Implement access controls

### Monitoring
- Monitor connection counts
- Track performance metrics
- Log network events
- Set up alerts
- Regular health checks
