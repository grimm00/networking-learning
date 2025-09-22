#!/bin/bash

# Routing Basics Lab
# Hands-on exercises for understanding routing concepts

echo "=========================================="
echo "ROUTING BASICS LAB"
echo "=========================================="
echo ""
echo "This lab provides hands-on practice with routing concepts and commands."
echo ""

# Function to demonstrate a routing concept
demonstrate_concept() {
    local title="$1"
    local description="$2"
    local commands="$3"
    local explanation="$4"
    
    echo "CONCEPT: $title"
    echo "=========================================="
    echo ""
    echo "Description: $description"
    echo ""
    echo "Commands to run:"
    echo "$commands"
    echo ""
    echo "Press Enter to run these commands..."
    read
    echo ""
    echo "Output:"
    echo "-------"
    eval "$commands"
    echo ""
    echo "Explanation:"
    echo "$explanation"
    echo ""
    echo "Press Enter to continue..."
    read
    echo ""
    echo "=========================================="
    echo ""
}

echo "ROUTING FUNDAMENTALS"
echo "===================="
echo ""
echo "Routing is the process of determining the best path for data packets"
echo "to travel from source to destination across multiple networks."
echo ""

# Concept 1: Viewing routing table
demonstrate_concept \
    "Viewing Routing Table" \
    "The routing table contains information about how to reach different networks." \
    "ip route show" \
    "This shows all routes in the routing table. Each line represents a route with destination, gateway, and interface information."

# Concept 2: Understanding route components
demonstrate_concept \
    "Route Components" \
    "Let's examine the components of a routing table entry." \
    "ip route show | head -5" \
    "Each route entry contains: Destination network, Gateway (next hop), Interface, and other flags."

# Concept 3: Default route
demonstrate_concept \
    "Default Route" \
    "The default route (0.0.0.0/0) is used when no specific route matches." \
    "ip route show | grep default" \
    "The default route is the 'catch-all' route used for destinations not in the routing table."

# Concept 4: Local routes
demonstrate_concept \
    "Local Routes" \
    "Local routes are for directly connected networks." \
    "ip route show | grep -E '^[0-9]'" \
    "These routes show networks that are directly connected to this host."

# Concept 5: Route metrics
demonstrate_concept \
    "Route Metrics" \
    "Routes have metrics that indicate their cost or preference." \
    "ip route show | grep -v '^default'" \
    "Metrics help the routing system choose the best path when multiple routes exist."

echo "=========================================="
echo "ROUTING COMMANDS PRACTICE"
echo "=========================================="
echo ""

echo "Exercise 1: Basic routing table analysis"
echo "---------------------------------------"
echo "1. View your current routing table"
echo "2. Identify the default route"
echo "3. Identify local routes"
echo "4. Count the total number of routes"
echo ""

echo "Commands to practice:"
echo "  ip route show"
echo "  ip route show | grep default"
echo "  ip route show | grep -E '^[0-9]'"
echo "  ip route show | wc -l"
echo ""

echo "Press Enter to run these commands..."
read
echo ""

echo "Current routing table:"
ip route show
echo ""

echo "Default route:"
ip route show | grep default
echo ""

echo "Local routes:"
ip route show | grep -E '^[0-9]'
echo ""

echo "Total routes:"
ip route show | wc -l
echo ""

echo "Press Enter to continue..."
read
echo ""

echo "Exercise 2: Route testing"
echo "------------------------"
echo "1. Test connectivity to different destinations"
echo "2. Trace the path packets take"
echo "3. Check if routes are working"
echo ""

echo "Commands to practice:"
echo "  ping 8.8.8.8"
echo "  traceroute 8.8.8.8"
echo "  ip route get 8.8.8.8"
echo ""

echo "Press Enter to run these commands..."
read
echo ""

echo "Testing connectivity to 8.8.8.8:"
ping -c 3 8.8.8.8
echo ""

echo "Tracing route to 8.8.8.8:"
traceroute -m 5 8.8.8.8
echo ""

echo "Route used for 8.8.8.8:"
ip route get 8.8.8.8
echo ""

echo "Press Enter to continue..."
read
echo ""

echo "Exercise 3: Route manipulation (simulation)"
echo "------------------------------------------"
echo "Note: We'll simulate route changes without actually modifying your routing table."
echo ""

echo "Current routing table:"
ip route show
echo ""

echo "Simulated route addition:"
echo "  sudo ip route add 192.168.100.0/24 via 192.168.1.1"
echo "  (This would add a route to 192.168.100.0/24 via 192.168.1.1)"
echo ""

echo "Simulated route deletion:"
echo "  sudo ip route del 192.168.100.0/24"
echo "  (This would delete the route to 192.168.100.0/24)"
echo ""

echo "Press Enter to continue..."
read
echo ""

echo "=========================================="
echo "ROUTING TROUBLESHOOTING"
echo "=========================================="
echo ""

echo "Common routing issues and solutions:"
echo ""

echo "Issue 1: Cannot reach specific network"
echo "-------------------------------------"
echo "Symptoms:"
echo "  - Can ping some hosts but not others"
echo "  - Traceroute shows unreachable destination"
echo ""
echo "Diagnosis:"
echo "  1. Check if route exists: ip route show | grep destination"
echo "  2. Test connectivity to next hop: ping next_hop_ip"
echo "  3. Check if destination is reachable: ping destination"
echo ""
echo "Solutions:"
echo "  - Add missing route: sudo ip route add destination via gateway"
echo "  - Fix incorrect route: sudo ip route del destination; sudo ip route add destination via correct_gateway"
echo "  - Check routing protocol configuration"
echo ""

echo "Issue 2: Default route problems"
echo "------------------------------"
echo "Symptoms:"
echo "  - Cannot access Internet"
echo "  - Cannot reach external networks"
echo "  - Local network communication works"
echo ""
echo "Diagnosis:"
echo "  1. Check default route: ip route show | grep default"
echo "  2. Test gateway connectivity: ping gateway_ip"
echo "  3. Check interface status: ip link show"
echo ""
echo "Solutions:"
echo "  - Add default route: sudo ip route add default via gateway_ip"
echo "  - Fix gateway connectivity"
echo "  - Check interface configuration"
echo ""

echo "Issue 3: Routing loops"
echo "---------------------"
echo "Symptoms:"
echo "  - Traceroute shows repeated hops"
echo "  - High latency"
echo "  - Packet loss"
echo ""
echo "Diagnosis:"
echo "  1. Use traceroute to identify loop"
echo "  2. Check routing table for conflicting routes"
echo "  3. Monitor network traffic"
echo ""
echo "Solutions:"
echo "  - Fix routing table configuration"
echo "  - Check routing protocol settings"
echo "  - Implement route filtering"
echo ""

echo "Press Enter to continue..."
read
echo ""

echo "=========================================="
echo "ROUTING PROTOCOLS OVERVIEW"
echo "=========================================="
echo ""

echo "Static Routing:"
echo "  - Manually configured routes"
echo "  - No protocol overhead"
echo "  - Suitable for small networks"
echo "  - No automatic failover"
echo ""

echo "Dynamic Routing:"
echo "  - Routes learned automatically"
echo "  - Protocol overhead"
echo "  - Adapts to network changes"
echo "  - Suitable for large networks"
echo ""

echo "Common Routing Protocols:"
echo "  - RIP (Routing Information Protocol)"
echo "  - OSPF (Open Shortest Path First)"
echo "  - BGP (Border Gateway Protocol)"
echo ""

echo "Press Enter to continue..."
read
echo ""

echo "=========================================="
echo "PRACTICAL EXERCISES"
echo "=========================================="
echo ""

echo "Exercise 4: Route analysis"
echo "-------------------------"
echo "1. Analyze your routing table"
echo "2. Identify route types"
echo "3. Check route metrics"
echo "4. Test route functionality"
echo ""

echo "Commands to practice:"
echo "  ip route show"
echo "  ip route show | grep -E '^[0-9]' | head -5"
echo "  ip route show | grep default"
echo "  ping -c 1 \$(ip route | grep default | awk '{print \$3}')"
echo ""

echo "Press Enter to run these commands..."
read
echo ""

echo "Route analysis:"
echo "==============="
echo ""

echo "All routes:"
ip route show
echo ""

echo "Local routes (first 5):"
ip route show | grep -E '^[0-9]' | head -5
echo ""

echo "Default route:"
ip route show | grep default
echo ""

echo "Testing default gateway:"
ping -c 1 $(ip route | grep default | awk '{print $3}')
echo ""

echo "Press Enter to continue..."
read
echo ""

echo "Exercise 5: Route testing"
echo "------------------------"
echo "1. Test connectivity to different destinations"
echo "2. Compare routes to different destinations"
echo "3. Analyze routing paths"
echo ""

echo "Commands to practice:"
echo "  ping -c 1 8.8.8.8"
echo "  ping -c 1 1.1.1.1"
echo "  traceroute -m 3 8.8.8.8"
echo "  traceroute -m 3 1.1.1.1"
echo ""

echo "Press Enter to run these commands..."
read
echo ""

echo "Testing connectivity to 8.8.8.8:"
ping -c 1 8.8.8.8
echo ""

echo "Testing connectivity to 1.1.1.1:"
ping -c 1 1.1.1.1
echo ""

echo "Tracing route to 8.8.8.8:"
traceroute -m 3 8.8.8.8
echo ""

echo "Tracing route to 1.1.1.1:"
traceroute -m 3 1.1.1.1
echo ""

echo "Press Enter to continue..."
read
echo ""

echo "=========================================="
echo "ROUTING BEST PRACTICES"
echo "=========================================="
echo ""

echo "1. Document all routes"
echo "   - Keep track of all static routes"
echo "   - Document routing protocol configurations"
echo "   - Maintain network topology diagrams"
echo ""

echo "2. Use consistent naming"
echo "   - Use descriptive names for interfaces"
echo "   - Use consistent addressing schemes"
echo "   - Follow organizational standards"
echo ""

echo "3. Implement redundancy"
echo "   - Provide multiple paths to destinations"
echo "   - Use load balancing where appropriate"
echo "   - Plan for failover scenarios"
echo ""

echo "4. Monitor routing health"
echo "   - Monitor routing table changes"
echo "   - Check routing protocol status"
echo "   - Monitor network performance"
echo ""

echo "5. Security considerations"
echo "   - Implement route filtering"
echo "   - Use authentication for routing protocols"
echo "   - Monitor for route hijacking"
echo ""

echo "=========================================="
echo "QUICK REFERENCE"
echo "=========================================="
echo ""

echo "Essential Commands:"
echo "  ip route show              # View routing table"
echo "  ip route add destination via gateway  # Add route"
echo "  ip route del destination   # Delete route"
echo "  ip route get destination   # Show route to destination"
echo "  ping destination           # Test connectivity"
echo "  traceroute destination     # Trace route path"
echo ""

echo "Troubleshooting Commands:"
echo "  ip route show | grep destination  # Check specific route"
echo "  ping gateway_ip                   # Test gateway"
echo "  traceroute destination            # Trace path"
echo "  ip link show                      # Check interfaces"
echo ""

echo "Lab completed! You should now understand the basics of routing"
echo "and how to use routing commands for troubleshooting."
