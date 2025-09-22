#!/bin/bash

# Routing Protocols Lab
# Learn about different routing protocols and their configuration

echo "=========================================="
echo "ROUTING PROTOCOLS LAB"
echo "=========================================="
echo ""
echo "This lab provides hands-on practice with routing protocols"
echo "and their configuration."
echo ""

# Function to explain a routing protocol
explain_protocol() {
    local name="$1"
    local type="$2"
    local metric="$3"
    local admin_distance="$4"
    local characteristics="$5"
    local use_cases="$6"
    
    echo "PROTOCOL: $name"
    echo "=========================================="
    echo ""
    echo "Type: $type"
    echo "Metric: $metric"
    echo "Administrative Distance: $admin_distance"
    echo ""
    echo "Characteristics:"
    echo "$characteristics"
    echo ""
    echo "Use Cases:"
    echo "$use_cases"
    echo ""
    echo "Press Enter to continue..."
    read
    echo ""
    echo "=========================================="
    echo ""
}

echo "ROUTING PROTOCOLS OVERVIEW"
echo "=========================="
echo ""
echo "Routing protocols are used to automatically discover and maintain"
echo "routes in a network. They exchange routing information between"
echo "routers to build and maintain routing tables."
echo ""

# Protocol 1: Static Routing
explain_protocol \
    "Static Routing" \
    "Manual Configuration" \
    "N/A" \
    "1" \
    "- Manually configured routes
- No protocol overhead
- Predictable behavior
- No automatic failover
- Suitable for small networks" \
    "- Small networks with few routes
- Default routes
- Backup routes
- Security-sensitive networks
- Simple network topologies"

# Protocol 2: RIP
explain_protocol \
    "RIP (Routing Information Protocol)" \
    "Distance Vector" \
    "Hop Count" \
    "120" \
    "- Simple to configure
- Slow convergence
- Limited scalability
- Maximum 15 hops
- Updates every 30 seconds" \
    "- Small networks
- Learning environments
- Legacy networks
- Simple topologies
- Low bandwidth links"

# Protocol 3: OSPF
explain_protocol \
    "OSPF (Open Shortest Path First)" \
    "Link State" \
    "Cost (bandwidth-based)" \
    "110" \
    "- Fast convergence
- Hierarchical design
- Complex configuration
- Good for large networks
- Event-driven updates" \
    "- Large enterprise networks
- Complex topologies
- High availability requirements
- Multi-vendor environments
- Internet service providers"

# Protocol 4: BGP
explain_protocol \
    "BGP (Border Gateway Protocol)" \
    "Path Vector" \
    "AS Path Length" \
    "20 (external), 200 (internal)" \
    "- Internet routing protocol
- Policy-based routing
- Complex configuration
- Used between ASes
- Very scalable" \
    "- Internet service providers
- Large enterprise networks
- Multi-homed networks
- Internet connectivity
- Policy-based routing"

echo "=========================================="
echo "ROUTING PROTOCOL COMPARISON"
echo "=========================================="
echo ""

echo "Protocol Comparison Table:"
echo "========================="
echo ""
echo "Protocol    | Type         | Metric      | AD   | Convergence | Scalability"
echo "------------|--------------|-------------|------|-------------|-------------"
echo "Static      | Manual       | N/A         | 1    | N/A         | Low"
echo "RIP         | Distance     | Hop Count   | 120  | Slow        | Low"
echo "OSPF        | Link State   | Cost        | 110  | Fast        | High"
echo "BGP         | Path Vector  | AS Path     | 20   | Medium      | Very High"
echo ""

echo "Press Enter to continue..."
read
echo ""

echo "=========================================="
echo "ROUTING PROTOCOL SELECTION"
echo "=========================================="
echo ""

echo "When to use Static Routing:"
echo "--------------------------"
echo "- Small networks with few routes"
echo "- Simple topologies"
echo "- Security-sensitive environments"
echo "- Backup routes"
echo "- Default routes"
echo ""

echo "When to use RIP:"
echo "---------------"
echo "- Small networks"
echo "- Learning environments"
echo "- Legacy networks"
echo "- Simple topologies"
echo "- Low bandwidth links"
echo ""

echo "When to use OSPF:"
echo "----------------"
echo "- Large enterprise networks"
echo "- Complex topologies"
echo "- High availability requirements"
echo "- Multi-vendor environments"
echo "- Fast convergence needed"
echo ""

echo "When to use BGP:"
echo "---------------"
echo "- Internet connectivity"
echo "- Multi-homed networks"
echo "- Policy-based routing"
echo "- Large scale networks"
echo "- Service provider networks"
echo ""

echo "Press Enter to continue..."
read
echo ""

echo "=========================================="
echo "ROUTING PROTOCOL CONFIGURATION"
echo "=========================================="
echo ""

echo "Static Routing Configuration:"
echo "----------------------------"
echo ""
echo "Linux:"
echo "  # Add static route"
echo "  sudo ip route add 192.168.2.0/24 via 192.168.1.2"
echo ""
echo "  # Add default route"
echo "  sudo ip route add default via 192.168.1.1"
echo ""
echo "Cisco:"
echo "  # Add static route"
echo "  ip route 192.168.2.0 255.255.255.0 192.168.1.2"
echo ""
echo "  # Add default route"
echo "  ip route 0.0.0.0 0.0.0.0 192.168.1.1"
echo ""

echo "RIP Configuration:"
echo "-----------------"
echo ""
echo "Linux (Quagga):"
echo "  router rip"
echo "   network 192.168.1.0/24"
echo "   network 192.168.2.0/24"
echo "   version 2"
echo ""
echo "Cisco:"
echo "  router rip"
echo "   network 192.168.1.0"
echo "   network 192.168.2.0"
echo "   version 2"
echo ""

echo "OSPF Configuration:"
echo "------------------"
echo ""
echo "Linux (Quagga):"
echo "  router ospf"
echo "   network 192.168.1.0/24 area 0"
echo "   network 192.168.2.0/24 area 0"
echo "   area 0 authentication message-digest"
echo ""
echo "Cisco:"
echo "  router ospf 1"
echo "   network 192.168.1.0 0.0.0.255 area 0"
echo "   network 192.168.2.0 0.0.0.255 area 0"
echo "   area 0 authentication message-digest"
echo ""

echo "BGP Configuration:"
echo "-----------------"
echo ""
echo "Linux (Quagga):"
echo "  router bgp 65001"
echo "   neighbor 192.168.1.2 remote-as 65002"
echo "   network 192.168.1.0/24"
echo "   network 192.168.2.0/24"
echo ""
echo "Cisco:"
echo "  router bgp 65001"
echo "   neighbor 192.168.1.2 remote-as 65002"
echo "   network 192.168.1.0 mask 255.255.255.0"
echo "   network 192.168.2.0 mask 255.255.255.0"
echo ""

echo "Press Enter to continue..."
read
echo ""

echo "=========================================="
echo "ROUTING PROTOCOL TROUBLESHOOTING"
echo "=========================================="
echo ""

echo "Common Issues and Solutions:"
echo "==========================="
echo ""

echo "Issue 1: Routes not learned"
echo "--------------------------"
echo "Symptoms:"
echo "  - Routes not appearing in routing table"
echo "  - Cannot reach remote networks"
echo "  - Protocol shows no neighbors"
echo ""
echo "Solutions:"
echo "  - Check protocol configuration"
echo "  - Verify network connectivity"
echo "  - Check authentication settings"
echo "  - Verify protocol status"
echo "  - Check for configuration errors"
echo ""

echo "Issue 2: Slow convergence"
echo "------------------------"
echo "Symptoms:"
echo "  - Slow route updates after changes"
echo "  - Temporary connectivity loss"
echo "  - Inconsistent routing table"
echo ""
echo "Solutions:"
echo "  - Check protocol timers"
echo "  - Verify network connectivity"
echo "  - Check for routing loops"
echo "  - Optimize protocol settings"
echo "  - Consider faster protocols"
echo ""

echo "Issue 3: Routing loops"
echo "---------------------"
echo "Symptoms:"
echo "  - High latency"
echo "  - Traceroute shows repeated hops"
echo "  - Packet loss"
echo "  - Network performance issues"
echo ""
echo "Solutions:"
echo "  - Fix routing table configuration"
echo "  - Check protocol settings"
echo "  - Implement route filtering"
echo "  - Verify network topology"
echo "  - Check for duplicate routes"
echo ""

echo "Issue 4: Protocol authentication failures"
echo "----------------------------------------"
echo "Symptoms:"
echo "  - Protocol neighbors not forming"
echo "  - Authentication errors in logs"
echo "  - Routes not learned"
echo ""
echo "Solutions:"
echo "  - Check authentication configuration"
echo "  - Verify shared secrets"
echo "  - Check protocol version compatibility"
echo "  - Verify neighbor configuration"
echo "  - Check for typos in configuration"
echo ""

echo "Press Enter to continue..."
read
echo ""

echo "=========================================="
echo "ROUTING PROTOCOL MONITORING"
echo "=========================================="
echo ""

echo "Monitoring Commands:"
echo "==================="
echo ""

echo "Check Protocol Status:"
echo "  # Check if protocol is running"
echo "  systemctl status quagga"
echo "  systemctl status bird"
echo ""
echo "  # Check protocol processes"
echo "  ps aux | grep ospf"
echo "  ps aux | grep bgp"
echo ""

echo "Check Protocol Configuration:"
echo "  # View configuration files"
echo "  cat /etc/quagga/ospfd.conf"
echo "  cat /etc/bird/bird.conf"
echo ""
echo "  # Check configuration syntax"
echo "  ospfd -f /etc/quagga/ospfd.conf -t"
echo "  bird -c /etc/bird/bird.conf -p"
echo ""

echo "Check Protocol Logs:"
echo "  # View protocol logs"
echo "  journalctl -u quagga"
echo "  journalctl -u bird"
echo ""
echo "  # Follow logs in real-time"
echo "  journalctl -u quagga -f"
echo "  journalctl -u bird -f"
echo ""

echo "Check Protocol Neighbors:"
echo "  # Check OSPF neighbors"
echo "  vtysh -c 'show ip ospf neighbor'"
echo ""
echo "  # Check BGP neighbors"
echo "  vtysh -c 'show ip bgp neighbor'"
echo ""

echo "Press Enter to continue..."
read
echo ""

echo "=========================================="
echo "ROUTING PROTOCOL BEST PRACTICES"
echo "=========================================="
echo ""

echo "Configuration Best Practices:"
echo "============================"
echo ""
echo "1. Use consistent naming conventions"
echo "2. Document all configurations"
echo "3. Use authentication for security"
echo "4. Implement route filtering"
echo "5. Use hierarchical addressing"
echo "6. Plan for future growth"
echo "7. Test changes in lab environment"
echo "8. Monitor protocol health"
echo ""

echo "Security Best Practices:"
echo "======================="
echo ""
echo "1. Use protocol authentication"
echo "2. Implement route filtering"
echo "3. Use access control lists"
echo "4. Monitor for route hijacking"
echo "5. Keep software updated"
echo "6. Use secure management interfaces"
echo "7. Implement logging and monitoring"
echo "8. Regular security audits"
echo ""

echo "Performance Best Practices:"
echo "=========================="
echo ""
echo "1. Use appropriate protocols for network size"
echo "2. Implement route summarization"
echo "3. Use load balancing where appropriate"
echo "4. Monitor protocol performance"
echo "5. Optimize protocol timers"
echo "6. Use hierarchical design"
echo "7. Implement redundancy"
echo "8. Regular performance testing"
echo ""

echo "=========================================="
echo "PRACTICAL EXERCISES"
echo "=========================================="
echo ""

echo "Exercise 1: Protocol selection"
echo "-----------------------------"
echo "1. Analyze your network requirements"
echo "2. Select appropriate routing protocol"
echo "3. Justify your selection"
echo "4. Plan implementation strategy"
echo ""

echo "Exercise 2: Configuration practice"
echo "---------------------------------"
echo "1. Configure static routes"
echo "2. Test route functionality"
echo "3. Add route redundancy"
echo "4. Test failover scenarios"
echo ""

echo "Exercise 3: Troubleshooting practice"
echo "-----------------------------------"
echo "1. Simulate routing problems"
echo "2. Use diagnostic tools"
echo "3. Identify root causes"
echo "4. Implement solutions"
echo ""

echo "=========================================="
echo "QUICK REFERENCE"
echo "=========================================="
echo ""

echo "Protocol Selection:"
echo "  Static: Small networks, simple topologies"
echo "  RIP: Small networks, learning environments"
echo "  OSPF: Large networks, complex topologies"
echo "  BGP: Internet connectivity, policy routing"
echo ""

echo "Common Commands:"
echo "  ip route show              # View routing table"
echo "  ip route add destination via gateway  # Add route"
echo "  systemctl status quagga    # Check protocol status"
echo "  journalctl -u quagga       # View protocol logs"
echo ""

echo "Troubleshooting:"
echo "  Check protocol status"
echo "  Verify configuration"
echo "  Check network connectivity"
echo "  Monitor protocol logs"
echo "  Test route functionality"
echo ""

echo "Lab completed! You should now understand routing protocols"
echo "and how to configure and troubleshoot them."
