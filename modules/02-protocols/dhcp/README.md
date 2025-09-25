# DHCP (Dynamic Host Configuration Protocol)

## Overview

The Dynamic Host Configuration Protocol (DHCP) is a network management protocol used to automatically assign IP addresses and other network configuration parameters to devices on a network. DHCP eliminates the need for manual IP configuration, making network administration more efficient and reducing configuration errors.

## Table of Contents

- [DHCP Fundamentals](#dhcp-fundamentals)
- [DHCP Message Types](#dhcp-message-types)
- [DHCP Process (DORA)](#dhcp-process-dora)
- [DHCP Options](#dhcp-options)
- [DHCP Server Types](#dhcp-server-types)
- [DHCP Lease Management](#dhcp-lease-management)
- [DHCP Security](#dhcp-security)
- [Practical Labs](#practical-labs)
- [Troubleshooting](#troubleshooting)

## DHCP Fundamentals

### What is DHCP?

DHCP is a client-server protocol that automatically provides:
- **IP Address**: Unique identifier for the device
- **Subnet Mask**: Defines the network portion of the IP address
- **Default Gateway**: Router address for external communication
- **DNS Servers**: Name resolution services
- **Additional Options**: NTP servers, domain names, vendor-specific settings

### Benefits of DHCP

1. **Automation**: Eliminates manual IP configuration
2. **Centralized Management**: Single point of control
3. **Conflict Prevention**: Prevents duplicate IP addresses
4. **Flexibility**: Easy to change network parameters
5. **Scalability**: Supports large networks efficiently

### DHCP vs Static Configuration

| Aspect | DHCP | Static |
|--------|------|--------|
| Configuration | Automatic | Manual |
| IP Conflicts | Prevented | Possible |
| Management | Centralized | Distributed |
| Flexibility | High | Low |
| Scalability | Excellent | Limited |

## DHCP Message Types

### Core DHCP Messages

1. **DHCPDISCOVER** (Client → Server)
   - Client broadcasts to find available DHCP servers
   - Source: 0.0.0.0, Destination: 255.255.255.255

2. **DHCPOFFER** (Server → Client)
   - Server responds with available IP address
   - Contains lease information and configuration

3. **DHCPREQUEST** (Client → Server)
   - Client requests specific IP address
   - Can be broadcast or unicast

4. **DHCPACK** (Server → Client)
   - Server confirms IP assignment
   - Final step in lease process

5. **DHCPNAK** (Server → Client)
   - Server denies IP request
   - Client must restart process

6. **DHCPDECLINE** (Client → Server)
   - Client rejects offered IP address
   - Usually due to IP conflict detection

7. **DHCPRELEASE** (Client → Server)
   - Client voluntarily releases IP address
   - Graceful lease termination

8. **DHCPINFORM** (Client → Server)
   - Client requests configuration without IP
   - Used when client has static IP

## DHCP Process (DORA)

The DHCP process follows the **DORA** sequence:

### 1. Discover (DHCPDISCOVER)
```
Client → Broadcast: "I need an IP address"
```

**Packet Details:**
- Source IP: 0.0.0.0
- Destination IP: 255.255.255.255
- Source Port: 68 (DHCP Client)
- Destination Port: 67 (DHCP Server)
- Message Type: DHCPDISCOVER

### 2. Offer (DHCPOFFER)
```
Server → Client: "Here's an available IP address"
```

**Packet Details:**
- Source IP: Server IP
- Destination IP: Offered IP or 255.255.255.255
- Source Port: 67 (DHCP Server)
- Destination Port: 68 (DHCP Client)
- Message Type: DHCPOFFER

### 3. Request (DHCPREQUEST)
```
Client → Server: "I accept this IP address"
```

**Packet Details:**
- Source IP: 0.0.0.0
- Destination IP: 255.255.255.255 (or specific server)
- Source Port: 68
- Destination Port: 67
- Message Type: DHCPREQUEST

### 4. Acknowledge (DHCPACK)
```
Server → Client: "IP address confirmed, here's your configuration"
```

**Packet Details:**
- Source IP: Server IP
- Destination IP: Assigned IP
- Source Port: 67
- Destination Port: 68
- Message Type: DHCPACK

## DHCP Options

DHCP options provide additional configuration parameters:

### Common DHCP Options

| Option | Name | Description |
|--------|------|-------------|
| 1 | Subnet Mask | Network mask for the assigned IP |
| 3 | Router | Default gateway address |
| 6 | Domain Name Server | DNS server addresses |
| 15 | Domain Name | Domain name for the client |
| 42 | NTP Servers | Network Time Protocol servers |
| 51 | IP Address Lease Time | How long the IP is valid |
| 54 | Server Identifier | DHCP server IP address |
| 58 | Renewal Time | When to renew the lease |
| 59 | Rebinding Time | When to rebind with any server |
| 66 | TFTP Server Name | Boot server for PXE |
| 67 | Bootfile Name | Boot file for PXE |

### Option Format
```
Option Code (1 byte) + Length (1 byte) + Data (Variable)
```

## DHCP Server Types

### 1. Authoritative DHCP Server
- **Primary server** for a network segment
- Maintains the **official** IP address pool
- Can assign IPs from its configured range
- Handles lease renewals and releases

### 2. Non-Authoritative DHCP Server
- **Secondary server** or backup
- Cannot assign new IPs
- Only responds to renewals and releases
- Provides redundancy

### 3. DHCP Relay Agent
- Forwards DHCP messages between subnets
- Allows centralized DHCP server management
- Uses **giaddr** (Gateway IP Address) field
- Enables single server for multiple subnets

## DHCP Lease Management

### Lease States

1. **Allocated**: IP assigned to client
2. **Available**: IP available for assignment
3. **Expired**: Lease time exceeded
4. **Reserved**: IP reserved for specific client

### Lease Renewal Process

1. **T1 (50% of lease time)**: Client attempts renewal with current server
2. **T2 (87.5% of lease time)**: Client attempts renewal with any server
3. **Expiration**: Client must release IP and restart DORA

### Lease Database

DHCP servers maintain lease databases containing:
- **IP Address**: Assigned IP
- **MAC Address**: Client hardware address
- **Lease Start**: When lease was granted
- **Lease End**: When lease expires
- **Client Hostname**: Optional client identifier
- **Binding State**: Current lease status

## DHCP Security

### Common Security Issues

1. **Rogue DHCP Servers**
   - Unauthorized servers providing incorrect configuration
   - Can redirect traffic or cause network issues
   - Mitigation: DHCP Snooping on switches

2. **DHCP Exhaustion Attacks**
   - Attacker requests all available IPs
   - Prevents legitimate clients from getting IPs
   - Mitigation: Rate limiting and monitoring

3. **DHCP Spoofing**
   - Attacker intercepts DHCP messages
   - Can redirect traffic to malicious servers
   - Mitigation: DHCP Snooping and ARP inspection

### Security Best Practices

1. **Enable DHCP Snooping** on network switches
2. **Monitor DHCP traffic** for anomalies
3. **Use DHCP reservations** for critical devices
4. **Implement rate limiting** to prevent exhaustion
5. **Regular security audits** of DHCP configuration

## Practical Labs

### Lab 1: Basic DHCP Analysis
```bash
# Capture DHCP traffic
sudo tcpdump -i any port 67 or port 68 -v

# Analyze DHCP packets
tshark -i any -f "port 67 or port 68" -T fields -e ip.src -e ip.dst -e dhcp.option.dhcp
```

### Lab 2: DHCP Server Configuration
```bash
# Install DHCP server (Ubuntu/Debian)
sudo apt-get install isc-dhcp-server

# Configure DHCP server
sudo nano /etc/dhcp/dhcpd.conf
```

### Lab 3: DHCP Client Testing
```bash
# Release current IP
sudo dhclient -r

# Request new IP
sudo dhclient

# Show current configuration
ip addr show
```

### Lab 4: DHCP Troubleshooting
```bash
# Check DHCP client status
systemctl status dhcpcd

# View DHCP logs
journalctl -u isc-dhcp-server

# Test DHCP server connectivity
nc -u -v <dhcp-server-ip> 67
```

## Troubleshooting

### Common Issues

1. **No IP Address Assigned**
   - Check DHCP server status
   - Verify network connectivity
   - Check for IP conflicts

2. **Incorrect Configuration**
   - Verify DHCP server configuration
   - Check option settings
   - Validate subnet configuration

3. **Lease Renewal Failures**
   - Check server availability
   - Verify network connectivity
   - Review lease database

4. **Slow IP Assignment**
   - Check server performance
   - Verify network latency
   - Review DHCP relay configuration

### Diagnostic Commands

```bash
# Check DHCP client status
ip addr show
ip route show

# Test DHCP server
nmap -sU -p 67 <server-ip>

# Capture DHCP traffic
tcpdump -i any port 67 or port 68

# Check DHCP server logs
tail -f /var/log/syslog | grep dhcp
```

## Quick Reference

### Essential Commands
```bash
# Client operations
dhclient -r                    # Release current lease
dhclient                       # Request new lease
dhclient -v                    # Verbose output

# Server operations
systemctl start isc-dhcp-server    # Start DHCP server
systemctl status isc-dhcp-server   # Check status
dhcp-lease-list                   # List active leases

# Network analysis
tcpdump -i any port 67 or port 68  # Capture DHCP traffic
tshark -i any -f "port 67 or port 68"  # Analyze with Wireshark
```

### Port Numbers
- **67**: DHCP Server (UDP)
- **68**: DHCP Client (UDP)

### Key Files
- **Client**: `/var/lib/dhcp/dhcpcd.leases`
- **Server**: `/etc/dhcp/dhcpd.conf`
- **Leases**: `/var/lib/dhcp/dhcpd.leases`

---

## Next Steps

1. **Practice**: Use the provided lab scripts to gain hands-on experience
2. **Analysis**: Use the DHCP analyzer to understand packet flows
3. **Configuration**: Set up your own DHCP server
4. **Troubleshooting**: Practice resolving common DHCP issues

For hands-on practice, run:
```bash
# Interactive DHCP lab
./dhcp-lab.sh

# DHCP packet analysis
python3 dhcp-analyzer.py

# Troubleshooting guide
./dhcp-troubleshoot.sh
```
