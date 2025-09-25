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
- [DHCPv6 (IPv6 Dynamic Host Configuration Protocol)](#dhcpv6-ipv6-dynamic-host-configuration-protocol)
- [Performance Tuning](#performance-tuning)
- [Enhanced Security](#enhanced-security)
- [DHCP Security](#dhcp-security)
- [Real-World Scenarios](#real-world-scenarios)
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

## DHCPv6 (IPv6 Dynamic Host Configuration Protocol)

### Overview
DHCPv6 is the IPv6 equivalent of DHCP, providing automatic configuration for IPv6 networks. While IPv6 has Stateless Address Autoconfiguration (SLAAC), DHCPv6 offers more control and additional options.

### Key Differences from DHCPv4
| Aspect | DHCPv4 | DHCPv6 |
|--------|--------|--------|
| Transport | UDP | UDP |
| Server Port | 67 | 547 |
| Client Port | 68 | 546 |
| Address Type | IPv4 | IPv6 |
| Message Types | 8 types | 12+ types |
| Options | 255 max | 65535 max |

### DHCPv6 Message Types
1. **Solicit** (Client → Server) - Equivalent to DISCOVER
2. **Advertise** (Server → Client) - Equivalent to OFFER
3. **Request** (Client → Server) - Equivalent to REQUEST
4. **Confirm** (Client → Server) - Verify address still valid
5. **Renew** (Client → Server) - Renew lease
6. **Rebind** (Client → Server) - Rebind to any server
7. **Reply** (Server → Client) - Response to various requests
8. **Release** (Client → Server) - Release address
9. **Decline** (Client → Server) - Reject offered address
10. **Reconfigure** (Server → Client) - Force client to renew
11. **Information-Request** (Client → Server) - Request config only
12. **Relay-Forward** (Relay → Server) - Forward client message
13. **Relay-Reply** (Server → Relay) - Response via relay

### DHCPv6 Process (SARR)
1. **Solicit** - Client requests configuration
2. **Advertise** - Server offers configuration
3. **Request** - Client requests specific configuration
4. **Reply** - Server confirms configuration

### Common DHCPv6 Options
| Option | Name | Description |
|--------|------|-------------|
| 1 | Client Identifier | Unique client identifier |
| 2 | Server Identifier | Server identifier |
| 3 | Identity Association | Address assignment info |
| 23 | DNS Recursive Name Server | DNS server addresses |
| 24 | Domain Search List | DNS search domains |
| 56 | NTP Server | Time server addresses |

### DHCPv6 Commands
```bash
# Release IPv6 address
dhclient -6 -r

# Request IPv6 address
dhclient -6

# Show IPv6 configuration
ip -6 addr show
ip -6 route show
```

## Performance Tuning

### Server Performance Optimization

#### 1. Hardware Considerations
- **CPU**: Multi-core processors for concurrent requests
- **Memory**: Sufficient RAM for lease database
- **Storage**: Fast I/O for lease database operations
- **Network**: High-bandwidth, low-latency connections

#### 2. Software Configuration
```bash
# Optimize lease database
default-lease-time 86400;        # 24 hours
max-lease-time 172800;           # 48 hours
authoritative;                   # Server is authoritative
ddns-update-style none;          # Disable DDNS if not needed

# Performance tuning
option domain-name-servers 8.8.8.8, 8.8.4.4;
option routers 192.168.1.1;
```

#### 3. Large-Scale Deployment
- **Load Balancing**: Multiple DHCP servers with failover
- **Database Optimization**: Regular lease database maintenance
- **Network Segmentation**: Reduce broadcast domain size
- **Monitoring**: Real-time performance monitoring

### Client Performance
```bash
# Optimize client configuration
# /etc/dhcp/dhcpcd.conf
interface eth0
static ip_address=192.168.1.100/24
static routers=192.168.1.1
static domain_name_servers=8.8.8.8 8.8.4.4

# Reduce renewal frequency
renew-interval 3600;
rebind-interval 7200;
```

### Monitoring and Metrics
- **Lease Utilization**: Percentage of IP pool used
- **Response Time**: Time to assign IP addresses
- **Error Rate**: Failed requests and NAK responses
- **Network Load**: DHCP traffic volume

## Enhanced Security

### Advanced Security Threats

#### 1. DHCP Starvation Attacks
**Description**: Attacker rapidly requests all available IP addresses
**Impact**: Prevents legitimate clients from getting IPs
**Detection**: Monitor for rapid lease requests from single MAC
**Mitigation**: 
```bash
# Rate limiting in dhcpd.conf
deny unknown-clients;
max-lease-time 3600;
```

#### 2. DHCP Rogue Server Attacks
**Description**: Unauthorized DHCP server provides malicious configuration
**Impact**: Traffic redirection, DNS poisoning, man-in-the-middle
**Detection**: Monitor for unexpected DHCP servers
**Mitigation**: DHCP Snooping on switches

#### 3. DHCP Option Injection
**Description**: Attacker injects malicious DHCP options
**Impact**: DNS redirection, proxy settings manipulation
**Detection**: Monitor DHCP options for anomalies
**Mitigation**: Validate and sanitize DHCP options

### Security Hardening

#### 1. Server Security
```bash
# Secure DHCP server configuration
# /etc/dhcp/dhcpd.conf
authoritative;
ddns-update-style none;
deny unknown-clients;
allow known-clients;

# Log security events
log-facility local7;
```

#### 2. Network Security
```bash
# Enable DHCP Snooping (Cisco)
ip dhcp snooping
ip dhcp snooping vlan 10
ip dhcp snooping trust

# Rate limiting
ip dhcp snooping limit rate 10
```

#### 3. Monitoring and Alerting
```bash
# Monitor DHCP traffic
tcpdump -i any port 67 or port 68 -w dhcp-security.log

# Alert on suspicious activity
tail -f /var/log/syslog | grep -E "(dhcp|DHCP)" | grep -E "(NAK|DECLINE|exhausted)"
```

### Authentication and Authorization

#### 1. DHCP Authentication (RFC 3118)
- **Message Authentication**: Verify message integrity
- **Replay Protection**: Prevent replay attacks
- **Key Management**: Secure key distribution

#### 2. Client Authentication
- **MAC Address Filtering**: Allow only known devices
- **Certificate-based**: Use certificates for authentication
- **802.1X Integration**: Network access control

### Incident Response

#### 1. Detection
- **Anomaly Detection**: Monitor for unusual patterns
- **Log Analysis**: Regular review of DHCP logs
- **Network Monitoring**: Real-time traffic analysis

#### 2. Response
- **Isolate Affected Devices**: Block suspicious MAC addresses
- **Update Security Policies**: Strengthen access controls
- **Forensic Analysis**: Investigate attack vectors

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

## Real-World Scenarios

### Enterprise Network Deployment

#### Large Corporate Network
```bash
# Multi-subnet DHCP with failover
# Primary server configuration
subnet 192.168.1.0 netmask 255.255.255.0 {
    range 192.168.1.100 192.168.1.200;
    option routers 192.168.1.1;
    option domain-name-servers 192.168.1.10, 192.168.1.11;
    option domain-name "company.local";
    default-lease-time 86400;
    max-lease-time 172800;
}

# Failover configuration
failover peer "dhcp-failover" {
    primary;
    address 192.168.1.10;
    port 647;
    peer address 192.168.1.11;
    peer port 647;
    max-response-delay 60;
    max-unacked-updates 10;
    load balance max seconds 3;
}
```

#### Branch Office with VPN
- **Centralized Management**: Single DHCP server for all locations
- **Relay Agents**: Forward DHCP requests across VPN tunnels
- **Site-Specific Options**: Different configurations per location
- **Redundancy**: Backup servers at each major site

### Home Network Configuration

#### Basic Home Setup
```bash
# Simple home router DHCP
subnet 192.168.1.0 netmask 255.255.255.0 {
    range 192.168.1.100 192.168.1.150;
    option routers 192.168.1.1;
    option domain-name-servers 8.8.8.8, 8.8.4.4;
    option domain-name "home.local";
    default-lease-time 86400;
    max-lease-time 172800;
}
```

#### Smart Home Integration
- **IoT Device Management**: Reserved IPs for smart devices
- **Guest Network**: Separate DHCP scope for visitors
- **Parental Controls**: Time-based access restrictions
- **Device Identification**: Easy device management

### Cloud Provider DHCP

#### AWS VPC DHCP Options
- **Custom DNS**: Route53 resolver integration
- **Domain Name**: Custom domain configuration
- **NTP Servers**: Time synchronization
- **NetBIOS**: Windows networking support

#### Azure Virtual Network
- **Dynamic IP Assignment**: Automatic IP allocation
- **Custom DNS**: Azure DNS integration
- **Load Balancer Integration**: High availability
- **Security Groups**: Network access control

### Industrial and IoT Networks

#### Manufacturing Environment
- **Deterministic Networks**: Time-sensitive applications
- **Device Classification**: Different lease times per device type
- **Network Segmentation**: Isolated production networks
- **Redundancy**: Multiple DHCP servers for reliability

#### IoT Device Management
- **Massive Scale**: Thousands of devices
- **Long Lease Times**: Reduce network overhead
- **Device Tracking**: Monitor device connectivity
- **Security**: Isolated IoT networks

## Troubleshooting

### Common Issues

#### 1. No IP Address Assigned
**Symptoms**: Client shows no IP address, network unreachable
**Causes**:
- DHCP server not running
- Network connectivity issues
- IP pool exhausted
- Firewall blocking DHCP traffic

**Diagnosis**:
```bash
# Check client status
ip addr show
systemctl status dhcpcd

# Test server connectivity
ping <dhcp-server-ip>
nc -u -v <dhcp-server-ip> 67

# Check for IP conflicts
arp -a | grep <expected-ip>
```

**Solutions**:
```bash
# Restart DHCP client
sudo systemctl restart dhcpcd
sudo dhclient -r && sudo dhclient

# Check server logs
sudo journalctl -u isc-dhcp-server -f
```

#### 2. Incorrect Configuration
**Symptoms**: Wrong IP, gateway, or DNS settings
**Causes**:
- Server configuration errors
- Multiple DHCP servers
- Option conflicts
- Relay agent issues

**Diagnosis**:
```bash
# Check current configuration
ip addr show
ip route show
cat /etc/resolv.conf

# Capture DHCP traffic
sudo tcpdump -i any port 67 or port 68 -v
```

**Solutions**:
```bash
# Verify server configuration
sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf

# Check for multiple servers
sudo nmap -sU -p 67 --script broadcast-dhcp-discover
```

#### 3. Lease Renewal Failures
**Symptoms**: IP address lost after lease expires
**Causes**:
- Server unavailable during renewal
- Network connectivity issues
- Server configuration changes
- Client clock synchronization

**Diagnosis**:
```bash
# Check lease information
cat /var/lib/dhcp/dhcpcd.leases
sudo dhclient -v

# Monitor renewal process
sudo tcpdump -i any port 67 or port 68
```

**Solutions**:
```bash
# Force lease renewal
sudo dhclient -r
sudo dhclient -v

# Check server availability
sudo systemctl status isc-dhcp-server
```

#### 4. Slow IP Assignment
**Symptoms**: Long delays getting IP address
**Causes**:
- Server performance issues
- Network latency
- Relay agent delays
- Database corruption

**Diagnosis**:
```bash
# Measure response time
time sudo dhclient -v

# Check server performance
top -p $(pgrep dhcpd)
iostat -x 1

# Monitor network latency
ping <dhcp-server-ip>
```

**Solutions**:
```bash
# Optimize server configuration
# Reduce lease time for faster turnover
default-lease-time 3600;

# Check database integrity
sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf
```

### Advanced Troubleshooting

#### 1. Windows vs Linux Differences
**Windows**:
```cmd
# Release IP
ipconfig /release

# Renew IP
ipconfig /renew

# Show configuration
ipconfig /all

# Flush DNS
ipconfig /flushdns
```

**Linux**:
```bash
# Release IP
sudo dhclient -r

# Renew IP
sudo dhclient

# Show configuration
ip addr show
ip route show
```

#### 2. Network Topology Issues
**VLAN Problems**:
- Check VLAN configuration on switches
- Verify DHCP relay agent settings
- Ensure proper routing between VLANs

**Router Issues**:
- Check DHCP relay configuration
- Verify helper-address settings
- Test end-to-end connectivity

#### 3. Security-Related Issues
**Rogue Server Detection**:
```bash
# Scan for unauthorized servers
sudo nmap -sU -p 67 --script broadcast-dhcp-discover

# Monitor for unexpected responses
sudo tcpdump -i any port 67 or port 68 | grep -v <authorized-server-ip>
```

**Attack Mitigation**:
```bash
# Enable DHCP Snooping
# Rate limiting
# MAC address filtering
```

### Diagnostic Commands

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
