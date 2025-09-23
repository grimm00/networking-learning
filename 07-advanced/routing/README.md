# Routing Fundamentals

Learn about network routing, routing protocols, and advanced routing concepts.

## What You'll Learn

- Static vs dynamic routing
- Routing tables and their components
- Routing protocols (RIP, OSPF, BGP)
- Route selection and metrics
- Troubleshooting routing issues
- Advanced routing concepts

## Understanding Routing

### What is Routing?
Routing is the process of determining the best path for data packets to travel from source to destination across multiple networks.

### Key Concepts
- **Routing Table**: Database of routes to different networks
- **Next Hop**: The next router in the path to destination
- **Metric**: Cost or preference value for a route
- **Administrative Distance**: Trustworthiness of a route source
- **Convergence**: Time for all routers to agree on network topology

## Types of Routing

### Static Routing
**Definition**: Manually configured routes that don't change automatically

**Characteristics**:
- Manual configuration required
- No protocol overhead
- Predictable behavior
- Suitable for small networks
- No automatic failover

**Configuration Examples**:
```bash
# Linux - Add static route
sudo ip route add 192.168.2.0/24 via 192.168.1.1

# Linux - Add default route
sudo ip route add default via 192.168.1.1

# Cisco - Add static route
ip route 192.168.2.0 255.255.255.0 192.168.1.1

# Cisco - Add default route
ip route 0.0.0.0 0.0.0.0 192.168.1.1
```

### Dynamic Routing
**Definition**: Routes learned automatically through routing protocols

**Characteristics**:
- Automatic route discovery
- Protocol overhead
- Adapts to network changes
- Suitable for large networks
- Automatic failover

**Types**:
- **Interior Gateway Protocols (IGP)**: RIP, OSPF, EIGRP
- **Exterior Gateway Protocols (EGP)**: BGP

## Routing Tables

### Components of a Routing Table
- **Destination**: Network or host address
- **Next Hop**: IP address of next router
- **Interface**: Outgoing interface
- **Metric**: Cost to reach destination
- **Administrative Distance**: Trustworthiness of route source

### Viewing Routing Tables
```bash
# Linux - Modern command
ip route show

# Linux - Legacy command
route -n

# Windows
route print

# Cisco
show ip route
```

### Example Routing Table
```
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         192.168.1.1     0.0.0.0         UG    0      0        0 eth0
192.168.1.0     0.0.0.0         255.255.255.0   U     0      0        0 eth0
192.168.2.0     192.168.1.2     255.255.255.0   UG    0      0        0 eth0
10.0.0.0        192.168.1.1     255.0.0.0       UG    0      0        0 eth0
```

## Routing Protocols

### RIP (Routing Information Protocol)
**Type**: Distance Vector
**Metric**: Hop count
**Administrative Distance**: 120
**Update Interval**: 30 seconds
**Maximum Hops**: 15

**Characteristics**:
- Simple to configure
- Slow convergence
- Limited scalability
- Good for small networks

**Configuration Example**:
```bash
# Linux - Quagga/BIRD
router rip
 network 192.168.1.0/24
 network 192.168.2.0/24
```

### OSPF (Open Shortest Path First)
**Type**: Link State
**Metric**: Cost (bandwidth-based)
**Administrative Distance**: 110
**Update**: Event-driven
**Scalability**: High

**Characteristics**:
- Fast convergence
- Hierarchical design
- Complex configuration
- Good for large networks

**Configuration Example**:
```bash
# Linux - Quagga/BIRD
router ospf
 network 192.168.1.0/24 area 0
 network 192.168.2.0/24 area 0
```

### BGP (Border Gateway Protocol)
**Type**: Path Vector
**Metric**: AS path length
**Administrative Distance**: 20 (external), 200 (internal)
**Update**: Event-driven
**Scalability**: Very high

**Characteristics**:
- Internet routing protocol
- Policy-based routing
- Complex configuration
- Used between ASes

## Route Selection Process

### Selection Criteria
1. **Administrative Distance**: Lower is preferred
2. **Metric**: Lower is preferred
3. **Longest Match**: More specific routes preferred
4. **Load Balancing**: Multiple equal-cost routes

### Administrative Distance Values
| Protocol | Administrative Distance |
|----------|------------------------|
| Direct | 0 |
| Static | 1 |
| EIGRP | 90 |
| OSPF | 110 |
| RIP | 120 |
| External BGP | 20 |
| Internal BGP | 200 |

## Troubleshooting Routing

### Common Issues
1. **Missing Routes**: Routes not in routing table
2. **Wrong Routes**: Incorrect next hop or metric
3. **Routing Loops**: Packets loop between routers
4. **Convergence Issues**: Slow or failed convergence
5. **Policy Issues**: Routes not advertised or accepted

### Diagnostic Commands
```bash
# Check routing table
ip route show
route -n

# Test connectivity
ping destination
traceroute destination

# Check routing protocol status
# (Protocol-specific commands)

# Monitor routing updates
# (Protocol-specific commands)
```

### Troubleshooting Steps
1. **Check routing table**: Is the route present?
2. **Test connectivity**: Can you reach the next hop?
3. **Check routing protocol**: Is the protocol running?
4. **Verify configuration**: Are routes configured correctly?
5. **Check logs**: Are there any error messages?

## Advanced Routing Concepts

### Route Aggregation
**Definition**: Combining multiple routes into a single route

**Benefits**:
- Reduces routing table size
- Improves convergence time
- Reduces memory usage

**Example**:
```
Routes: 192.168.1.0/24, 192.168.2.0/24, 192.168.3.0/24, 192.168.4.0/24
Aggregated: 192.168.0.0/22
```

### Route Redistribution
**Definition**: Sharing routes between different routing protocols

**Considerations**:
- Administrative distance
- Metric conversion
- Loop prevention
- Policy configuration

### Load Balancing
**Definition**: Distributing traffic across multiple paths

**Types**:
- **Per-packet**: Alternate packets between paths
- **Per-destination**: All packets to same destination use same path
- **Per-flow**: All packets in same flow use same path

### Route Filtering
**Definition**: Controlling which routes are advertised or accepted

**Methods**:
- **Access Lists**: Filter based on network addresses
- **Prefix Lists**: Filter based on network prefixes
- **Route Maps**: Complex filtering and modification

## Practical Examples

### Basic Static Routing
```bash
# Add route to specific network
sudo ip route add 192.168.2.0/24 via 192.168.1.2

# Add default route
sudo ip route add default via 192.168.1.1

# Delete route
sudo ip route del 192.168.2.0/24
```

### Route Monitoring
```bash
# Monitor routing table changes
watch -n 1 'ip route show'

# Check specific route
ip route get 192.168.2.1

# Show route statistics
ip -s route show
```

### Troubleshooting Examples
```bash
# Test connectivity to next hop
ping 192.168.1.2

# Trace route to destination
traceroute 192.168.2.1

# Check if route is in table
ip route show | grep 192.168.2.0
```

## Lab Exercises

Run the included scripts for hands-on practice:

```bash
./routing-basics.sh          # Basic routing concepts
./routing-troubleshooting.sh # Troubleshooting practice
./routing-protocols.sh       # Protocol configuration
```

## Quick Reference

### Essential Commands
```bash
# View routing table
ip route show
route -n

# Add/delete routes
ip route add/del destination via gateway
route add/del destination gateway

# Test connectivity
ping destination
traceroute destination

# Monitor routes
watch ip route show
```

### Common Troubleshooting
```bash
# Check if route exists
ip route get destination

# Test next hop
ping next_hop_ip

# Check interface status
ip link show

# Monitor routing updates
# (Protocol-specific)
```

## Best Practices

### Design Principles
1. **Hierarchical Design**: Use area-based routing
2. **Route Summarization**: Aggregate routes where possible
3. **Redundancy**: Provide multiple paths
4. **Security**: Implement route filtering
5. **Monitoring**: Monitor routing health

### Configuration Guidelines
1. **Consistent Naming**: Use consistent naming conventions
2. **Documentation**: Document all configurations
3. **Testing**: Test changes in lab environment
4. **Backup**: Backup configurations before changes
5. **Monitoring**: Monitor routing performance

### Security Considerations
1. **Route Filtering**: Filter unwanted routes
2. **Authentication**: Use protocol authentication
3. **Access Control**: Restrict configuration access
4. **Monitoring**: Monitor for route hijacking
5. **Updates**: Keep software updated
