# Network and System Monitoring

## What You'll Learn

This module covers comprehensive monitoring and observability concepts essential for maintaining healthy, performant networks and systems. You'll learn to:
- **Design and implement monitoring architectures** for networks, systems, and applications
- **Configure and optimize monitoring tools** using Prometheus, Grafana, and other solutions
- **Implement alerting and notification systems** for proactive issue detection
- **Analyze metrics and logs** for performance optimization and troubleshooting
- **Build observability dashboards** for real-time system visibility
- **Implement distributed tracing** for complex application monitoring

## Key Concepts

### Monitoring Fundamentals
- **Metrics Collection**: Gathering quantitative data about system performance
- **Log Aggregation**: Centralizing and analyzing log data from multiple sources
- **Distributed Tracing**: Tracking requests across distributed systems
- **Alerting**: Proactive notification of issues and anomalies
- **Dashboards**: Visual representation of system health and performance
- **Observability**: Understanding system behavior through external outputs

### Monitoring Types
- **Infrastructure Monitoring**: Servers, networks, storage, and hardware
- **Application Monitoring**: Application performance, errors, and user experience
- **Network Monitoring**: Traffic analysis, bandwidth utilization, and connectivity
- **Security Monitoring**: Threat detection, access patterns, and security events
- **Business Monitoring**: Key performance indicators and business metrics
- **Synthetic Monitoring**: Proactive testing from external locations

### Monitoring Stack Components
- **Time Series Databases**: Prometheus, InfluxDB, TimescaleDB
- **Visualization Tools**: Grafana, Kibana, Chronograf
- **Log Aggregation**: ELK Stack, Fluentd, Splunk
- **APM Tools**: New Relic, Datadog, AppDynamics
- **Network Monitoring**: Zabbix, Nagios, PRTG
- **Cloud Monitoring**: AWS CloudWatch, GCP Monitoring, Azure Monitor

## Detailed Explanations

### Prometheus Monitoring Architecture

#### Prometheus Data Model
```
Prometheus Data Model:
┌─────────────────────────────────────────────────────────────────┐
│                    Prometheus Metrics                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Metric Name: http_requests_total                              │
│  Labels: {method="GET", status="200", endpoint="/api/users"}   │
│  Value: 1234                                                   │
│  Timestamp: 1640995200                                         │
│                                                                 │
│  Metric Types:                                                 │
│  • Counter: Monotonically increasing values                    │
│  • Gauge: Values that can go up and down                       │
│  • Histogram: Distribution of values in buckets                │
│  • Summary: Quantiles and count of observations                │
└─────────────────────────────────────────────────────────────────┘
```

#### Prometheus Configuration
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    cluster: 'production'
    region: 'us-west-2'

rule_files:
  - "alert_rules.yml"
  - "recording_rules.yml"

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
  
  - job_name: 'postgres-exporter'
    static_configs:
      - targets: ['postgres-exporter:9187']
    scrape_interval: 30s
```

### Grafana Dashboard Configuration

#### Network Monitoring Dashboard
```json
{
  "dashboard": {
    "title": "Network Monitoring Dashboard",
    "panels": [
      {
        "title": "Network Traffic",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(node_network_receive_bytes_total[5m])",
            "legendFormat": "{{device}} - RX"
          },
          {
            "expr": "rate(node_network_transmit_bytes_total[5m])",
            "legendFormat": "{{device}} - TX"
          }
        ]
      },
      {
        "title": "TCP Connections",
        "type": "stat",
        "targets": [
          {
            "expr": "node_netstat_Tcp_CurrEstab",
            "legendFormat": "Active TCP Connections"
          }
        ]
      },
      {
        "title": "Network Errors",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(node_network_receive_errs_total[5m])",
            "legendFormat": "{{device}} - RX Errors"
          },
          {
            "expr": "rate(node_network_transmit_errs_total[5m])",
            "legendFormat": "{{device}} - TX Errors"
          }
        ]
      }
    ]
  }
}
```

#### System Performance Dashboard
```json
{
  "dashboard": {
    "title": "System Performance Dashboard",
    "panels": [
      {
        "title": "CPU Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "100 - (avg by (instance) (rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)",
            "legendFormat": "{{instance}} - CPU Usage %"
          }
        ]
      },
      {
        "title": "Memory Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes",
            "legendFormat": "{{instance}} - Used Memory"
          },
          {
            "expr": "node_memory_MemAvailable_bytes",
            "legendFormat": "{{instance}} - Available Memory"
          }
        ]
      },
      {
        "title": "Disk I/O",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(node_disk_read_bytes_total[5m])",
            "legendFormat": "{{device}} - Read"
          },
          {
            "expr": "rate(node_disk_written_bytes_total[5m])",
            "legendFormat": "{{device}} - Write"
          }
        ]
      }
    ]
  }
}
```

### Network Monitoring with SNMP

#### SNMP Configuration
```bash
# SNMP Agent Configuration
# /etc/snmp/snmpd.conf

# Community strings
rocommunity public
rwcommunity private

# System information
syslocation "Data Center - Rack 1"
syscontact "admin@company.com"

# Network interfaces
ifIndex.1 = 1
ifDescr.1 = "eth0"
ifType.1 = 6
ifMtu.1 = 1500
ifSpeed.1 = 1000000000
ifPhysAddress.1 = "00:11:22:33:44:55"
ifAdminStatus.1 = 1
ifOperStatus.1 = 1

# CPU and Memory
hrSystemUptime.0 = 1234567
hrSystemDate.0 = "2024-01-01 12:00:00"
hrSystemInitialLoadDevice.0 = 1
hrSystemInitialLoadParameters.0 = "console=ttyS0"
hrSystemNumUsers.0 = 1
hrSystemProcesses.0 = 45
hrSystemMaxProcesses.0 = 1000

# Storage
hrStorageIndex.1 = 1
hrStorageType.1 = hrStorageRam
hrStorageDescr.1 = "Physical memory"
hrStorageAllocationUnits.1 = 1024
hrStorageSize.1 = 8388608
hrStorageUsed.1 = 4194304
hrStorageAllocationFailures.1 = 0
```

#### SNMP Monitoring Script
```bash
#!/bin/bash
# SNMP Network Monitoring Script

SNMP_COMMUNITY="public"
SNMP_HOST="192.168.1.1"

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
for i in {1..10}; do
    if_descr=$(snmpget -v2c -c "$SNMP_COMMUNITY" "$SNMP_HOST" "1.3.6.1.2.1.2.2.1.2.$i" 2>/dev/null | awk '{print $4}')
    if [ -n "$if_descr" ] && [ "$if_descr" != "No Such Instance" ]; then
        echo "Interface $i: $if_descr"
        
        # Interface status
        if_admin=$(snmpget -v2c -c "$SNMP_COMMUNITY" "$SNMP_HOST" "1.3.6.1.2.1.2.2.1.7.$i" 2>/dev/null | awk '{print $4}')
        if_oper=$(snmpget -v2c -c "$SNMP_COMMUNITY" "$SNMP_HOST" "1.3.6.1.2.1.2.2.1.8.$i" 2>/dev/null | awk '{print $4}')
        
        echo "  Admin Status: $if_admin"
        echo "  Oper Status: $if_oper"
        
        # Interface statistics
        if_in_octets=$(snmpget -v2c -c "$SNMP_COMMUNITY" "$SNMP_HOST" "1.3.6.1.2.1.2.2.1.10.$i" 2>/dev/null | awk '{print $4}')
        if_out_octets=$(snmpget -v2c -c "$SNMP_COMMUNITY" "$SNMP_HOST" "1.3.6.1.2.1.2.2.1.16.$i" 2>/dev/null | awk '{print $4}')
        
        echo "  Bytes In: $if_in_octets"
        echo "  Bytes Out: $if_out_octets"
        echo
    fi
done
```

### Log Monitoring and Analysis

#### ELK Stack Configuration
```yaml
# docker-compose.yml for ELK Stack
version: '3.8'
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.11.0
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    ports:
      - "9200:9200"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data

  logstash:
    image: docker.elastic.co/logstash/logstash:8.11.0
    ports:
      - "5044:5044"
    volumes:
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf
    depends_on:
      - elasticsearch

  kibana:
    image: docker.elastic.co/kibana/kibana:8.11.0
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    depends_on:
      - elasticsearch

volumes:
  elasticsearch_data:
```

#### Logstash Configuration
```ruby
# logstash.conf
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
  
  file {
    path => "/var/log/syslog"
    type => "syslog"
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
    
    geoip {
      source => "clientip"
    }
  }
  
  if [type] == "nginx_error" {
    grok {
      match => { "message" => "%{NGINXERROR}" }
    }
  }
  
  if [type] == "syslog" {
    grok {
      match => { "message" => "%{SYSLOGTIMESTAMP:timestamp} %{IPORHOST:host} %{PROG:program}: %{GREEDYDATA:message}" }
    }
    
    date {
      match => [ "timestamp", "MMM  d HH:mm:ss", "MMM dd HH:mm:ss" ]
    }
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "logs-%{+YYYY.MM.dd}"
  }
}
```

### Application Performance Monitoring (APM)

#### Prometheus Application Metrics
```python
# Python application with Prometheus metrics
from prometheus_client import Counter, Histogram, Gauge, start_http_server
import time
import random

# Define metrics
REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint', 'status'])
REQUEST_DURATION = Histogram('http_request_duration_seconds', 'HTTP request duration')
ACTIVE_CONNECTIONS = Gauge('active_connections', 'Number of active connections')
MEMORY_USAGE = Gauge('memory_usage_bytes', 'Memory usage in bytes')

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
    import psutil
    
    # Update memory usage
    memory = psutil.virtual_memory()
    MEMORY_USAGE.set(memory.used)
    
    # Update active connections
    connections = len(psutil.net_connections())
    ACTIVE_CONNECTIONS.set(connections)

if __name__ == '__main__':
    # Start Prometheus metrics server
    start_http_server(8000)
    
    # Simulate application requests
    endpoints = ['/api/users', '/api/orders', '/api/products', '/health']
    methods = ['GET', 'POST', 'PUT', 'DELETE']
    
    while True:
        method = random.choice(methods)
        endpoint = random.choice(endpoints)
        
        process_request(method, endpoint)
        update_system_metrics()
        
        time.sleep(1)
```

### Alerting Configuration

#### Prometheus Alert Rules
```yaml
# alert_rules.yml
groups:
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
  
  - name: application_alerts
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) * 100 > 5
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }}% for {{ $labels.endpoint }}"
      
      - alert: HighResponseTime
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High response time detected"
          description: "95th percentile response time is {{ $value }}s"
```

#### Alertmanager Configuration
```yaml
# alertmanager.yml
global:
  smtp_smarthost: 'localhost:587'
  smtp_from: 'alerts@company.com'

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
      - to: 'admin@company.com'
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
```

## Practical Examples

### Complete Monitoring Stack Setup
```bash
#!/bin/bash
# Complete monitoring stack setup

# Create monitoring network
docker network create monitoring

# Start Prometheus
docker run -d --name prometheus \
  --network monitoring \
  -p 9090:9090 \
  -v $(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml \
  -v $(pwd)/alert_rules.yml:/etc/prometheus/alert_rules.yml \
  prom/prometheus:latest

# Start Grafana
docker run -d --name grafana \
  --network monitoring \
  -p 3000:3000 \
  -e GF_SECURITY_ADMIN_PASSWORD=admin \
  grafana/grafana:latest

# Start Node Exporter
docker run -d --name node-exporter \
  --network monitoring \
  -p 9100:9100 \
  -v /proc:/host/proc:ro \
  -v /sys:/host/sys:ro \
  -v /:/rootfs:ro \
  prom/node-exporter:latest \
  --path.procfs=/host/proc \
  --path.sysfs=/host/sys \
  --collector.filesystem.mount-points-exclude="^/(sys|proc|dev|host|etc)($$|/)"

# Start Nginx Exporter
docker run -d --name nginx-exporter \
  --network monitoring \
  -p 9113:9113 \
  nginx/nginx-prometheus-exporter:latest \
  -nginx.scrape-uri=http://nginx:80/nginx_status

# Start Alertmanager
docker run -d --name alertmanager \
  --network monitoring \
  -p 9093:9093 \
  -v $(pwd)/alertmanager.yml:/etc/alertmanager/alertmanager.yml \
  prom/alertmanager:latest

echo "Monitoring stack started successfully!"
echo "Prometheus: http://localhost:9090"
echo "Grafana: http://localhost:3000 (admin/admin)"
echo "Alertmanager: http://localhost:9093"
```

### Network Performance Monitoring
```bash
#!/bin/bash
# Network performance monitoring script

# Function to monitor network performance
monitor_network_performance() {
    local interface=$1
    local duration=${2:-60}
    
    echo "Monitoring network performance on $interface for $duration seconds..."
    
    # Get initial statistics
    local rx_bytes_initial=$(cat /sys/class/net/$interface/statistics/rx_bytes)
    local tx_bytes_initial=$(cat /sys/class/net/$interface/statistics/tx_bytes)
    local rx_packets_initial=$(cat /sys/class/net/$interface/statistics/rx_packets)
    local tx_packets_initial=$(cat /sys/class/net/$interface/statistics/tx_packets)
    local rx_errors_initial=$(cat /sys/class/net/$interface/statistics/rx_errors)
    local tx_errors_initial=$(cat /sys/class/net/$interface/statistics/tx_errors)
    
    sleep $duration
    
    # Get final statistics
    local rx_bytes_final=$(cat /sys/class/net/$interface/statistics/rx_bytes)
    local tx_bytes_final=$(cat /sys/class/net/$interface/statistics/tx_packets)
    local rx_packets_final=$(cat /sys/class/net/$interface/statistics/rx_packets)
    local tx_packets_final=$(cat /sys/class/net/$interface/statistics/tx_packets)
    local rx_errors_final=$(cat /sys/class/net/$interface/statistics/rx_errors)
    local tx_errors_final=$(cat /sys/class/net/$interface/statistics/tx_errors)
    
    # Calculate rates
    local rx_bytes_rate=$(( (rx_bytes_final - rx_bytes_initial) / duration ))
    local tx_bytes_rate=$(( (tx_bytes_final - tx_bytes_initial) / duration ))
    local rx_packets_rate=$(( (rx_packets_final - rx_packets_initial) / duration ))
    local tx_packets_rate=$(( (tx_packets_final - tx_packets_initial) / duration ))
    local rx_errors_rate=$(( (rx_errors_final - rx_errors_initial) / duration ))
    local tx_errors_rate=$(( (tx_errors_final - tx_errors_initial) / duration ))
    
    # Display results
    echo "=== Network Performance Results ==="
    echo "Interface: $interface"
    echo "Duration: $duration seconds"
    echo
    echo "Receive Rate:"
    echo "  Bytes/sec: $rx_bytes_rate"
    echo "  Packets/sec: $rx_packets_rate"
    echo "  Errors/sec: $rx_errors_rate"
    echo
    echo "Transmit Rate:"
    echo "  Bytes/sec: $tx_bytes_rate"
    echo "  Packets/sec: $tx_packets_rate"
    echo "  Errors/sec: $tx_errors_rate"
    echo
    echo "Total Throughput: $(( (rx_bytes_rate + tx_bytes_rate) / 1024 / 1024 )) MB/s"
}

# Monitor all network interfaces
for interface in $(ls /sys/class/net/ | grep -v lo); do
    monitor_network_performance $interface 30
    echo "----------------------------------------"
done
```

### System Health Monitoring
```bash
#!/bin/bash
# System health monitoring script

# Function to check system health
check_system_health() {
    echo "=== System Health Check ==="
    echo "Timestamp: $(date)"
    echo "Hostname: $(hostname)"
    echo "Uptime: $(uptime)"
    echo
    
    # CPU usage
    echo "=== CPU Usage ==="
    top -bn1 | grep "Cpu(s)" || uptime
    echo
    
    # Memory usage
    echo "=== Memory Usage ==="
    free -h
    echo
    
    # Disk usage
    echo "=== Disk Usage ==="
    df -h
    echo
    
    # Network interfaces
    echo "=== Network Interfaces ==="
    ip addr show | grep -E "(inet |UP|DOWN)"
    echo
    
    # Active connections
    echo "=== Active Connections ==="
    ss -tuna | wc -l
    echo "Total connections: $(ss -tuna | wc -l)"
    echo
    
    # Process count
    echo "=== Process Information ==="
    echo "Total processes: $(ps aux | wc -l)"
    echo "Running processes: $(ps aux | grep -v grep | wc -l)"
    echo
    
    # Load average
    echo "=== Load Average ==="
    cat /proc/loadavg
    echo
    
    # System temperature (if available)
    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        echo "=== System Temperature ==="
        temp=$(cat /sys/class/thermal/thermal_zone0/temp)
        echo "CPU Temperature: $((temp / 1000))°C"
        echo
    fi
}

# Run health check
check_system_health

# Save to log file
log_file="/var/log/system-health-$(date +%Y%m%d).log"
check_system_health >> "$log_file"
echo "Health check saved to: $log_file"
```

## Advanced Usage Patterns

### Distributed Tracing with Jaeger
```yaml
# docker-compose.yml for Jaeger
version: '3.8'
services:
  jaeger:
    image: jaegertracing/all-in-one:latest
    ports:
      - "16686:16686"
      - "14268:14268"
    environment:
      - COLLECTOR_OTLP_ENABLED=true

  app:
    image: your-app:latest
    environment:
      - JAEGER_AGENT_HOST=jaeger
      - JAEGER_AGENT_PORT=14268
    depends_on:
      - jaeger
```

### Custom Metrics Collection
```python
# Custom metrics collector
import psutil
import time
from prometheus_client import Gauge, Counter, start_http_server

# Define custom metrics
CUSTOM_CPU_USAGE = Gauge('custom_cpu_usage_percent', 'Custom CPU usage percentage')
CUSTOM_MEMORY_USAGE = Gauge('custom_memory_usage_bytes', 'Custom memory usage in bytes')
CUSTOM_DISK_IOPS = Counter('custom_disk_iops_total', 'Custom disk IOPS', ['device', 'operation'])
CUSTOM_NETWORK_BYTES = Counter('custom_network_bytes_total', 'Custom network bytes', ['interface', 'direction'])

def collect_custom_metrics():
    """Collect custom system metrics"""
    while True:
        # CPU usage
        cpu_percent = psutil.cpu_percent(interval=1)
        CUSTOM_CPU_USAGE.set(cpu_percent)
        
        # Memory usage
        memory = psutil.virtual_memory()
        CUSTOM_MEMORY_USAGE.set(memory.used)
        
        # Disk IOPS
        disk_io = psutil.disk_io_counters(perdisk=True)
        for device, io in disk_io.items():
            CUSTOM_DISK_IOPS.labels(device=device, operation='read').inc(io.read_count)
            CUSTOM_DISK_IOPS.labels(device=device, operation='write').inc(io.write_count)
        
        # Network bytes
        net_io = psutil.net_io_counters(pernic=True)
        for interface, io in net_io.items():
            CUSTOM_NETWORK_BYTES.labels(interface=interface, direction='rx').inc(io.bytes_recv)
            CUSTOM_NETWORK_BYTES.labels(interface=interface, direction='tx').inc(io.bytes_sent)
        
        time.sleep(10)

if __name__ == '__main__':
    start_http_server(8000)
    collect_custom_metrics()
```

## Troubleshooting Common Issues

### Prometheus Not Scraping Targets
**Symptoms:**
- Targets showing as down in Prometheus UI
- No metrics being collected
- Scrape errors in logs

**Diagnosis:**
```bash
# Check Prometheus configuration
promtool check config prometheus.yml

# Check target accessibility
curl http://target:port/metrics

# Check Prometheus logs
docker logs prometheus
```

**Solutions:**
- Verify target URLs are correct
- Check network connectivity
- Ensure targets are exposing metrics on correct port
- Verify scrape intervals and timeouts

### Grafana Dashboard Not Loading
**Symptoms:**
- Dashboard panels showing "No data"
- Query errors in dashboard
- Slow dashboard loading

**Diagnosis:**
```bash
# Check Grafana logs
docker logs grafana

# Test Prometheus query
curl "http://prometheus:9090/api/v1/query?query=up"

# Check data source configuration
curl -u admin:admin http://grafana:3000/api/datasources
```

**Solutions:**
- Verify data source configuration
- Check query syntax and time ranges
- Ensure Prometheus is accessible from Grafana
- Verify metric names and labels

### High Memory Usage in Monitoring Stack
**Symptoms:**
- Monitoring containers using excessive memory
- System running out of memory
- Slow query performance

**Diagnosis:**
```bash
# Check container memory usage
docker stats

# Check Prometheus memory usage
curl http://prometheus:9090/api/v1/status/config

# Check retention settings
grep retention prometheus.yml
```

**Solutions:**
- Adjust retention policies
- Optimize scrape intervals
- Increase container memory limits
- Use external storage for long-term retention

## Lab Exercises

### Exercise 1: Basic Prometheus Setup
**Goal**: Learn to set up and configure Prometheus
**Steps**:
1. Install and configure Prometheus
2. Add basic scrape targets
3. Create simple alert rules
4. Test metrics collection

### Exercise 2: Grafana Dashboard Creation
**Goal**: Learn to create monitoring dashboards
**Steps**:
1. Set up Grafana
2. Configure Prometheus data source
3. Create system monitoring dashboard
4. Add network monitoring panels

### Exercise 3: SNMP Monitoring
**Goal**: Learn to monitor network devices with SNMP
**Steps**:
1. Configure SNMP agent
2. Set up SNMP monitoring
3. Create SNMP-based dashboards
4. Implement SNMP alerts

### Exercise 4: Log Monitoring with ELK
**Goal**: Learn to aggregate and analyze logs
**Steps**:
1. Set up ELK stack
2. Configure log collection
3. Create log analysis dashboards
4. Set up log-based alerts

### Exercise 5: Application Performance Monitoring
**Goal**: Learn to monitor application performance
**Steps**:
1. Instrument application with metrics
2. Set up APM monitoring
3. Create application dashboards
4. Implement performance alerts

### Exercise 6: Distributed Tracing
**Goal**: Learn to trace requests across services
**Steps**:
1. Set up Jaeger
2. Instrument applications for tracing
3. Create trace analysis dashboards
4. Implement trace-based monitoring

## Quick Reference

### Essential Commands
```bash
# Prometheus
promtool check config prometheus.yml
promtool query instant 'up'
curl http://localhost:9090/api/v1/targets

# Grafana
grafana-cli admin reset-admin-password newpassword
curl -u admin:admin http://localhost:3000/api/datasources

# SNMP
snmpwalk -v2c -c public localhost 1.3.6.1.2.1.1
snmpget -v2c -c public localhost 1.3.6.1.2.1.1.1.0

# System monitoring
top -bn1 | head -20
free -h
df -h
ss -tuna
```

### Common Use Cases
```bash
# Monitor CPU usage
node_cpu_seconds_total

# Monitor memory usage
node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes

# Monitor disk usage
(node_filesystem_size_bytes - node_filesystem_free_bytes) / node_filesystem_size_bytes * 100

# Monitor network traffic
rate(node_network_receive_bytes_total[5m])
rate(node_network_transmit_bytes_total[5m])

# Monitor HTTP requests
rate(http_requests_total[5m])
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
```

### Performance Tips
- **Optimize scrape intervals** based on metric importance
- **Use recording rules** for complex queries
- **Implement proper retention** policies
- **Monitor monitoring stack** itself
- **Use external storage** for long-term retention
- **Implement proper alerting** thresholds

## Security Considerations

### Monitoring Security Best Practices
- **Secure communication** between monitoring components
- **Implement authentication** for monitoring interfaces
- **Use encryption** for sensitive metrics and logs
- **Regular security updates** for monitoring tools
- **Access control** for monitoring dashboards
- **Audit monitoring** access and changes

### Common Security Issues
- **Exposed monitoring interfaces** without authentication
- **Sensitive data** in logs and metrics
- **Insecure communication** between components
- **Privilege escalation** through monitoring tools
- **Data leakage** through monitoring dashboards

### Security Monitoring
- **Monitor access** to monitoring systems
- **Track configuration changes** in monitoring tools
- **Alert on suspicious** monitoring activities
- **Regular security audits** of monitoring setup
- **Implement logging** for security events

## Additional Learning Resources

### Recommended Reading
- **Prometheus Documentation**: Complete Prometheus reference
- **Grafana Documentation**: Dashboard and visualization guide
- **ELK Stack Guide**: Log aggregation and analysis
- **SNMP Monitoring**: Network device monitoring
- **APM Best Practices**: Application performance monitoring

### Online Tools
- **Prometheus Query Builder**: Visual query builder
- **Grafana Dashboard Library**: Pre-built dashboards
- **ELK Stack Tutorials**: Log analysis tutorials
- **SNMP MIB Browser**: SNMP object browser
- **Monitoring Tools Comparison**: Tool selection guide

### Video Tutorials
- **Prometheus Fundamentals**: Basic Prometheus concepts
- **Grafana Dashboard Creation**: Dashboard building
- **ELK Stack Setup**: Log aggregation setup
- **SNMP Monitoring**: Network monitoring
- **APM Implementation**: Application monitoring

---

**Next Steps**: Practice with the lab exercises and explore the analyzer tools to deepen your understanding of monitoring and observability concepts.

