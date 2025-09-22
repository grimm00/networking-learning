# Basic Networking Commands

Essential command-line tools for network troubleshooting, analysis, and configuration.

## What You'll Learn

- Essential networking commands and their usage
- Command syntax and common options
- Practical examples for each command
- Troubleshooting techniques using command-line tools
- Output interpretation and analysis

## Connectivity Testing Commands

### ping
**Purpose**: Test network connectivity and measure round-trip time

**Basic Syntax**:
```bash
ping [options] destination
```

**Common Options**:
- `-c count`: Send specified number of packets
- `-i interval`: Set interval between packets
- `-s size`: Set packet size
- `-t ttl`: Set Time To Live
- `-W timeout`: Set timeout for each packet

**Examples**:
```bash
# Basic ping test
ping google.com

# Ping with specific count and interval
ping -c 4 -i 1 8.8.8.8

# Ping with custom packet size
ping -s 1000 192.168.1.1

# Ping with TTL limit
ping -t 5 google.com
```

**Output Interpretation**:
```
PING google.com (142.250.191.14): 56 data bytes
64 bytes from 142.250.191.14: icmp_seq=0 ttl=64 time=12.345 ms
64 bytes from 142.250.191.14: icmp_seq=1 ttl=64 time=11.234 ms
64 bytes from 142.250.191.14: icmp_seq=2 ttl=64 time=10.123 ms
64 bytes from 142.250.191.14: icmp_seq=3 ttl=64 time=9.012 ms

--- google.com ping statistics ---
4 packets transmitted, 4 received, 0% packet loss
round-trip min/avg/max/stddev = 9.012/10.678/12.345/1.234 ms
```

### traceroute
**Purpose**: Trace the path packets take to reach a destination

**Note**: Command options vary between operating systems. Examples shown are for macOS/Linux.

**Basic Syntax**:
```bash
traceroute [options] destination
```

**Common Options**:
- `-n`: Don't resolve hostnames (numeric output)
- `-I`: Use ICMP instead of UDP (macOS)
- `-P protocol`: Use specified protocol (UDP, TCP, ICMP, GRE)
- `-m max_ttl`: Set maximum TTL
- `-w timeout`: Set timeout for each probe
- `-q queries`: Set number of probes per TTL

**Examples**:
```bash
# Basic traceroute
traceroute google.com

# Numeric output only
traceroute -n 8.8.8.8

# ICMP traceroute (macOS)
traceroute -I google.com

# TCP traceroute (if supported)
traceroute -P tcp google.com

# UDP traceroute (default)
traceroute -P udp google.com
```

**Output Interpretation**:
```
traceroute to google.com (142.250.191.14), 64 hops max, 52 byte packets
 1  192.168.1.1 (192.168.1.1)  1.234 ms  0.987 ms  0.765 ms
 2  10.0.0.1 (10.0.0.1)  5.432 ms  4.321 ms  3.210 ms
 3  * * *
 4  72.14.239.1 (72.14.239.1)  15.678 ms  14.567 ms  13.456 ms
```

## Network Configuration Commands

### ip
**Purpose**: Modern network configuration and information tool

**Note**: Not available on macOS by default. Install with: `brew install iproute2mac`

**Basic Syntax**:
```bash
ip [object] [command] [options]
```

**Common Objects**:
- `addr`: IP address management
- `route`: Routing table management
- `link`: Network interface management
- `neigh`: Neighbor/ARP table management

**Examples**:
```bash
# Show all IP addresses
ip addr show

# Show routing table
ip route show

# Show network interfaces
ip link show

# Show ARP table
ip neigh show

# Add IP address
sudo ip addr add 192.168.1.100/24 dev eth0

# Add route
sudo ip route add 192.168.2.0/24 via 192.168.1.1

# Delete route
sudo ip route del 192.168.2.0/24
```

### ifconfig
**Purpose**: Legacy network interface configuration (deprecated but still used)

**Note**: Default network configuration tool on macOS. Use `ip` command on Linux for modern functionality.

**Basic Syntax**:
```bash
ifconfig [interface] [options]
```

**Examples**:
```bash
# Show all interfaces
ifconfig

# Show specific interface
ifconfig eth0

# Configure IP address
sudo ifconfig eth0 192.168.1.100 netmask 255.255.255.0

# Bring interface up/down
sudo ifconfig eth0 up
sudo ifconfig eth0 down
```

### route
**Purpose**: Legacy routing table management (deprecated but still used)

**Note**: Available on both macOS and Linux. Modern alternative is `ip route` on Linux.

**Basic Syntax**:
```bash
route [options] [command] [destination] [gateway]
```

**Examples**:
```bash
# Show routing table
route -n

# Add default route
sudo route add default gw 192.168.1.1

# Add specific route
sudo route add -net 192.168.2.0 netmask 255.255.255.0 gw 192.168.1.1

# Delete route
sudo route del -net 192.168.2.0 netmask 255.255.255.0
```

## Network Statistics Commands

### netstat
**Purpose**: Display network connections, routing tables, and interface statistics

**Basic Syntax**:
```bash
netstat [options]
```

**Common Options**:
- `-t`: Show TCP connections
- `-u`: Show UDP connections
- `-l`: Show listening ports
- `-n`: Show numeric addresses
- `-p`: Show process IDs
- `-r`: Show routing table
- `-i`: Show interface statistics
- `-s`: Show protocol statistics

**Examples**:
```bash
# Show all connections
netstat -tuln

# Show listening ports
netstat -tuln | grep LISTEN

# Show routing table
netstat -rn

# Show interface statistics
netstat -i

# Show protocol statistics
netstat -s
```

### ss
**Purpose**: Modern replacement for netstat (faster and more features)

**Basic Syntax**:
```bash
ss [options]
```

**Common Options**:
- `-t`: Show TCP connections
- `-u`: Show UDP connections
- `-l`: Show listening ports
- `-n`: Show numeric addresses
- `-p`: Show process IDs
- `-r`: Show routing table
- `-i`: Show interface statistics
- `-s`: Show summary statistics

**Examples**:
```bash
# Show all connections
ss -tuln

# Show listening ports
ss -tuln | grep LISTEN

# Show TCP connections
ss -t

# Show UDP connections
ss -u

# Show summary
ss -s
```

## DNS and Name Resolution Commands

### nslookup
**Purpose**: Query DNS servers for name resolution

**Basic Syntax**:
```bash
nslookup [options] [hostname] [server]
```

**Examples**:
```bash
# Basic DNS lookup
nslookup google.com

# Query specific DNS server
nslookup google.com 8.8.8.8

# Reverse DNS lookup
nslookup 8.8.8.8

# Interactive mode
nslookup
```

### dig
**Purpose**: Advanced DNS lookup tool with more detailed output

**Basic Syntax**:
```bash
dig [options] [hostname] [type]
```

**Common Options**:
- `@server`: Query specific DNS server
- `+short`: Short output
- `+trace`: Trace DNS resolution
- `+recurse`: Recursive query
- `-x`: Reverse DNS lookup

**Examples**:
```bash
# Basic DNS lookup
dig google.com

# Query specific DNS server
dig @8.8.8.8 google.com

# Short output
dig +short google.com

# Trace DNS resolution
dig +trace google.com

# Reverse DNS lookup
dig -x 8.8.8.8
```

## ARP Commands

### arp
**Purpose**: Display and manipulate ARP table

**Basic Syntax**:
```bash
arp [options] [command]
```

**Common Options**:
- `-a`: Show all entries
- `-d`: Delete entry
- `-s`: Add static entry
- `-n`: Show numeric addresses

**Examples**:
```bash
# Show ARP table
arp -a

# Show numeric ARP table
arp -n

# Add static ARP entry
sudo arp -s 192.168.1.100 aa:bb:cc:dd:ee:ff

# Delete ARP entry
sudo arp -d 192.168.1.100
```

## Packet Capture Commands

### tcpdump
**Purpose**: Capture and analyze network packets

**Basic Syntax**:
```bash
tcpdump [options] [expression]
```

**Common Options**:
- `-i interface`: Specify interface
- `-n`: Don't resolve hostnames
- `-c count`: Capture specified number of packets
- `-w file`: Write to file
- `-r file`: Read from file
- `-v`: Verbose output
- `-x`: Show packet contents in hex

**Examples**:
```bash
# Capture on all interfaces
sudo tcpdump -i any

# Capture specific number of packets
sudo tcpdump -c 10

# Capture to file
sudo tcpdump -w capture.pcap

# Read from file
tcpdump -r capture.pcap

# Capture specific traffic
sudo tcpdump host 192.168.1.1
sudo tcpdump port 80
sudo tcpdump icmp
```

## System Information Commands

### hostname
**Purpose**: Display or set system hostname

**Examples**:
```bash
# Show hostname
hostname

# Show FQDN
hostname -f

# Show short hostname
hostname -s
```

### uname
**Purpose**: Display system information

**Examples**:
```bash
# Show all information
uname -a

# Show kernel name
uname -s

# Show kernel version
uname -r
```

## Practical Examples

### Check Network Connectivity
```bash
# Test basic connectivity
ping -c 4 8.8.8.8

# Test DNS resolution
nslookup google.com

# Test specific port
telnet google.com 80
```

### Diagnose Network Issues
```bash
# Check IP configuration
ip addr show

# Check routing table
ip route show

# Test connectivity to gateway
ping $(ip route | grep default | awk '{print $3}')

# Check DNS servers
cat /etc/resolv.conf
```

### Monitor Network Activity
```bash
# Show active connections
netstat -tuln

# Show listening ports
ss -tuln | grep LISTEN

# Monitor network traffic
sudo tcpdump -i any -n
```

## Command Comparison

### Modern vs Legacy Commands
| Function | Modern | Legacy |
|----------|--------|--------|
| Interface config | `ip addr` | `ifconfig` |
| Routing | `ip route` | `route` |
| Statistics | `ss` | `netstat` |
| Neighbor table | `ip neigh` | `arp` |

### When to Use Which
- **Use modern commands** (`ip`, `ss`) for new scripts and automation
- **Use legacy commands** (`ifconfig`, `netstat`, `route`) for compatibility
- **Learn both** as you may encounter either in different environments

## Troubleshooting Workflow

### 1. Check Physical Layer
```bash
# Check interface status
ip link show
ifconfig
```

### 2. Check Network Layer
```bash
# Check IP configuration
ip addr show

# Check routing table
ip route show

# Test connectivity
ping 8.8.8.8
```

### 3. Check Transport Layer
```bash
# Check listening ports
ss -tuln

# Test specific ports
telnet hostname port
```

### 4. Check Application Layer
```bash
# Test DNS resolution
nslookup hostname

# Test HTTP connectivity
curl -I http://hostname
```

## Quick Reference

### Essential Commands
```bash
# Connectivity
ping destination
traceroute destination

# Configuration
ip addr show
ip route show

# Statistics
ss -tuln
netstat -tuln

# DNS
nslookup hostname
dig hostname

# ARP
arp -a
ip neigh show
```

### Common Options
- `-n`: Numeric output
- `-v`: Verbose output
- `-a`: Show all
- `-l`: Show listening
- `-t`: TCP only
- `-u`: UDP only

## macOS-Specific Notes

### Installing Modern Tools
```bash
# Install ip command (Linux equivalent)
brew install iproute2mac

# Install additional networking tools
brew install nmap
brew install tcpdump
brew install wireshark
```

### macOS vs Linux Command Equivalents
| Function | macOS | Linux |
|----------|-------|-------|
| Interface config | `ifconfig` | `ip addr` |
| Route management | `route` | `ip route` |
| ARP table | `arp -a` | `ip neigh` |
| Network stats | `netstat` | `ss` |
| Packet capture | `tcpdump` | `tcpdump` |

### macOS-Specific Commands
```bash
# Show all network interfaces
ifconfig -a

# Show routing table
netstat -rn

# Show network statistics
netstat -i

# Show active connections
netstat -an

# Show multicast groups
netstat -g
```
