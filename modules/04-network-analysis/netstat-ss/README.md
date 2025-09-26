# Network Analysis: netstat and ss

## What You'll Learn

This module covers the essential network analysis tools `netstat` and `ss` (Socket Statistics), which are critical for:
- **Real-time network monitoring** and connection analysis
- **Troubleshooting network issues** and performance problems
- **Security analysis** and identifying suspicious connections
- **Understanding modern vs legacy** network analysis approaches

## Key Concepts

### netstat vs ss: The Evolution
- **netstat**: Legacy tool, part of net-tools package
- **ss**: Modern replacement, part of iproute2 package
- **Performance**: ss is significantly faster and more efficient
- **Features**: ss provides more detailed information and better filtering

### Network Connection States
- **TCP States**: LISTEN, ESTABLISHED, SYN_SENT, SYN_RECV, FIN_WAIT_1, FIN_WAIT_2, TIME_WAIT, CLOSE_WAIT, LAST_ACK, CLOSING
- **UDP States**: UNCONN (unconnected), CONNECTED
- **Unix Sockets**: LISTENING, CONNECTED

### Socket Types and Families
- **TCP Sockets**: Stream sockets with reliable, ordered communication
- **UDP Sockets**: Datagram sockets with connectionless communication
- **Unix Sockets**: Local inter-process communication
- **Raw Sockets**: Direct access to network protocols

## Detailed Explanations

### netstat Command Deep Dive

#### Basic Syntax and Options
```bash
netstat [options]
```

#### Key Options Explained
- **`-t`**: Show TCP connections
- **`-u`**: Show UDP connections
- **`-n`**: Show numerical addresses instead of resolving hosts
- **`-a`**: Show all sockets (listening and non-listening)
- **`-l`**: Show only listening sockets
- **`-p`**: Show process ID and name
- **`-r`**: Show routing table
- **`-i`**: Show network interface statistics
- **`-s`**: Show network statistics
- **`-c`**: Continuous output (refresh every second)

#### Understanding netstat Output

**TCP Connections:**
```
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 192.168.1.100:22       192.168.1.50:54321      ESTABLISHED   1234/sshd
tcp        0      0 0.0.0.0:80             0.0.0.0:*               LISTEN       5678/nginx
```

**Column Explanations:**
- **Proto**: Protocol (tcp, udp, unix)
- **Recv-Q**: Bytes not copied by user program
- **Send-Q**: Bytes not acknowledged by remote host
- **Local Address**: Local IP:port
- **Foreign Address**: Remote IP:port
- **State**: Connection state
- **PID/Program name**: Process using the socket

**UDP Connections:**
```
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
udp        0      0 0.0.0.0:53             0.0.0.0:*                           1234/named
udp        0      0 192.168.1.100:123      8.8.8.8:123            ESTABLISHED   5678/ntpd
```

### ss Command Deep Dive

#### Basic Syntax and Options
```bash
ss [options] [filter]
```

#### Key Options Explained
- **`-t`**: Show TCP sockets
- **`-u`**: Show UDP sockets
- **`-n`**: Don't resolve service names
- **`-a`**: Show all sockets
- **`-l`**: Show only listening sockets
- **`-p`**: Show process information
- **`-o`**: Show timer information
- **`-i`**: Show internal TCP information
- **`-e`**: Show detailed socket information
- **`-m`**: Show socket memory usage
- **`-s`**: Show summary statistics

#### Advanced ss Filtering
```bash
# Filter by state
ss -t state established
ss -t state listening

# Filter by port
ss -t sport :80
ss -t dport :443

# Filter by address
ss -t src 192.168.1.100
ss -t dst 8.8.8.8

# Complex filters
ss -t '( dport = :80 or dport = :443 )'
ss -t state established '( dport = :80 or dport = :443 )'
```

#### Understanding ss Output

**TCP Connections:**
```
State      Recv-Q Send-Q Local Address:Port       Peer Address:Port
ESTAB      0      0      192.168.1.100:22        192.168.1.50:54321
LISTEN     0      128    0.0.0.0:80              0.0.0.0:*
```

**Detailed ss Output:**
```
State      Recv-Q Send-Q Local Address:Port       Peer Address:Port       Process
ESTAB      0      0      192.168.1.100:22        192.168.1.50:54321      users:(("sshd",pid=1234,fd=3))
LISTEN     0      128    0.0.0.0:80              0.0.0.0:*               users:(("nginx",pid=5678,fd=6))
```

### Network Statistics Analysis

#### Interface Statistics
```bash
# netstat interface statistics
netstat -i

# ss summary statistics
ss -s
```

**Understanding Interface Stats:**
- **RX-OK**: Successfully received packets
- **RX-ERR**: Receive errors
- **RX-DRP**: Dropped packets
- **TX-OK**: Successfully transmitted packets
- **TX-ERR**: Transmission errors
- **TX-DRP**: Dropped packets

#### Protocol Statistics
```bash
# Detailed protocol statistics
netstat -s
```

**Key TCP Statistics:**
- **Active Opens**: Number of SYN packets sent
- **Passive Opens**: Number of SYN packets received
- **Segments Retransmitted**: Retransmission count
- **Bad Segments**: Corrupted segments received
- **Connection Drops**: Connections dropped due to errors

## Practical Examples

### Basic Network Monitoring
```bash
# Show all active TCP connections
ss -tuna

# Show listening ports
ss -tuln

# Show connections with process info
ss -tunap

# Monitor connections continuously
watch -n 1 'ss -tuna'
```

### Troubleshooting Network Issues
```bash
# Check if a port is listening
ss -tuln | grep :80

# Find processes using specific ports
ss -tunap | grep :80

# Check for connection issues
ss -tuna | grep -E "(SYN-SENT|SYN-RECV|FIN-WAIT)"

# Monitor connection states
ss -tuna | awk '{print $1}' | sort | uniq -c
```

### Security Analysis
```bash
# Find suspicious connections
ss -tuna | grep -v 127.0.0.1 | grep -v 192.168

# Check for unusual listening ports
ss -tuln | grep -v -E ":(22|80|443|53|25|110|143|993|995)"

# Monitor connection attempts
ss -tuna | grep SYN-SENT
```

### Performance Analysis
```bash
# Check socket memory usage
ss -m

# Monitor connection counts
ss -s

# Check for connection leaks
ss -tuna | grep TIME-WAIT | wc -l
```

## Advanced Usage Patterns

### Continuous Monitoring Scripts
```bash
#!/bin/bash
# Monitor network connections
while true; do
    echo "=== $(date) ==="
    ss -tuna | awk '{print $1}' | sort | uniq -c
    sleep 5
done
```

### Connection Analysis
```bash
#!/bin/bash
# Analyze connection patterns
echo "=== Connection States ==="
ss -tuna | awk '{print $1}' | sort | uniq -c

echo "=== Top Remote Addresses ==="
ss -tuna | awk '{print $4}' | cut -d: -f1 | sort | uniq -c | sort -nr | head -10

echo "=== Top Ports ==="
ss -tuna | awk '{print $4}' | cut -d: -f2 | sort | uniq -c | sort -nr | head -10
```

### Automated Alerts
```bash
#!/bin/bash
# Alert on suspicious activity
CONNECTIONS=$(ss -tuna | grep -v 127.0.0.1 | wc -l)
if [ $CONNECTIONS -gt 100 ]; then
    echo "ALERT: High number of external connections: $CONNECTIONS"
fi
```

## Troubleshooting Common Issues

### High Connection Counts
**Symptoms:**
- System becomes slow
- High memory usage
- Network timeouts

**Diagnosis:**
```bash
# Check total connections
ss -s

# Check connection states
ss -tuna | awk '{print $1}' | sort | uniq -c

# Check for connection leaks
ss -tuna | grep TIME-WAIT | wc -l
```

**Solutions:**
- Adjust TCP timeout settings
- Implement connection pooling
- Check for application bugs

### Port Binding Issues
**Symptoms:**
- Service fails to start
- "Address already in use" errors

**Diagnosis:**
```bash
# Check what's using a port
ss -tuln | grep :80
ss -tunap | grep :80

# Check for zombie processes
ps aux | grep defunct
```

**Solutions:**
- Kill the process using the port
- Change the port number
- Use SO_REUSEADDR socket option

### Network Performance Issues
**Symptoms:**
- Slow network transfers
- High latency
- Packet loss

**Diagnosis:**
```bash
# Check interface statistics
netstat -i

# Check protocol statistics
netstat -s | grep -i retrans

# Monitor connection states
ss -tuna | grep -E "(SYN-SENT|SYN-RECV)"
```

**Solutions:**
- Adjust TCP window sizes
- Check network hardware
- Optimize application settings

## Lab Exercises

### Exercise 1: Basic Network Analysis
**Goal**: Learn basic netstat and ss usage
**Steps**:
1. Start a web server: `python3 -m http.server 8000`
2. Use `ss -tuln` to find the listening port
3. Connect to the server: `curl localhost:8000`
4. Use `ss -tuna` to see the established connection
5. Compare output between netstat and ss

### Exercise 2: Connection State Analysis
**Goal**: Understand different connection states
**Steps**:
1. Start multiple services (SSH, HTTP, DNS)
2. Use `ss -tuna` to identify different states
3. Create connections and observe state changes
4. Document the state transitions

### Exercise 3: Security Analysis
**Goal**: Identify potential security issues
**Steps**:
1. Use `ss -tuna` to find external connections
2. Identify unusual listening ports
3. Check for suspicious connection patterns
4. Create a security report

### Exercise 4: Performance Monitoring
**Goal**: Monitor network performance
**Steps**:
1. Create a monitoring script using ss
2. Track connection counts over time
3. Identify performance bottlenecks
4. Implement automated alerts

### Exercise 5: Troubleshooting Practice
**Goal**: Practice real-world troubleshooting
**Steps**:
1. Simulate network issues
2. Use netstat/ss to diagnose problems
3. Implement solutions
4. Verify fixes

### Exercise 6: Advanced Filtering
**Goal**: Master advanced ss filtering
**Steps**:
1. Practice complex ss filters
2. Create custom monitoring scripts
3. Implement automated analysis
4. Build a network dashboard

## Quick Reference

### Essential Commands
```bash
# Basic connection listing
ss -tuna                    # All TCP/UDP connections
ss -tuln                    # Listening sockets
ss -tunap                   # With process info

# State filtering
ss -t state established     # Established connections
ss -t state listening       # Listening sockets
ss -t state time-wait       # Time-wait connections

# Port filtering
ss -t sport :80             # Source port 80
ss -t dport :443            # Destination port 443
ss -t '( dport = :80 or dport = :443 )'  # Multiple ports

# Address filtering
ss -t src 192.168.1.100     # Source address
ss -t dst 8.8.8.8           # Destination address

# Statistics
ss -s                       # Summary statistics
netstat -i                  # Interface statistics
netstat -s                  # Protocol statistics
```

### Common Use Cases
```bash
# Find what's using port 80
ss -tunap | grep :80

# Monitor connections continuously
watch -n 1 'ss -tuna'

# Check for connection leaks
ss -tuna | grep TIME-WAIT | wc -l

# Find external connections
ss -tuna | grep -v 127.0.0.1 | grep -v 192.168

# Monitor connection states
ss -tuna | awk '{print $1}' | sort | uniq -c
```

### Performance Tips
- **Use ss instead of netstat** for better performance
- **Use specific filters** to reduce output
- **Combine with awk/grep** for complex analysis
- **Monitor continuously** for real-time insights
- **Set up automated monitoring** for production systems

## Security Considerations

### Network Security Best Practices
- **Regular monitoring** of network connections
- **Alert on suspicious** connection patterns
- **Limit listening ports** to necessary services
- **Use firewall rules** to restrict access
- **Monitor for port scans** and attacks

### Common Security Issues
- **Open ports** exposing unnecessary services
- **Suspicious connections** to external hosts
- **High connection counts** indicating attacks
- **Unusual port usage** suggesting malware
- **Connection state anomalies** indicating problems

### Monitoring and Alerting
- **Set up automated monitoring** for connection counts
- **Alert on unusual patterns** or high counts
- **Monitor for specific threats** (port scans, DDoS)
- **Track connection trends** over time
- **Implement log analysis** for security events

## Additional Learning Resources

### Recommended Reading
- **man netstat**: Complete netstat manual
- **man ss**: Complete ss manual
- **RFC 793**: TCP protocol specification
- **RFC 768**: UDP protocol specification

### Online Tools
- **Wireshark**: Packet analysis tool
- **tcpdump**: Command-line packet capture
- **nmap**: Network discovery and security auditing
- **netstat-nat**: NAT connection monitoring

### Video Tutorials
- **Network Analysis with ss**: Modern socket statistics
- **Troubleshooting Network Issues**: Real-world examples
- **Security Analysis**: Identifying threats with netstat/ss

---

**Next Steps**: Practice with the lab exercises and explore the analyzer tools to deepen your understanding of network analysis with netstat and ss.
