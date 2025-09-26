#!/bin/bash
"""
TCP Lab Exercises
Interactive hands-on exercises for learning TCP protocol concepts.
"""

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Lab configuration
LAB_DIR="/tmp/tcp-lab-$(date +%s)"
mkdir -p "$LAB_DIR"

echo -e "${BLUE}🚀 TCP Protocol Lab Exercises${NC}"
echo "=================================="
echo "This lab will guide you through TCP protocol concepts"
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
required_commands=("netstat" "ss" "tcpdump" "nc" "telnet" "curl")
for cmd in "${required_commands[@]}"; do
    if check_command "$cmd"; then
        echo -e "${GREEN}✅ $cmd${NC}"
    else
        echo -e "${RED}❌ $cmd${NC}"
    fi
done

wait_for_user

# Exercise 1: TCP Connection States
print_exercise "1" "TCP Connection States Analysis"
echo "Let's examine TCP connection states using netstat and ss commands."

echo -e "\n${BLUE}Step 1: View all TCP connections${NC}"
echo "Command: netstat -tuln"
netstat -tuln | grep tcp

echo -e "\n${BLUE}Step 2: View TCP connections with states${NC}"
echo "Command: ss -tuln"
ss -tuln

echo -e "\n${BLUE}Step 3: View established connections${NC}"
echo "Command: ss -tuln state established"
ss -tuln state established

echo -e "\n${BLUE}Step 4: View listening connections${NC}"
echo "Command: ss -tuln state listening"
ss -tuln state listening

echo -e "\n${YELLOW}📝 Questions:${NC}"
echo "1. What TCP states do you see?"
echo "2. Which ports are listening for connections?"
echo "3. Are there any established connections?"

wait_for_user

# Exercise 2: TCP Handshake Analysis
print_exercise "2" "TCP Three-Way Handshake"
echo "Let's observe the TCP three-way handshake in action."

echo -e "\n${BLUE}Step 1: Start packet capture${NC}"
echo "We'll capture TCP packets to observe the handshake process."
echo "Command: tcpdump -i any -n tcp port 80"

echo -e "\n${YELLOW}📝 Instructions:${NC}"
echo "1. Run the tcpdump command in another terminal"
echo "2. In this terminal, make a connection to a web server"
echo "3. Observe the SYN, SYN-ACK, ACK sequence"

echo -e "\n${BLUE}Step 2: Make a TCP connection${NC}"
echo "Command: curl -v http://httpbin.org/get"
echo "This will establish a TCP connection to port 80"

echo -e "\n${YELLOW}📝 Questions:${NC}"
echo "1. Can you identify the SYN packet?"
echo "2. Can you identify the SYN-ACK response?"
echo "3. Can you identify the final ACK?"

wait_for_user

# Exercise 3: TCP Performance Analysis
print_exercise "3" "TCP Performance Analysis"
echo "Let's analyze TCP performance and statistics."

echo -e "\n${BLUE}Step 1: View TCP statistics${NC}"
echo "Command: cat /proc/net/tcp"
if [ -f /proc/net/tcp ]; then
    echo "TCP Statistics:"
    head -5 /proc/net/tcp
else
    echo "TCP statistics not available on this system"
fi

echo -e "\n${BLUE}Step 2: View network statistics${NC}"
echo "Command: cat /proc/net/netstat | grep Tcp"
if [ -f /proc/net/netstat ]; then
    cat /proc/net/netstat | grep Tcp
else
    echo "Network statistics not available on this system"
fi

echo -e "\n${BLUE}Step 3: Monitor TCP connections${NC}"
echo "Command: ss -s"
ss -s

echo -e "\n${YELLOW}📝 Questions:${NC}"
echo "1. How many TCP connections are currently active?"
echo "2. What are the main TCP statistics?"
echo "3. Are there any error counters?"

wait_for_user

# Exercise 4: TCP Connection Testing
print_exercise "4" "TCP Connection Testing"
echo "Let's test TCP connections to various services."

echo -e "\n${BLUE}Step 1: Test HTTP connection${NC}"
echo "Command: nc -v httpbin.org 80"
echo "Testing connection to HTTP server..."

if nc -w 5 -v httpbin.org 80 < /dev/null 2>&1; then
    echo -e "${GREEN}✅ HTTP connection successful${NC}"
else
    echo -e "${RED}❌ HTTP connection failed${NC}"
fi

echo -e "\n${BLUE}Step 2: Test HTTPS connection${NC}"
echo "Command: nc -v httpbin.org 443"
echo "Testing connection to HTTPS server..."

if nc -w 5 -v httpbin.org 443 < /dev/null 2>&1; then
    echo -e "${GREEN}✅ HTTPS connection successful${NC}"
else
    echo -e "${RED}❌ HTTPS connection failed${NC}"
fi

echo -e "\n${BLUE}Step 3: Test SSH connection${NC}"
echo "Command: nc -v github.com 22"
echo "Testing connection to SSH server..."

if nc -w 5 -v github.com 22 < /dev/null 2>&1; then
    echo -e "${GREEN}✅ SSH connection successful${NC}"
else
    echo -e "${RED}❌ SSH connection failed${NC}"
fi

echo -e "\n${YELLOW}📝 Questions:${NC}"
echo "1. Which connections were successful?"
echo "2. What happens when a connection fails?"
echo "3. How long does each connection attempt take?"

wait_for_user

# Exercise 5: TCP Port Scanning
print_exercise "5" "TCP Port Scanning"
echo "Let's perform basic TCP port scanning."

echo -e "\n${BLUE}Step 1: Scan common ports on localhost${NC}"
echo "Scanning ports 22, 80, 443, 8080 on localhost..."

for port in 22 80 443 8080; do
    if nc -w 1 -z localhost $port 2>/dev/null; then
        echo -e "${GREEN}✅ Port $port is open${NC}"
    else
        echo -e "${RED}❌ Port $port is closed${NC}"
    fi
done

echo -e "\n${BLUE}Step 2: Scan a range of ports${NC}"
echo "Scanning ports 80-85 on localhost..."

for port in {80..85}; do
    if nc -w 1 -z localhost $port 2>/dev/null; then
        echo -e "${GREEN}✅ Port $port is open${NC}"
    else
        echo -e "${RED}❌ Port $port is closed${NC}"
    fi
done

echo -e "\n${YELLOW}📝 Questions:${NC}"
echo "1. Which ports are open on your system?"
echo "2. What services might be running on open ports?"
echo "3. How does port scanning work?"

wait_for_user

# Exercise 6: TCP Troubleshooting
print_exercise "6" "TCP Troubleshooting"
echo "Let's practice TCP troubleshooting techniques."

echo -e "\n${BLUE}Step 1: Check TCP connection timeout${NC}"
echo "Command: timeout 5 nc -v nonexistent.example.com 80"
echo "Testing connection to non-existent host..."

timeout 5 nc -v nonexistent.example.com 80 2>&1 || echo "Connection timed out as expected"

echo -e "\n${BLUE}Step 2: Check TCP connection to closed port${NC}"
echo "Command: nc -v localhost 9999"
echo "Testing connection to closed port..."

timeout 3 nc -v localhost 9999 2>&1 || echo "Connection failed as expected"

echo -e "\n${BLUE}Step 3: Monitor TCP connections in real-time${NC}"
echo "Command: watch -n 1 'ss -tuln'"
echo "This will show TCP connections updating every second"
echo "Press Ctrl+C to stop monitoring"

echo -e "\n${YELLOW}📝 Questions:${NC}"
echo "1. What happens when you try to connect to a non-existent host?"
echo "2. What happens when you try to connect to a closed port?"
echo "3. How can you monitor TCP connections in real-time?"

wait_for_user

# Exercise 7: TCP vs UDP Comparison
print_exercise "7" "TCP vs UDP Comparison"
echo "Let's compare TCP and UDP characteristics."

echo -e "\n${BLUE}Step 1: Compare connection-oriented vs connectionless${NC}"
echo "TCP is connection-oriented, UDP is connectionless"

echo -e "\n${BLUE}Step 2: Compare reliability${NC}"
echo "TCP provides reliable delivery, UDP provides best-effort delivery"

echo -e "\n${BLUE}Step 3: Compare overhead${NC}"
echo "TCP has higher overhead due to reliability features"
echo "UDP has lower overhead due to simplicity"

echo -e "\n${YELLOW}📝 Questions:${NC}"
echo "1. When would you use TCP instead of UDP?"
echo "2. When would you use UDP instead of TCP?"
echo "3. What are the trade-offs between reliability and speed?"

wait_for_user

# Lab Summary
print_section "Lab Summary"
echo -e "${GREEN}🎉 Congratulations! You've completed the TCP Lab Exercises${NC}"
echo ""
echo "What you've learned:"
echo "✅ TCP connection states and monitoring"
echo "✅ TCP three-way handshake process"
echo "✅ TCP performance analysis"
echo "✅ TCP connection testing"
echo "✅ TCP port scanning"
echo "✅ TCP troubleshooting techniques"
echo "✅ TCP vs UDP comparison"
echo ""
echo "Next steps:"
echo "• Practice these commands regularly"
echo "• Experiment with different TCP parameters"
echo "• Learn about TCP congestion control"
echo "• Study TCP windowing and flow control"
echo ""
echo "Lab files saved in: $LAB_DIR"
echo ""

# Cleanup
echo -e "${BLUE}Cleaning up lab directory...${NC}"
rm -rf "$LAB_DIR"

echo -e "${GREEN}Lab completed successfully!${NC}"
