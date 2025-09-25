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

### Timing Diagram
```
Client                    Server
  |                         |
  |-- DHCPDISCOVER -------->|  (Broadcast)
  |   (0.0.0.0:68 → 255.255.255.255:67)
  |                         |
  |<-- DHCPOFFER -----------|  (Unicast/Broadcast)
  |   (Server:67 → Client:68)
  |                         |
  |-- DHCPREQUEST -------->|  (Broadcast)
  |   (0.0.0.0:68 → 255.255.255.255:67)
  |                         |
  |<-- DHCPACK ------------|  (Unicast)
  |   (Server:67 → Client:68)
  |                         |
```

### Detailed Process Flow

#### 1. Discover (DHCPDISCOVER)
```
Client → Broadcast: "I need an IP address"
```

**Timing**: Immediate (client startup)
**Retry**: 4 attempts with exponential backoff (1s, 2s, 4s, 8s)
**Timeout**: 60 seconds total

**Packet Details:**
- Source IP: 0.0.0.0
- Destination IP: 255.255.255.255
- Source Port: 68 (DHCP Client)
- Destination Port: 67 (DHCP Server)
- Message Type: DHCPDISCOVER
- Client MAC: Hardware address
- Transaction ID: Random 32-bit number

**What happens if no response:**
- Client retries with exponential backoff
- After 4 attempts, client may use APIPA (169.254.x.x)
- Client continues to retry in background

#### 2. Offer (DHCPOFFER)
```
Server → Client: "Here's an available IP address"
```

**Timing**: Within 1 second of DISCOVER
**Multiple servers**: Client may receive multiple offers
**Selection**: Client typically chooses first offer received

**Packet Details:**
- Source IP: Server IP
- Destination IP: Offered IP or 255.255.255.255
- Source Port: 67 (DHCP Server)
- Destination Port: 68 (DHCP Client)
- Message Type: DHCPOFFER
- Your IP: Offered IP address
- Server ID: Server's IP address
- Lease Time: How long IP is valid
- Options: Subnet mask, gateway, DNS, etc.

#### 3. Request (DHCPREQUEST)
```
Client → Server: "I accept this IP address"
```

**Timing**: Within 1 second of receiving OFFER
**Broadcast**: Informs all servers of choice
**Server selection**: Includes chosen server's ID

**Packet Details:**
- Source IP: 0.0.0.0
- Destination IP: 255.255.255.255 (or specific server)
- Source Port: 68
- Destination Port: 67
- Message Type: DHCPREQUEST
- Requested IP: Chosen IP address
- Server ID: Chosen server's IP
- Client MAC: Hardware address

#### 4. Acknowledge (DHCPACK)
```
Server → Client: "IP address confirmed, here's your configuration"
```

**Timing**: Within 1 second of REQUEST
**Final step**: Client can now use the IP address
**Configuration**: All network parameters provided

**Packet Details:**
- Source IP: Server IP
- Destination IP: Assigned IP
- Source Port: 67
- Destination Port: 68
- Message Type: DHCPACK
- Your IP: Confirmed IP address
- Lease Time: Confirmed lease duration
- Options: Complete network configuration

### Alternative Outcomes

#### DHCPNAK (Negative Acknowledgment)
```
Server → Client: "IP address request denied"
```
**Causes**: IP no longer available, client not authorized, configuration error
**Client action**: Must restart DORA process

#### DHCPDECLINE (Client Rejection)
```
Client → Server: "I reject this IP address"
```
**Causes**: IP conflict detected, client doesn't like offered IP
**Server action**: Marks IP as unavailable, offers different IP

### Lease Renewal Process

#### T1 (50% of lease time)
```
Client → Server: "I want to renew my lease"
```
- **Message**: DHCPREQUEST (unicast to current server)
- **Server response**: DHCPACK (renewal granted) or DHCPNAK (renewal denied)
- **If no response**: Client continues using IP until T2

#### T2 (87.5% of lease time)
```
Client → Any Server: "I need to rebind my lease"
```
- **Message**: DHCPREQUEST (broadcast to any server)
- **Any server can respond**: DHCPACK or DHCPNAK
- **If no response**: Client must release IP and restart DORA

#### Lease Expiration
```
Client → Server: "I'm releasing my IP address"
```
- **Message**: DHCPRELEASE (optional, graceful release)
- **Client action**: Must restart DORA process to get new IP

## DHCP Options

DHCP options provide additional configuration parameters beyond basic IP assignment. They allow fine-grained control over client network behavior.

### Option Format and Structure
```
+--------+--------+--------+--------+
|  Code  | Length |        Data      |
| (1 byte)|(1 byte)|    (Variable)   |
+--------+--------+--------+--------+
```

**Example**: Option 6 (DNS Servers) with two servers
```
Code: 06 (DNS Servers)
Length: 08 (8 bytes)
Data: 08 08 08 08 08 08 04 04 (8.8.8.8, 8.8.4.4)
```

### Essential DHCP Options

#### Basic Network Configuration
| Option | Name | Type | Example | Description |
|--------|------|------|---------|-------------|
| 1 | Subnet Mask | IP Address | 255.255.255.0 | Network mask for assigned IP |
| 3 | Router | IP Address List | 192.168.1.1 | Default gateway addresses |
| 6 | Domain Name Server | IP Address List | 8.8.8.8, 8.8.4.4 | DNS server addresses |
| 15 | Domain Name | String | company.local | Domain name for client |
| 28 | Broadcast Address | IP Address | 192.168.1.255 | Broadcast address for subnet |

#### Time and Lease Management
| Option | Name | Type | Example | Description |
|--------|------|------|---------|-------------|
| 51 | IP Address Lease Time | 32-bit Integer | 86400 | Lease duration in seconds |
| 58 | Renewal Time | 32-bit Integer | 43200 | T1 time (50% of lease) |
| 59 | Rebinding Time | 32-bit Integer | 75600 | T2 time (87.5% of lease) |
| 42 | NTP Servers | IP Address List | time.nist.gov | Time synchronization servers |

#### Server Identification
| Option | Name | Type | Example | Description |
|--------|------|------|---------|-------------|
| 54 | Server Identifier | IP Address | 192.168.1.10 | DHCP server IP address |
| 60 | Vendor Class Identifier | String | MSFT 5.0 | Client vendor information |
| 61 | Client Identifier | Variable | MAC address | Unique client identifier |

#### Boot and PXE Options
| Option | Name | Type | Example | Description |
|--------|------|------|---------|-------------|
| 66 | TFTP Server Name | String | boot.company.com | Boot server hostname |
| 67 | Bootfile Name | String | pxelinux.0 | Boot file name |
| 150 | TFTP Server Address | IP Address List | 192.168.1.100 | Boot server IP addresses |

### Advanced DHCP Options

#### Network Services
| Option | Name | Type | Example | Description |
|--------|------|------|---------|-------------|
| 2 | Time Offset | 32-bit Integer | -18000 | Time zone offset in seconds |
| 4 | Time Server | IP Address List | time.company.com | Time server addresses |
| 5 | Name Server | IP Address List | ns1.company.com | Name server addresses |
| 7 | Log Server | IP Address List | syslog.company.com | System log servers |
| 8 | Cookie Server | IP Address List | cookie.company.com | Cookie server addresses |
| 9 | LPR Server | IP Address List | printer.company.com | Print server addresses |
| 10 | Impress Server | IP Address List | impress.company.com | Impress server addresses |
| 11 | Resource Location Server | IP Address List | rls.company.com | Resource location servers |

#### Microsoft-Specific Options
| Option | Name | Type | Example | Description |
|--------|------|------|---------|-------------|
| 43 | Vendor Specific Information | Variable | Various | Vendor-specific data |
| 44 | NetBIOS Name Server | IP Address List | 192.168.1.20 | WINS server addresses |
| 45 | NetBIOS Datagram Distribution | IP Address List | 192.168.1.20 | NetBIOS datagram server |
| 46 | NetBIOS Node Type | 8-bit Integer | 0x8 | NetBIOS node type |
| 47 | NetBIOS Scope | String | COMPANY | NetBIOS scope identifier |

#### Security and Authentication
| Option | Name | Type | Example | Description |
|--------|------|------|---------|-------------|
| 90 | Authentication | Variable | Various | DHCP authentication data |
| 114 | DHCP Captive Portal | String | https://portal.company.com | Captive portal URL |
| 160 | PXE Client System Architecture | 16-bit Integer | 0x0007 | PXE client architecture |

### Option Usage Examples

#### Basic Home Network
```bash
# /etc/dhcp/dhcpd.conf
subnet 192.168.1.0 netmask 255.255.255.0 {
    range 192.168.1.100 192.168.1.200;
    option routers 192.168.1.1;                    # Option 3
    option subnet-mask 255.255.255.0;              # Option 1
    option domain-name-servers 8.8.8.8, 8.8.4.4;   # Option 6
    option domain-name "home.local";               # Option 15
    option broadcast-address 192.168.1.255;        # Option 28
    default-lease-time 86400;                      # Option 51
    max-lease-time 172800;
}
```

#### Enterprise Network
```bash
# /etc/dhcp/dhcpd.conf
subnet 192.168.10.0 netmask 255.255.255.0 {
    range 192.168.10.100 192.168.10.200;
    option routers 192.168.10.1;
    option subnet-mask 255.255.255.0;
    option domain-name-servers 192.168.10.10, 192.168.10.11;
    option domain-name "company.local";
    option ntp-servers time.company.com;           # Option 42
    option time-offset -18000;                     # Option 2 (EST)
    option netbios-name-servers 192.168.10.20;     # Option 44
    option netbios-node-type 8;                    # Option 46
    default-lease-time 86400;
    max-lease-time 172800;
}
```

#### PXE Boot Configuration
```bash
# /etc/dhcp/dhcpd.conf
subnet 192.168.100.0 netmask 255.255.255.0 {
    range 192.168.100.100 192.168.100.150;
    option routers 192.168.100.1;
    option subnet-mask 255.255.255.0;
    option domain-name-servers 192.168.100.10;
    option tftp-server-name "boot.company.com";    # Option 66
    option bootfile-name "pxelinux.0";             # Option 67
    option tftp-server-address 192.168.100.50;     # Option 150
    default-lease-time 3600;
    max-lease-time 7200;
}
```

### Option Validation and Security

#### Common Option Issues
1. **Invalid Length**: Option length doesn't match data
2. **Malformed Data**: Incorrect format for option type
3. **Conflicting Values**: Multiple options with same purpose
4. **Oversized Options**: Options exceeding maximum size

#### Security Considerations
- **Validate all options** before sending to clients
- **Sanitize string options** to prevent injection
- **Limit option size** to prevent buffer overflows
- **Monitor for anomalies** in option usage

### Custom Vendor Options

#### Defining Vendor Options
```bash
# /etc/dhcp/dhcpd.conf
option space company;
option company.server-identifier code 1 = ip-address;
option company.custom-string code 2 = string;

class "company-devices" {
    match if option vendor-class-identifier = "CompanyDevice";
    option company.server-identifier 192.168.1.100;
    option company.custom-string "CustomValue";
}
```

#### Vendor Class Matching
```bash
# Match specific device types
class "cisco-phones" {
    match if option vendor-class-identifier = "Cisco Systems, Inc.";
    option tftp-server-name "tftp.company.com";
    option bootfile-name "phone.cfg";
}
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

### Lease States and Lifecycle

#### Visual Lease Timeline
```
Lease Start    T1 (50%)    T2 (87.5%)    Lease End
     |            |            |            |
     |<---------->|<---------->|<---------->|
     |            |            |            |
  Allocated    Renewal     Rebind      Expired
     |            |            |            |
     |            |            |            |
   Active      Renewal     Rebind      Must
  (Normal)    Attempted   Attempted   Restart
```

#### Lease States
1. **Allocated**: IP assigned to client and actively used
2. **Available**: IP available for assignment to new clients
3. **Expired**: Lease time exceeded, IP reclaimed
4. **Reserved**: IP reserved for specific client (static assignment)
5. **Abandoned**: IP marked as unusable due to conflicts
6. **Free**: IP returned to pool after release

### Detailed Lease Renewal Process

#### T1 (50% of lease time) - Renewal Attempt
```
Timeline: 50% of lease duration
Example: 24-hour lease → T1 at 12 hours

Process:
1. Client sends DHCPREQUEST (unicast to current server)
2. Server responds with DHCPACK (renewal granted)
3. If successful: Lease extended, continue using IP
4. If failed: Continue using IP until T2
```

#### T2 (87.5% of lease time) - Rebind Attempt
```
Timeline: 87.5% of lease duration
Example: 24-hour lease → T2 at 21 hours

Process:
1. Client sends DHCPREQUEST (broadcast to any server)
2. Any server can respond with DHCPACK or DHCPNAK
3. If successful: Lease extended, continue using IP
4. If failed: Continue using IP until expiration
```

#### Lease Expiration (100% of lease time)
```
Timeline: 100% of lease duration
Example: 24-hour lease → Expiration at 24 hours

Process:
1. Client must stop using IP address
2. Client sends DHCPRELEASE (optional, graceful)
3. Client must restart DORA process
4. Server reclaims IP for reassignment
```

### Lease Database Structure

#### Database Fields
```bash
# Example lease entry
lease 192.168.1.100 {
    starts 3 2024/09/25 10:30:45;    # Lease start time
    ends 4 2024/09/26 10:30:45;      # Lease end time
    tstp 4 2024/09/26 10:30:45;      # T2 time
    tsfp 4 2024/09/26 10:30:45;      # T1 time
    cltt 3 2024/09/25 10:30:45;      # Client last transaction time
    binding state active;             # Current state
    next binding state free;          # Next state
    rewind binding state free;        # State on rewind
    hardware ethernet 00:11:22:33:44:55;  # Client MAC
    client-hostname "laptop-01";      # Client hostname
    option dhcp-client-identifier 01:00:11:22:33:44:55;  # Client ID
}
```

#### Database Maintenance
```bash
# Check database integrity
sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf

# Backup lease database
sudo cp /var/lib/dhcp/dhcpd.leases /backup/dhcpd.leases.$(date +%Y%m%d)

# Recover from corruption
sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf
sudo systemctl restart isc-dhcp-server
```

### Lease Configuration Examples

#### Short Lease Times (High Mobility)
```bash
# Mobile devices, guest networks
subnet 192.168.100.0 netmask 255.255.255.0 {
    range 192.168.100.100 192.168.100.200;
    default-lease-time 3600;          # 1 hour
    max-lease-time 7200;              # 2 hours
    min-lease-time 1800;              # 30 minutes
}
```

#### Long Lease Times (Stable Networks)
```bash
# Corporate desktops, servers
subnet 192.168.10.0 netmask 255.255.255.0 {
    range 192.168.10.100 192.168.10.200;
    default-lease-time 86400;         # 24 hours
    max-lease-time 604800;            # 7 days
    min-lease-time 3600;              # 1 hour
}
```

#### Mixed Lease Times (Device Classification)
```bash
# Different lease times per device type
class "mobile-devices" {
    match if substring(option vendor-class-identifier, 0, 4) = "MSFT";
    default-lease-time 3600;
    max-lease-time 7200;
}

class "servers" {
    match if substring(option host-name, 0, 3) = "srv";
    default-lease-time 604800;
    max-lease-time 2592000;
}
```

### Lease Monitoring and Statistics

#### Real-time Monitoring
```bash
# Monitor active leases
sudo dhcp-lease-list

# Check lease utilization
dhcp-lease-list | wc -l

# Monitor specific client
dhcp-lease-list | grep "00:11:22:33:44:55"
```

#### Lease Statistics
```bash
# Server statistics
sudo journalctl -u isc-dhcp-server | grep -E "(DHCPDISCOVER|DHCPREQUEST|DHCPACK|DHCPNAK)"

# Lease database analysis
grep "binding state active" /var/lib/dhcp/dhcpd.leases | wc -l
grep "binding state free" /var/lib/dhcp/dhcpd.leases | wc -l
```

#### Performance Metrics
- **Lease Utilization**: Percentage of IP pool in use
- **Renewal Success Rate**: Percentage of successful renewals
- **Average Lease Duration**: How long clients keep IPs
- **Conflict Rate**: Frequency of IP conflicts
- **Response Time**: Time to assign new leases

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
