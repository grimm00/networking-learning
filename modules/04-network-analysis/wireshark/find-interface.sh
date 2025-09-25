#!/bin/bash

# Find the Right Network Interface for Wireshark
# This script helps you identify which interface to use

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Find Your Wireshark Interface${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if we're on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "${GREEN}🍎 macOS detected${NC}"
    echo ""
    
    echo -e "${YELLOW}Your network interfaces:${NC}"
    echo ""
    
    # Get interface details
    ifconfig | grep -E "^en[0-9]+:" -A 5 | while IFS= read -r line; do
        if [[ $line =~ ^en[0-9]+: ]]; then
            interface=$(echo "$line" | cut -d: -f1)
            echo -e "${BLUE}Interface: $interface${NC}"
        elif [[ $line =~ inet ]]; then
            ip=$(echo "$line" | awk '{print $2}')
            echo -e "  ${GREEN}IP Address: $ip${NC}"
            echo -e "  ${YELLOW}✅ This interface has an IP - likely your main interface${NC}"
            echo ""
        elif [[ $line =~ flags ]]; then
            if [[ $line =~ UP ]]; then
                echo -e "  ${GREEN}Status: UP (active)${NC}"
            else
                echo -e "  ${RED}Status: DOWN${NC}"
            fi
        fi
    done
    
    echo ""
    echo -e "${YELLOW}Recommendation:${NC}"
    echo "1. Look for the interface with an IP address"
    echo "2. Usually en0 is your main interface"
    echo "3. In Wireshark, select the interface with traffic indicators"
    echo ""
    
    echo -e "${BLUE}Quick test:${NC}"
    echo "1. Open Wireshark"
    echo "2. Select the interface with an IP address"
    echo "3. Start capturing"
    echo "4. Visit http://httpbin.org/get"
    echo "5. Filter: http"
    echo "6. You should see HTTP packets!"
    
else
    echo -e "${GREEN}Linux detected${NC}"
    echo ""
    
    echo -e "${YELLOW}Your network interfaces:${NC}"
    echo ""
    
    # Get interface details for Linux
    ip link show | grep -E "^[0-9]+:" | while read line; do
        interface=$(echo "$line" | cut -d: -f2 | sed 's/^ *//')
        state=$(echo "$line" | grep -o "state [A-Z]*" | cut -d' ' -f2)
        
        if [ "$state" = "UP" ]; then
            echo -e "${GREEN}✅ $interface: $state${NC}"
        else
            echo -e "${RED}❌ $interface: $state${NC}"
        fi
    done
    
    echo ""
    echo -e "${YELLOW}Recommendation:${NC}"
    echo "1. Look for interfaces with UP status"
    echo "2. Usually eth0 (Ethernet) or wlan0 (WiFi)"
    echo "3. In Wireshark, select the interface with traffic indicators"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Interface Selection Tips${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}In Wireshark, look for:${NC}"
echo "• Interface with an IP address"
echo "• Green bars or packet counts"
echo "• Interface that shows traffic when you browse"
echo ""
echo -e "${YELLOW}Common interface names:${NC}"
echo "• macOS: en0, en1, en2..."
echo "• Linux: eth0, wlan0, enp0s3..."
echo "• Windows: Ethernet, Wi-Fi, Local Area Connection"
echo ""
echo -e "${GREEN}Happy packet capturing!${NC}"
