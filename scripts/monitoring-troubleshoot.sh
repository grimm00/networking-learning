#!/bin/bash
# Monitoring Troubleshooting Guide
# Comprehensive troubleshooting and diagnostic tools for monitoring systems

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

print_step() {
    echo -e "${CYAN}→ $1${NC}"
}

# Function to check if running in container
check_container() {
    if [ -f /.dockerenv ] || [ -n "${DOCKER_CONTAINER:-}" ]; then
        return 0
    else
        return 1
    fi
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to run command with timeout
run_with_timeout() {
    local timeout=$1
    shift
    timeout "$timeout" "$@" 2>/dev/null || return 1
}

# Troubleshooting: Prometheus Issues
troubleshoot_prometheus() {
    print_header "Prometheus Troubleshooting"
    
    print_step "Checking Prometheus status..."
    if systemctl is-active prometheus >/dev/null 2>&1; then
        print_status "Prometheus is running"
    else
        print_error "Prometheus is not running"
        
        print_step "Checking Prometheus configuration..."
        if promtool check config /etc/prometheus/prometheus.yml 2>&1 | grep -q "SUCCESS"; then
            print_status "Prometheus configuration is valid"
            print_step "Attempting to start Prometheus..."
            systemctl start prometheus
            if systemctl is-active prometheus >/dev/null 2>&1; then
                print_status "Prometheus started successfully"
            else
                print_error "Failed to start Prometheus"
                print_step "Checking Prometheus error logs..."
                journalctl -u prometheus --no-pager -n 20
            fi
        else
            print_error "Prometheus configuration has errors"
            promtool check config /etc/prometheus/prometheus.yml
        fi
    fi
    
    print_step "Checking Prometheus targets..."
    if command_exists curl; then
        local targets_response=$(run_with_timeout 10 curl -s http://localhost:9090/api/v1/targets 2>/dev/null)
        if [ -n "$targets_response" ]; then
            print_status "Prometheus targets accessible"
            echo "$targets_response" | jq -r '.data.activeTargets[] | "\(.labels.job): \(.health)"' 2>/dev/null || echo "$targets_response"
        else
            print_error "Prometheus targets not accessible"
        fi
    fi
    
    print_step "Checking Prometheus metrics..."
    if command_exists curl; then
        local metrics_response=$(run_with_timeout 10 curl -s http://localhost:9090/api/v1/query?query=up 2>/dev/null)
        if [ -n "$metrics_response" ]; then
            print_status "Prometheus metrics accessible"
        else
            print_error "Prometheus metrics not accessible"
        fi
    fi
    
    print_step "Checking Prometheus storage..."
    if [ -d "/var/lib/prometheus" ]; then
        local storage_size=$(du -sh /var/lib/prometheus 2>/dev/null | cut -f1)
        print_status "Prometheus storage size: $storage_size"
        
        local wal_files=$(find /var/lib/prometheus -name "*.wal" | wc -l)
        print_status "WAL files: $wal_files"
    else
        print_warning "Prometheus storage directory not found"
    fi
}

# Troubleshooting: Grafana Issues
troubleshoot_grafana() {
    print_header "Grafana Troubleshooting"
    
    print_step "Checking Grafana status..."
    if systemctl is-active grafana-server >/dev/null 2>&1; then
        print_status "Grafana is running"
    else
        print_error "Grafana is not running"
        
        print_step "Attempting to start Grafana..."
        systemctl start grafana-server
        if systemctl is-active grafana-server >/dev/null 2>&1; then
            print_status "Grafana started successfully"
        else
            print_error "Failed to start Grafana"
            print_step "Checking Grafana error logs..."
            journalctl -u grafana-server --no-pager -n 20
        fi
    fi
    
    print_step "Checking Grafana API..."
    if command_exists curl; then
        local health_response=$(run_with_timeout 10 curl -s http://localhost:3000/api/health 2>/dev/null)
        if [ -n "$health_response" ]; then
            print_status "Grafana API accessible"
            echo "$health_response" | jq '.' 2>/dev/null || echo "$health_response"
        else
            print_error "Grafana API not accessible"
        fi
    fi
    
    print_step "Checking Grafana data sources..."
    if command_exists curl; then
        local datasources_response=$(run_with_timeout 10 curl -s -u admin:admin http://localhost:3000/api/datasources 2>/dev/null)
        if [ -n "$datasources_response" ]; then
            print_status "Grafana data sources accessible"
            echo "$datasources_response" | jq -r '.[] | "\(.name): \(.type)"' 2>/dev/null || echo "$datasources_response"
        else
            print_error "Grafana data sources not accessible"
        fi
    fi
    
    print_step "Checking Grafana dashboards..."
    if command_exists curl; then
        local dashboards_response=$(run_with_timeout 10 curl -s -u admin:admin http://localhost:3000/api/search?type=dash-db 2>/dev/null)
        if [ -n "$dashboards_response" ]; then
            print_status "Grafana dashboards accessible"
            echo "$dashboards_response" | jq -r '.[] | "\(.title): \(.type)"' 2>/dev/null || echo "$dashboards_response"
        else
            print_error "Grafana dashboards not accessible"
        fi
    fi
    
    print_step "Checking Grafana configuration..."
    if [ -f "/etc/grafana/grafana.ini" ]; then
        print_status "Grafana configuration file found"
        
        local http_port=$(grep "^http_port" /etc/grafana/grafana.ini | cut -d'=' -f2 | tr -d ' ')
        if [ -n "$http_port" ]; then
            print_status "Grafana HTTP port: $http_port"
        fi
        
        local admin_user=$(grep "^admin_user" /etc/grafana/grafana.ini | cut -d'=' -f2 | tr -d ' ')
        if [ -n "$admin_user" ]; then
            print_status "Grafana admin user: $admin_user"
        fi
    else
        print_warning "Grafana configuration file not found"
    fi
}

# Troubleshooting: ELK Stack Issues
troubleshoot_elk_stack() {
    print_header "ELK Stack Troubleshooting"
    
    # Check Elasticsearch
    print_step "Checking Elasticsearch status..."
    if systemctl is-active elasticsearch >/dev/null 2>&1; then
        print_status "Elasticsearch is running"
    else
        print_error "Elasticsearch is not running"
        
        print_step "Attempting to start Elasticsearch..."
        systemctl start elasticsearch
        if systemctl is-active elasticsearch >/dev/null 2>&1; then
            print_status "Elasticsearch started successfully"
        else
            print_error "Failed to start Elasticsearch"
            print_step "Checking Elasticsearch error logs..."
            journalctl -u elasticsearch --no-pager -n 20
        fi
    fi
    
    print_step "Checking Elasticsearch cluster health..."
    if command_exists curl; then
        local health_response=$(run_with_timeout 10 curl -s http://localhost:9200/_cluster/health 2>/dev/null)
        if [ -n "$health_response" ]; then
            print_status "Elasticsearch cluster health:"
            echo "$health_response" | jq '.' 2>/dev/null || echo "$health_response"
        else
            print_error "Elasticsearch cluster health not accessible"
        fi
    fi
    
    # Check Logstash
    print_step "Checking Logstash status..."
    if systemctl is-active logstash >/dev/null 2>&1; then
        print_status "Logstash is running"
    else
        print_error "Logstash is not running"
        
        print_step "Attempting to start Logstash..."
        systemctl start logstash
        if systemctl is-active logstash >/dev/null 2>&1; then
            print_status "Logstash started successfully"
        else
            print_error "Failed to start Logstash"
            print_step "Checking Logstash error logs..."
            journalctl -u logstash --no-pager -n 20
        fi
    fi
    
    # Check Kibana
    print_step "Checking Kibana status..."
    if systemctl is-active kibana >/dev/null 2>&1; then
        print_status "Kibana is running"
    else
        print_error "Kibana is not running"
        
        print_step "Attempting to start Kibana..."
        systemctl start kibana
        if systemctl is-active kibana >/dev/null 2>&1; then
            print_status "Kibana started successfully"
        else
            print_error "Failed to start Kibana"
            print_step "Checking Kibana error logs..."
            journalctl -u kibana --no-pager -n 20
        fi
    fi
    
    print_step "Checking Kibana API..."
    if command_exists curl; then
        local kibana_response=$(run_with_timeout 10 curl -s http://localhost:5601/api/status 2>/dev/null)
        if [ -n "$kibana_response" ]; then
            print_status "Kibana API accessible"
        else
            print_error "Kibana API not accessible"
        fi
    fi
}

# Troubleshooting: Alerting Issues
troubleshoot_alerting() {
    print_header "Alerting System Troubleshooting"
    
    # Check Alertmanager
    print_step "Checking Alertmanager status..."
    if systemctl is-active alertmanager >/dev/null 2>&1; then
        print_status "Alertmanager is running"
    else
        print_error "Alertmanager is not running"
        
        print_step "Attempting to start Alertmanager..."
        systemctl start alertmanager
        if systemctl is-active alertmanager >/dev/null 2>&1; then
            print_status "Alertmanager started successfully"
        else
            print_error "Failed to start Alertmanager"
            print_step "Checking Alertmanager error logs..."
            journalctl -u alertmanager --no-pager -n 20
        fi
    fi
    
    print_step "Checking Alertmanager API..."
    if command_exists curl; then
        local status_response=$(run_with_timeout 10 curl -s http://localhost:9093/api/v1/status 2>/dev/null)
        if [ -n "$status_response" ]; then
            print_status "Alertmanager API accessible"
            echo "$status_response" | jq '.' 2>/dev/null || echo "$status_response"
        else
            print_error "Alertmanager API not accessible"
        fi
    fi
    
    print_step "Checking Alertmanager configuration..."
    if [ -f "/etc/alertmanager/alertmanager.yml" ]; then
        print_status "Alertmanager configuration file found"
        
        # Check for common configuration issues
        if grep -q "smtp_smarthost" /etc/alertmanager/alertmanager.yml; then
            print_status "SMTP configuration found"
        else
            print_warning "No SMTP configuration found"
        fi
        
        if grep -q "webhook" /etc/alertmanager/alertmanager.yml; then
            print_status "Webhook configuration found"
        else
            print_warning "No webhook configuration found"
        fi
    else
        print_warning "Alertmanager configuration file not found"
    fi
    
    print_step "Checking Prometheus alert rules..."
    if [ -f "/etc/prometheus/alert_rules.yml" ]; then
        print_status "Prometheus alert rules file found"
        
        local alert_count=$(grep -c "alert:" /etc/prometheus/alert_rules.yml)
        print_status "Alert rules count: $alert_count"
        
        # Check for common alert rule issues
        if grep -q "expr:" /etc/prometheus/alert_rules.yml; then
            print_status "Alert expressions found"
        else
            print_warning "No alert expressions found"
        fi
        
        if grep -q "for:" /etc/prometheus/alert_rules.yml; then
            print_status "Alert durations found"
        else
            print_warning "No alert durations found"
        fi
    else
        print_warning "Prometheus alert rules file not found"
    fi
}

# Troubleshooting: Metrics Collection Issues
troubleshoot_metrics_collection() {
    print_header "Metrics Collection Troubleshooting"
    
    print_step "Checking Node Exporter status..."
    if systemctl is-active node_exporter >/dev/null 2>&1; then
        print_status "Node Exporter is running"
    else
        print_error "Node Exporter is not running"
        
        print_step "Attempting to start Node Exporter..."
        systemctl start node_exporter
        if systemctl is-active node_exporter >/dev/null 2>&1; then
            print_status "Node Exporter started successfully"
        else
            print_error "Failed to start Node Exporter"
            print_step "Checking Node Exporter error logs..."
            journalctl -u node_exporter --no-pager -n 20
        fi
    fi
    
    print_step "Checking Node Exporter metrics..."
    if command_exists curl; then
        local metrics_response=$(run_with_timeout 10 curl -s http://localhost:9100/metrics 2>/dev/null)
        if [ -n "$metrics_response" ]; then
            print_status "Node Exporter metrics accessible"
            
            local metric_count=$(echo "$metrics_response" | grep -c "^[^#]")
            print_status "Metrics count: $metric_count"
            
            # Check for key metrics
            local key_metrics=("node_cpu_seconds_total" "node_memory_MemTotal_bytes" "node_filesystem_size_bytes")
            for metric in "${key_metrics[@]}"; do
                if echo "$metrics_response" | grep -q "^$metric"; then
                    print_status "✅ $metric found"
                else
                    print_warning "❌ $metric not found"
                fi
            done
        else
            print_error "Node Exporter metrics not accessible"
        fi
    fi
    
    print_step "Checking custom metrics applications..."
    local custom_metrics_ports=(8000 8001 8002)
    for port in "${custom_metrics_ports[@]}"; do
        if command_exists curl; then
            local response=$(run_with_timeout 5 curl -s http://localhost:$port/metrics 2>/dev/null)
            if [ -n "$response" ]; then
                print_status "Custom metrics found on port $port"
            else
                print_warning "No custom metrics on port $port"
            fi
        fi
    done
    
    print_step "Checking Prometheus scrape targets..."
    if command_exists curl; then
        local targets_response=$(run_with_timeout 10 curl -s http://localhost:9090/api/v1/targets 2>/dev/null)
        if [ -n "$targets_response" ]; then
            print_status "Prometheus targets:"
            echo "$targets_response" | jq -r '.data.activeTargets[] | "\(.labels.job): \(.health) - \(.scrapeUrl)"' 2>/dev/null || echo "$targets_response"
        else
            print_error "Prometheus targets not accessible"
        fi
    fi
}

# Troubleshooting: Dashboard Issues
troubleshoot_dashboards() {
    print_header "Dashboard Troubleshooting"
    
    print_step "Checking Grafana dashboard accessibility..."
    if command_exists curl; then
        local dashboards_response=$(run_with_timeout 10 curl -s -u admin:admin http://localhost:3000/api/search?type=dash-db 2>/dev/null)
        if [ -n "$dashboards_response" ]; then
            print_status "Grafana dashboards accessible"
            
            local dashboard_count=$(echo "$dashboards_response" | jq length 2>/dev/null || echo "0")
            print_status "Dashboard count: $dashboard_count"
            
            # Check dashboard health
            local healthy_dashboards=0
            for dashboard in $(echo "$dashboards_response" | jq -r '.[].uid' 2>/dev/null); do
                if [ -n "$dashboard" ] && [ "$dashboard" != "null" ]; then
                    local db_response=$(run_with_timeout 5 curl -s -u admin:admin http://localhost:3000/api/dashboards/uid/$dashboard 2>/dev/null)
                    if [ -n "$db_response" ]; then
                        healthy_dashboards=$((healthy_dashboards + 1))
                    fi
                fi
            done
            
            print_status "Healthy dashboards: $healthy_dashboards/$dashboard_count"
        else
            print_error "Grafana dashboards not accessible"
        fi
    fi
    
    print_step "Checking data source connectivity..."
    if command_exists curl; then
        local datasources_response=$(run_with_timeout 10 curl -s -u admin:admin http://localhost:3000/api/datasources 2>/dev/null)
        if [ -n "$datasources_response" ]; then
            print_status "Data sources:"
            echo "$datasources_response" | jq -r '.[] | "\(.name): \(.type)"' 2>/dev/null || echo "$datasources_response"
            
            # Test data source connectivity
            for ds in $(echo "$datasources_response" | jq -r '.[].id' 2>/dev/null); do
                if [ -n "$ds" ] && [ "$ds" != "null" ]; then
                    local health_response=$(run_with_timeout 5 curl -s -u admin:admin http://localhost:3000/api/datasources/$ds/health 2>/dev/null)
                    if [ -n "$health_response" ]; then
                        print_status "✅ Data source $ds is healthy"
                    else
                        print_warning "❌ Data source $ds is not healthy"
                    fi
                fi
            done
        else
            print_error "Data sources not accessible"
        fi
    fi
    
    print_step "Checking dashboard queries..."
    if command_exists curl; then
        local query_response=$(run_with_timeout 10 curl -s "http://localhost:9090/api/v1/query?query=up" 2>/dev/null)
        if [ -n "$query_response" ]; then
            print_status "Prometheus queries working"
            
            local result_count=$(echo "$query_response" | jq '.data.result | length' 2>/dev/null || echo "0")
            print_status "Query results: $result_count"
        else
            print_error "Prometheus queries not working"
        fi
    fi
}

# Troubleshooting: Performance Issues
troubleshoot_performance() {
    print_header "Performance Troubleshooting"
    
    print_step "Checking system resources..."
    
    # CPU usage
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    if [ -n "$cpu_usage" ]; then
        print_status "CPU usage: $cpu_usage%"
        if (( $(echo "$cpu_usage > 80" | bc -l) )); then
            print_warning "High CPU usage detected"
        fi
    fi
    
    # Memory usage
    local memory_usage=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
    if [ -n "$memory_usage" ]; then
        print_status "Memory usage: $memory_usage%"
        if (( $(echo "$memory_usage > 90" | bc -l) )); then
            print_warning "High memory usage detected"
        fi
    fi
    
    # Disk usage
    local disk_usage=$(df / | tail -1 | awk '{print $5}' | cut -d'%' -f1)
    if [ -n "$disk_usage" ]; then
        print_status "Disk usage: $disk_usage%"
        if [ "$disk_usage" -gt 90 ]; then
            print_warning "High disk usage detected"
        fi
    fi
    
    print_step "Checking monitoring service performance..."
    
    # Check Prometheus performance
    if systemctl is-active prometheus >/dev/null 2>&1; then
        local prometheus_memory=$(ps aux | grep prometheus | grep -v grep | awk '{print $6}')
        if [ -n "$prometheus_memory" ]; then
            local prometheus_memory_mb=$((prometheus_memory / 1024))
            print_status "Prometheus memory usage: ${prometheus_memory_mb}MB"
        fi
    fi
    
    # Check Grafana performance
    if systemctl is-active grafana-server >/dev/null 2>&1; then
        local grafana_memory=$(ps aux | grep grafana | grep -v grep | awk '{print $6}')
        if [ -n "$grafana_memory" ]; then
            local grafana_memory_mb=$((grafana_memory / 1024))
            print_status "Grafana memory usage: ${grafana_memory_mb}MB"
        fi
    fi
    
    print_step "Checking network connections..."
    local total_connections=$(ss -tuna | wc -l)
    print_status "Total network connections: $total_connections"
    
    local prometheus_connections=$(ss -tuna | grep :9090 | wc -l)
    print_status "Prometheus connections: $prometheus_connections"
    
    local grafana_connections=$(ss -tuna | grep :3000 | wc -l)
    print_status "Grafana connections: $grafana_connections"
    
    print_step "Checking log file sizes..."
    local log_files=("/var/log/prometheus.log" "/var/log/grafana.log" "/var/log/elasticsearch.log")
    for log_file in "${log_files[@]}"; do
        if [ -f "$log_file" ]; then
            local log_size=$(du -h "$log_file" | cut -f1)
            print_status "$log_file: $log_size"
        fi
    done
}

# Troubleshooting: Log Analysis
analyze_logs() {
    print_header "Log Analysis"
    
    print_step "Analyzing Prometheus logs..."
    if [ -f "/var/log/prometheus.log" ]; then
        print_step "Recent Prometheus errors:"
        tail -20 /var/log/prometheus.log | grep -i error || echo "No recent errors found"
    else
        print_warning "Prometheus log file not found"
    fi
    
    print_step "Analyzing Grafana logs..."
    if [ -f "/var/log/grafana.log" ]; then
        print_step "Recent Grafana errors:"
        tail -20 /var/log/grafana.log | grep -i error || echo "No recent errors found"
    else
        print_warning "Grafana log file not found"
    fi
    
    print_step "Analyzing system logs..."
    print_step "Recent system messages:"
    journalctl --no-pager -n 20 | grep -i "prometheus\|grafana\|elasticsearch" || echo "No monitoring-related messages found"
    
    print_step "Recent kernel messages:"
    dmesg | tail -10 | grep -i "error\|fail\|warn" || echo "No recent kernel issues found"
    
    print_step "Analyzing monitoring service logs..."
    local services=("prometheus" "grafana-server" "elasticsearch" "logstash" "kibana" "alertmanager")
    for service in "${services[@]}"; do
        if systemctl is-active "$service" >/dev/null 2>&1; then
            print_step "Recent $service errors:"
            journalctl -u "$service" --no-pager -n 5 | grep -i error || echo "No recent errors found"
        fi
    done
}

# Generate troubleshooting report
generate_report() {
    print_header "Generating Troubleshooting Report"
    
    local report_file="/tmp/monitoring-troubleshoot-report.txt"
    
    {
        echo "Monitoring Troubleshooting Report"
        echo "Generated: $(date)"
        echo "Hostname: $(hostname)"
        echo "OS: $(uname -a)"
        echo "=========================================="
        echo
        
        echo "=== System Information ==="
        uptime
        free -h
        df -h
        echo
        
        echo "=== Monitoring Services Status ==="
        systemctl status prometheus --no-pager 2>/dev/null || echo "Prometheus not found"
        systemctl status grafana-server --no-pager 2>/dev/null || echo "Grafana not found"
        systemctl status elasticsearch --no-pager 2>/dev/null || echo "Elasticsearch not found"
        systemctl status alertmanager --no-pager 2>/dev/null || echo "Alertmanager not found"
        echo
        
        echo "=== Network Connections ==="
        ss -tuna | grep -E ":(9090|3000|9200|5601|9093)" | head -10
        echo
        
        echo "=== Process Information ==="
        ps aux | grep -E "(prometheus|grafana|elasticsearch|alertmanager)" | grep -v grep
        echo
        
        echo "=== Configuration Files ==="
        if [ -f "/etc/prometheus/prometheus.yml" ]; then
            echo "Prometheus configuration:"
            head -20 /etc/prometheus/prometheus.yml
        fi
        if [ -f "/etc/grafana/grafana.ini" ]; then
            echo "Grafana configuration:"
            head -20 /etc/grafana/grafana.ini
        fi
        
    } > "$report_file"
    
    print_status "Troubleshooting report generated: $report_file"
    print_step "Report contents:"
    cat "$report_file"
}

# Main troubleshooting menu
show_troubleshoot_menu() {
    echo
    print_header "Monitoring Troubleshooting Menu"
    echo "1. Prometheus Issues"
    echo "2. Grafana Issues"
    echo "3. ELK Stack Issues"
    echo "4. Alerting Issues"
    echo "5. Metrics Collection Issues"
    echo "6. Dashboard Issues"
    echo "7. Performance Issues"
    echo "8. Log Analysis"
    echo "9. Generate Troubleshooting Report"
    echo "10. Run All Troubleshooting Checks"
    echo "0. Exit"
    echo
}

# Main function
main() {
    print_header "Monitoring Troubleshooting Guide"
    print_status "Welcome to the Monitoring Troubleshooting Guide!"
    print_status "This guide will help you diagnose and fix common monitoring system issues."
    
    # Check if running in container
    if check_container; then
        print_status "Running in container environment"
    else
        print_warning "Not running in container - some checks may not work properly"
    fi
    
    while true; do
        show_troubleshoot_menu
        read -p "Select a troubleshooting option (0-10): " choice
        
        case $choice in
            1)
                troubleshoot_prometheus
                ;;
            2)
                troubleshoot_grafana
                ;;
            3)
                troubleshoot_elk_stack
                ;;
            4)
                troubleshoot_alerting
                ;;
            5)
                troubleshoot_metrics_collection
                ;;
            6)
                troubleshoot_dashboards
                ;;
            7)
                troubleshoot_performance
                ;;
            8)
                analyze_logs
                ;;
            9)
                generate_report
                ;;
            10)
                troubleshoot_prometheus
                troubleshoot_grafana
                troubleshoot_elk_stack
                troubleshoot_alerting
                troubleshoot_metrics_collection
                troubleshoot_dashboards
                troubleshoot_performance
                analyze_logs
                generate_report
                ;;
            0)
                print_status "Exiting Troubleshooting Guide"
                exit 0
                ;;
            *)
                print_error "Invalid option. Please select 0-10."
                ;;
        esac
        
        echo
        read -p "Press Enter to continue..."
    done
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

