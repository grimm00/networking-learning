#!/bin/bash

# Simple Wireshark Capture Lab
# This script helps you capture real, visible traffic

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Wireshark Simple Capture Lab${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo -e "${YELLOW}This lab will help you capture real, visible traffic${NC}"
echo ""

# Check if Wireshark is installed
if ! command -v wireshark &> /dev/null; then
    echo -e "${RED}Wireshark is not installed. Please install it first.${NC}"
    echo "Install with: sudo apt-get install wireshark"
    exit 1
fi

echo -e "${GREEN}✅ Wireshark is installed${NC}"
echo ""

# Show available interfaces
echo -e "${BLUE}Available network interfaces:${NC}"
ip link show | grep -E "^[0-9]+:" | while read line; do
    interface=$(echo "$line" | cut -d: -f2 | sed 's/^ *//')
    state=$(echo "$line" | grep -o "state [A-Z]*" | cut -d' ' -f2)
    echo "  $interface: $state"
done
echo ""

# Get user's choice
read -p "Enter the interface you want to use (e.g., wlan0, eth0): " interface

if [ -z "$interface" ]; then
    echo -e "${RED}No interface specified. Exiting.${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}Starting Wireshark with interface: $interface${NC}"
echo ""

# Create a simple capture file
capture_file="/tmp/simple_capture_$(date +%Y%m%d_%H%M%S).pcap"

echo -e "${YELLOW}Instructions:${NC}"
echo "1. Wireshark will open automatically"
echo "2. Click the blue shark fin to start capturing"
echo "3. Open a web browser and visit: http://httpbin.org/get"
echo "4. In Wireshark, type 'http' in the filter bar"
echo "5. You should see HTTP packets!"
echo ""

read -p "Press Enter when you're ready to start Wireshark..."

# Start Wireshark with the specified interface
wireshark -i "$interface" -k -w "$capture_file" &

echo ""
echo -e "${GREEN}Wireshark started!${NC}"
echo ""
echo -e "${YELLOW}Now follow these steps:${NC}"
echo "1. Click the blue shark fin (🦈) to start capturing"
echo "2. Open a web browser"
echo "3. Visit: http://httpbin.org/get"
echo "4. In Wireshark, type 'http' in the filter bar"
echo "5. Click on a packet to see the details"
echo ""

echo -e "${BLUE}Why this works:${NC}"
echo "- httpbin.org uses HTTP (not HTTPS)"
echo "- HTTP traffic is visible in Wireshark"
echo "- HTTPS traffic is encrypted and not readable"
echo ""

echo -e "${YELLOW}If you don't see packets:${NC}"
echo "- Make sure you selected the right interface"
echo "- Look for green bars indicating traffic"
echo "- Try a different interface"
echo ""

echo -e "${GREEN}Happy packet capturing!${NC}"
