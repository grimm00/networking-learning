#!/bin/bash

# Routing Troubleshooting Lab
# Practice troubleshooting routing issues systematically

echo "=========================================="
echo "ROUTING TROUBLESHOOTING LAB"
echo "=========================================="
echo ""
echo "This lab teaches you to troubleshoot routing problems using"
echo "systematic approaches and diagnostic tools."
echo ""

# Function to present a troubleshooting scenario
present_scenario() {
    local title="$1"
    local problem="$2"
    local symptoms="$3"
    local diagnosis="$4"
    local solution="$5"
    local commands="$6"
    
    echo "SCENARIO: $title"
    echo "=========================================="
    echo ""
    echo "Problem: $problem"
    echo ""
    echo "Symptoms:"
    echo "$symptoms"
    echo ""
    echo "Press Enter to see the diagnosis..."
    read
    echo ""
    echo "DIAGNOSIS:"
    echo "---------"
    echo "$diagnosis"
    echo ""
    echo "Press Enter to see the solution..."
    read
    echo ""
    echo "SOLUTION:"
    echo "--------"
    echo "$solution"
    echo ""
    if [[ -n "$commands" ]]; then
        echo "Diagnostic Commands:"
        echo "$commands"
    fi
    echo ""
    echo "Press Enter to continue..."
    read
    echo ""
    echo "=========================================="
    echo ""
}

echo "ROUTING TROUBLESHOOTING METHODOLOGY"
echo "==================================="
echo ""
echo "1. Gather Information"
echo "   - What is the problem?"
echo "   - When did it start?"
echo "   - What changed recently?"
echo "   - Who is affected?"
echo ""
echo "2. Reproduce the Problem"
echo "   - Can you reproduce it?"
echo "   - Is it consistent?"
echo "   - What triggers it?"
echo ""
echo "3. Isolate the Problem"
echo "   - Use OSI model approach"
echo "   - Test layer by layer"
echo "   - Eliminate variables"
echo ""
echo "4. Test Solutions"
echo "   - One change at a time"
echo "   - Document changes"
echo "   - Verify fixes"
echo ""
echo "5. Document Results"
echo "   - What was the root cause?"
echo "   - How was it fixed?"
echo "   - How to prevent it?"
echo ""

# Scenario 1: Missing Route
present_scenario \
    "Missing Route" \
    "Cannot reach a specific network" \
    "- Cannot ping hosts on 192.168.2.0/24
- Traceroute shows unreachable destination
- Other networks are reachable
- Local network communication works" \
    "1. Check routing table for route to 192.168.2.0/24
2. Verify if route exists
3. Check if route is correct
4. Test connectivity to next hop" \
    "1. Add missing route to routing table
2. Verify route is added correctly
3. Test connectivity to destination
4. Check if route persists after reboot
5. Update routing protocol configuration if needed" \
    "# Check routing table
ip route show | grep 192.168.2.0

# Test connectivity to next hop
ping 192.168.1.2

# Add missing route
sudo ip route add 192.168.2.0/24 via 192.168.1.2

# Test connectivity to destination
ping 192.168.2.1

# Verify route is added
ip route show | grep 192.168.2.0"

# Scenario 2: Incorrect Route
present_scenario \
    "Incorrect Route" \
    "Route points to wrong next hop" \
    "- Cannot reach 192.168.3.0/24
- Traceroute shows wrong path
- Next hop is unreachable
- Other routes work correctly" \
    "1. Check routing table for route to 192.168.3.0/24
2. Verify next hop is correct
3. Test connectivity to next hop
4. Check if route is learned from protocol" \
    "1. Delete incorrect route
2. Add correct route
3. Test connectivity to destination
4. Check routing protocol configuration
5. Verify route is correct" \
    "# Check current route
ip route show | grep 192.168.3.0

# Test next hop connectivity
ping 192.168.1.3

# Delete incorrect route
sudo ip route del 192.168.3.0/24

# Add correct route
sudo ip route add 192.168.3.0/24 via 192.168.1.3

# Test connectivity
ping 192.168.3.1

# Verify route
ip route show | grep 192.168.3.0"

# Scenario 3: Default Route Issues
present_scenario \
    "Default Route Problems" \
    "Cannot access Internet or external networks" \
    "- Cannot ping 8.8.8.8
- Cannot access websites
- Local network communication works
- Traceroute shows no route" \
    "1. Check if default route exists
2. Verify default route gateway
3. Test connectivity to gateway
4. Check interface status
5. Verify routing protocol status" \
    "1. Add or fix default route
2. Verify gateway connectivity
3. Check interface configuration
4. Test Internet connectivity
5. Check routing protocol configuration" \
    "# Check default route
ip route show | grep default

# Test gateway connectivity
ping 192.168.1.1

# Add default route
sudo ip route add default via 192.168.1.1

# Test Internet connectivity
ping 8.8.8.8

# Verify default route
ip route show | grep default"

# Scenario 4: Routing Loop
present_scenario \
    "Routing Loop" \
    "Packets loop between routers" \
    "- High latency to destination
- Traceroute shows repeated hops
- Packet loss
- Network performance degradation" \
    "1. Use traceroute to identify loop
2. Check routing table for conflicting routes
3. Verify routing protocol configuration
4. Check for duplicate routes
5. Monitor network traffic" \
    "1. Fix routing table configuration
2. Remove duplicate or conflicting routes
3. Check routing protocol settings
4. Implement route filtering
5. Monitor for loop resolution" \
    "# Trace route to identify loop
traceroute 192.168.4.1

# Check for duplicate routes
ip route show | grep 192.168.4.0

# Check routing table for conflicts
ip route show

# Monitor network traffic
sudo tcpdump -i any -n | grep 192.168.4.1"

# Scenario 5: Convergence Issues
present_scenario \
    "Routing Protocol Convergence" \
    "Routes not updating after network changes" \
    "- Routes not learned from protocol
- Slow convergence after changes
- Inconsistent routing table
- Protocol errors in logs" \
    "1. Check routing protocol status
2. Verify protocol configuration
3. Check for protocol errors
4. Monitor protocol updates
5. Check network connectivity" \
    "1. Restart routing protocol
2. Fix protocol configuration
3. Check network connectivity
4. Verify protocol authentication
5. Monitor convergence time" \
    "# Check routing protocol status
systemctl status quagga
systemctl status bird

# Check protocol configuration
cat /etc/quagga/ospfd.conf
cat /etc/bird/bird.conf

# Monitor protocol updates
# (Protocol-specific commands)

# Check protocol logs
journalctl -u quagga
journalctl -u bird"

echo "=========================================="
echo "ROUTING TROUBLESHOOTING TOOLS"
echo "=========================================="
echo ""

echo "Layer 1 (Physical) Troubleshooting:"
echo "----------------------------------"
echo "  # Check interface status
  ip link show
  ifconfig
  
  # Check link status
  cat /sys/class/net/*/operstate
  
  # Check interface details
  ethtool eth0
  iwconfig"
echo ""

echo "Layer 2 (Data Link) Troubleshooting:"
echo "-----------------------------------"
echo "  # Check MAC addresses
  ip addr show
  ifconfig
  
  # Check ARP table
  arp -a
  ip neigh show
  
  # Check switch connectivity
  ping 192.168.1.1"
echo ""

echo "Layer 3 (Network) Troubleshooting:"
echo "---------------------------------"
echo "  # Check IP configuration
  ip addr show
  ifconfig
  
  # Check routing table
  ip route show
  route -n
  
  # Test connectivity
  ping 8.8.8.8
  traceroute google.com
  
  # Check specific route
  ip route get destination"
echo ""

echo "Layer 4 (Transport) Troubleshooting:"
echo "-----------------------------------"
echo "  # Check listening ports
  netstat -tuln
  ss -tuln
  
  # Test port connectivity
  telnet hostname port
  nc -zv hostname port
  
  # Check firewall rules
  iptables -L
  ufw status"
echo ""

echo "=========================================="
echo "COMMON ROUTING PROBLEMS"
echo "=========================================="
echo ""

echo "Problem 1: Missing Routes"
echo "------------------------"
echo "Symptoms:"
echo "  - Cannot reach specific networks"
echo "  - Traceroute shows unreachable destination"
echo "  - Other networks are reachable"
echo ""
echo "Solutions:"
echo "  - Add missing route to routing table"
echo "  - Check routing protocol configuration"
echo "  - Verify network connectivity"
echo ""

echo "Problem 2: Incorrect Routes"
echo "--------------------------"
echo "Symptoms:"
echo "  - Cannot reach destination"
echo "  - Traceroute shows wrong path"
echo "  - Next hop is unreachable"
echo ""
echo "Solutions:"
echo "  - Delete incorrect route"
echo "  - Add correct route"
echo "  - Check routing protocol configuration"
echo ""

echo "Problem 3: Default Route Issues"
echo "------------------------------"
echo "Symptoms:"
echo "  - Cannot access Internet"
echo "  - Cannot reach external networks"
echo "  - Local network communication works"
echo ""
echo "Solutions:"
echo "  - Add or fix default route"
echo "  - Verify gateway connectivity"
echo "  - Check interface configuration"
echo ""

echo "Problem 4: Routing Loops"
echo "-----------------------"
echo "Symptoms:"
echo "  - High latency"
echo "  - Traceroute shows repeated hops"
echo "  - Packet loss"
echo ""
echo "Solutions:"
echo "  - Fix routing table configuration"
echo "  - Remove duplicate routes"
echo "  - Check routing protocol settings"
echo ""

echo "Problem 5: Convergence Issues"
echo "----------------------------"
echo "Symptoms:"
echo "  - Routes not updating"
echo "  - Slow convergence"
echo "  - Protocol errors"
echo ""
echo "Solutions:"
echo "  - Restart routing protocol"
echo "  - Fix protocol configuration"
echo "  - Check network connectivity"
echo ""

echo "=========================================="
echo "TROUBLESHOOTING CHECKLIST"
echo "=========================================="
echo ""

echo "Before starting troubleshooting:"
echo "□ Document the problem and symptoms"
echo "□ Gather information about recent changes"
echo "□ Identify affected devices and users"
echo "□ Check if the problem is widespread"
echo ""

echo "Physical layer checks:"
echo "□ Check cable connections"
echo "□ Verify interface status"
echo "□ Check for physical damage"
echo "□ Verify power supply"
echo ""

echo "Data link layer checks:"
echo "□ Check MAC address assignment"
echo "□ Verify ARP table"
echo "□ Check for duplex mismatches"
echo "□ Verify VLAN configuration"
echo ""

echo "Network layer checks:"
echo "□ Check IP address assignment"
echo "□ Verify routing table"
echo "□ Test connectivity to gateway"
echo "□ Check DNS resolution"
echo ""

echo "Transport layer checks:"
echo "□ Check port availability"
echo "□ Verify firewall rules"
echo "□ Test TCP/UDP connectivity"
echo "□ Check for port conflicts"
echo ""

echo "Application layer checks:"
echo "□ Check service status"
echo "□ Verify application configuration"
echo "□ Check application logs"
echo "□ Test application functionality"
echo ""

echo "=========================================="
echo "PREVENTION STRATEGIES"
echo "=========================================="
echo ""

echo "To prevent common routing issues:"
echo ""
echo "1. Use routing protocols for automatic route discovery"
echo "2. Implement route redundancy and load balancing"
echo "3. Monitor routing table changes"
echo "4. Document all routing configurations"
echo "5. Use consistent addressing schemes"
echo "6. Implement route filtering and security"
echo "7. Regular network audits"
echo "8. Test changes in lab environment"
echo ""

echo "=========================================="
echo "TROUBLESHOOTING EXERCISES"
echo "=========================================="
echo ""

echo "Exercise 1: Diagnose routing issues"
echo "----------------------------------"
echo "1. Check your current routing table"
echo "2. Test connectivity to different destinations"
echo "3. Identify any routing problems"
echo "4. Propose solutions"
echo ""

echo "Exercise 2: Simulate common problems"
echo "-----------------------------------"
echo "1. Temporarily remove a route"
echo "2. Test connectivity and identify the issue"
echo "3. Fix the problem"
echo "4. Document the solution"
echo ""

echo "Exercise 3: Practice with tools"
echo "------------------------------"
echo "1. Use ping to test connectivity"
echo "2. Use traceroute to identify routing issues"
echo "3. Use ip route to manage routes"
echo "4. Use netstat to check network status"
echo ""

echo "Lab completed! You should now understand how to troubleshoot"
echo "common routing problems systematically."
