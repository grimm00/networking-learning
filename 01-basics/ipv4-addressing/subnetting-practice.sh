#!/bin/bash

# Subnetting Practice Lab
# Hands-on exercises for IPv4 subnetting

echo "=========================================="
echo "SUBNETTING PRACTICE LAB"
echo "=========================================="
echo ""
echo "This lab provides hands-on practice with IPv4 subnetting concepts."
echo ""

# Function to test subnetting knowledge
test_subnetting() {
    local question="$1"
    local answer="$2"
    local explanation="$3"
    
    echo "Question: $question"
    echo ""
    read -p "Your answer: " user_answer
    echo ""
    
    if [[ "$user_answer" == "$answer" ]]; then
        echo "✅ Correct!"
    else
        echo "❌ Incorrect. The correct answer is: $answer"
    fi
    echo "Explanation: $explanation"
    echo ""
    echo "---"
    echo ""
}

echo "SUBNETTING FUNDAMENTALS"
echo "======================="
echo ""

echo "1. Understanding Subnet Masks"
echo "-----------------------------"
echo "A subnet mask determines which portion of an IP address is the network"
echo "and which portion is the host."
echo ""

echo "Example: 192.168.1.1/24"
echo "  - IP Address: 192.168.1.1"
echo "  - Subnet Mask: 255.255.255.0"
echo "  - Network Portion: 192.168.1"
echo "  - Host Portion: .1"
echo ""

echo "2. CIDR Notation"
echo "----------------"
echo "CIDR (Classless Inter-Domain Routing) uses slash notation to specify"
echo "the number of network bits."
echo ""

echo "Common CIDR notations:"
echo "  /24 = 255.255.255.0 (Class C default)"
echo "  /16 = 255.255.0.0 (Class B default)"
echo "  /8  = 255.0.0.0 (Class A default)"
echo ""

echo "3. Binary Conversion"
echo "-------------------"
echo "Understanding binary is crucial for subnetting."
echo ""

echo "Powers of 2:"
echo "  2^0 = 1    2^4 = 16   2^8 = 256"
echo "  2^1 = 2    2^5 = 32"
echo "  2^2 = 4    2^6 = 64"
echo "  2^3 = 8    2^7 = 128"
echo ""

echo "=========================================="
echo "PRACTICE EXERCISES"
echo "=========================================="
echo ""

# Exercise 1: Basic subnet mask identification
test_subnetting \
    "What is the subnet mask for /24?" \
    "255.255.255.0" \
    "/24 means 24 network bits, so the first 24 bits are 1s and the last 8 bits are 0s. This gives us 255.255.255.0."

# Exercise 2: Network identification
test_subnetting \
    "What is the network address for 192.168.1.100/24?" \
    "192.168.1.0" \
    "With /24, the first 24 bits (192.168.1) are the network portion, and the last 8 bits are the host portion. The network address has all host bits set to 0."

# Exercise 3: Broadcast address
test_subnetting \
    "What is the broadcast address for 192.168.1.0/24?" \
    "192.168.1.255" \
    "The broadcast address has all host bits set to 1. With /24, the host portion is the last 8 bits, so 192.168.1.255."

# Exercise 4: Host range
test_subnetting \
    "What is the usable host range for 192.168.1.0/24?" \
    "192.168.1.1 - 192.168.1.254" \
    "The first usable host is network address + 1, and the last usable host is broadcast address - 1."

# Exercise 5: Number of hosts
test_subnetting \
    "How many usable hosts are in a /24 network?" \
    "254" \
    "A /24 network has 8 host bits, so 2^8 = 256 total addresses. Subtract 2 for network and broadcast addresses = 254 usable hosts."

echo "=========================================="
echo "SUBNETTING SCENARIOS"
echo "=========================================="
echo ""

echo "Scenario 1: Small Office Network"
echo "--------------------------------"
echo "You have the network 192.168.1.0/24 and need to create 4 subnets."
echo ""

echo "Step 1: Calculate the new subnet mask"
echo "  - Need 4 subnets: 2^2 = 4, so we need 2 additional bits"
echo "  - New prefix: 24 + 2 = 26"
echo "  - New subnet mask: 255.255.255.192"
echo ""

echo "Step 2: Calculate subnet ranges"
echo "  - Subnet 1: 192.168.1.0/26 (192.168.1.1 - 192.168.1.62)"
echo "  - Subnet 2: 192.168.1.64/26 (192.168.1.65 - 192.168.1.126)"
echo "  - Subnet 3: 192.168.1.128/26 (192.168.1.129 - 192.168.1.190)"
echo "  - Subnet 4: 192.168.1.192/26 (192.168.1.193 - 192.168.1.254)"
echo ""

echo "Scenario 2: VLSM (Variable Length Subnet Masking)"
echo "------------------------------------------------"
echo "You have 192.168.1.0/24 and need:"
echo "  - 2 subnets with 100 hosts each"
echo "  - 4 subnets with 50 hosts each"
echo "  - 8 subnets with 10 hosts each"
echo ""

echo "Solution:"
echo "  - 100 hosts: Need 2^7 = 128 addresses, so /25 (255.255.255.128)"
echo "  - 50 hosts: Need 2^6 = 64 addresses, so /26 (255.255.255.192)"
echo "  - 10 hosts: Need 2^4 = 16 addresses, so /28 (255.255.255.240)"
echo ""

echo "=========================================="
echo "HANDS-ON EXERCISES"
echo "=========================================="
echo ""

echo "Exercise 1: Analyze your current network"
echo "---------------------------------------"
echo "Run these commands to analyze your current network configuration:"
echo ""
echo "  # Check your IP address and subnet mask"
echo "  ip addr show"
echo "  ifconfig"
echo ""
echo "  # Use the IPv4 calculator to analyze your network"
echo "  python3 ipv4-calculator.py \$(ip route | grep default | awk '{print \$3}')/24"
echo ""

echo "Exercise 2: Practice subnetting calculations"
echo "-------------------------------------------"
echo "Try these subnetting problems:"
echo ""
echo "1. Given: 10.0.0.0/8, create 8 subnets"
echo "   Answer: Use /11 (255.248.0.0)"
echo ""
echo "2. Given: 172.16.0.0/16, create 16 subnets"
echo "   Answer: Use /20 (255.255.240.0)"
echo ""
echo "3. Given: 192.168.1.0/24, create 32 subnets"
echo "   Answer: Use /29 (255.255.255.248)"
echo ""

echo "Exercise 3: VLSM practice"
echo "------------------------"
echo "Given: 192.168.1.0/24, create subnets for:"
echo "  - 2 subnets with 100 hosts each"
echo "  - 4 subnets with 50 hosts each"
echo "  - 8 subnets with 10 hosts each"
echo ""
echo "Use the VLSM calculator:"
echo "  python3 ipv4-calculator.py --vlsm 100 100 50 50 50 50 10 10 10 10 10 10 10 10 192.168.1.0/24"
echo ""

echo "=========================================="
echo "COMMON SUBNET MASK REFERENCE"
echo "=========================================="
echo ""

echo "CIDR | Subnet Mask        | Hosts | Networks"
echo "-----|--------------------|-------|---------"
echo "/24 | 255.255.255.0      | 254   | 1"
echo "/25 | 255.255.255.128    | 126   | 2"
echo "/26 | 255.255.255.192    | 62    | 4"
echo "/27 | 255.255.255.224    | 30    | 8"
echo "/28 | 255.255.255.240    | 14    | 16"
echo "/29 | 255.255.255.248    | 6     | 32"
echo "/30 | 255.255.255.252    | 2     | 64"
echo ""

echo "=========================================="
echo "TROUBLESHOOTING TIPS"
echo "=========================================="
echo ""

echo "Common subnetting mistakes:"
echo "1. Forgetting to subtract 2 for network and broadcast addresses"
echo "2. Not understanding binary conversion"
echo "3. Confusing network bits with host bits"
echo "4. Not considering future growth"
echo ""

echo "Tips for success:"
echo "1. Practice binary conversion regularly"
echo "2. Use the powers of 2 table"
echo "3. Always verify your calculations"
echo "4. Consider using subnetting calculators for complex scenarios"
echo "5. Practice with real-world scenarios"
echo ""

echo "=========================================="
echo "ADVANCED EXERCISES"
echo "=========================================="
echo ""

echo "Exercise 4: Supernetting"
echo "------------------------"
echo "Combine these networks into a supernet:"
echo "  192.168.1.0/24"
echo "  192.168.2.0/24"
echo "  192.168.3.0/24"
echo "  192.168.4.0/24"
echo ""
echo "Answer: 192.168.0.0/22"
echo ""

echo "Exercise 5: Route summarization"
echo "------------------------------"
echo "Summarize these routes:"
echo "  10.1.0.0/16"
echo "  10.2.0.0/16"
echo "  10.3.0.0/16"
echo "  10.4.0.0/16"
echo ""
echo "Answer: 10.0.0.0/14"
echo ""

echo "Exercise 6: Complex VLSM"
echo "-----------------------"
echo "Given: 10.0.0.0/16, create subnets for:"
echo "  - 1 subnet with 1000 hosts"
echo "  - 2 subnets with 500 hosts each"
echo "  - 4 subnets with 250 hosts each"
echo "  - 8 subnets with 100 hosts each"
echo ""
echo "Use the VLSM calculator to solve this:"
echo "  python3 ipv4-calculator.py --vlsm 1000 500 500 250 250 250 250 100 100 100 100 100 100 100 100 10.0.0.0/16"
echo ""

echo "Lab completed! You should now have a better understanding of IPv4 subnetting."
echo "Continue practicing with the calculator and real-world scenarios."
