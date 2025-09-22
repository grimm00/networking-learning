#!/bin/bash

# Network Design Lab
# Practice designing networks for real-world scenarios

echo "=========================================="
echo "NETWORK DESIGN LAB"
echo "=========================================="
echo ""
echo "This lab provides real-world network design scenarios to practice"
echo "IPv4 addressing and subnetting skills."
echo ""

# Function to present a design scenario
present_scenario() {
    local title="$1"
    local description="$2"
    local requirements="$3"
    local solution="$4"
    
    echo "SCENARIO: $title"
    echo "=========================================="
    echo ""
    echo "Description: $description"
    echo ""
    echo "Requirements:"
    echo "$requirements"
    echo ""
    echo "Press Enter to see the solution..."
    read
    echo ""
    echo "SOLUTION:"
    echo "--------"
    echo "$solution"
    echo ""
    echo "Press Enter to continue..."
    read
    echo ""
    echo "=========================================="
    echo ""
}

echo "NETWORK DESIGN FUNDAMENTALS"
echo "==========================="
echo ""
echo "When designing a network, consider:"
echo "1. Current requirements (number of devices)"
echo "2. Future growth (scalability)"
echo "3. Security requirements (network segmentation)"
echo "4. Performance requirements (broadcast domains)"
echo "5. Management requirements (logical grouping)"
echo ""

echo "Design Process:"
echo "1. Analyze requirements"
echo "2. Choose IP address range"
echo "3. Calculate subnet requirements"
echo "4. Design subnet layout"
echo "5. Document the design"
echo "6. Test the design"
echo ""

# Scenario 1: Small Office
present_scenario \
    "Small Office Network" \
    "A small office with 25 employees needs a network design. They have a server room, office area, and guest WiFi." \
    "- 20 workstations in office area
- 5 servers in server room
- Guest WiFi for visitors
- Future growth: 50% increase in 2 years
- Security: Isolate guest network
- Management: Easy to manage and troubleshoot" \
    "Network Design:
- Use 192.168.1.0/24 as base network
- Subnet 1: 192.168.1.0/26 (Office area - 62 hosts)
  - Range: 192.168.1.1 - 192.168.1.62
  - Gateway: 192.168.1.1
- Subnet 2: 192.168.1.64/26 (Server room - 62 hosts)
  - Range: 192.168.1.65 - 192.168.1.126
  - Gateway: 192.168.1.65
- Subnet 3: 192.168.1.128/26 (Guest WiFi - 62 hosts)
  - Range: 192.168.1.129 - 192.168.1.190
  - Gateway: 192.168.1.129
- Subnet 4: 192.168.1.192/26 (Future expansion - 62 hosts)
  - Range: 192.168.1.193 - 192.168.1.254
  - Gateway: 192.168.1.193

VLAN Assignment:
- VLAN 10: Office area
- VLAN 20: Server room
- VLAN 30: Guest WiFi
- VLAN 40: Future expansion

Security:
- Firewall rules between VLANs
- Guest network isolated from internal networks
- Server room access restricted"

# Scenario 2: Medium Business
present_scenario \
    "Medium Business Network" \
    "A medium business with 200 employees needs a network design. They have multiple departments, servers, and need high availability." \
    "- 150 workstations across 5 departments
- 20 servers in data center
- 30 IP phones
- Guest WiFi network
- Future growth: 100% increase in 3 years
- High availability requirements
- Department isolation needed" \
    "Network Design:
- Use 10.0.0.0/16 as base network
- Department subnets: /24 (254 hosts each)
- Server subnet: /23 (510 hosts)
- Guest subnet: /24 (254 hosts)
- Future expansion: /24 subnets

Subnet Layout:
- 10.0.1.0/24 - Sales (254 hosts)
- 10.0.2.0/24 - Marketing (254 hosts)
- 10.0.3.0/24 - Engineering (254 hosts)
- 10.0.4.0/24 - HR (254 hosts)
- 10.0.5.0/24 - Finance (254 hosts)
- 10.0.10.0/23 - Data Center (510 hosts)
- 10.0.20.0/24 - Guest WiFi (254 hosts)
- 10.0.30.0/24 - IP Phones (254 hosts)
- 10.0.100.0/24 - Future expansion 1
- 10.0.101.0/24 - Future expansion 2

VLAN Assignment:
- VLAN 10-14: Departments
- VLAN 20: Data Center
- VLAN 30: Guest WiFi
- VLAN 40: IP Phones
- VLAN 100+: Future expansion

High Availability:
- Redundant switches
- Load balancers
- Backup connections
- Monitoring systems"

# Scenario 3: Data Center
present_scenario \
    "Data Center Network" \
    "A data center needs to host multiple customers with strict isolation requirements." \
    "- 10 customers, each with 100-500 servers
- Customer isolation required
- Scalability for more customers
- Management network
- Backup network
- Monitoring network" \
    "Network Design:
- Use 172.16.0.0/12 as base network
- Customer subnets: /22 (1022 hosts each)
- Management subnet: /24 (254 hosts)
- Backup subnet: /24 (254 hosts)
- Monitoring subnet: /24 (254 hosts)

Subnet Layout:
- 172.16.0.0/22 - Customer 1 (1022 hosts)
- 172.16.4.0/22 - Customer 2 (1022 hosts)
- 172.16.8.0/22 - Customer 3 (1022 hosts)
- 172.16.12.0/22 - Customer 4 (1022 hosts)
- 172.16.16.0/22 - Customer 5 (1022 hosts)
- 172.16.20.0/22 - Customer 6 (1022 hosts)
- 172.16.24.0/22 - Customer 7 (1022 hosts)
- 172.16.28.0/22 - Customer 8 (1022 hosts)
- 172.16.32.0/22 - Customer 9 (1022 hosts)
- 172.16.36.0/22 - Customer 10 (1022 hosts)
- 172.16.100.0/24 - Management (254 hosts)
- 172.16.101.0/24 - Backup (254 hosts)
- 172.16.102.0/24 - Monitoring (254 hosts)
- 172.16.200.0/22 - Future customers

VLAN Assignment:
- VLAN 100-109: Customer networks
- VLAN 200: Management
- VLAN 201: Backup
- VLAN 202: Monitoring
- VLAN 300+: Future customers

Security:
- Strict VLAN isolation
- Firewall between customer networks
- Access control lists
- Monitoring and logging"

echo "=========================================="
echo "HANDS-ON DESIGN EXERCISES"
echo "=========================================="
echo ""

echo "Exercise 1: Design a Home Network"
echo "--------------------------------"
echo "Requirements:"
echo "- 4 family members with devices"
echo "- Smart home devices (10 devices)"
echo "- Guest network"
echo "- Future expansion for 2 more family members"
echo ""
echo "Your task: Design the network using 192.168.1.0/24"
echo "Consider: Device types, security, and future growth"
echo ""

echo "Exercise 2: Design a School Network"
echo "----------------------------------"
echo "Requirements:"
echo "- 500 students with laptops"
echo "- 50 teachers with computers"
echo "- 20 administrative staff"
echo "- Library computers (30)"
echo "- Guest network for visitors"
echo "- Future expansion for 200 more students"
echo ""
echo "Your task: Design the network using 10.0.0.0/16"
echo "Consider: Department separation, security, and scalability"
echo ""

echo "Exercise 3: Design a Hospital Network"
echo "------------------------------------"
echo "Requirements:"
echo "- Patient records system (100 workstations)"
echo "- Medical equipment network (50 devices)"
echo "- Guest network for visitors"
echo "- Emergency systems (20 devices)"
echo "- Administrative network (30 workstations)"
echo "- Future expansion for new wing (100 devices)"
echo ""
echo "Your task: Design the network using 172.16.0.0/16"
echo "Consider: Security, compliance, and critical systems"
echo ""

echo "=========================================="
echo "DESIGN VALIDATION TOOLS"
echo "=========================================="
echo ""

echo "Use these tools to validate your designs:"
echo ""
echo "1. IPv4 Calculator:"
echo "   python3 ipv4-calculator.py --interactive"
echo ""
echo "2. Subnet Testing:"
echo "   python3 ipv4-calculator.py 192.168.1.0/24 --subnets 4"
echo ""
echo "3. VLSM Testing:"
echo "   python3 ipv4-calculator.py --vlsm 100 50 25 10 192.168.1.0/24"
echo ""

echo "=========================================="
echo "DESIGN DOCUMENTATION TEMPLATE"
echo "=========================================="
echo ""

echo "Network Design Document Template:"
echo ""
echo "1. Executive Summary"
echo "   - Purpose of the network"
echo "   - Key requirements"
echo "   - Design approach"
echo ""
echo "2. Network Requirements"
echo "   - Current needs"
echo "   - Future growth"
echo "   - Security requirements"
echo "   - Performance requirements"
echo ""
echo "3. Network Design"
echo "   - IP addressing scheme"
echo "   - Subnet layout"
echo "   - VLAN assignment"
echo "   - Routing design"
echo ""
echo "4. Security Design"
echo "   - Access control"
echo "   - Firewall rules"
echo "   - Network segmentation"
echo ""
echo "5. Implementation Plan"
echo "   - Phases"
echo "   - Timeline"
echo "   - Resources needed"
echo ""
echo "6. Testing and Validation"
echo "   - Test scenarios"
echo "   - Success criteria"
echo "   - Monitoring plan"
echo ""

echo "=========================================="
echo "COMMON DESIGN MISTAKES"
echo "=========================================="
echo ""

echo "Avoid these common mistakes:"
echo ""
echo "1. Not planning for future growth"
echo "2. Using inefficient subnet sizes"
echo "3. Not considering security requirements"
echo "4. Poor documentation"
echo "5. Not testing the design"
echo "6. Ignoring management requirements"
echo "7. Not considering performance implications"
echo ""

echo "=========================================="
echo "DESIGN BEST PRACTICES"
echo "=========================================="
echo ""

echo "Follow these best practices:"
echo ""
echo "1. Start with requirements analysis"
echo "2. Use hierarchical addressing"
echo "3. Plan for future growth"
echo "4. Document everything"
echo "5. Test your design"
echo "6. Consider security from the start"
echo "7. Use consistent naming conventions"
echo "8. Plan for management and monitoring"
echo ""

echo "Lab completed! You should now understand how to design"
echo "networks for real-world scenarios. Practice with the"
echo "exercises and use the tools to validate your designs."
