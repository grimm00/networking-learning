#!/bin/bash

# TLS Filter Helper
# Helps you create focused TLS filters for specific sites

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  TLS Filter Helper${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo -e "${YELLOW}This script helps you create focused TLS filters${NC}"
echo ""

# Function to get IP address
get_ip() {
    local domain=$1
    echo -e "${BLUE}Looking up $domain...${NC}"
    
    # Try different methods to get IP
    local ip=$(nslookup "$domain" 2>/dev/null | grep -A 1 "Name:" | grep "Address:" | head -1 | awk '{print $2}')
    
    if [ -z "$ip" ]; then
        ip=$(dig +short "$domain" | head -1)
    fi
    
    if [ -z "$ip" ]; then
        ip=$(host "$domain" 2>/dev/null | grep "has address" | head -1 | awk '{print $4}')
    fi
    
    if [ -n "$ip" ]; then
        echo -e "${GREEN}✅ $domain → $ip${NC}"
        echo "$ip"
    else
        echo -e "${RED}❌ Could not resolve $domain${NC}"
        echo ""
    fi
}

# Get user input
echo -e "${YELLOW}Enter the domains you want to filter (one per line, empty line to finish):${NC}"
echo ""

domains=()
while true; do
    read -p "Domain (or press Enter to finish): " domain
    if [ -z "$domain" ]; then
        break
    fi
    domains+=("$domain")
done

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  IP Address Lookup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

ips=()
for domain in "${domains[@]}"; do
    ip=$(get_ip "$domain")
    if [ -n "$ip" ]; then
        ips+=("$ip")
    fi
done

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Generated Filters${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

if [ ${#ips[@]} -eq 0 ]; then
    echo -e "${RED}No valid IP addresses found.${NC}"
    exit 1
fi

# Generate filters
echo -e "${YELLOW}Copy these filters into Wireshark:${NC}"
echo ""

# Single IP filter
if [ ${#ips[@]} -eq 1 ]; then
    echo -e "${GREEN}Single site filter:${NC}"
    echo "ip.addr == ${ips[0]} and tls"
    echo ""
fi

# Multiple IP filter
if [ ${#ips[@]} -gt 1 ]; then
    echo -e "${GREEN}Multiple sites filter:${NC}"
    echo -n "("
    for i in "${!ips[@]}"; do
        if [ $i -gt 0 ]; then
            echo -n " or "
        fi
        echo -n "ip.addr == ${ips[$i]}"
    done
    echo ") and tls"
    echo ""
fi

# Individual filters
echo -e "${GREEN}Individual site filters:${NC}"
for i in "${!domains[@]}"; do
    if [ $i -lt ${#ips[@]} ]; then
        echo "ip.addr == ${ips[$i]} and tls  # ${domains[$i]}"
    fi
done
echo ""

# Additional useful filters
echo -e "${GREEN}Additional useful filters:${NC}"
echo "tls.handshake.type == 1  # TLS Client Hello only"
echo "tls.record.content_type == 23  # TLS Application Data only"
echo "tcp.port == 443  # All HTTPS traffic"
echo ""

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Usage Instructions${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}1. Copy one of the filters above${NC}"
echo -e "${YELLOW}2. Paste it into Wireshark's filter bar${NC}"
echo -e "${YELLOW}3. Press Enter to apply the filter${NC}"
echo -e "${YELLOW}4. Visit the websites while capturing${NC}"
echo -e "${YELLOW}5. You should see only TLS traffic for those sites${NC}"
echo ""
echo -e "${GREEN}Happy TLS analysis!${NC}"
