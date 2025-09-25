# DHCP Quick Reference

## Essential Commands

### Client Operations
```bash
# Release current IP address
dhclient -r

# Request new IP address
dhclient

# Request IP on specific interface
dhclient eth0

# Verbose output
dhclient -v

# Show current configuration
ip addr show
ip route show
```

### Server Operations
```bash
# Start DHCP server
sudo systemctl start isc-dhcp-server

# Stop DHCP server
sudo systemctl stop isc-dhcp-server

# Check server status
sudo systemctl status isc-dhcp-server

# Restart server
sudo systemctl restart isc-dhcp-server

# View server logs
sudo journalctl -u isc-dhcp-server -f
```

### Network Analysis
```bash
# Capture DHCP traffic
sudo tcpdump -i any port 67 or port 68 -v

# Capture to file
sudo tcpdump -i any port 67 or port 68 -w dhcp.pcap

# Analyze with tshark
tshark -r dhcp.pcap -T fields -e ip.src -e ip.dst -e dhcp.option.dhcp

# Real-time analysis
tshark -i any -f "port 67 or port 68"
```

## DHCP Message Types

| Type | Name | Description | Port |
|------|------|-------------|------|
| 1 | DHCPDISCOVER | Client discovers servers | 68→67 |
| 2 | DHCPOFFER | Server offers IP address | 67→68 |
| 3 | DHCPREQUEST | Client requests specific IP | 68→67 |
| 4 | DHCPACK | Server acknowledges assignment | 67→68 |
| 5 | DHCPNAK | Server denies request | 67→68 |
| 6 | DHCPDECLINE | Client declines offer | 68→67 |
| 7 | DHCPRELEASE | Client releases IP | 68→67 |
| 8 | DHCPINFORM | Client requests config only | 68→67 |

## Common DHCP Options

| Option | Name | Description |
|--------|------|-------------|
| 1 | Subnet Mask | Network mask |
| 3 | Router | Default gateway |
| 6 | Domain Name Server | DNS servers |
| 15 | Domain Name | Domain name |
| 42 | NTP Servers | Time servers |
| 51 | IP Address Lease Time | Lease duration |
| 54 | Server Identifier | DHCP server IP |
| 58 | Renewal Time | When to renew |
| 59 | Rebinding Time | When to rebind |

## Port Numbers

- **67**: DHCP Server (UDP)
- **68**: DHCP Client (UDP)

## Configuration Files

### Client Configuration
```bash
# DHCP client config
/etc/dhcp/dhcpcd.conf

# Network manager config
/etc/NetworkManager/NetworkManager.conf

# Resolv.conf (DNS)
/etc/resolv.conf
```

### Server Configuration
```bash
# DHCP server config
/etc/dhcp/dhcpd.conf

# Lease database
/var/lib/dhcp/dhcpd.leases

# Server logs
/var/log/syslog
```

## Troubleshooting Commands

### Basic Diagnostics
```bash
# Check network interfaces
ip link show

# Check IP addresses
ip addr show

# Check routing table
ip route show

# Check DNS configuration
cat /etc/resolv.conf

# Test connectivity
ping -c 3 8.8.8.8
```

### DHCP-Specific Troubleshooting
```bash
# Check DHCP client status
systemctl status dhcpcd

# View DHCP client logs
journalctl -u dhcpcd

# Check for DHCP processes
ps aux | grep dhclient

# Test DHCP server connectivity
nc -u -v <server-ip> 67

# Scan for DHCP servers
nmap -sU -p 67 --script broadcast-dhcp-discover
```

### Packet Analysis
```bash
# Capture DHCP traffic
sudo tcpdump -i any port 67 or port 68 -v

# Filter specific message types
sudo tcpdump -i any port 67 or port 68 and 'udp[8:1] = 1'  # DISCOVER
sudo tcpdump -i any port 67 or port 68 and 'udp[8:1] = 2'  # OFFER
sudo tcpdump -i any port 67 or port 68 and 'udp[8:1] = 3'  # REQUEST
sudo tcpdump -i any port 67 or port 68 and 'udp[8:1] = 4'  # ACK

# Analyze with tshark
tshark -i any -f "port 67 or port 68" -T fields -e frame.number -e ip.src -e ip.dst -e dhcp.option.dhcp
```

## Common Issues and Solutions

### No IP Address Assigned
```bash
# Check if DHCP client is running
systemctl status dhcpcd

# Restart DHCP client
sudo systemctl restart dhcpcd

# Manual renewal
sudo dhclient -r && sudo dhclient

# Check for IP conflicts
ping -c 1 <current-ip>
```

### Incorrect Configuration
```bash
# Check DHCP server configuration
sudo cat /etc/dhcp/dhcpd.conf

# Verify subnet configuration
ip route show

# Check DNS settings
cat /etc/resolv.conf

# Test DNS resolution
nslookup google.com
```

### Slow IP Assignment
```bash
# Check server performance
top -p $(pgrep dhcpd)

# Check network latency
ping -c 10 <dhcp-server>

# Monitor DHCP traffic
sudo tcpdump -i any port 67 or port 68
```

### Lease Renewal Failures
```bash
# Check server availability
ping <dhcp-server>

# Test UDP connectivity
nc -u -v <dhcp-server> 67

# Check lease database
sudo cat /var/lib/dhcp/dhcpd.leases

# Force lease renewal
sudo dhclient -r && sudo dhclient
```

## Security Considerations

### DHCP Snooping
```bash
# Enable on Cisco switches
ip dhcp snooping
ip dhcp snooping vlan 10

# Check for rogue servers
sudo tcpdump -i any port 67 or port 68
```

### Rate Limiting
```bash
# Configure in dhcpd.conf
deny unknown-clients;
max-lease-time 3600;
```

### Monitoring
```bash
# Monitor DHCP traffic
sudo tcpdump -i any port 67 or port 68 -c 100

# Check for anomalies
sudo tcpdump -i any port 67 or port 68 | grep -E "(NAK|DECLINE)"
```

## Performance Tuning

### Server Optimization
```bash
# Increase lease time for stability
default-lease-time 86400;
max-lease-time 172800;

# Optimize for large networks
authoritative;
ddns-update-style none;
```

### Client Optimization
```bash
# Reduce renewal frequency
renew-interval 3600;
rebind-interval 7200;
```

## Useful Scripts

### Quick DHCP Test
```bash
#!/bin/bash
echo "Testing DHCP..."
dhclient -r
sleep 2
dhclient -v
ip addr show | grep inet
```

### Monitor DHCP Traffic
```bash
#!/bin/bash
echo "Monitoring DHCP traffic..."
sudo tcpdump -i any port 67 or port 68 -v | while read line; do
    echo "$(date): $line"
done
```

### Check DHCP Servers
```bash
#!/bin/bash
echo "Scanning for DHCP servers..."
nmap -sU -p 67 --script broadcast-dhcp-discover
```

## Best Practices

1. **Use DHCP Reservations** for critical devices
2. **Monitor DHCP Traffic** for anomalies
3. **Implement DHCP Snooping** on switches
4. **Regular Security Audits** of configuration
5. **Backup Configuration** files regularly
6. **Use Appropriate Lease Times** for your environment
7. **Monitor Server Performance** and logs
8. **Test Failover** scenarios regularly

## Additional Resources

- [RFC 2131](https://tools.ietf.org/html/rfc2131) - DHCP Protocol
- [RFC 2132](https://tools.ietf.org/html/rfc2132) - DHCP Options
- [ISC DHCP Documentation](https://kb.isc.org/docs/)
- [DHCP Snooping Guide](https://www.cisco.com/c/en/us/td/docs/switches/lan/catalyst2960/software/release/12-2_55_se/configuration/guide/swdhcp82.html)
