# IPv4 Addressing Quick Reference

## IPv4 Address Structure

### Format
- **32 bits total**: 4 octets × 8 bits each
- **Dotted decimal**: 192.168.1.1
- **Binary**: 11000000.10101000.00000001.00000001
- **Hex**: C0A80101

### Address Components
- **Network Portion**: Identifies the network
- **Host Portion**: Identifies the specific device
- **Subnet Mask**: Determines network vs host portions

## Subnet Masks

### Common Subnet Masks
| CIDR | Subnet Mask | Hosts | Networks |
|------|-------------|-------|----------|
| /24 | 255.255.255.0 | 254 | 1 |
| /25 | 255.255.255.128 | 126 | 2 |
| /26 | 255.255.255.192 | 62 | 4 |
| /27 | 255.255.255.224 | 30 | 8 |
| /28 | 255.255.255.240 | 14 | 16 |
| /29 | 255.255.255.248 | 6 | 32 |
| /30 | 255.255.255.252 | 2 | 64 |

### Binary to Decimal
- **128**: 10000000
- **192**: 11000000
- **224**: 11100000
- **240**: 11110000
- **248**: 11111000
- **252**: 11111100
- **254**: 11111110
- **255**: 11111111

## IP Address Classes

### Class A (1.0.0.0 - 126.255.255.255)
- **Default mask**: /8 (255.0.0.0)
- **Network bits**: 8
- **Host bits**: 24
- **Networks**: 126
- **Hosts per network**: 16,777,214

### Class B (128.0.0.0 - 191.255.255.255)
- **Default mask**: /16 (255.255.0.0)
- **Network bits**: 16
- **Host bits**: 16
- **Networks**: 16,384
- **Hosts per network**: 65,534

### Class C (192.0.0.0 - 223.255.255.255)
- **Default mask**: /24 (255.255.255.0)
- **Network bits**: 24
- **Host bits**: 8
- **Networks**: 2,097,152
- **Hosts per network**: 254

## Private IP Addresses (RFC 1918)

### Private Ranges
- **10.0.0.0/8**: 10.0.0.0 - 10.255.255.255
- **172.16.0.0/12**: 172.16.0.0 - 172.31.255.255
- **192.168.0.0/16**: 192.168.0.0 - 192.168.255.255

### Special Addresses
- **127.0.0.1**: Loopback (localhost)
- **169.254.x.x**: Link-local (APIPA)
- **0.0.0.0**: Default route
- **255.255.255.255**: Broadcast

## Subnetting Calculations

### Basic Formula
- **Hosts needed**: 2^n - 2 (where n = host bits)
- **Subnets needed**: 2^n (where n = subnet bits)
- **Magic number**: 256 - subnet mask octet

### Subnetting Steps
1. **Determine requirements**: How many subnets? How many hosts?
2. **Calculate subnet mask**: Based on requirements
3. **Identify subnet ranges**: Calculate network addresses
4. **Assign addresses**: Allocate IP ranges to subnets

### Example: 192.168.1.0/24 → 4 subnets
- **New mask**: /26 (255.255.255.192)
- **Subnet 1**: 192.168.1.0/26 (192.168.1.1 - 192.168.1.62)
- **Subnet 2**: 192.168.1.64/26 (192.168.1.65 - 192.168.1.126)
- **Subnet 3**: 192.168.1.128/26 (192.168.1.129 - 192.168.1.190)
- **Subnet 4**: 192.168.1.192/26 (192.168.1.193 - 192.168.1.254)

## VLSM (Variable Length Subnet Masking)

### Purpose
Using different subnet masks for different subnets to optimize IP address usage.

### VLSM Example
**Given**: 192.168.1.0/24, need:
- 2 subnets with 100 hosts each → /25
- 4 subnets with 50 hosts each → /26
- 8 subnets with 10 hosts each → /28

## Supernetting

### Purpose
Combining multiple smaller networks into a larger network.

### Example
**Given**: 192.168.1.0/24, 192.168.2.0/24, 192.168.3.0/24, 192.168.4.0/24
**Supernet**: 192.168.0.0/22

## Powers of 2

| Power | Value | Power | Value |
|-------|-------|-------|-------|
| 2^0 | 1 | 2^8 | 256 |
| 2^1 | 2 | 2^9 | 512 |
| 2^2 | 4 | 2^10 | 1,024 |
| 2^3 | 8 | 2^11 | 2,048 |
| 2^4 | 16 | 2^12 | 4,096 |
| 2^5 | 32 | 2^13 | 8,192 |
| 2^6 | 64 | 2^14 | 16,384 |
| 2^7 | 128 | 2^15 | 32,768 |

## Common Commands

### Linux/Unix
```bash
# Check IP configuration
ip addr show
ifconfig

# Check routing table
ip route show
route -n

# Test connectivity
ping 8.8.8.8
traceroute google.com

# Check DNS
nslookup google.com
dig google.com

# Check ARP table
arp -a
ip neigh show
```

### Windows
```cmd
# Check IP configuration
ipconfig
ipconfig /all

# Check routing table
route print

# Test connectivity
ping 8.8.8.8
tracert google.com

# Check DNS
nslookup google.com

# Check ARP table
arp -a
```

## Troubleshooting Checklist

### Layer 1 (Physical)
- [ ] Check cable connections
- [ ] Verify interface status
- [ ] Check for physical damage
- [ ] Verify power supply

### Layer 2 (Data Link)
- [ ] Check MAC address assignment
- [ ] Verify ARP table
- [ ] Check for duplex mismatches
- [ ] Verify VLAN configuration

### Layer 3 (Network)
- [ ] Check IP address assignment
- [ ] Verify routing table
- [ ] Test connectivity to gateway
- [ ] Check DNS resolution

### Layer 4 (Transport)
- [ ] Check port availability
- [ ] Verify firewall rules
- [ ] Test TCP/UDP connectivity
- [ ] Check for port conflicts

## Common Issues

### IP Conflicts
- **Symptoms**: Intermittent connectivity, ARP table shows multiple MACs
- **Solution**: Change one of the conflicting IP addresses

### Wrong Subnet Mask
- **Symptoms**: Cannot communicate with devices on same network
- **Solution**: Verify and correct subnet mask configuration

### Gateway Issues
- **Symptoms**: Cannot access Internet or other networks
- **Solution**: Check gateway configuration and connectivity

### DNS Problems
- **Symptoms**: Cannot resolve hostnames, IP addresses work
- **Solution**: Check DNS server configuration and connectivity

## Design Best Practices

### Addressing
- Use hierarchical addressing
- Plan for future growth
- Use consistent naming conventions
- Document all configurations

### Security
- Implement network segmentation
- Use private IP ranges internally
- Implement access control lists
- Monitor network traffic

### Management
- Use DHCP for automatic assignment
- Implement IP address management
- Regular network audits
- Proper documentation

## Tools and Resources

### Online Tools
- Subnet calculators
- IP address analyzers
- Network design tools
- CIDR calculators

### Command Line Tools
- `ipcalc`: Calculate network information
- `nmap`: Network discovery and scanning
- `tcpdump`: Packet capture and analysis
- `netstat`: Network statistics

### Python Tools
- `ipaddress` module
- Custom calculators
- Network analysis scripts
- Automation tools
