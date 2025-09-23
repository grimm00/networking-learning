# Network Interfaces

Network interfaces are the physical and logical connections between devices and networks. Understanding how to manage, configure, and troubleshoot network interfaces is fundamental to networking.

## Table of Contents

- [Interface Types](#interface-types)
- [Interface Management Commands](#interface-management-commands)
- [Interface Configuration](#interface-configuration)
- [Interface States and Properties](#interface-states-and-properties)
- [Virtual Interfaces](#virtual-interfaces)
- [Interface Troubleshooting](#interface-troubleshooting)
- [Security Considerations](#security-considerations)
- [Practical Labs](#practical-labs)

## Interface Types

### Physical Interfaces
- **Ethernet**: Most common wired interface (eth0, enp0s3, etc.)
  - Uses RJ45 connectors, supports speeds from 10Mbps to 100Gbps
  - Full-duplex communication by default
- **WiFi**: Wireless interfaces (wlan0, wlp2s0, etc.)
  - IEEE 802.11 standards (a/b/g/n/ac/ax)
  - Requires wireless drivers and authentication
- **Loopback**: Virtual interface for local communication (lo)
  - Always present, used for localhost traffic (127.0.0.1)
  - Never goes down, no physical hardware required
- **Serial**: Point-to-point connections (ppp0, etc.)
  - Used for dial-up, ISDN, or serial connections
  - Less common in modern networks

### Virtual Interfaces
- **VLAN**: Virtual LAN interfaces (eth0.100, vlan100)
  - Segments traffic at Layer 2 using 802.1Q tagging
  - Allows multiple logical networks on single physical interface
- **Bridge**: Software bridge interfaces (br0, virbr0)
  - Connects multiple network segments at Layer 2
  - Common in virtualization (Docker, KVM, VMware)
- **Bond**: Link aggregation interfaces (bond0)
  - Combines multiple physical interfaces for redundancy/performance
  - Supports various bonding modes (active-backup, 802.3ad, etc.)
- **Tunnel**: VPN and tunneling interfaces (tun0, tap0)
  - TUN: Layer 3 tunneling (IP packets)
  - TAP: Layer 2 tunneling (Ethernet frames)
  - Used for VPNs, GRE tunnels, VXLAN

## Interface Management Commands

### Linux Commands (Primary)

#### `ip` Command - Modern Interface Management
```bash
# Show all interfaces
ip link show
ip addr show

# Show specific interface
ip link show eth0
ip addr show eth0

# Bring interface up/down
sudo ip link set eth0 up
sudo ip link set eth0 down

# Add IP address to interface
sudo ip addr add 192.168.1.100/24 dev eth0
sudo ip addr del 192.168.1.100/24 dev eth0

# Show routing table
ip route show
ip route show dev eth0

# Add/remove routes
sudo ip route add 10.0.0.0/8 via 192.168.1.1 dev eth0
sudo ip route del 10.0.0.0/8 via 192.168.1.1 dev eth0
```

#### `ss` Command - Socket Statistics
```bash
# Show all listening sockets
ss -tuln

# Show connections by interface
ss -i

# Show detailed socket information
ss -tulnp
```

### macOS Commands (Legacy/Alternative)

#### `ifconfig` Command
```bash
# Show all interfaces
ifconfig -a

# Show specific interface
ifconfig en0

# Configure interface
sudo ifconfig en0 192.168.1.100 netmask 255.255.255.0
sudo ifconfig en0 up
sudo ifconfig en0 down

# Show interface statistics
ifconfig en0 | grep -E "(RX|TX|errors|dropped)"
```

#### `networksetup` Command (macOS)
```bash
# List network services
networksetup -listallnetworkservices

# Get interface information
networksetup -getinfo "Wi-Fi"
networksetup -getinfo "Ethernet"

# Configure DNS
networksetup -setdnsservers "Wi-Fi" 8.8.8.8 8.8.4.4
```

## Interface Configuration

### Static IP Configuration

#### Linux (using ip command)
```bash
# Configure static IP
sudo ip addr add 192.168.1.100/24 dev eth0
sudo ip link set eth0 up
sudo ip route add default via 192.168.1.1 dev eth0

# Configure DNS
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
echo "nameserver 8.8.4.4" | sudo tee -a /etc/resolv.conf
```

#### Linux (using netplan - Ubuntu 18.04+)
```yaml
# /etc/netplan/01-netcfg.yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
```

#### Linux (using NetworkManager)
```bash
# Configure with nmcli
sudo nmcli connection modify "Wired connection 1" \
    ipv4.addresses 192.168.1.100/24 \
    ipv4.gateway 192.168.1.1 \
    ipv4.dns "8.8.8.8,8.8.4.4" \
    ipv4.method manual

sudo nmcli connection up "Wired connection 1"
```

### DHCP Configuration

#### Linux
```bash
# Enable DHCP
sudo dhclient eth0

# Release DHCP lease
sudo dhclient -r eth0

# Renew DHCP lease
sudo dhclient eth0
```

#### macOS
```bash
# Renew DHCP lease
sudo ipconfig set en0 DHCP

# Release and renew
sudo ipconfig set en0 BOOTP
sudo ipconfig set en0 DHCP
```

## Interface States and Properties

### Interface States
- **UP**: Interface is active and can transmit/receive
  - Software interface is enabled and ready for traffic
  - Does not guarantee physical connectivity
- **DOWN**: Interface is inactive
  - Software interface is disabled, no traffic can pass
  - May be intentional or due to configuration issues
- **UNKNOWN**: State cannot be determined
  - Usually indicates driver or hardware problems
  - Requires investigation and troubleshooting
- **LOWER_UP**: Physical layer is up (cable connected)
  - Indicates physical connectivity is established
  - Cable is plugged in and link is detected

### Key Properties
- **MTU**: Maximum Transmission Unit (default: 1500 bytes)
  - Largest packet size interface can handle without fragmentation
  - Ethernet standard is 1500 bytes, jumbo frames can be 9000+ bytes
- **MAC Address**: Hardware address (unique identifier)
  - 48-bit address assigned by manufacturer (first 24 bits) + unique (last 24 bits)
  - Used for Layer 2 communication, globally unique
- **Speed**: Interface speed (10Mbps, 100Mbps, 1Gbps, etc.)
  - Negotiated speed between interface and connected device
  - Auto-negotiation determines best common speed
- **Duplex**: Communication mode (half/full duplex)
  - Half-duplex: Can send OR receive, but not simultaneously
  - Full-duplex: Can send AND receive simultaneously (modern standard)

### Viewing Interface Properties
```bash
# Show interface details
ip link show eth0

# Show interface statistics
cat /proc/net/dev

# Show interface speed and duplex
ethtool eth0

# Show interface information (macOS)
ifconfig en0
```

## Virtual Interfaces

### VLAN Configuration
```bash
# Create VLAN interface
sudo ip link add link eth0 name eth0.100 type vlan id 100

# Configure VLAN interface
sudo ip addr add 192.168.100.1/24 dev eth0.100
sudo ip link set eth0.100 up
```

### Bridge Configuration
```bash
# Create bridge
sudo ip link add name br0 type bridge

# Add interface to bridge
sudo ip link set eth0 master br0
sudo ip link set br0 up

# Configure bridge IP
sudo ip addr add 192.168.1.1/24 dev br0
```

### Bond Configuration (Link Aggregation)
```bash
# Create bond interface
sudo ip link add name bond0 type bond mode 802.3ad

# Add interfaces to bond
sudo ip link set eth0 master bond0
sudo ip link set eth1 master bond0

# Configure bond IP
sudo ip addr add 192.168.1.100/24 dev bond0
sudo ip link set bond0 up
```

## Interface Troubleshooting

### Common Issues and Solutions

#### Interface Not Coming Up
**Symptoms**: Interface shows DOWN state, no connectivity
```bash
# Check interface status
ip link show eth0

# Check for driver issues
dmesg | grep eth0

# Check cable connection
ethtool eth0

# Restart network service
sudo systemctl restart NetworkManager

# Check if interface is disabled in BIOS/UEFI
# Check physical cable connections
# Verify switch/router port is active
```

#### No IP Address
**Symptoms**: Interface is UP but has no IP address assigned
```bash
# Check DHCP client
sudo dhclient -v eth0

# Check for IP conflicts
arping -I eth0 192.168.1.100

# Check routing table
ip route show

# Verify DHCP server is reachable
ping -c 3 192.168.1.1

# Check DHCP client logs
journalctl -u NetworkManager
```

#### Slow Performance
**Symptoms**: High latency, low throughput, packet loss
```bash
# Check interface statistics
cat /proc/net/dev

# Check for errors
ethtool -S eth0

# Check MTU
ip link show eth0

# Test with different MTU
sudo ip link set eth0 mtu 9000

# Check for duplex mismatches
ethtool eth0 | grep -E "(Speed|Duplex)"

# Monitor real-time traffic
iftop -i eth0
```

#### Intermittent Connectivity
**Symptoms**: Connection works sometimes, fails randomly
```bash
# Check for cable issues
ethtool eth0 | grep -E "(Link detected|Speed|Duplex)"

# Monitor interface errors over time
watch -n 1 'cat /proc/net/dev | grep eth0'

# Check for electrical interference
# Test with different cable
# Check switch/router logs
```

#### High Error Rates
**Symptoms**: Many RX/TX errors, dropped packets
```bash
# Check detailed error statistics
ethtool -S eth0 | grep -i error

# Check for buffer overruns
cat /proc/net/dev | grep eth0

# Verify interface speed/duplex settings
ethtool eth0

# Check for hardware issues
dmesg | grep -i "eth0.*error"
```

### Diagnostic Commands

#### Interface Analysis
```bash
# Comprehensive interface check
ip -s link show

# Check interface errors
ethtool -S eth0 | grep -i error

# Monitor interface traffic
iftop -i eth0

# Check interface utilization
sar -n DEV 1 10
```

#### Network Connectivity Tests
```bash
# Test local connectivity
ping -I eth0 192.168.1.1

# Test with specific source IP
ping -I 192.168.1.100 8.8.8.8

# Test routing
traceroute -i eth0 8.8.8.8

# Test DNS resolution
nslookup google.com
```

### Troubleshooting Flowchart

```
Interface Problem
       ↓
Is interface UP?
   ↓        ↓
  NO       YES
   ↓        ↓
Bring up   Has IP?
interface    ↓    ↓
   ↓        NO   YES
Check      Check  Test
cable      DHCP   connectivity
   ↓        ↓        ↓
Check     Check   Check
driver    server  routing
   ↓        ↓        ↓
Check     Check   Check
BIOS      logs    DNS
```

### Systematic Troubleshooting Approach

1. **Physical Layer**
   - Check cable connections
   - Verify switch/router port status
   - Test with different cable
   - Check for physical damage

2. **Data Link Layer**
   - Verify interface is UP
   - Check for driver issues
   - Verify speed/duplex settings
   - Check for errors

3. **Network Layer**
   - Verify IP address assignment
   - Check routing table
   - Test connectivity to gateway
   - Verify DNS resolution

4. **Application Layer**
   - Test specific applications
   - Check firewall rules
   - Verify service status
   - Check application logs

## Security Considerations

### Interface Security
- **Disable unused interfaces**: Reduce attack surface
  - Prevents unauthorized access through unused ports
  - Reduces potential attack vectors
- **Use VLANs**: Segment network traffic
  - Isolate different network segments
  - Control traffic flow between VLANs
- **Monitor interface activity**: Detect anomalies
  - Monitor for unusual traffic patterns
  - Detect potential security breaches
- **Secure management interfaces**: Use dedicated management networks
  - Separate management traffic from data traffic
  - Use out-of-band management when possible

### Best Practices
```bash
# Disable unused interfaces
sudo ip link set eth1 down

# Use VLANs for segmentation
sudo ip link add link eth0 name eth0.100 type vlan id 100

# Monitor interface activity
sudo tcpdump -i eth0 -n

# Use secure protocols for management
ssh -o StrictHostKeyChecking=yes admin@192.168.1.1

# Implement port security (if supported)
# Limit MAC addresses per port
# Enable port authentication (802.1X)

# Regular security audits
# Monitor interface logs
# Keep drivers and firmware updated
```

### Security Monitoring
```bash
# Monitor for unusual traffic patterns
sudo tcpdump -i eth0 -n -c 100

# Check for unauthorized interfaces
ip link show

# Monitor interface statistics for anomalies
watch -n 5 'cat /proc/net/dev'

# Check for interface promiscuous mode
ip link show | grep PROMISC

# Monitor ARP table for suspicious entries
arp -a
```

## Practical Labs

### Lab 1: Basic Interface Management
**Objective**: Learn fundamental interface operations
1. List all network interfaces using `ip link show`
2. Identify the primary interface and its properties
3. Check interface status, MTU, and MAC address
4. Bring an interface down and back up
5. View interface statistics and error counts
6. **Expected Outcome**: Understand interface states and basic management

### Lab 2: IP Configuration
**Objective**: Master IP address assignment and routing
1. Configure static IP address (192.168.100.10/24)
2. Configure default gateway (192.168.100.1)
3. Configure DNS servers (8.8.8.8, 8.8.4.4)
4. Test connectivity to gateway and internet
5. Switch to DHCP configuration and verify
6. **Expected Outcome**: Understand static vs dynamic IP configuration

### Lab 3: Virtual Interfaces
**Objective**: Work with advanced interface types
1. Create a VLAN interface (eth0.100)
2. Configure VLAN IP address (192.168.100.20/24)
3. Test VLAN connectivity and isolation
4. Create a bridge interface (br0)
5. Add physical interface to bridge
6. Test bridge functionality
7. **Expected Outcome**: Understand VLANs and bridging concepts

### Lab 4: Troubleshooting
**Objective**: Develop diagnostic skills
1. Simulate interface problems (cable unplugged, wrong IP)
2. Use diagnostic commands to identify issues
3. Apply appropriate solutions
4. Monitor interface performance over time
5. Document troubleshooting steps and solutions
6. **Expected Outcome**: Build systematic troubleshooting approach

### Lab 5: Performance Optimization
**Objective**: Optimize interface performance
1. Check current interface speed and duplex
2. Test with different MTU sizes
3. Monitor interface utilization and errors
4. Configure interface bonding (if multiple interfaces available)
5. Test failover scenarios
6. **Expected Outcome**: Understand performance tuning concepts

### Lab 6: Security Hardening
**Objective**: Implement interface security
1. Disable unused interfaces
2. Configure VLANs for network segmentation
3. Monitor interface activity for anomalies
4. Implement access controls where possible
5. Document security configuration
6. **Expected Outcome**: Apply security best practices

## Quick Reference

### Essential Commands
```bash
# Interface management
ip link show                    # Show all interfaces
ip addr show                   # Show IP addresses
ip link set eth0 up            # Bring interface up
ip link set eth0 down          # Bring interface down

# IP configuration
ip addr add 192.168.1.100/24 dev eth0    # Add IP
ip addr del 192.168.1.100/24 dev eth0    # Remove IP
ip route add default via 192.168.1.1     # Add default route

# Diagnostics
ip -s link show               # Show interface statistics
ethtool eth0                  # Show interface properties
cat /proc/net/dev             # Show network statistics
```

### Common Interface Names

#### Linux Interface Naming
- **Legacy**: eth0, eth1, wlan0 (traditional naming)
- **Predictable**: enp0s3, enp2s0, wlp3s0 (systemd/udev naming)
  - `en` = Ethernet, `wl` = Wireless LAN
  - `p0s3` = PCI bus 0, slot 3
  - `p2s0` = PCI bus 2, slot 0
- **Virtual**: br0, bond0, tun0, tap0, vlan100
- **Special**: lo (loopback), docker0 (Docker bridge)

#### macOS Interface Naming
- **Ethernet**: en0, en1, en2 (en = Ethernet)
- **WiFi**: en0, en1 (same as Ethernet, depends on connection)
- **Loopback**: lo0
- **Virtual**: bridge0, utun0, utun1

#### Interface Naming Rules
- **Physical**: Based on hardware location (PCI slot, USB port)
- **Virtual**: Descriptive names (br0, bond0, vlan100)
- **Consistent**: Same interface gets same name across reboots
- **Predictable**: Names based on hardware topology, not discovery order

## Tools and Scripts

This module includes several tools for network interface management:

- **`interface-analyzer.py`**: Comprehensive interface analysis tool
- **`interface-troubleshoot.sh`**: Automated troubleshooting script
- **`interface-config-lab.sh`**: Hands-on configuration practice
- **`quick-reference.md`**: Command reference and examples

## Next Steps

After mastering network interfaces, you'll be ready to explore:
- **Routing**: How packets move between networks
- **DNS**: Name resolution and domain services
- **Protocols**: HTTP/HTTPS, SSH, and other application protocols
- **Security**: Network security and monitoring

---

*This module provides the foundation for understanding and managing network interfaces in modern networking environments.*
