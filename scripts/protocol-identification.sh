#!/bin/bash

# Protocol Identification Lab
# Learn to identify which OSI layer different protocols operate at

echo "=========================================="
echo "PROTOCOL IDENTIFICATION LAB"
echo "=========================================="
echo ""
echo "This lab helps you identify which OSI layer different protocols operate at."
echo ""

# Function to test a protocol and identify its layer
test_protocol() {
    local protocol_name="$1"
    local command="$2"
    local expected_layer="$3"
    local description="$4"
    
    echo "Testing: $protocol_name"
    echo "Command: $command"
    echo "Expected Layer: $expected_layer"
    echo "Description: $description"
    echo ""
    
    # Run the command and capture output
    echo "Output:"
    eval "$command" 2>&1 | head -5
    echo ""
    echo "---"
    echo ""
}

echo "PROTOCOL IDENTIFICATION EXERCISES"
echo "================================="
echo ""

# Layer 7 (Application) Protocols
echo "LAYER 7 (Application) Protocols:"
echo "--------------------------------"
test_protocol "HTTP" "curl -I http://httpbin.org/get" "Layer 7" "Web browsing protocol"
test_protocol "DNS" "nslookup google.com" "Layer 7" "Domain name resolution"
test_protocol "SSH" "ssh -V" "Layer 7" "Secure shell protocol"

echo ""

# Layer 6 (Presentation) Protocols
echo "LAYER 6 (Presentation) Protocols:"
echo "---------------------------------"
test_protocol "SSL/TLS" "timeout 5 openssl s_client -connect google.com:443 -servername google.com -quiet 2>/dev/null | head -3" "Layer 6" "Encryption and data translation"
test_protocol "File Encoding" "file -bi /etc/passwd" "Layer 6" "Character encoding detection"

echo ""

# Layer 5 (Session) Protocols
echo "LAYER 5 (Session) Protocols:"
echo "----------------------------"
test_protocol "Session Management" "netstat -an | grep ESTABLISHED | head -3" "Layer 5" "Session establishment and management"

echo ""

# Layer 4 (Transport) Protocols
echo "LAYER 4 (Transport) Protocols:"
echo "------------------------------"
test_protocol "TCP" "timeout 3 bash -c 'echo | telnet google.com 80' 2>/dev/null | head -3" "Layer 4" "Reliable, connection-oriented transport"
test_protocol "UDP" "nc -u -z 8.8.8.8 53" "Layer 4" "Unreliable, connectionless transport"
test_protocol "Port Status" "netstat -tuln | head -5" "Layer 4" "Port and connection management"

echo ""

# Layer 3 (Network) Protocols
echo "LAYER 3 (Network) Protocols:"
echo "----------------------------"
test_protocol "IP" "ping -c 2 8.8.8.8" "Layer 3" "Internet Protocol addressing"
test_protocol "ICMP" "ping -c 2 google.com" "Layer 3" "Internet Control Message Protocol"
test_protocol "Routing" "timeout 10 traceroute -m 3 google.com 2>/dev/null" "Layer 3" "IP routing and path determination"

echo ""

# Layer 2 (Data Link) Protocols
echo "LAYER 2 (Data Link) Protocols:"
echo "------------------------------"
test_protocol "Ethernet" "ifconfig | grep -A 5 'en0\|eth0'" "Layer 2" "Ethernet frame handling and MAC addresses"
test_protocol "ARP" "arp -a | head -3" "Layer 2" "Address Resolution Protocol (IP to MAC mapping)"

echo ""

# Layer 1 (Physical) Protocols
echo "LAYER 1 (Physical) Protocols:"
echo "-----------------------------"
test_protocol "Physical Interface" "ifconfig | grep -E 'flags|mtu'" "Layer 1" "Physical interface characteristics"
test_protocol "Link Status" "cat /sys/class/net/*/operstate 2>/dev/null | head -3" "Layer 1" "Physical link status"

echo ""

echo "=========================================="
echo "PROTOCOL IDENTIFICATION QUIZ"
echo "=========================================="
echo ""
echo "Now test your knowledge! For each protocol below, identify which OSI layer it operates at:"
echo ""

# Quiz section
echo "QUIZ QUESTIONS:"
echo "1. FTP (File Transfer Protocol) - Which layer?"
echo "   a) Layer 7  b) Layer 6  c) Layer 5  d) Layer 4"
echo "   Answer: a) Layer 7 - Application layer protocol"
echo ""

echo "2. TCP (Transmission Control Protocol) - Which layer?"
echo "   a) Layer 7  b) Layer 6  c) Layer 5  d) Layer 4"
echo "   Answer: d) Layer 4 - Transport layer protocol"
echo ""

echo "3. Ethernet - Which layer?"
echo "   a) Layer 3  b) Layer 2  c) Layer 1  d) Layer 4"
echo "   Answer: b) Layer 2 - Data Link layer protocol"
echo ""

echo "4. IP (Internet Protocol) - Which layer?"
echo "   a) Layer 3  b) Layer 2  c) Layer 1  d) Layer 4"
echo "   Answer: a) Layer 3 - Network layer protocol"
echo ""

echo "5. SSL/TLS - Which layer?"
echo "   a) Layer 7  b) Layer 6  c) Layer 5  d) Layer 4"
echo "   Answer: b) Layer 6 - Presentation layer protocol"
echo ""

echo "6. HTTP (Hypertext Transfer Protocol) - Which layer?"
echo "   a) Layer 7  b) Layer 6  c) Layer 5  d) Layer 4"
echo "   Answer: a) Layer 7 - Application layer protocol"
echo ""

echo "=========================================="
echo "COMMON PROTOCOL MAPPINGS"
echo "=========================================="
echo ""
echo "Layer 7 (Application):"
echo "  - HTTP, HTTPS, FTP, SMTP, POP3, IMAP, DNS, SSH, Telnet, SNMP, DHCP"
echo ""
echo "Layer 6 (Presentation):"
echo "  - SSL, TLS, JPEG, PNG, MPEG, ASCII, Unicode, ZIP compression"
echo ""
echo "Layer 5 (Session):"
echo "  - NetBIOS, RPC, SQL, NFS, SMB, PPTP, L2TP"
echo ""
echo "Layer 4 (Transport):"
echo "  - TCP, UDP, SCTP, DCCP, QUIC"
echo ""
echo "Layer 3 (Network):"
echo "  - IPv4, IPv6, ICMP, ARP, RARP, OSPF, BGP, RIP, EIGRP"
echo ""
echo "Layer 2 (Data Link):"
echo "  - Ethernet, WiFi (802.11), PPP, Frame Relay, ATM, Token Ring"
echo ""
echo "Layer 1 (Physical):"
echo "  - Ethernet cables, WiFi radio, Fiber optic, Coaxial, DSL, Cellular"
echo ""

echo "=========================================="
echo "PRACTICAL EXERCISES"
echo "=========================================="
echo ""
echo "Try these exercises to practice protocol identification:"
echo ""
echo "1. Capture network traffic and identify protocols:"
echo "   sudo tcpdump -i any -n -c 10"
echo "   (Look for protocol names in the output)"
echo ""
echo "2. Check what protocols are running on your system:"
echo "   netstat -tuln | grep LISTEN"
echo "   (Identify which layer each service operates at)"
echo ""
echo "3. Test different protocols and observe their behavior:"
echo "   curl -v http://httpbin.org/get    # HTTP (Layer 7)"
echo "   ping google.com                   # ICMP (Layer 3)"
echo "   telnet google.com 80              # TCP (Layer 4)"
echo ""
echo "4. Use the OSI analyzer tool:"
echo "   python3 osi-analyzer.py --interactive"
echo ""

echo "Lab completed! You should now have a better understanding of"
echo "which OSI layer different protocols operate at."
