#!/bin/bash
"""
TCP/UDP Troubleshooting Guide
Comprehensive troubleshooting guide for TCP and UDP protocol issues.
"""

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 TCP/UDP Troubleshooting Guide${NC}"
echo "======================================"
echo "This guide helps diagnose and resolve TCP/UDP protocol issues"
echo ""

# Function to print section headers
print_section() {
    echo -e "\n${YELLOW}📋 $1${NC}"
    echo "----------------------------------------"
}

# Function to print troubleshooting steps
print_step() {
    echo -e "\n${GREEN}🔍 Step $1: $2${NC}"
    echo "----------------------------------------"
}

# Function to print diagnostic commands
print_command() {
    echo -e "${BLUE}Command: $1${NC}"
    echo "Description: $2"
    echo ""
}

# Function to check if command exists
check_command() {
    if command -v "$1" &> /dev/null; then
        echo -e "${GREEN}✅ $1${NC}"
        return 0
    else
        echo -e "${RED}❌ $1${NC}"
        return 1
    fi
}

# Prerequisites Check
print_section "Prerequisites Check"
echo "Required tools for troubleshooting:"
required_tools=("netstat" "ss" "tcpdump" "nc" "ping" "traceroute" "dig" "nslookup")
for tool in "${required_tools[@]}"; do
    check_command "$tool"
done

# TCP Troubleshooting
print_section "TCP Troubleshooting"

print_step "1" "Check TCP Connection Status"
print_command "netstat -tuln" "View all TCP connections and listening ports"
print_command "ss -tuln" "Modern alternative to netstat for TCP connections"
print_command "ss -tuln state established" "View only established TCP connections"
print_command "ss -tuln state listening" "View only listening TCP ports"

print_step "2" "Analyze TCP Connection Issues"
print_command "ss -tuln | grep :PORT" "Check specific port status"
print_command "lsof -i :PORT" "Find process using specific port"
print_command "netstat -tuln | grep :PORT" "Alternative port check method"

print_step "3" "Monitor TCP Traffic"
print_command "tcpdump -i any -n tcp" "Capture all TCP traffic"
print_command "tcpdump -i any -n tcp port PORT" "Capture TCP traffic for specific port"
print_command "tcpdump -i any -n 'tcp and host HOST'" "Capture TCP traffic to/from specific host"

print_step "4" "Test TCP Connectivity"
print_command "nc -v HOST PORT" "Test TCP connection to host:port"
print_command "telnet HOST PORT" "Test TCP connection with telnet"
print_command "curl -v http://HOST:PORT" "Test HTTP connection"
print_command "ping HOST" "Test basic connectivity"

print_step "5" "Analyze TCP Performance"
print_command "ss -s" "View TCP connection statistics"
print_command "cat /proc/net/tcp" "View detailed TCP connection table"
print_command "cat /proc/net/netstat | grep Tcp" "View TCP statistics"
print_command "netstat -i" "View network interface statistics"

# UDP Troubleshooting
print_section "UDP Troubleshooting"

print_step "1" "Check UDP Connection Status"
print_command "netstat -uln" "View all UDP connections and listening ports"
print_command "ss -uln" "Modern alternative to netstat for UDP connections"
print_command "ss -u" "View UDP socket information"

print_step "2" "Analyze UDP Service Issues"
print_command "dig @SERVER DOMAIN" "Test DNS service (UDP port 53)"
print_command "nslookup DOMAIN SERVER" "Alternative DNS test"
print_command "nc -u HOST PORT" "Test UDP connection to host:port"
print_command "nc -u -v HOST PORT" "Test UDP connection with verbose output"

print_step "3" "Monitor UDP Traffic"
print_command "tcpdump -i any -n udp" "Capture all UDP traffic"
print_command "tcpdump -i any -n udp port PORT" "Capture UDP traffic for specific port"
print_command "tcpdump -i any -n 'udp and host HOST'" "Capture UDP traffic to/from specific host"

print_step "4" "Test UDP Services"
print_command "dig @8.8.8.8 google.com" "Test DNS resolution"
print_command "nc -u pool.ntp.org 123" "Test NTP service"
print_command "nc -u localhost 67" "Test DHCP service"
print_command "nc -u localhost 161" "Test SNMP service"

print_step "5" "Analyze UDP Performance"
print_command "ss -s" "View UDP connection statistics"
print_command "cat /proc/net/udp" "View detailed UDP connection table"
print_command "cat /proc/net/netstat | grep Udp" "View UDP statistics"
print_command "netstat -su" "View UDP statistics"

# Common Issues and Solutions
print_section "Common Issues and Solutions"

print_step "1" "Connection Refused"
echo "Symptoms: 'Connection refused' error"
echo "Causes:"
echo "  • Service not running"
echo "  • Port not listening"
echo "  • Firewall blocking connection"
echo "Solutions:"
echo "  • Check if service is running: systemctl status SERVICE"
echo "  • Check listening ports: ss -tuln | grep :PORT"
echo "  • Check firewall rules: iptables -L"
echo "  • Start service if needed: systemctl start SERVICE"

print_step "2" "Connection Timeout"
echo "Symptoms: Connection hangs or times out"
echo "Causes:"
echo "  • Network connectivity issues"
echo "  • Firewall blocking traffic"
echo "  • Routing problems"
echo "Solutions:"
echo "  • Test basic connectivity: ping HOST"
echo "  • Check routing: traceroute HOST"
echo "  • Check firewall: iptables -L"
echo "  • Check network interface: ip link show"

print_step "3" "Slow Performance"
echo "Symptoms: Slow data transfer or high latency"
echo "Causes:"
echo "  • Network congestion"
echo "  • High CPU usage"
echo "  • Memory issues"
echo "  • TCP window size problems"
echo "Solutions:"
echo "  • Monitor network usage: iftop"
echo "  • Check system resources: top, htop"
echo "  • Check TCP statistics: ss -s"
echo "  • Optimize TCP parameters"

print_step "4" "Packet Loss"
echo "Symptoms: Data loss or retransmissions"
echo "Causes:"
echo "  • Network congestion"
echo "  • Hardware issues"
echo "  • MTU problems"
echo "Solutions:"
echo "  • Check packet loss: ping -c 100 HOST"
echo "  • Check MTU: ping -M do -s 1472 HOST"
echo "  • Monitor network errors: netstat -i"
echo "  • Check hardware: ethtool INTERFACE"

print_step "5" "DNS Resolution Issues"
echo "Symptoms: Cannot resolve domain names"
echo "Causes:"
echo "  • DNS server unreachable"
echo "  • Incorrect DNS configuration"
echo "  • DNS server issues"
echo "Solutions:"
echo "  • Test DNS server: dig @SERVER DOMAIN"
echo "  • Check DNS configuration: cat /etc/resolv.conf"
echo "  • Test different DNS server: dig @8.8.8.8 DOMAIN"
echo "  • Check DNS service: systemctl status systemd-resolved"

# Advanced Troubleshooting
print_section "Advanced Troubleshooting"

print_step "1" "TCP Handshake Analysis"
print_command "tcpdump -i any -n 'tcp[tcpflags] & (tcp-syn|tcp-ack) != 0'" "Capture TCP handshake packets"
print_command "tcpdump -i any -n 'tcp[tcpflags] & tcp-syn != 0'" "Capture SYN packets"
print_command "tcpdump -i any -n 'tcp[tcpflags] & tcp-fin != 0'" "Capture FIN packets"

print_step "2" "UDP Service Discovery"
print_command "nmap -sU HOST" "UDP port scan"
print_command "nc -u -z HOST PORT" "Test UDP port"
print_command "dig @HOST DOMAIN" "Test DNS service"

print_step "3" "Network Interface Analysis"
print_command "ip link show" "View network interfaces"
print_command "ip addr show" "View IP addresses"
print_command "ip route show" "View routing table"
print_command "ethtool INTERFACE" "View interface statistics"

print_step "4" "System Resource Analysis"
print_command "top" "View system processes"
print_command "htop" "Enhanced process viewer"
print_command "iostat" "View I/O statistics"
print_command "vmstat" "View virtual memory statistics"

print_step "5" "Log Analysis"
print_command "journalctl -u SERVICE" "View service logs"
print_command "tail -f /var/log/syslog" "Monitor system logs"
print_command "dmesg | grep -i network" "View kernel network messages"
print_command "tail -f /var/log/kern.log" "Monitor kernel logs"

# Troubleshooting Checklist
print_section "Troubleshooting Checklist"

echo "Before starting troubleshooting:"
echo "✅ Identify the problem (connection, performance, service)"
echo "✅ Gather error messages and symptoms"
echo "✅ Check if the issue is reproducible"
echo "✅ Identify affected systems and services"
echo ""

echo "Basic troubleshooting steps:"
echo "✅ Check service status"
echo "✅ Verify network connectivity"
echo "✅ Check listening ports"
echo "✅ Test with different tools"
echo "✅ Check system resources"
echo "✅ Review logs"
echo ""

echo "Advanced troubleshooting steps:"
echo "✅ Capture network traffic"
echo "✅ Analyze packet contents"
echo "✅ Check routing and DNS"
echo "✅ Verify firewall rules"
echo "✅ Test with different hosts"
echo "✅ Check hardware status"
echo ""

# Quick Reference
print_section "Quick Reference"

echo "Essential Commands:"
echo "• netstat -tuln          # View all connections"
echo "• ss -tuln              # Modern connection viewer"
echo "• tcpdump -i any -n     # Capture network traffic"
echo "• nc -v HOST PORT       # Test TCP connection"
echo "• nc -u HOST PORT       # Test UDP connection"
echo "• ping HOST             # Test connectivity"
echo "• traceroute HOST       # Trace network path"
echo "• dig @SERVER DOMAIN    # Test DNS"
echo ""

echo "Common Ports:"
echo "• TCP 22  - SSH"
echo "• TCP 80  - HTTP"
echo "• TCP 443 - HTTPS"
echo "• UDP 53  - DNS"
echo "• UDP 67  - DHCP Server"
echo "• UDP 68  - DHCP Client"
echo "• UDP 123 - NTP"
echo "• UDP 161 - SNMP"
echo ""

echo "Useful Files:"
echo "• /proc/net/tcp         # TCP connection table"
echo "• /proc/net/udp         # UDP connection table"
echo "• /proc/net/netstat     # Network statistics"
echo "• /etc/resolv.conf      # DNS configuration"
echo "• /etc/hosts            # Host file"
echo ""

echo -e "${GREEN}🎉 Troubleshooting guide complete!${NC}"
echo "Use this guide to systematically diagnose and resolve TCP/UDP issues."
echo "Remember to document your findings and solutions for future reference."
