#!/bin/bash

# OSI Layer Troubleshooting Lab
# Practice systematic troubleshooting using the OSI model

echo "=========================================="
echo "OSI LAYER TROUBLESHOOTING LAB"
echo "=========================================="
echo ""
echo "This lab teaches you to troubleshoot network problems systematically"
echo "using the OSI model - starting from Layer 1 and working up."
echo ""

# Function to test a specific layer
test_layer() {
    local layer_num="$1"
    local layer_name="$2"
    local test_command="$3"
    local description="$4"
    
    echo "Testing Layer $layer_num: $layer_name"
    echo "Description: $description"
    echo "Command: $test_command"
    echo ""
    
    # Run the test
    echo "Result:"
    if eval "$test_command" 2>/dev/null; then
        echo "✅ Layer $layer_num ($layer_name): PASS"
    else
        echo "❌ Layer $layer_num ($layer_name): FAIL"
    fi
    echo ""
    echo "---"
    echo ""
}

echo "SYSTEMATIC TROUBLESHOOTING APPROACH"
echo "==================================="
echo ""
echo "The OSI model provides a systematic approach to troubleshooting:"
echo "1. Start from Layer 1 (Physical) and work up"
echo "2. Test each layer before moving to the next"
echo "3. Fix problems at lower layers first"
echo "4. Use appropriate diagnostic tools for each layer"
echo ""

# Layer 1 (Physical) Tests
echo "LAYER 1 (Physical) Troubleshooting"
echo "=================================="
echo ""

test_layer "1" "Physical Interface" "ifconfig | grep -E 'UP|DOWN'" "Check if network interfaces are up"
test_layer "1" "Cable Connection" "ethtool eth0 2>/dev/null || echo 'Interface not found'" "Check physical cable connection"
test_layer "1" "Link Status" "cat /sys/class/net/*/operstate 2>/dev/null | grep -v unknown" "Check physical link status"

echo ""

# Layer 2 (Data Link) Tests
echo "LAYER 2 (Data Link) Troubleshooting"
echo "==================================="
echo ""

test_layer "2" "MAC Addresses" "ifconfig | grep -E 'HWaddr|ether'" "Check MAC address assignment"
test_layer "2" "ARP Table" "arp -a | head -3" "Check ARP table for local network"
test_layer "2" "Switch Connectivity" "ping -c 1 \$(ip route | grep default | awk '{print \$3}')" "Test connectivity to default gateway"

echo ""

# Layer 3 (Network) Tests
echo "LAYER 3 (Network) Troubleshooting"
echo "================================="
echo ""

test_layer "3" "IP Configuration" "ip addr show | grep inet" "Check IP address assignment"
test_layer "3" "Routing Table" "ip route show | head -5" "Check routing table"
test_layer "3" "Network Connectivity" "ping -c 2 8.8.8.8" "Test Internet connectivity"
test_layer "3" "DNS Resolution" "nslookup google.com" "Test DNS name resolution"

echo ""

# Layer 4 (Transport) Tests
echo "LAYER 4 (Transport) Troubleshooting"
echo "==================================="
echo ""

test_layer "4" "Port Availability" "netstat -tuln | grep :80" "Check if port 80 is listening"
test_layer "4" "TCP Connections" "netstat -an | grep ESTABLISHED | head -3" "Check active TCP connections"
test_layer "4" "Firewall Rules" "iptables -L 2>/dev/null || echo 'No iptables rules'" "Check firewall configuration"

echo ""

# Layer 5 (Session) Tests
echo "LAYER 5 (Session) Troubleshooting"
echo "================================="
echo ""

test_layer "5" "Session Management" "netstat -an | grep ESTABLISHED | wc -l" "Count active sessions"
test_layer "5" "Session Timeouts" "ss -tuln | head -5" "Check session states"

echo ""

# Layer 6 (Presentation) Tests
echo "LAYER 6 (Presentation) Troubleshooting"
echo "======================================"
echo ""

test_layer "6" "SSL/TLS Support" "openssl version" "Check SSL/TLS support"
test_layer "6" "Certificate Validation" "openssl s_client -connect google.com:443 -servername google.com -quiet 2>/dev/null" "Test SSL certificate validation"

echo ""

# Layer 7 (Application) Tests
echo "LAYER 7 (Application) Troubleshooting"
echo "===================================="
echo ""

test_layer "7" "HTTP Service" "curl -I http://httpbin.org/get 2>/dev/null" "Test HTTP connectivity"
test_layer "7" "Service Status" "systemctl is-active networking 2>/dev/null || echo 'Service not found'" "Check network service status"

echo ""

echo "=========================================="
echo "TROUBLESHOOTING SCENARIOS"
echo "=========================================="
echo ""

echo "SCENARIO 1: Cannot access a website"
echo "-----------------------------------"
echo "1. Layer 1: Check if network cable is connected"
echo "2. Layer 2: Check if you can ping the gateway"
echo "3. Layer 3: Check if you can ping 8.8.8.8"
echo "4. Layer 4: Check if port 80/443 is accessible"
echo "5. Layer 7: Check if the web service is running"
echo ""

echo "SCENARIO 2: Slow network performance"
echo "-----------------------------------"
echo "1. Layer 1: Check cable quality and interface speed"
echo "2. Layer 2: Check for duplex mismatches"
echo "3. Layer 3: Check routing table and path"
echo "4. Layer 4: Check for connection limits"
echo "5. Layer 7: Check application performance"
echo ""

echo "SCENARIO 3: Intermittent connectivity"
echo "------------------------------------"
echo "1. Layer 1: Check for loose cables or interference"
echo "2. Layer 2: Check for MAC address conflicts"
echo "3. Layer 3: Check for IP address conflicts"
echo "4. Layer 4: Check for port conflicts"
echo "5. Layer 7: Check for application issues"
echo ""

echo "=========================================="
echo "DIAGNOSTIC COMMANDS BY LAYER"
echo "=========================================="
echo ""

echo "Layer 1 (Physical):"
echo "  ifconfig, ip link show, ethtool, iwconfig"
echo ""

echo "Layer 2 (Data Link):"
echo "  arp -a, ifconfig, ip neigh show, bridge show"
echo ""

echo "Layer 3 (Network):"
echo "  ping, traceroute, ip route show, nslookup, dig"
echo ""

echo "Layer 4 (Transport):"
echo "  netstat, ss, telnet, nc, iptables"
echo ""

echo "Layer 5 (Session):"
echo "  netstat -an, ss -tuln, lsof"
echo ""

echo "Layer 6 (Presentation):"
echo "  openssl s_client, file -bi, curl -I"
echo ""

echo "Layer 7 (Application):"
echo "  curl, wget, telnet, ssh, systemctl status"
echo ""

echo "=========================================="
echo "PRACTICAL EXERCISES"
echo "=========================================="
echo ""

echo "Exercise 1: Simulate a Layer 1 problem"
echo "1. Disconnect your network cable"
echo "2. Run: ifconfig"
echo "3. Notice the interface status"
echo "4. Reconnect the cable"
echo "5. Run: ifconfig again"
echo ""

echo "Exercise 2: Simulate a Layer 3 problem"
echo "1. Change your DNS server to an invalid one"
echo "2. Run: nslookup google.com"
echo "3. Notice the DNS resolution failure"
echo "4. Restore your DNS settings"
echo ""

echo "Exercise 3: Simulate a Layer 4 problem"
echo "1. Block a port with iptables: sudo iptables -A INPUT -p tcp --dport 80 -j DROP"
echo "2. Try: curl http://httpbin.org/get"
echo "3. Notice the connection failure"
echo "4. Remove the rule: sudo iptables -D INPUT -p tcp --dport 80 -j DROP"
echo ""

echo "Exercise 4: Use packet capture for analysis"
echo "1. Start packet capture: sudo tcpdump -i any -n -c 10"
echo "2. In another terminal, run: ping google.com"
echo "3. Analyze the captured packets"
echo "4. Identify which layers are involved"
echo ""

echo "=========================================="
echo "TROUBLESHOOTING CHECKLIST"
echo "=========================================="
echo ""

echo "Before starting troubleshooting:"
echo "□ Document the problem and symptoms"
echo "□ Gather information about the network topology"
echo "□ Check if the problem affects multiple users"
echo "□ Determine if the problem is intermittent or constant"
echo ""

echo "Layer 1 (Physical) checklist:"
echo "□ Check cable connections"
echo "□ Verify interface status (up/down)"
echo "□ Check for physical damage"
echo "□ Verify power supply"
echo ""

echo "Layer 2 (Data Link) checklist:"
echo "□ Check MAC address assignment"
echo "□ Verify ARP table"
echo "□ Check for duplex mismatches"
echo "□ Verify VLAN configuration"
echo ""

echo "Layer 3 (Network) checklist:"
echo "□ Check IP address assignment"
echo "□ Verify routing table"
echo "□ Test connectivity to gateway"
echo "□ Check DNS resolution"
echo ""

echo "Layer 4 (Transport) checklist:"
echo "□ Check port availability"
echo "□ Verify firewall rules"
echo "□ Test TCP/UDP connectivity"
echo "□ Check for port conflicts"
echo ""

echo "Layer 5 (Session) checklist:"
echo "□ Check session establishment"
echo "□ Verify session timeouts"
echo "□ Check for session limits"
echo "□ Monitor session activity"
echo ""

echo "Layer 6 (Presentation) checklist:"
echo "□ Check SSL/TLS configuration"
echo "□ Verify certificate validity"
echo "□ Check data format compatibility"
echo "□ Verify encryption settings"
echo ""

echo "Layer 7 (Application) checklist:"
echo "□ Check application status"
echo "□ Verify service configuration"
echo "□ Check application logs"
echo "□ Test application functionality"
echo ""

echo "Lab completed! You should now understand how to use the OSI model"
echo "for systematic network troubleshooting."
