# IPv4 Addressing and Subnetting

Learn IPv4 addressing, subnet masks, CIDR notation, and subnetting through hands-on examples and practical exercises.

## What You'll Learn

- IPv4 address structure and components
- Subnet masks and their purpose
- CIDR notation and slash notation
- Subnetting techniques and calculations
- Network and host identification
- Private vs public IP addresses
- VLSM (Variable Length Subnet Masking)
- Supernetting and route aggregation

## Understanding IPv4 Addresses

### IPv4 Address Structure
An IPv4 address is a 32-bit number divided into four 8-bit octets, separated by dots.

**Format**: `192.168.1.1`
- **32 bits total**: 4 octets × 8 bits each
- **Dotted decimal notation**: Each octet ranges from 0-255
- **Binary representation**: `11000000.10101000.00000001.00000001`

### Address Components
- **Network Portion**: Identifies the network
- **Host Portion**: Identifies the specific device
- **Subnet Mask**: Determines which part is network vs host

## Subnet Masks

### Purpose
Subnet masks define which portion of an IP address is the network and which is the host.

### Common Subnet Masks
- **/8**: `255.0.0.0` (Class A)
- **/16**: `255.255.0.0` (Class B)
- **/24**: `255.255.255.0` (Class C)
- **/32**: `255.255.255.255` (Single host)

### Binary Representation
```
IP Address:  192.168.1.1    = 11000000.10101000.00000001.00000001
Subnet Mask: 255.255.255.0  = 11111111.11111111.11111111.00000000
Network:     192.168.1.0    = 11000000.10101000.00000001.00000000
Host:        0.0.0.1        = 00000000.00000000.00000000.00000001
```

## CIDR Notation

### What is CIDR?
Classless Inter-Domain Routing (CIDR) uses slash notation to specify the number of network bits.

### CIDR Examples
- **192.168.1.0/24**: 24 network bits, 8 host bits
- **10.0.0.0/8**: 8 network bits, 24 host bits
- **172.16.0.0/16**: 16 network bits, 16 host bits
- **192.168.1.128/25**: 25 network bits, 7 host bits

### Calculating Subnet Information
```bash
# Use the included calculator
python3 ipv4-calculator.py 192.168.1.0/24
```

## IP Address Classes

### Class A (1.0.0.0 - 126.255.255.255)
- **Default mask**: /8 (255.0.0.0)
- **Network bits**: 8
- **Host bits**: 24
- **Networks**: 126 (0 and 127 reserved)
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

### Special Addresses
- **127.0.0.1**: Loopback (localhost)
- **169.254.x.x**: Link-local (APIPA)
- **0.0.0.0**: Default route
- **255.255.255.255**: Broadcast

## Private vs Public IP Addresses

### Private IP Ranges (RFC 1918)
- **10.0.0.0/8**: 10.0.0.0 - 10.255.255.255
- **172.16.0.0/12**: 172.16.0.0 - 172.31.255.255
- **192.168.0.0/16**: 192.168.0.0 - 192.168.255.255

### Public IP Addresses
- All other addresses not in private ranges
- Must be unique globally
- Assigned by IANA and regional registries

## Subnetting

### What is Subnetting?
Dividing a large network into smaller, more manageable subnets.

### Benefits
- **Security**: Isolate network segments
- **Performance**: Reduce broadcast domains
- **Organization**: Logical grouping of devices
- **Efficiency**: Better use of IP address space

### Subnetting Process
1. **Determine requirements**: How many subnets? How many hosts per subnet?
2. **Calculate subnet mask**: Based on requirements
3. **Identify subnet ranges**: Calculate network addresses
4. **Assign addresses**: Allocate IP ranges to subnets

### Subnetting Example
**Given**: 192.168.1.0/24, need 4 subnets

**Solution**:
- **Subnet mask**: /26 (255.255.255.192)
- **Subnet 1**: 192.168.1.0/26 (192.168.1.1 - 192.168.1.62)
- **Subnet 2**: 192.168.1.64/26 (192.168.1.65 - 192.168.1.126)
- **Subnet 3**: 192.168.1.128/26 (192.168.1.129 - 192.168.1.190)
- **Subnet 4**: 192.168.1.192/26 (192.168.1.193 - 192.168.1.254)

## VLSM (Variable Length Subnet Masking)

### What is VLSM?
Using different subnet masks for different subnets to optimize IP address usage.

### VLSM Example
**Given**: 192.168.1.0/24, need:
- 2 subnets with 100 hosts each
- 4 subnets with 50 hosts each
- 8 subnets with 10 hosts each

**Solution**:
- **100 hosts**: /25 (126 hosts each)
- **50 hosts**: /26 (62 hosts each)
- **10 hosts**: /28 (14 hosts each)

## Supernetting

### What is Supernetting?
Combining multiple smaller networks into a larger network.

### Benefits
- **Route aggregation**: Reduce routing table size
- **Efficiency**: Summarize multiple routes
- **Performance**: Faster routing decisions

### Supernetting Example
**Given**: 192.168.1.0/24, 192.168.2.0/24, 192.168.3.0/24, 192.168.4.0/24

**Supernet**: 192.168.0.0/22 (covers 192.168.0.0 - 192.168.3.255)

## Practical Exercises

### Exercise 1: Basic Address Analysis
```bash
# Analyze your current IP configuration
ip addr show
ifconfig

# Identify network and host portions
python3 ipv4-calculator.py $(ip route | grep default | awk '{print $3}')/24
```

### Exercise 2: Subnetting Practice
```bash
# Practice subnetting with different scenarios
./subnetting-practice.sh

# Use the interactive calculator
python3 ipv4-calculator.py --interactive
```

### Exercise 3: Network Design
```bash
# Design a network for a small office
./network-design-lab.sh

# Test your design
./network-testing.sh
```

## Common Subnet Masks Reference

| CIDR | Subnet Mask | Hosts | Networks |
|------|-------------|-------|----------|
| /24 | 255.255.255.0 | 254 | 1 |
| /25 | 255.255.255.128 | 126 | 2 |
| /26 | 255.255.255.192 | 62 | 4 |
| /27 | 255.255.255.224 | 30 | 8 |
| /28 | 255.255.255.240 | 14 | 16 |
| /29 | 255.255.255.248 | 6 | 32 |
| /30 | 255.255.255.252 | 2 | 64 |

## Troubleshooting IP Addressing

### Common Issues
1. **IP conflicts**: Same IP used by multiple devices
2. **Wrong subnet mask**: Incorrect network/host identification
3. **Gateway issues**: Default gateway not reachable
4. **DNS problems**: Cannot resolve hostnames

### Diagnostic Commands
```bash
# Check IP configuration
ip addr show
ifconfig

# Test connectivity
ping 8.8.8.8
ping gateway-ip

# Check routing
ip route show
traceroute destination

# Test DNS
nslookup hostname
dig hostname
```

## Lab Exercises

Run the included scripts for hands-on practice:

```bash
./subnetting-practice.sh     # Subnetting exercises
./network-design-lab.sh      # Network design scenarios
./ipv4-troubleshooting.sh    # Troubleshooting practice
```

## Quick Reference

### Binary to Decimal Conversion
- **128**: 10000000
- **192**: 11000000
- **224**: 11100000
- **240**: 11110000
- **248**: 11111000
- **252**: 11111100
- **254**: 11111110
- **255**: 11111111

### Powers of 2
- **2^0 = 1**
- **2^1 = 2**
- **2^2 = 4**
- **2^3 = 8**
- **2^4 = 16**
- **2^5 = 32**
- **2^6 = 64**
- **2^7 = 128**
- **2^8 = 256**

### Magic Numbers
- **/25**: 128
- **/26**: 64
- **/27**: 32
- **/28**: 16
- **/29**: 8
- **/30**: 4
