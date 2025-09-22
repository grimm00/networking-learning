#!/bin/bash

# OSI Layer Analysis Script
# Demonstrates each layer of the OSI model with practical examples

echo "=========================================="
echo "OSI MODEL LAYER ANALYSIS"
echo "=========================================="
echo ""

# Function to display layer information
display_layer() {
    local layer_num=$1
    local layer_name=$2
    local purpose=$3
    local examples=$4
    local devices=$5
    local data_unit=$6
    
    echo "Layer $layer_num: $layer_name"
    echo "  Purpose: $purpose"
    echo "  Data Unit: $data_unit"
    echo "  Examples: $examples"
    echo "  Devices: $devices"
    echo ""
}

# Display all layers
echo "OSI MODEL OVERVIEW"
echo "=================="
echo ""

display_layer 7 "Application" \
    "Provides network services to user applications" \
    "HTTP, HTTPS, FTP, SMTP, DNS, SSH, Telnet" \
    "Gateways, Firewalls" \
    "Data"

display_layer 6 "Presentation" \
    "Data translation, encryption, compression" \
    "SSL/TLS, JPEG, MPEG, ASCII, Unicode" \
    "Gateways, Firewalls" \
    "Data"

display_layer 5 "Session" \
    "Establishes, manages, and terminates sessions" \
    "NetBIOS, RPC, SQL, NFS" \
    "Gateways, Firewalls" \
    "Data"

display_layer 4 "Transport" \
    "End-to-end communication, reliability, flow control" \
    "TCP, UDP, SCTP" \
    "Firewalls, Load Balancers" \
    "Segments (TCP) or Datagrams (UDP)"

display_layer 3 "Network" \
    "Logical addressing and routing" \
    "IP, ICMP, ARP, OSPF, BGP" \
    "Routers, Layer 3 Switches" \
    "Packets"

display_layer 2 "Data Link" \
    "Physical addressing, error detection, frame synchronization" \
    "Ethernet, WiFi, PPP, Frame Relay" \
    "Switches, Bridges, NICs" \
    "Frames"

display_layer 1 "Physical" \
    "Physical transmission of data" \
    "Ethernet cables, WiFi radio, Fiber optic" \
    "Hubs, Repeaters, Cables, NICs" \
    "Bits"

echo "=========================================="
echo "PRACTICAL LAYER DEMONSTRATIONS"
echo "=========================================="
echo ""

# Layer 7: Application
echo "Layer 7 (Application) - HTTP Request:"
echo "------------------------------------"
echo "Command: curl -v http://httpbin.org/get"
echo "Output:"
curl -s -v http://httpbin.org/get 2>&1 | head -10
echo ""

# Layer 4: Transport
echo "Layer 4 (Transport) - TCP Connection:"
echo "------------------------------------"
echo "Command: telnet google.com 80"
echo "Note: This will attempt to establish a TCP connection"
echo "Press Ctrl+C to cancel after seeing the connection attempt"
echo ""

# Layer 3: Network
echo "Layer 3 (Network) - IP Routing:"
echo "------------------------------"
echo "Command: traceroute google.com"
echo "Output:"
traceroute -m 5 google.com 2>/dev/null | head -10
echo ""

# Layer 2: Data Link
echo "Layer 2 (Data Link) - MAC Addresses:"
echo "-----------------------------------"
echo "Command: arp -a"
echo "Output:"
arp -a 2>/dev/null | head -5
echo ""

# Layer 1: Physical
echo "Layer 1 (Physical) - Network Interfaces:"
echo "---------------------------------------"
echo "Command: ifconfig"
echo "Output:"
ifconfig 2>/dev/null | grep -A 5 "en0\|eth0" | head -10
echo ""

echo "=========================================="
echo "LAYER INTERACTION DEMONSTRATION"
echo "=========================================="
echo ""

echo "Data Encapsulation Process:"
echo "1. Application Layer: User data + Application header"
echo "2. Presentation Layer: + Encryption/compression header"
echo "3. Session Layer: + Session header"
echo "4. Transport Layer: + TCP/UDP header (ports, sequence numbers)"
echo "5. Network Layer: + IP header (source/dest IP, TTL)"
echo "6. Data Link Layer: + Ethernet header (MAC addresses)"
echo "7. Physical Layer: + Physical transmission (electrical signals)"
echo ""

echo "Data Decapsulation Process (Reverse):"
echo "1. Physical Layer: Receive electrical signals"
echo "2. Data Link Layer: Remove Ethernet header, check MAC"
echo "3. Network Layer: Remove IP header, check destination IP"
echo "4. Transport Layer: Remove TCP/UDP header, check port"
echo "5. Session Layer: Remove session header"
echo "6. Presentation Layer: Decrypt/decompress data"
echo "7. Application Layer: Remove application header, deliver to user"
echo ""

echo "=========================================="
echo "TROUBLESHOOTING BY LAYER"
echo "=========================================="
echo ""

echo "Layer 7 Issues: Application not responding, authentication failures"
echo "Layer 6 Issues: Encryption problems, data format incompatibility"
echo "Layer 5 Issues: Session timeouts, connection drops"
echo "Layer 4 Issues: Port not available, connection refused"
echo "Layer 3 Issues: Routing problems, IP address conflicts"
echo "Layer 2 Issues: MAC address problems, switch port issues"
echo "Layer 1 Issues: Cable problems, interface down"
echo ""

echo "=========================================="
echo "MEMORY AIDS"
echo "=========================================="
echo ""

echo "OSI Model Mnemonics:"
echo "  Top to Bottom: 'All People Seem To Need Data Processing'"
echo "  Bottom to Top: 'Please Do Not Throw Sausage Pizza Away'"
echo ""

echo "Layer Numbers:"
echo "  7: Application (A)"
echo "  6: Presentation (P)"
echo "  5: Session (S)"
echo "  4: Transport (T)"
echo "  3: Network (N)"
echo "  2: Data Link (D)"
echo "  1: Physical (P)"
echo ""

echo "Analysis complete!"
