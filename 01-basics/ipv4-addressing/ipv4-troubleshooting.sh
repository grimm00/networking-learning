#!/bin/bash

# IPv4 Troubleshooting Lab
# Practice troubleshooting IP addressing and subnetting issues

echo "=========================================="
echo "IPv4 TROUBLESHOOTING LAB"
echo "=========================================="
echo ""
echo "This lab teaches you to troubleshoot common IPv4 addressing"
echo "and subnetting problems using systematic approaches."
echo ""

# Function to test a troubleshooting scenario
test_scenario() {
    local title="$1"
    local problem="$2"
    local symptoms="$3"
    local solution="$4"
    local commands="$5"
    
    echo "SCENARIO: $title"
    echo "=========================================="
    echo ""
    echo "Problem: $problem"
    echo ""
    echo "Symptoms:"
    echo "$symptoms"
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

echo "TROUBLESHOOTING METHODOLOGY"
echo "==========================="
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

# Scenario 1: IP Conflict
test_scenario \
    "IP Address Conflict" \
    "Two devices have the same IP address" \
    "- Intermittent connectivity issues
- Devices cannot communicate
- ARP table shows multiple MAC addresses for same IP
- Network performance degradation
- Error messages about duplicate IP addresses" \
    "1. Identify the conflicting devices
2. Change one of the IP addresses
3. Update DHCP server if applicable
4. Clear ARP cache
5. Verify connectivity" \
    "# Check for IP conflicts
arp -a | grep '192.168.1.100'

# Check ARP table
ip neigh show

# Clear ARP cache
sudo ip neigh flush all

# Check DHCP leases
cat /var/lib/dhcp/dhcpd.leases

# Test connectivity
ping 192.168.1.100"

# Scenario 2: Wrong Subnet Mask
test_scenario \
    "Incorrect Subnet Mask" \
    "Device has wrong subnet mask configuration" \
    "- Cannot communicate with devices on same network
- Can communicate with some devices but not others
- Routing issues
- Inconsistent connectivity
- Devices appear to be on different networks" \
    "1. Verify correct subnet mask for the network
2. Update device configuration
3. Test connectivity to all devices
4. Update documentation
5. Verify routing table" \
    "# Check current configuration
ip addr show
ifconfig

# Check routing table
ip route show
route -n

# Test connectivity
ping 192.168.1.1
ping 192.168.1.100

# Check network configuration
ipcalc 192.168.1.0/24"

# Scenario 3: Gateway Issues
test_scenario \
    "Default Gateway Problems" \
    "Device cannot reach devices on other networks" \
    "- Cannot access Internet
- Cannot reach devices on other subnets
- Local network communication works
- DNS resolution may fail
- Traceroute shows first hop fails" \
    "1. Verify gateway IP address
2. Check gateway connectivity
3. Verify routing table
4. Test gateway response
5. Check firewall rules" \
    "# Check gateway configuration
ip route show | grep default

# Test gateway connectivity
ping 192.168.1.1

# Check routing table
ip route show

# Test Internet connectivity
ping 8.8.8.8

# Check DNS resolution
nslookup google.com"

# Scenario 4: DHCP Issues
test_scenario \
    "DHCP Configuration Problems" \
    "Device cannot obtain IP address automatically" \
    "- Device shows 169.254.x.x address
- No IP address assigned
- Cannot connect to network
- DHCP client errors
- Network unreachable" \
    "1. Check DHCP server status
2. Verify DHCP scope configuration
3. Check network connectivity to DHCP server
4. Restart DHCP client
5. Check DHCP server logs" \
    "# Check current IP configuration
ip addr show

# Check DHCP client status
systemctl status dhcpcd
systemctl status NetworkManager

# Restart DHCP client
sudo systemctl restart dhcpcd

# Check DHCP server
nmap -sU -p 67 192.168.1.1

# Check network connectivity
ping 192.168.1.1"

# Scenario 5: DNS Resolution Issues
test_scenario \
    "DNS Resolution Problems" \
    "Device cannot resolve hostnames to IP addresses" \
    "- Cannot access websites by name
- IP addresses work but hostnames don't
- DNS timeout errors
- Slow network performance
- Some sites work, others don't" \
    "1. Check DNS server configuration
2. Test DNS server connectivity
3. Verify DNS server response
4. Check DNS cache
5. Try alternative DNS servers" \
    "# Check DNS configuration
cat /etc/resolv.conf

# Test DNS resolution
nslookup google.com
dig google.com

# Test DNS server connectivity
ping 8.8.8.8
ping 1.1.1.1

# Check DNS cache
sudo systemctl flush-dns

# Try alternative DNS
echo 'nameserver 8.8.8.8' | sudo tee /etc/resolv.conf"

# Scenario 6: Subnet Design Issues
test_scenario \
    "Subnet Design Problems" \
    "Network was designed with insufficient address space" \
    "- Cannot add new devices
- IP address exhaustion
- Devices cannot get IP addresses
- Network performance issues
- Frequent IP conflicts" \
    "1. Analyze current address usage
2. Calculate required address space
3. Redesign subnet layout
4. Plan migration strategy
5. Implement new addressing scheme" \
    "# Analyze current network
ip addr show
ip route show

# Calculate address space
python3 ipv4-calculator.py 192.168.1.0/24

# Check address usage
nmap -sn 192.168.1.0/24

# Plan new addressing
python3 ipv4-calculator.py 192.168.0.0/16 --subnets 8"

echo "=========================================="
echo "TROUBLESHOOTING TOOLS AND COMMANDS"
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
  
  # Check DNS resolution
  nslookup google.com
  dig google.com"
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
echo "COMMON TROUBLESHOOTING SCENARIOS"
echo "=========================================="
echo ""

echo "Scenario 1: New device cannot connect"
echo "------------------------------------"
echo "1. Check physical connection"
echo "2. Verify IP configuration"
echo "3. Test connectivity to gateway"
echo "4. Check DNS resolution"
echo "5. Verify firewall rules"
echo ""

echo "Scenario 2: Intermittent connectivity"
echo "------------------------------------"
echo "1. Check for IP conflicts"
echo "2. Verify cable connections"
echo "3. Check for duplex mismatches"
echo "4. Monitor network traffic"
echo "5. Check for interference"
echo ""

echo "Scenario 3: Slow network performance"
echo "-----------------------------------"
echo "1. Check for broadcast storms"
echo "2. Verify subnet design"
echo "3. Check for routing loops"
echo "4. Monitor bandwidth usage"
echo "5. Check for network congestion"
echo ""

echo "Scenario 4: Cannot access specific services"
echo "------------------------------------------"
echo "1. Check port connectivity"
echo "2. Verify firewall rules"
echo "3. Check service status"
echo "4. Test from different devices"
echo "5. Check routing configuration"
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

echo "To prevent common IP addressing issues:"
echo ""
echo "1. Use DHCP for automatic IP assignment"
echo "2. Implement IP address management (IPAM)"
echo "3. Document all network configurations"
echo "4. Use consistent naming conventions"
echo "5. Implement network monitoring"
echo "6. Regular network audits"
echo "7. Proper subnet design"
echo "8. Security best practices"
echo ""

echo "=========================================="
echo "TROUBLESHOOTING EXERCISES"
echo "=========================================="
echo ""

echo "Exercise 1: Diagnose connectivity issues"
echo "---------------------------------------"
echo "1. Check your current network configuration"
echo "2. Test connectivity to different destinations"
echo "3. Identify any issues"
echo "4. Propose solutions"
echo ""

echo "Exercise 2: Simulate common problems"
echo "-----------------------------------"
echo "1. Change your DNS server to an invalid one"
echo "2. Test connectivity and identify the issue"
echo "3. Fix the problem"
echo "4. Document the solution"
echo ""

echo "Exercise 3: Practice with tools"
echo "------------------------------"
echo "1. Use ping to test connectivity"
echo "2. Use traceroute to identify routing issues"
echo "3. Use nslookup to test DNS resolution"
echo "4. Use netstat to check port status"
echo ""

echo "Lab completed! You should now understand how to troubleshoot"
echo "common IPv4 addressing and subnetting problems systematically."
