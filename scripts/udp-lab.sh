#!/bin/bash
"""
UDP Lab Exercises
Interactive hands-on exercises for learning UDP protocol concepts.
"""

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Lab configuration
LAB_DIR="/tmp/udp-lab-$(date +%s)"
mkdir -p "$LAB_DIR"

echo -e "${BLUE}🚀 UDP Protocol Lab Exercises${NC}"
echo "=================================="
echo "This lab will guide you through UDP protocol concepts"
echo "Lab directory: $LAB_DIR"
echo ""

# Function to print section headers
print_section() {
    echo -e "\n${YELLOW}📋 $1${NC}"
    echo "----------------------------------------"
}

# Function to print exercise headers
print_exercise() {
    echo -e "\n${GREEN}🔧 Exercise $1: $2${NC}"
    echo "----------------------------------------"
}

# Function to wait for user input
wait_for_user() {
    echo -e "\n${BLUE}Press Enter to continue...${NC}"
    read -r
}

# Function to check if command exists
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}❌ Command '$1' not found. Please install it first.${NC}"
        return 1
    fi
    return 0
}

# Check required commands
print_section "Prerequisites Check"
required_commands=("netstat" "ss" "tcpdump" "nc" "dig" "nslookup")
for cmd in "${required_commands[@]}"; do
    if check_command "$cmd"; then
        echo -e "${GREEN}✅ $cmd${NC}"
    else
        echo -e "${RED}❌ $cmd${NC}"
    fi
done

wait_for_user

# Exercise 1: UDP Connection Analysis
print_exercise "1" "UDP Connection Analysis"
echo "Let's examine UDP connections using netstat and ss commands."

echo -e "\n${BLUE}Step 1: View all UDP connections${NC}"
echo "Command: netstat -uln"
netstat -uln

echo -e "\n${BLUE}Step 2: View UDP connections with ss${NC}"
echo "Command: ss -uln"
ss -uln

echo -e "\n${BLUE}Step 3: View UDP statistics${NC}"
echo "Command: ss -s"
ss -s

echo -e "\n${YELLOW}📝 Questions:${NC}"
echo "1. What UDP ports are listening?"
echo "2. How does UDP differ from TCP in connection display?"
echo "3. What services are using UDP?"

wait_for_user

# Exercise 2: UDP Service Testing
print_exercise "2" "UDP Service Testing"
echo "Let's test various UDP services."

echo -e "\n${BLUE}Step 1: Test DNS service (UDP port 53)${NC}"
echo "Command: dig @8.8.8.8 google.com"
echo "Testing DNS resolution using UDP..."

dig @8.8.8.8 google.com

echo -e "\n${BLUE}Step 2: Test NTP service (UDP port 123)${NC}"
echo "Command: ntpdate -q pool.ntp.org"
echo "Testing NTP time synchronization using UDP..."

if command -v ntpdate &> /dev/null; then
    ntpdate -q pool.ntp.org
else
    echo "ntpdate not available, testing with nc instead"
    echo "Command: echo 'test' | nc -u pool.ntp.org 123"
    echo "test" | nc -u pool.ntp.org 123
fi

echo -e "\n${BLUE}Step 3: Test DHCP service (UDP port 67)${NC}"
echo "Command: nc -u localhost 67"
echo "Testing DHCP service..."

timeout 3 nc -u localhost 67 2>&1 || echo "DHCP service not available locally"

echo -e "\n${YELLOW}📝 Questions:${NC}"
echo "1. Which UDP services responded?"
echo "2. What happens when a UDP service doesn't respond?"
echo "3. How does UDP handle service discovery?"

wait_for_user

# Exercise 3: UDP Packet Analysis
print_exercise "3" "UDP Packet Analysis"
echo "Let's analyze UDP packets using tcpdump."

echo -e "\n${BLUE}Step 1: Capture UDP packets${NC}"
echo "Command: tcpdump -i any -n udp"
echo "We'll capture UDP packets to analyze their structure."

echo -e "\n${YELLOW}📝 Instructions:${NC}"
echo "1. Run the tcpdump command in another terminal"
echo "2. In this terminal, generate some UDP traffic"
echo "3. Observe the UDP packet structure"

echo -e "\n${BLUE}Step 2: Generate UDP traffic${NC}"
echo "Command: dig @8.8.8.8 google.com"
echo "This will generate DNS UDP packets"

dig @8.8.8.8 google.com

echo -e "\n${BLUE}Step 3: Analyze UDP packet structure${NC}"
echo "UDP packets have a simple structure:"
echo "- Source Port (2 bytes)"
echo "- Destination Port (2 bytes)"
echo "- Length (2 bytes)"
echo "- Checksum (2 bytes)"
echo "- Data (variable length)"

echo -e "\n${YELLOW}📝 Questions:${NC}"
echo "1. Can you identify the source and destination ports?"
echo "2. What is the length of the UDP packet?"
echo "3. How does UDP checksum work?"

wait_for_user

# Exercise 4: UDP Performance Testing
print_exercise "4" "UDP Performance Testing"
echo "Let's test UDP performance characteristics."

echo -e "\n${BLUE}Step 1: Test UDP throughput${NC}"
echo "Command: nc -u -l 9999 &"
echo "Starting UDP listener on port 9999..."

nc -u -l 9999 &
LISTENER_PID=$!

sleep 2

echo -e "\n${BLUE}Step 2: Send UDP data${NC}"
echo "Command: echo 'Hello UDP World' | nc -u localhost 9999"
echo "Sending UDP data..."

echo "Hello UDP World" | nc -u localhost 9999

sleep 2

echo -e "\n${BLUE}Step 3: Test UDP with large data${NC}"
echo "Command: dd if=/dev/zero bs=1024 count=100 | nc -u localhost 9999"
echo "Sending 100KB of data via UDP..."

if command -v dd &> /dev/null; then
    dd if=/dev/zero bs=1024 count=100 2>/dev/null | nc -u localhost 9999
else
    echo "dd not available, using alternative method"
    for i in {1..100}; do
        echo "Data packet $i" | nc -u localhost 9999
    done
fi

# Clean up listener
kill $LISTENER_PID 2>/dev/null || true

echo -e "\n${YELLOW}📝 Questions:${NC}"
echo "1. How fast was UDP data transmission?"
echo "2. Did all packets arrive successfully?"
echo "3. What happens when UDP packets are lost?"

wait_for_user

# Exercise 5: UDP Port Scanning
print_exercise "5" "UDP Port Scanning"
echo "Let's perform UDP port scanning."

echo -e "\n${BLUE}Step 1: Scan common UDP ports${NC}"
echo "Scanning ports 53, 67, 68, 123, 161 on localhost..."

for port in 53 67 68 123 161; do
    echo -n "Port $port: "
    if timeout 2 nc -u -z localhost $port 2>/dev/null; then
        echo -e "${GREEN}Open${NC}"
    else
        echo -e "${RED}Closed/Filtered${NC}"
    fi
done

echo -e "\n${BLUE}Step 2: Scan a range of UDP ports${NC}"
echo "Scanning ports 53-60 on localhost..."

for port in {53..60}; do
    echo -n "Port $port: "
    if timeout 1 nc -u -z localhost $port 2>/dev/null; then
        echo -e "${GREEN}Open${NC}"
    else
        echo -e "${RED}Closed/Filtered${NC}"
    fi
done

echo -e "\n${YELLOW}📝 Questions:${NC}"
echo "1. Which UDP ports are open on your system?"
echo "2. Why is UDP port scanning more difficult than TCP?"
echo "3. What services might be running on open UDP ports?"

wait_for_user

# Exercise 6: UDP Troubleshooting
print_exercise "6" "UDP Troubleshooting"
echo "Let's practice UDP troubleshooting techniques."

echo -e "\n${BLUE}Step 1: Check UDP connectivity${NC}"
echo "Command: nc -u -v 8.8.8.8 53"
echo "Testing UDP connectivity to DNS server..."

timeout 5 nc -u -v 8.8.8.8 53 2>&1 || echo "UDP connection test completed"

echo -e "\n${BLUE}Step 2: Check UDP packet loss${NC}"
echo "Command: ping -c 10 8.8.8.8"
echo "Testing packet loss using ping (ICMP over UDP-like protocol)..."

ping -c 10 8.8.8.8

echo -e "\n${BLUE}Step 3: Monitor UDP traffic${NC}"
echo "Command: netstat -su"
echo "Viewing UDP statistics..."

if [ -f /proc/net/snmp ]; then
    echo "UDP Statistics:"
    grep -A 1 "Udp:" /proc/net/snmp
else
    echo "UDP statistics not available on this system"
fi

echo -e "\n${YELLOW}📝 Questions:${NC}"
echo "1. What happens when UDP packets are lost?"
echo "2. How can you detect UDP packet loss?"
echo "3. What are common UDP troubleshooting steps?"

wait_for_user

# Exercise 7: UDP vs TCP Comparison
print_exercise "7" "UDP vs TCP Comparison"
echo "Let's compare UDP and TCP characteristics."

echo -e "\n${BLUE}Step 1: Compare connection establishment${NC}"
echo "TCP: Requires three-way handshake"
echo "UDP: No connection establishment required"

echo -e "\n${BLUE}Step 2: Compare reliability${NC}"
echo "TCP: Guaranteed delivery with acknowledgments"
echo "UDP: Best-effort delivery, no acknowledgments"

echo -e "\n${BLUE}Step 3: Compare overhead${NC}"
echo "TCP: Higher overhead due to reliability features"
echo "UDP: Lower overhead due to simplicity"

echo -e "\n${BLUE}Step 4: Compare use cases${NC}"
echo "TCP: Web browsing, email, file transfer"
echo "UDP: DNS, DHCP, video streaming, gaming"

echo -e "\n${YELLOW}📝 Questions:${NC}"
echo "1. When would you choose UDP over TCP?"
echo "2. When would you choose TCP over UDP?"
echo "3. What are the trade-offs between reliability and speed?"

wait_for_user

# Lab Summary
print_section "Lab Summary"
echo -e "${GREEN}🎉 Congratulations! You've completed the UDP Lab Exercises${NC}"
echo ""
echo "What you've learned:"
echo "✅ UDP connection analysis and monitoring"
echo "✅ UDP service testing (DNS, NTP, DHCP)"
echo "✅ UDP packet analysis and structure"
echo "✅ UDP performance testing"
echo "✅ UDP port scanning"
echo "✅ UDP troubleshooting techniques"
echo "✅ UDP vs TCP comparison"
echo ""
echo "Next steps:"
echo "• Practice these commands regularly"
echo "• Experiment with different UDP services"
echo "• Learn about UDP-based protocols"
echo "• Study UDP error handling and recovery"
echo ""
echo "Lab files saved in: $LAB_DIR"
echo ""

# Cleanup
echo -e "${BLUE}Cleaning up lab directory...${NC}"
rm -rf "$LAB_DIR"

echo -e "${GREEN}Lab completed successfully!${NC}"
