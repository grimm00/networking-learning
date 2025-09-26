#!/bin/bash
# netstat-ss-troubleshoot.sh
# Network Analysis Troubleshooting Guide

echo "Network Analysis Troubleshooting Guide"
echo "====================================="

# Function to check if command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo "❌ $1 is not installed"
        return 1
    else
        echo "✅ $1 is available"
        return 0
    fi
}

# Function to check network connectivity
check_connectivity() {
    echo -e "\n=== Network Connectivity Check ==="
    
    # Check if we can resolve DNS
    if nslookup google.com &> /dev/null; then
        echo "✅ DNS resolution working"
    else
        echo "❌ DNS resolution failed"
    fi
    
    # Check if we can ping external host
    if ping -c 1 8.8.8.8 &> /dev/null; then
        echo "✅ External connectivity working"
    else
        echo "❌ External connectivity failed"
    fi
    
    # Check local connectivity
    if ping -c 1 127.0.0.1 &> /dev/null; then
        echo "✅ Local connectivity working"
    else
        echo "❌ Local connectivity failed"
    fi
}

# Function to check listening ports
check_listening_ports() {
    echo -e "\n=== Listening Ports Check ==="
    
    echo "TCP Listening Ports:"
    ss -tuln | grep LISTEN | head -10
    
    echo -e "\nUDP Listening Ports:"
    ss -uln | grep UNCONN | head -10
    
    echo -e "\nProcesses using ports:"
    ss -tunap | grep LISTEN | head -10
}

# Function to check connection states
check_connection_states() {
    echo -e "\n=== Connection States Analysis ==="
    
    echo "Connection States Summary:"
    ss -tuna | awk '{print $1}' | sort | uniq -c | sort -nr
    
    echo -e "\nEstablished Connections:"
    ss -tuna state established | wc -l
    
    echo -e "\nTIME-WAIT Connections:"
    ss -tuna state time-wait | wc -l
    
    echo -e "\nSYN-SENT Connections:"
    ss -tuna state syn-sent | wc -l
}

# Function to check for port conflicts
check_port_conflicts() {
    echo -e "\n=== Port Conflict Check ==="
    
    echo "Checking for duplicate listening ports..."
    
    # Get all listening ports
    ss -tuln | grep LISTEN | awk '{print $4}' | cut -d: -f2 | sort | uniq -d
    
    if [ $? -eq 0 ]; then
        echo "❌ Found duplicate listening ports"
    else
        echo "✅ No duplicate listening ports found"
    fi
}

# Function to check for high connection counts
check_connection_counts() {
    echo -e "\n=== Connection Count Analysis ==="
    
    total_connections=$(ss -tuna | wc -l)
    echo "Total connections: $total_connections"
    
    if [ $total_connections -gt 1000 ]; then
        echo "⚠️  High connection count detected"
        echo "   This may indicate connection leaks or high traffic"
    else
        echo "✅ Connection count is normal"
    fi
    
    # Check TIME-WAIT connections
    timewait_count=$(ss -tuna state time-wait | wc -l)
    echo "TIME-WAIT connections: $timewait_count"
    
    if [ $timewait_count -gt 100 ]; then
        echo "⚠️  High TIME-WAIT count detected"
        echo "   This may indicate connection churn or leaks"
    else
        echo "✅ TIME-WAIT count is normal"
    fi
}

# Function to check for suspicious connections
check_suspicious_connections() {
    echo -e "\n=== Security Analysis ==="
    
    echo "External connections (excluding localhost):"
    ss -tuna | grep -v 127.0.0.1 | grep -v 192.168 | head -10
    
    echo -e "\nUnusual listening ports (excluding common ones):"
    ss -tuln | grep -v -E ":(22|80|443|53|25|110|143|993|995|21|23|69|123|161|162|389|636|993|995|1433|3306|5432|6379|11211|27017)" | head -10
    
    echo -e "\nSYN-SENT connections (connection attempts):"
    ss -tuna state syn-sent | head -10
}

# Function to check network statistics
check_network_stats() {
    echo -e "\n=== Network Statistics ==="
    
    echo "Summary Statistics:"
    ss -s
    
    echo -e "\nInterface Statistics:"
    netstat -i 2>/dev/null || echo "netstat not available"
    
    echo -e "\nProtocol Statistics:"
    netstat -s 2>/dev/null | head -20 || echo "netstat not available"
}

# Function to check for common issues
check_common_issues() {
    echo -e "\n=== Common Issues Check ==="
    
    # Check for zombie processes
    zombie_count=$(ps aux | grep -c '<defunct>')
    if [ $zombie_count -gt 0 ]; then
        echo "⚠️  Found $zombie_count zombie processes"
    else
        echo "✅ No zombie processes found"
    fi
    
    # Check for processes with high file descriptor usage
    echo -e "\nProcesses with high file descriptor usage:"
    lsof 2>/dev/null | awk '{print $2}' | sort | uniq -c | sort -nr | head -5 || echo "lsof not available"
    
    # Check system load
    echo -e "\nSystem Load:"
    uptime
}

# Function to provide troubleshooting recommendations
provide_recommendations() {
    echo -e "\n=== Troubleshooting Recommendations ==="
    
    echo "1. High Connection Count:"
    echo "   - Check for connection leaks in applications"
    echo "   - Adjust TCP timeout settings"
    echo "   - Implement connection pooling"
    
    echo -e "\n2. Port Conflicts:"
    echo "   - Kill processes using conflicting ports"
    echo "   - Change port numbers in configuration"
    echo "   - Use SO_REUSEADDR socket option"
    
    echo -e "\n3. High TIME-WAIT Count:"
    echo "   - Adjust TCP timeout settings"
    echo "   - Enable TCP timestamp options"
    echo "   - Check for connection churn"
    
    echo -e "\n4. Suspicious Connections:"
    echo "   - Review firewall rules"
    echo "   - Check for malware or unauthorized access"
    echo "   - Monitor connection patterns"
    
    echo -e "\n5. Performance Issues:"
    echo "   - Check network interface statistics"
    echo "   - Monitor system resources"
    echo "   - Optimize application settings"
}

# Function to generate diagnostic report
generate_report() {
    echo -e "\n=== Generating Diagnostic Report ==="
    
    report_file="/tmp/network_diagnostic_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "Network Diagnostic Report"
        echo "Generated: $(date)"
        echo "======================================"
        
        echo -e "\n=== System Information ==="
        uname -a
        cat /etc/os-release 2>/dev/null || echo "OS release info not available"
        
        echo -e "\n=== Network Interfaces ==="
        ip addr show 2>/dev/null || ifconfig 2>/dev/null || echo "Network interface info not available"
        
        echo -e "\n=== Routing Table ==="
        ip route show 2>/dev/null || route -n 2>/dev/null || echo "Routing table not available"
        
        echo -e "\n=== Listening Ports ==="
        ss -tuln
        
        echo -e "\n=== Active Connections ==="
        ss -tuna
        
        echo -e "\n=== Connection States ==="
        ss -tuna | awk '{print $1}' | sort | uniq -c | sort -nr
        
        echo -e "\n=== Network Statistics ==="
        ss -s
        
    } > "$report_file"
    
    echo "Diagnostic report saved to: $report_file"
}

# Main troubleshooting function
main() {
    echo "Starting network analysis troubleshooting..."
    echo "=========================================="
    
    # Check if required commands are available
    echo "=== Command Availability Check ==="
    check_command "ss"
    check_command "netstat"
    check_command "ping"
    check_command "nslookup"
    
    # Run all checks
    check_connectivity
    check_listening_ports
    check_connection_states
    check_port_conflicts
    check_connection_counts
    check_suspicious_connections
    check_network_stats
    check_common_issues
    
    # Provide recommendations
    provide_recommendations
    
    # Generate report
    generate_report
    
    echo -e "\n✅ Troubleshooting analysis complete!"
    echo "Review the output above for any issues or warnings."
}

# Run main function
main "$@"
