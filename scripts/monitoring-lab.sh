#!/bin/bash
# Monitoring Lab Exercises
# Comprehensive hands-on exercises for learning monitoring and observability concepts

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Lab configuration
LAB_DIR="/tmp/monitoring-lab"
PROMETHEUS_DIR="$LAB_DIR/prometheus"
GRAFANA_DIR="$LAB_DIR/grafana"
ELK_DIR="$LAB_DIR/elk"
SCRIPTS_DIR="$LAB_DIR/scripts"

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

# Function to setup lab environment
setup_lab_environment() {
    print_header "Setting Up Monitoring Lab Environment"
    
    # Create lab directories
    mkdir -p "$LAB_DIR"/{prometheus,grafana,elk,scripts,logs}
    mkdir -p "$PROMETHEUS_DIR"/{configs,rules}
    mkdir -p "$GRAFANA_DIR"/{dashboards,datasources}
    mkdir -p "$ELK_DIR"/{elasticsearch,logstash,kibana}
    
    print_status "Lab directories created"
    
    # Check if Docker is available
    if command -v docker >/dev/null 2>&1; then
        print_status "Docker is available"
        USE_DOCKER=true
    else
        print_warning "Docker not available, using local setup"
        USE_DOCKER=false
    fi
    
    # Check if Python is available
    if command -v python3 >/dev/null 2>&1; then
        print_status "Python3 is available"
        PYTHON_AVAILABLE=true
    else
        print_warning "Python3 not available"
        PYTHON_AVAILABLE=false
    fi
    
    # Check if curl is available
    if command -v curl >/dev/null 2>&1; then
        print_status "curl is available"
        CURL_AVAILABLE=true
    else
        print_warning "curl not available"
        CURL_AVAILABLE=false
    fi
}

# Exercise 1: Basic Prometheus Setup
exercise_1_prometheus() {
    print_header "Exercise 1: Basic Prometheus Setup"
    
    print_step "Creating Prometheus configuration..."
    
    # Create Prometheus configuration
    cat > "$PROMETHEUS_DIR/configs/prometheus.yml" << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    cluster: 'monitoring-lab'
    region: 'local'

rule_files:
  - "alert_rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
    scrape_interval: 5s
    metrics_path: /metrics
  
  - job_name: 'nginx-exporter'
    static_configs:
      - targets: ['nginx-exporter:9113']
    scrape_interval: 10s
  
  - job_name: 'custom-metrics'
    static_configs:
      - targets: ['custom-metrics:8000']
    scrape_interval: 10s
EOF
    
    # Create alert rules
    cat > "$PROMETHEUS_DIR/rules/alert_rules.yml" << 'EOF'
groups:
  - name: system_alerts
    rules:
      - alert: HighCPUUsage
        expr: 100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage detected"
          description: "CPU usage is {{ $value }}% on {{ $labels.instance }}"
      
      - alert: HighMemoryUsage
        expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 90
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High memory usage detected"
          description: "Memory usage is {{ $value }}% on {{ $labels.instance }}"
      
      - alert: DiskSpaceLow
        expr: (node_filesystem_size_bytes - node_filesystem_free_bytes) / node_filesystem_size_bytes * 100 > 90
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Disk space is low"
          description: "Disk usage is {{ $value }}% on {{ $labels.instance }} {{ $labels.mountpoint }}"
  
  - name: network_alerts
    rules:
      - alert: HighNetworkTraffic
        expr: rate(node_network_receive_bytes_total[5m]) > 1000000000
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High network traffic detected"
          description: "Network interface {{ $labels.device }} is receiving {{ $value }} bytes/sec"
      
      - alert: NetworkInterfaceDown
        expr: node_network_up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Network interface is down"
          description: "Interface {{ $labels.device }} on {{ $labels.instance }} is down"
EOF
    
    if [ "$USE_DOCKER" = true ]; then
        print_step "Starting Prometheus with Docker..."
        
        # Start Prometheus
        docker run -d --name prometheus \
            --network bridge \
            -p 9090:9090 \
            -v "$PROMETHEUS_DIR/configs/prometheus.yml:/etc/prometheus/prometheus.yml" \
            -v "$PROMETHEUS_DIR/rules/alert_rules.yml:/etc/prometheus/alert_rules.yml" \
            prom/prometheus:latest
        
        print_status "Prometheus started on http://localhost:9090"
        
        # Wait for Prometheus to start
        sleep 10
        
        # Test Prometheus
        if [ "$CURL_AVAILABLE" = true ]; then
            print_step "Testing Prometheus..."
            curl -s http://localhost:9090/api/v1/query?query=up | head -5
        fi
        
    else
        print_warning "Docker not available for this exercise"
        print_status "Please install Docker to run this exercise"
    fi
}

# Exercise 2: Node Exporter and System Metrics
exercise_2_node_exporter() {
    print_header "Exercise 2: Node Exporter and System Metrics"
    
    if [ "$USE_DOCKER" = true ]; then
        print_step "Starting Node Exporter..."
        
        # Start Node Exporter
        docker run -d --name node-exporter \
            --network bridge \
            -p 9100:9100 \
            -v /proc:/host/proc:ro \
            -v /sys:/host/sys:ro \
            -v /:/rootfs:ro \
            prom/node-exporter:latest \
            --path.procfs=/host/proc \
            --path.sysfs=/host/sys \
            --collector.filesystem.mount-points-exclude="^/(sys|proc|dev|host|etc)($$|/)"
        
        print_status "Node Exporter started on http://localhost:9100"
        
        # Wait for Node Exporter to start
        sleep 5
        
        # Test Node Exporter
        if [ "$CURL_AVAILABLE" = true ]; then
            print_step "Testing Node Exporter metrics..."
            curl -s http://localhost:9100/metrics | head -10
        fi
        
        # Update Prometheus configuration to include Node Exporter
        print_step "Updating Prometheus configuration..."
        docker exec prometheus promtool check config /etc/prometheus/prometheus.yml
        
        # Reload Prometheus configuration
        docker exec prometheus kill -HUP 1
        
        print_status "Prometheus configuration reloaded"
        
    else
        print_warning "Docker not available for this exercise"
    fi
}

# Exercise 3: Custom Metrics Application
exercise_3_custom_metrics() {
    print_header "Exercise 3: Custom Metrics Application"
    
    if [ "$PYTHON_AVAILABLE" = true ]; then
        print_step "Creating custom metrics application..."
        
        # Create custom metrics application
        cat > "$SCRIPTS_DIR/custom_metrics.py" << 'EOF'
#!/usr/bin/env python3
"""
Custom Metrics Application
Generates sample metrics for monitoring lab
"""

import time
import random
import psutil
from prometheus_client import Counter, Histogram, Gauge, start_http_server

# Define metrics
REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint', 'status'])
REQUEST_DURATION = Histogram('http_request_duration_seconds', 'HTTP request duration')
ACTIVE_CONNECTIONS = Gauge('active_connections', 'Number of active connections')
MEMORY_USAGE = Gauge('memory_usage_bytes', 'Memory usage in bytes')
CPU_USAGE = Gauge('cpu_usage_percent', 'CPU usage percentage')
DISK_USAGE = Gauge('disk_usage_percent', 'Disk usage percentage')

def process_request(method, endpoint):
    """Process a request and record metrics"""
    start_time = time.time()
    
    # Simulate request processing
    time.sleep(random.uniform(0.1, 0.5))
    
    # Determine status code
    status = '200' if random.random() > 0.1 else '500'
    
    # Record metrics
    REQUEST_COUNT.labels(method=method, endpoint=endpoint, status=status).inc()
    REQUEST_DURATION.observe(time.time() - start_time)
    
    return status

def update_system_metrics():
    """Update system metrics"""
    # Update memory usage
    memory = psutil.virtual_memory()
    MEMORY_USAGE.set(memory.used)
    
    # Update CPU usage
    cpu_percent = psutil.cpu_percent(interval=1)
    CPU_USAGE.set(cpu_percent)
    
    # Update disk usage
    disk = psutil.disk_usage('/')
    disk_percent = (disk.used / disk.total) * 100
    DISK_USAGE.set(disk_percent)
    
    # Update active connections
    connections = len(psutil.net_connections())
    ACTIVE_CONNECTIONS.set(connections)

if __name__ == '__main__':
    # Start Prometheus metrics server
    start_http_server(8000)
    print("Custom metrics server started on port 8000")
    
    # Simulate application requests
    endpoints = ['/api/users', '/api/orders', '/api/products', '/health']
    methods = ['GET', 'POST', 'PUT', 'DELETE']
    
    while True:
        method = random.choice(methods)
        endpoint = random.choice(endpoints)
        
        process_request(method, endpoint)
        update_system_metrics()
        
        time.sleep(1)
EOF
        
        chmod +x "$SCRIPTS_DIR/custom_metrics.py"
        
        print_step "Starting custom metrics application..."
        python3 "$SCRIPTS_DIR/custom_metrics.py" &
        CUSTOM_METRICS_PID=$!
        
        print_status "Custom metrics application started (PID: $CUSTOM_METRICS_PID)"
        print_status "Metrics available at http://localhost:8000/metrics"
        
        # Wait for application to start
        sleep 5
        
        # Test custom metrics
        if [ "$CURL_AVAILABLE" = true ]; then
            print_step "Testing custom metrics..."
            curl -s http://localhost:8000/metrics | head -10
        fi
        
    else
        print_warning "Python3 not available for this exercise"
    fi
}

# Exercise 4: Grafana Dashboard Setup
exercise_4_grafana() {
    print_header "Exercise 4: Grafana Dashboard Setup"
    
    if [ "$USE_DOCKER" = true ]; then
        print_step "Starting Grafana..."
        
        # Start Grafana
        docker run -d --name grafana \
            --network bridge \
            -p 3000:3000 \
            -e GF_SECURITY_ADMIN_PASSWORD=admin \
            grafana/grafana:latest
        
        print_status "Grafana started on http://localhost:3000 (admin/admin)"
        
        # Wait for Grafana to start
        sleep 15
        
        # Test Grafana
        if [ "$CURL_AVAILABLE" = true ]; then
            print_step "Testing Grafana..."
            curl -s http://localhost:3000/api/health
        fi
        
        # Create Prometheus data source
        print_step "Creating Prometheus data source..."
        cat > "$GRAFANA_DIR/datasources/prometheus.json" << 'EOF'
{
  "name": "Prometheus",
  "type": "prometheus",
  "url": "http://prometheus:9090",
  "access": "proxy",
  "isDefault": true
}
EOF
        
        # Add data source to Grafana
        if [ "$CURL_AVAILABLE" = true ]; then
            curl -X POST \
                -H "Content-Type: application/json" \
                -d @$GRAFANA_DIR/datasources/prometheus.json \
                http://admin:admin@localhost:3000/api/datasources
        fi
        
        print_status "Prometheus data source added to Grafana"
        
    else
        print_warning "Docker not available for this exercise"
    fi
}

# Exercise 5: ELK Stack for Log Monitoring
exercise_5_elk_stack() {
    print_header "Exercise 5: ELK Stack for Log Monitoring"
    
    if [ "$USE_DOCKER" = true ]; then
        print_step "Starting ELK Stack..."
        
        # Create Elasticsearch
        docker run -d --name elasticsearch \
            --network bridge \
            -p 9200:9200 \
            -e "discovery.type=single-node" \
            -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" \
            elasticsearch:8.11.0
        
        # Create Logstash configuration
        cat > "$ELK_DIR/logstash/logstash.conf" << 'EOF'
input {
  beats {
    port => 5044
  }
  
  file {
    path => "/var/log/nginx/access.log"
    type => "nginx_access"
  }
  
  file {
    path => "/var/log/nginx/error.log"
    type => "nginx_error"
  }
}

filter {
  if [type] == "nginx_access" {
    grok {
      match => { "message" => "%{NGINXACCESS}" }
    }
    
    date {
      match => [ "timestamp", "dd/MMM/yyyy:HH:mm:ss Z" ]
    }
  }
  
  if [type] == "nginx_error" {
    grok {
      match => { "message" => "%{NGINXERROR}" }
    }
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "logs-%{+YYYY.MM.dd}"
  }
}
EOF
        
        # Start Logstash
        docker run -d --name logstash \
            --network bridge \
            -p 5044:5044 \
            -v "$ELK_DIR/logstash/logstash.conf:/usr/share/logstash/pipeline/logstash.conf" \
            logstash:8.11.0
        
        # Start Kibana
        docker run -d --name kibana \
            --network bridge \
            -p 5601:5601 \
            -e "ELASTICSEARCH_HOSTS=http://elasticsearch:9200" \
            kibana:8.11.0
        
        print_status "ELK Stack started:"
        print_status "  Elasticsearch: http://localhost:9200"
        print_status "  Kibana: http://localhost:5601"
        print_status "  Logstash: localhost:5044"
        
        # Wait for services to start
        sleep 30
        
        # Test Elasticsearch
        if [ "$CURL_AVAILABLE" = true ]; then
            print_step "Testing Elasticsearch..."
            curl -s http://localhost:9200/_cluster/health
        fi
        
    else
        print_warning "Docker not available for this exercise"
    fi
}

# Exercise 6: SNMP Network Monitoring
exercise_6_snmp_monitoring() {
    print_header "Exercise 6: SNMP Network Monitoring"
    
    # Check if SNMP tools are available
    if command_exists snmpwalk; then
        print_step "SNMP tools available, testing SNMP monitoring..."
        
        # Create SNMP monitoring script
        cat > "$SCRIPTS_DIR/snmp_monitor.sh" << 'EOF'
#!/bin/bash
# SNMP Network Monitoring Script

SNMP_COMMUNITY="public"
SNMP_HOST="127.0.0.1"

# Function to get SNMP value
get_snmp_value() {
    local oid=$1
    local description=$2
    
    local value=$(snmpget -v2c -c "$SNMP_COMMUNITY" "$SNMP_HOST" "$oid" 2>/dev/null | awk '{print $4}')
    
    if [ -n "$value" ]; then
        echo "$description: $value"
    else
        echo "$description: Error retrieving value"
    fi
}

echo "=== SNMP Network Monitoring ==="
echo "Host: $SNMP_HOST"
echo "Community: $SNMP_COMMUNITY"
echo

# System information
get_snmp_value "1.3.6.1.2.1.1.1.0" "System Description"
get_snmp_value "1.3.6.1.2.1.1.3.0" "System Uptime"
get_snmp_value "1.3.6.1.2.1.1.5.0" "System Name"

echo

# Interface information
echo "=== Network Interfaces ==="
for i in {1..5}; do
    if_descr=$(snmpget -v2c -c "$SNMP_COMMUNITY" "$SNMP_HOST" "1.3.6.1.2.1.2.2.1.2.$i" 2>/dev/null | awk '{print $4}')
    if [ -n "$if_descr" ] && [ "$if_descr" != "No Such Instance" ]; then
        echo "Interface $i: $if_descr"
        
        # Interface status
        if_admin=$(snmpget -v2c -c "$SNMP_COMMUNITY" "$SNMP_HOST" "1.3.6.1.2.1.2.2.1.7.$i" 2>/dev/null | awk '{print $4}')
        if_oper=$(snmpget -v2c -c "$SNMP_COMMUNITY" "$SNMP_HOST" "1.3.6.1.2.1.2.2.1.8.$i" 2>/dev/null | awk '{print $4}')
        
        echo "  Admin Status: $if_admin"
        echo "  Oper Status: $if_oper"
        echo
    fi
done
EOF
        
        chmod +x "$SCRIPTS_DIR/snmp_monitor.sh"
        
        print_step "Running SNMP monitoring script..."
        bash "$SCRIPTS_DIR/snmp_monitor.sh"
        
    else
        print_warning "SNMP tools not available"
        print_status "Installing SNMP tools..."
        
        if command_exists apt-get; then
            sudo apt-get update && sudo apt-get install -y snmp snmp-mibs-downloader
        elif command_exists yum; then
            sudo yum install -y net-snmp net-snmp-utils
        else
            print_error "Package manager not found, please install SNMP tools manually"
        fi
    fi
}

# Exercise 7: Alerting and Notifications
exercise_7_alerting() {
    print_header "Exercise 7: Alerting and Notifications"
    
    if [ "$USE_DOCKER" = true ]; then
        print_step "Starting Alertmanager..."
        
        # Create Alertmanager configuration
        cat > "$PROMETHEUS_DIR/configs/alertmanager.yml" << 'EOF'
global:
  smtp_smarthost: 'localhost:587'
  smtp_from: 'alerts@monitoring-lab.com'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'

receivers:
  - name: 'web.hook'
    webhook_configs:
      - url: 'http://webhook:5001/'
  
  - name: 'email'
    email_configs:
      - to: 'admin@monitoring-lab.com'
        subject: 'Alert: {{ .GroupLabels.alertname }}'
        body: |
          {{ range .Alerts }}
          Alert: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          {{ end }}
  
  - name: 'slack'
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/...'
        channel: '#alerts'
        title: 'Alert: {{ .GroupLabels.alertname }}'
        text: |
          {{ range .Alerts }}
          {{ .Annotations.summary }}
          {{ .Annotations.description }}
          {{ end }}
EOF
        
        # Start Alertmanager
        docker run -d --name alertmanager \
            --network bridge \
            -p 9093:9093 \
            -v "$PROMETHEUS_DIR/configs/alertmanager.yml:/etc/alertmanager/alertmanager.yml" \
            prom/alertmanager:latest
        
        print_status "Alertmanager started on http://localhost:9093"
        
        # Wait for Alertmanager to start
        sleep 10
        
        # Test Alertmanager
        if [ "$CURL_AVAILABLE" = true ]; then
            print_step "Testing Alertmanager..."
            curl -s http://localhost:9093/api/v1/status
        fi
        
        # Create webhook receiver for testing
        cat > "$SCRIPTS_DIR/webhook_receiver.py" << 'EOF'
#!/usr/bin/env python3
"""
Webhook Receiver for Alert Testing
"""

from flask import Flask, request, jsonify
import json
import datetime

app = Flask(__name__)

@app.route('/', methods=['POST'])
def webhook():
    data = request.get_json()
    
    print(f"\n=== Alert Received at {datetime.datetime.now()} ===")
    print(json.dumps(data, indent=2))
    print("=" * 50)
    
    return jsonify({"status": "received"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)
EOF
        
        chmod +x "$SCRIPTS_DIR/webhook_receiver.py"
        
        print_step "Starting webhook receiver..."
        python3 "$SCRIPTS_DIR/webhook_receiver.py" &
        WEBHOOK_PID=$!
        
        print_status "Webhook receiver started (PID: $WEBHOOK_PID)"
        print_status "Webhook available at http://localhost:5001"
        
    else
        print_warning "Docker not available for this exercise"
    fi
}

# Exercise 8: Performance Testing and Analysis
exercise_8_performance_testing() {
    print_header "Exercise 8: Performance Testing and Analysis"
    
    print_step "Running performance tests..."
    
    # Create performance test script
    cat > "$SCRIPTS_DIR/performance_test.sh" << 'EOF'
#!/bin/bash
# Performance Testing Script

echo "=== Performance Testing ==="
echo "Timestamp: $(date)"
echo

# System performance
echo "=== System Performance ==="
echo "CPU Usage:"
top -bn1 | grep "Cpu(s)" || uptime
echo

echo "Memory Usage:"
free -h
echo

echo "Disk Usage:"
df -h
echo

echo "Network Interfaces:"
ip addr show | grep -E "(inet |UP|DOWN)"
echo

# Load testing
if command -v ab >/dev/null 2>&1; then
    echo "=== Load Testing ==="
    echo "Testing localhost:9090 (Prometheus)..."
    ab -n 100 -c 10 http://localhost:9090/ > /tmp/ab-prometheus.txt 2>&1
    if [ -f "/tmp/ab-prometheus.txt" ]; then
        echo "Prometheus Load Test Results:"
        grep -E "(Requests per second|Time per request|Transfer rate)" /tmp/ab-prometheus.txt
    fi
    echo
    
    echo "Testing localhost:3000 (Grafana)..."
    ab -n 50 -c 5 http://localhost:3000/ > /tmp/ab-grafana.txt 2>&1
    if [ -f "/tmp/ab-grafana.txt" ]; then
        echo "Grafana Load Test Results:"
        grep -E "(Requests per second|Time per request|Transfer rate)" /tmp/ab-grafana.txt
    fi
else
    echo "Apache Bench (ab) not available for load testing"
fi

echo

# Connection monitoring
echo "=== Connection Monitoring ==="
echo "Active connections on port 9090:"
ss -tuna | grep :9090 | wc -l
echo "Active connections on port 3000:"
ss -tuna | grep :3000 | wc -l
echo "Active connections on port 9200:"
ss -tuna | grep :9200 | wc -l
echo

# Process monitoring
echo "=== Process Monitoring ==="
echo "Docker containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "Docker not available"
echo

echo "Top processes by CPU:"
ps aux --sort=-%cpu | head -5
echo

echo "Top processes by memory:"
ps aux --sort=-%mem | head -5
echo

# Log analysis
echo "=== Log Analysis ==="
echo "Recent system messages:"
journalctl --no-pager -n 10 2>/dev/null || echo "Journal not available"
echo

echo "Recent kernel messages:"
dmesg | tail -5
echo

echo "Performance test completed at $(date)"
EOF
    
    chmod +x "$SCRIPTS_DIR/performance_test.sh"
    
    print_step "Running performance test..."
    bash "$SCRIPTS_DIR/performance_test.sh"
    
    print_status "Performance test completed"
}

# Exercise 9: Monitoring Analysis
exercise_9_monitoring_analysis() {
    print_header "Exercise 9: Monitoring Analysis"
    
    print_step "Running monitoring analysis..."
    
    # Use the monitoring analyzer if available
    if [ -f "/usr/local/bin/monitoring-analyzer.py" ] || [ -f "./monitoring-analyzer.py" ]; then
        if [ -f "./monitoring-analyzer.py" ]; then
            python3 ./monitoring-analyzer.py --all
        else
            python3 /usr/local/bin/monitoring-analyzer.py --all
        fi
    else
        print_warning "Monitoring analyzer not available"
        print_status "Manual analysis:"
        
        # Check Prometheus status
        if docker ps | grep -q prometheus; then
            print_status "Prometheus container status:"
            docker ps | grep prometheus
        fi
        
        # Check Grafana status
        if docker ps | grep -q grafana; then
            print_status "Grafana container status:"
            docker ps | grep grafana
        fi
        
        # Check ELK stack status
        if docker ps | grep -q elasticsearch; then
            print_status "ELK stack status:"
            docker ps | grep -E "(elasticsearch|logstash|kibana)"
        fi
        
        # Check system resources
        print_status "System resources:"
        free -h
        df -h
        uptime
    fi
}

# Cleanup function
cleanup_lab() {
    print_header "Cleaning Up Lab Environment"
    
    if [ "$USE_DOCKER" = true ]; then
        print_status "Stopping and removing containers..."
        
        # Stop and remove containers
        docker stop prometheus grafana elasticsearch logstash kibana alertmanager node-exporter 2>/dev/null || true
        docker rm prometheus grafana elasticsearch logstash kibana alertmanager node-exporter 2>/dev/null || true
        
        print_status "Containers removed"
    fi
    
    # Kill background processes
    if [ -n "${CUSTOM_METRICS_PID:-}" ]; then
        kill $CUSTOM_METRICS_PID 2>/dev/null || true
    fi
    
    if [ -n "${WEBHOOK_PID:-}" ]; then
        kill $WEBHOOK_PID 2>/dev/null || true
    fi
    
    # Remove lab directory
    if [ -d "$LAB_DIR" ]; then
        rm -rf "$LAB_DIR"
        print_status "Lab directory removed"
    fi
    
    print_status "Cleanup complete"
}

# Main menu
show_menu() {
    echo
    print_header "Monitoring Lab Menu"
    echo "1. Setup Lab Environment"
    echo "2. Exercise 1: Basic Prometheus Setup"
    echo "3. Exercise 2: Node Exporter and System Metrics"
    echo "4. Exercise 3: Custom Metrics Application"
    echo "5. Exercise 4: Grafana Dashboard Setup"
    echo "6. Exercise 5: ELK Stack for Log Monitoring"
    echo "7. Exercise 6: SNMP Network Monitoring"
    echo "8. Exercise 7: Alerting and Notifications"
    echo "9. Exercise 8: Performance Testing and Analysis"
    echo "10. Exercise 9: Monitoring Analysis"
    echo "11. Run All Exercises"
    echo "12. Cleanup Lab Environment"
    echo "0. Exit"
    echo
}

# Main function
main() {
    print_header "Monitoring Lab Exercises"
    print_status "Welcome to the Monitoring Lab!"
    print_status "This lab will teach you monitoring and observability concepts through hands-on exercises."
    
    # Check if running in container
    if check_container; then
        print_status "Running in container environment"
    else
        print_warning "Not running in container - some exercises may not work properly"
    fi
    
    while true; do
        show_menu
        read -p "Select an option (0-12): " choice
        
        case $choice in
            1)
                setup_lab_environment
                ;;
            2)
                exercise_1_prometheus
                ;;
            3)
                exercise_2_node_exporter
                ;;
            4)
                exercise_3_custom_metrics
                ;;
            5)
                exercise_4_grafana
                ;;
            6)
                exercise_5_elk_stack
                ;;
            7)
                exercise_6_snmp_monitoring
                ;;
            8)
                exercise_7_alerting
                ;;
            9)
                exercise_8_performance_testing
                ;;
            10)
                exercise_9_monitoring_analysis
                ;;
            11)
                setup_lab_environment
                exercise_1_prometheus
                exercise_2_node_exporter
                exercise_3_custom_metrics
                exercise_4_grafana
                exercise_5_elk_stack
                exercise_6_snmp_monitoring
                exercise_7_alerting
                exercise_8_performance_testing
                exercise_9_monitoring_analysis
                ;;
            12)
                cleanup_lab
                ;;
            0)
                print_status "Exiting Monitoring Lab"
                exit 0
                ;;
            *)
                print_error "Invalid option. Please select 0-12."
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

