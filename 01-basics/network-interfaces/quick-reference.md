# Network Interfaces Quick Reference

## Essential Commands

### Interface Management

#### `ip` Command (Linux - Primary)
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

# Add/remove IP address
sudo ip addr add 192.168.1.100/24 dev eth0
sudo ip addr del 192.168.1.100/24 dev eth0

# Show interface statistics
ip -s link show eth0
```

#### `ifconfig` Command (macOS - Legacy)
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

### Routing Commands

#### `ip route` Command (Linux)
```bash
# Show routing table
ip route show
ip route show dev eth0

# Add/remove routes
sudo ip route add 10.0.0.0/8 via 192.168.1.1 dev eth0
sudo ip route del 10.0.0.0/8 via 192.168.1.1 dev eth0

# Add default route
sudo ip route add default via 192.168.1.1 dev eth0
```

#### `route` Command (Legacy)
```bash
# Show routing table
route -n

# Add/remove routes
sudo route add -net 10.0.0.0/8 gw 192.168.1.1
sudo route del -net 10.0.0.0/8 gw 192.168.1.1

# Add default route
sudo route add default gw 192.168.1.1
```

### DNS Configuration

```bash
# Configure DNS servers
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
echo "nameserver 8.8.4.4" | sudo tee -a /etc/resolv.conf

# Test DNS resolution
nslookup google.com
dig google.com
```

### DHCP Configuration

```bash
# Enable DHCP
sudo dhclient eth0

# Release DHCP lease
sudo dhclient -r eth0

# Renew DHCP lease
sudo dhclient eth0
```

## Virtual Interfaces

### VLAN Configuration
```bash
# Create VLAN interface
sudo ip link add link eth0 name eth0.100 type vlan id 100

# Configure VLAN interface
sudo ip addr add 192.168.100.1/24 dev eth0.100
sudo ip link set eth0.100 up

# Remove VLAN interface
sudo ip link set eth0.100 down
sudo ip link delete eth0.100
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

# Remove interface from bridge
sudo ip link set eth0 nomaster
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

## Diagnostic Commands

### Interface Analysis
```bash
# Show interface details
ip link show eth0
ip addr show eth0

# Show interface statistics
cat /proc/net/dev
ip -s link show eth0

# Show interface errors
ethtool -S eth0 | grep -i error

# Monitor interface traffic
iftop -i eth0
sar -n DEV 1 10
```

### Connectivity Tests
```bash
# Test local connectivity
ping -I eth0 192.168.1.1
ping -I 192.168.1.100 8.8.8.8

# Test routing
traceroute -i eth0 8.8.8.8

# Test DNS resolution
nslookup google.com
dig google.com
```

### Network Statistics
```bash
# Show network statistics
ss -tuln                    # Show listening sockets
ss -i                       # Show connections by interface
ss -tulnp                   # Show detailed socket information

# Show interface utilization
sar -n DEV 1 10             # Show network device statistics
iftop -i eth0               # Show real-time network usage
```

## Common Interface Names

### Linux
- **Ethernet**: `eth0`, `enp0s3`, `ens33`
- **WiFi**: `wlan0`, `wlp2s0`
- **Loopback**: `lo`
- **Virtual**: `br0`, `bond0`, `tun0`, `tap0`

### macOS
- **Ethernet**: `en0`, `en1`
- **WiFi**: `en0`, `en1`
- **Loopback**: `lo0`
- **Virtual**: `bridge0`, `utun0`

## Interface States

- **UP**: Interface is active and can transmit/receive
- **DOWN**: Interface is inactive
- **UNKNOWN**: State cannot be determined
- **LOWER_UP**: Physical layer is up (cable connected)

## Common Issues and Solutions

### Interface Not Coming Up
```bash
# Check interface status
ip link show eth0

# Check for driver issues
dmesg | grep eth0

# Check cable connection
ethtool eth0

# Restart network service
sudo systemctl restart NetworkManager
```

### No IP Address
```bash
# Check DHCP client
sudo dhclient -v eth0

# Check for IP conflicts
arping -I eth0 192.168.1.100

# Check routing table
ip route show
```

### Slow Performance
```bash
# Check interface statistics
cat /proc/net/dev

# Check for errors
ethtool -S eth0

# Check MTU
ip link show eth0

# Test with different MTU
sudo ip link set eth0 mtu 9000
```

## Configuration Files

### Linux (Ubuntu/Debian)
- **Netplan**: `/etc/netplan/01-netcfg.yaml`
- **NetworkManager**: `/etc/NetworkManager/NetworkManager.conf`
- **Interfaces**: `/etc/network/interfaces`
- **DNS**: `/etc/resolv.conf`

### Linux (CentOS/RHEL)
- **Network**: `/etc/sysconfig/network-scripts/ifcfg-eth0`
- **DNS**: `/etc/resolv.conf`

### macOS
- **Network**: System Preferences → Network
- **DNS**: `/etc/resolv.conf`

## Security Best Practices

### Interface Security
```bash
# Disable unused interfaces
sudo ip link set eth1 down

# Use VLANs for segmentation
sudo ip link add link eth0 name eth0.100 type vlan id 100

# Monitor interface activity
sudo tcpdump -i eth0 -n

# Use secure protocols for management
ssh -o StrictHostKeyChecking=yes admin@192.168.1.1
```

### Monitoring
```bash
# Monitor interface activity
sudo tcpdump -i eth0 -n

# Check for unusual traffic
iftop -i eth0

# Monitor interface errors
watch -n 1 'cat /proc/net/dev | grep eth0'
```

## Tools and Scripts

This module includes several tools for network interface management:

- **`interface-analyzer.py`**: Comprehensive interface analysis tool
- **`interface-troubleshoot.sh`**: Automated troubleshooting script
- **`interface-config-lab.sh`**: Hands-on configuration practice

## Quick Troubleshooting Checklist

1. **Check interface status**: `ip link show eth0`
2. **Check IP configuration**: `ip addr show eth0`
3. **Check routing**: `ip route show`
4. **Test connectivity**: `ping 8.8.8.8`
5. **Check DNS**: `nslookup google.com`
6. **Check errors**: `cat /proc/net/dev`
7. **Restart service**: `sudo systemctl restart NetworkManager`

## Command Comparison: Linux vs macOS

| Task | Linux (ip) | macOS (ifconfig) |
|------|------------|------------------|
| Show interfaces | `ip link show` | `ifconfig -a` |
| Show IP addresses | `ip addr show` | `ifconfig en0` |
| Bring up interface | `ip link set eth0 up` | `ifconfig en0 up` |
| Add IP address | `ip addr add 192.168.1.100/24 dev eth0` | `ifconfig en0 192.168.1.100 netmask 255.255.255.0` |
| Show routes | `ip route show` | `route -n` |
| Add route | `ip route add default via 192.168.1.1` | `route add default 192.168.1.1` |

---

*This quick reference provides essential commands and concepts for network interface management.*
