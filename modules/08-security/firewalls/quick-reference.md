# iptables Quick Reference

## Essential Commands

### Viewing Rules
```bash
# List all rules
iptables -L

# List with verbose output
iptables -L -v

# List with line numbers
iptables -L --line-numbers

# List with numeric addresses
iptables -L -n

# List specific table
iptables -t nat -L
iptables -t mangle -L
iptables -t raw -L
```

### Rule Management
```bash
# Add rule
iptables -A CHAIN -p PROTOCOL --dport PORT -j ACTION

# Insert rule at position
iptables -I CHAIN POSITION -p PROTOCOL --dport PORT -j ACTION

# Delete rule by line number
iptables -D CHAIN POSITION

# Delete specific rule
iptables -D CHAIN -p PROTOCOL --dport PORT -j ACTION

# Flush all rules in chain
iptables -F CHAIN

# Flush all rules in table
iptables -F
```

### Policy Management
```bash
# Set default policy
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# View policies
iptables -L | grep "policy"
```

## Common Rule Patterns

### Basic Security Rules
```bash
# Allow loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow SSH
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow HTTP/HTTPS
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Allow ICMP
iptables -A INPUT -p icmp -j ACCEPT

# Drop all other traffic
iptables -P INPUT DROP
```

### Port-based Rules
```bash
# Allow port range
iptables -A INPUT -p tcp --dport 8000:8010 -j ACCEPT

# Allow multiple ports
iptables -A INPUT -p tcp -m multiport --dports 22,80,443 -j ACCEPT

# Block specific port
iptables -A INPUT -p tcp --dport 23 -j DROP
```

### IP-based Rules
```bash
# Allow specific IP
iptables -A INPUT -s 192.168.1.100 -j ACCEPT

# Allow IP range
iptables -A INPUT -s 192.168.1.0/24 -j ACCEPT

# Block specific IP
iptables -A INPUT -s 10.0.0.100 -j DROP

# Allow from interface
iptables -A INPUT -i eth0 -j ACCEPT
```

### Logging Rules
```bash
# Log dropped packets
iptables -A INPUT -j LOG --log-prefix "DROPPED: " --log-level 4

# Log specific traffic
iptables -A INPUT -p tcp --dport 22 -j LOG --log-prefix "SSH: "
```

## NAT Rules

### SNAT (Source NAT)
```bash
# Masquerade outgoing traffic
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# SNAT for specific network
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o eth0 -j SNAT --to-source 203.0.113.1
```

### DNAT (Destination NAT)
```bash
# Port forwarding
iptables -t nat -A PREROUTING -p tcp --dport 8080 -j DNAT --to-destination 192.168.1.100:80

# Redirect to different port
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080
```

## Connection Tracking
```bash
# Allow established and related connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow new connections only to specific ports
iptables -A INPUT -m state --state NEW -p tcp --dport 22 -j ACCEPT

# Limit connection rate
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --set
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 4 -j DROP
```

## Rule Management
```bash
# Save rules
iptables-save > /etc/iptables/rules.v4

# Restore rules
iptables-restore < /etc/iptables/rules.v4

# Save specific table
iptables-save -t nat > nat-rules.txt

# Restore specific table
iptables-restore -t nat < nat-rules.txt
```

## Troubleshooting Commands
```bash
# Check if IP forwarding is enabled
cat /proc/sys/net/ipv4/ip_forward

# Enable IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# Check connection tracking
conntrack -L

# Monitor iptables logs
tail -f /var/log/kern.log | grep iptables

# Test connectivity
telnet hostname port
nc -v hostname port

# Check rule counters
iptables -L -n -v
```

## Common Issues and Solutions

### Connection Refused
```bash
# Check if rules are blocking traffic
iptables -L -n -v

# Check if service is listening
netstat -tlnp | grep :22
ss -tlnp | grep :22

# Test with verbose logging
iptables -A INPUT -j LOG --log-prefix "DEBUG: "
```

### Performance Issues
```bash
# Check rule order
iptables -L -n --line-numbers

# Count packets per rule
iptables -L -n -v

# Optimize rule order (most hit rules first)
iptables -I INPUT 1 -p tcp --dport 22 -j ACCEPT
```

### Rule Conflicts
```bash
# Check for conflicting rules
iptables -L -n | grep -E "(ACCEPT|DROP|REJECT)"

# Test specific rule
iptables -t filter -I INPUT 1 -p tcp --dport 80 -j ACCEPT

# Remove conflicting rule
iptables -D INPUT -p tcp --dport 80 -j DROP
```

## Security Best Practices

### Rule Order
1. Allow loopback traffic
2. Allow established/related connections
3. Allow specific services (SSH, HTTP, etc.)
4. Allow ICMP
5. Log dropped packets
6. Drop all other traffic

### Logging
- Always log dropped packets
- Use descriptive log prefixes
- Monitor logs regularly
- Set up log rotation

### Testing
- Test rules in a safe environment
- Use verbose logging during testing
- Test both positive and negative cases
- Document rule changes

### Maintenance
- Regular rule review
- Remove unused rules
- Optimize rule order
- Keep backups of working configurations
