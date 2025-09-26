# Network Analysis Quick Reference

## Essential Commands

### Basic Connection Listing
```bash
# All TCP/UDP connections
ss -tuna                    # Modern (recommended)
netstat -tuna               # Legacy

# Listening sockets only
ss -tuln                    # Modern (recommended)
netstat -tuln               # Legacy

# With process information
ss -tunap                   # Modern (recommended)
netstat -tunap              # Legacy
```

### State Filtering
```bash
# Established connections
ss -t state established
ss -tuna | grep ESTAB

# Listening sockets
ss -t state listening
ss -tuln | grep LISTEN

# TIME-WAIT connections
ss -t state time-wait
ss -tuna | grep TIME-WAIT

# SYN-SENT connections
ss -t state syn-sent
ss -tuna | grep SYN-SENT
```

### Port Filtering
```bash
# Source port
ss -t sport :80
ss -t sport :443

# Destination port
ss -t dport :80
ss -t dport :443

# Multiple ports
ss -t '( dport = :80 or dport = :443 )'
ss -t '( sport = :80 or sport = :443 )'
```

### Address Filtering
```bash
# Source address
ss -t src 192.168.1.100
ss -t src 10.0.0.0/8

# Destination address
ss -t dst 8.8.8.8
ss -t dst 192.168.1.0/24
```

### Statistics and Monitoring
```bash
# Summary statistics
ss -s

# Interface statistics
netstat -i

# Protocol statistics
netstat -s

# Continuous monitoring
watch -n 1 'ss -tuna'
watch -n 1 'ss -s'
```

## Common Use Cases

### Find What's Using a Port
```bash
# Check if port 80 is in use
ss -tuln | grep :80

# Find process using port 80
ss -tunap | grep :80

# Check for port conflicts
ss -tuln | awk '{print $4}' | cut -d: -f2 | sort | uniq -d
```

### Monitor Connections
```bash
# Count total connections
ss -tuna | wc -l

# Count by state
ss -tuna | awk '{print $1}' | sort | uniq -c

# Monitor connection trends
while true; do
    echo "=== $(date) ==="
    ss -tuna | awk '{print $1}' | sort | uniq -c
    sleep 5
done
```

### Security Analysis
```bash
# Find external connections
ss -tuna | grep -v 127.0.0.1 | grep -v 192.168

# Find unusual listening ports
ss -tuln | grep -v -E ":(22|80|443|53|25|110|143|993|995)"

# Find connection attempts
ss -tuna | grep SYN-SENT

# Top remote addresses
ss -tuna | awk '{print $4}' | cut -d: -f1 | sort | uniq -c | sort -nr | head -10
```

### Performance Analysis
```bash
# Check socket memory usage
ss -m

# Check TCP internal info
ss -i

# Monitor connection counts
ss -s

# Check for connection leaks
ss -tuna state time-wait | wc -l
```

## Troubleshooting Commands

### Connection Issues
```bash
# Check if service is listening
ss -tuln | grep :80

# Check if connection can be established
ss -t state syn-sent

# Check for connection leaks
ss -tuna state time-wait | wc -l

# Check for zombie connections
ss -tuna | grep -E "(CLOSE-WAIT|LAST-ACK)"
```

### Port Conflicts
```bash
# Find process using port
ss -tunap | grep :8080

# Kill process using port
sudo kill -9 $(ss -tunap | grep :8080 | awk '{print $6}' | cut -d, -f2 | cut -d= -f2)

# Check for duplicate ports
ss -tuln | awk '{print $4}' | cut -d: -f2 | sort | uniq -d
```

### Performance Issues
```bash
# Check interface errors
netstat -i

# Check protocol statistics
netstat -s | grep -i retrans

# Check connection states
ss -tuna | awk '{print $1}' | sort | uniq -c

# Monitor system load
uptime
```

## Performance Tips

### Use ss Instead of netstat
- **Faster**: ss is significantly faster than netstat
- **More efficient**: Better memory usage and CPU utilization
- **Better filtering**: More powerful filtering capabilities
- **Modern**: Actively maintained and developed

### Optimize Command Performance
```bash
# Use specific filters to reduce output
ss -t state established
ss -t dport :80

# Use numerical addresses to avoid DNS lookups
ss -tuna

# Combine with other tools for analysis
ss -tuna | awk '{print $1}' | sort | uniq -c
```

### Monitoring Best Practices
```bash
# Set up continuous monitoring
watch -n 1 'ss -tuna | awk "{print \$1}" | sort | uniq -c'

# Create monitoring scripts
#!/bin/bash
while true; do
    echo "=== $(date) ==="
    ss -s
    sleep 10
done

# Use automated alerts
CONNECTIONS=$(ss -tuna | wc -l)
if [ $CONNECTIONS -gt 1000 ]; then
    echo "ALERT: High connection count: $CONNECTIONS"
fi
```

## Common Output Formats

### ss Output Format
```
State      Recv-Q Send-Q Local Address:Port       Peer Address:Port
ESTAB      0      0      192.168.1.100:22        192.168.1.50:54321
LISTEN     0      128    0.0.0.0:80              0.0.0.0:*
```

### netstat Output Format
```
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 192.168.1.100:22       192.168.1.50:54321      ESTABLISHED   1234/sshd
tcp        0      0 0.0.0.0:80             0.0.0.0:*               LISTEN       5678/nginx
```

## Connection States Reference

### TCP States
- **LISTEN**: Server listening for connections
- **SYN-SENT**: Client sent SYN, waiting for SYN-ACK
- **SYN-RECV**: Server received SYN, sent SYN-ACK
- **ESTABLISHED**: Connection established, data can flow
- **FIN-WAIT-1**: First FIN sent, waiting for ACK
- **FIN-WAIT-2**: FIN acknowledged, waiting for remote FIN
- **CLOSE-WAIT**: Remote FIN received, waiting for local FIN
- **LAST-ACK**: Local FIN sent, waiting for ACK
- **TIME-WAIT**: Connection closed, waiting for cleanup
- **CLOSING**: Both sides sent FIN, waiting for ACK
- **CLOSED**: Connection closed

### UDP States
- **UNCONN**: Unconnected UDP socket
- **CONNECTED**: Connected UDP socket

## Useful One-Liners

```bash
# Count connections by state
ss -tuna | awk '{print $1}' | sort | uniq -c

# Find top remote addresses
ss -tuna | awk '{print $4}' | cut -d: -f1 | sort | uniq -c | sort -nr | head -10

# Find top ports
ss -tuna | awk '{print $4}' | cut -d: -f2 | sort | uniq -c | sort -nr | head -10

# Monitor connection changes
watch -n 1 'ss -tuna | wc -l'

# Find processes with most connections
ss -tunap | awk '{print $6}' | cut -d, -f2 | cut -d= -f2 | sort | uniq -c | sort -nr | head -10

# Check for port conflicts
ss -tuln | awk '{print $4}' | cut -d: -f2 | sort | uniq -d

# Find external connections
ss -tuna | grep -v 127.0.0.1 | grep -v 192.168

# Monitor TIME-WAIT connections
watch -n 1 'ss -tuna state time-wait | wc -l'
```

## Error Messages and Solutions

### Common Errors
- **"ss: command not found"**: Install iproute2 package
- **"netstat: command not found"**: Install net-tools package
- **"Permission denied"**: Use sudo for some operations
- **"No such file or directory"**: Check if command exists

### Solutions
```bash
# Install required packages
sudo apt-get install iproute2 net-tools  # Ubuntu/Debian
sudo yum install iproute net-tools        # CentOS/RHEL
sudo dnf install iproute net-tools       # Fedora

# Check command availability
which ss
which netstat

# Use sudo for privileged operations
sudo ss -tunap
sudo netstat -tunap
```

---

**Remember**: Use `ss` for modern systems and `netstat` for legacy compatibility. Always prefer `ss` for better performance and features.
