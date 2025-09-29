# Monitoring Quick Reference

## Essential Commands

### Prometheus Monitoring
```bash
# Test configuration
promtool check config prometheus.yml

# Query metrics
promtool query instant 'up'
curl http://localhost:9090/api/v1/query?query=up

# Check targets
curl http://localhost:9090/api/v1/targets

# Check rules
curl http://localhost:9090/api/v1/rules

# Check alerts
curl http://localhost:9090/api/v1/alerts

# Reload configuration
curl -X POST http://localhost:9090/-/reload
```

### Grafana Monitoring
```bash
# Check status
systemctl status grafana-server

# Check API health
curl http://localhost:3000/api/health

# List data sources
curl -u admin:admin http://localhost:3000/api/datasources

# List dashboards
curl -u admin:admin http://localhost:3000/api/search?type=dash-db

# Test data source
curl -u admin:admin http://localhost:3000/api/datasources/1/health
```

### ELK Stack Monitoring
```bash
# Elasticsearch health
curl http://localhost:9200/_cluster/health

# Elasticsearch indices
curl http://localhost:9200/_cat/indices

# Logstash status
systemctl status logstash

# Kibana status
curl http://localhost:5601/api/status
```

### System Monitoring
```bash
# CPU usage
top -bn1 | grep "Cpu(s)"
htop

# Memory usage
free -h
cat /proc/meminfo

# Disk usage
df -h
du -sh /var/lib/prometheus

# Network statistics
ss -tuna
netstat -tuna
ip addr show

# Process monitoring
ps aux --sort=-%cpu
ps aux --sort=-%mem
```

## Prometheus Query Language (PromQL)

### Basic Queries
```promql
# All metrics
up

# CPU usage percentage
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory usage percentage
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100

# Disk usage percentage
(node_filesystem_size_bytes - node_filesystem_free_bytes) / node_filesystem_size_bytes * 100

# Network traffic rate
rate(node_network_receive_bytes_total[5m])
rate(node_network_transmit_bytes_total[5m])
```

### Aggregation Functions
```promql
# Sum across instances
sum(up)

# Average across instances
avg(up)

# Maximum across instances
max(up)

# Count of instances
count(up)

# Group by labels
sum by (job) (up)

# Top 5 instances
topk(5, up)
```

### Time-based Queries
```promql
# Rate over 5 minutes
rate(http_requests_total[5m])

# Increase over 1 hour
increase(http_requests_total[1h])

# Average over 10 minutes
avg_over_time(node_cpu_seconds_total[10m])

# Quantile (95th percentile)
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
```

### Alerting Queries
```promql
# High CPU usage
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80

# High memory usage
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 90

# Disk space low
(node_filesystem_size_bytes - node_filesystem_free_bytes) / node_filesystem_size_bytes * 100 > 90

# High error rate
rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) * 100 > 5

# High response time
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1
```

## Grafana Dashboard Queries

### System Metrics
```promql
# CPU Usage
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory Usage
node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes

# Disk Usage
node_filesystem_size_bytes - node_filesystem_free_bytes

# Network Traffic
rate(node_network_receive_bytes_total[5m])
rate(node_network_transmit_bytes_total[5m])
```

### Application Metrics
```promql
# HTTP Requests
rate(http_requests_total[5m])

# Response Time
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# Error Rate
rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) * 100

# Active Connections
node_netstat_Tcp_CurrEstab
```

### Business Metrics
```promql
# User Registrations
increase(user_registrations_total[1h])

# Order Volume
increase(orders_total[1h])

# Revenue
increase(revenue_total[1h])

# Conversion Rate
rate(orders_total[5m]) / rate(visitors_total[5m]) * 100
```

## Alert Rules Configuration

### System Alerts
```yaml
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
```

### Application Alerts
```yaml
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
      
      - alert: ServiceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Service is down"
          description: "Service {{ $labels.job }} on {{ $labels.instance }} is down"
```

## Alertmanager Configuration

### Basic Configuration
```yaml
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
```

### Advanced Configuration
```yaml
global:
  smtp_smarthost: 'smtp.company.com:587'
  smtp_from: 'alerts@company.com'
  smtp_auth_username: 'alerts@company.com'
  smtp_auth_password: 'password'

route:
  group_by: ['alertname', 'cluster']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'default'
  routes:
    - match:
        severity: critical
      receiver: 'critical-alerts'
    - match:
        severity: warning
      receiver: 'warning-alerts'

receivers:
  - name: 'default'
    webhook_configs:
      - url: 'http://webhook:5001/'
  
  - name: 'critical-alerts'
    email_configs:
      - to: 'admin@company.com'
        subject: 'CRITICAL: {{ .GroupLabels.alertname }}'
        body: |
          {{ range .Alerts }}
          Alert: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          {{ end }}
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/...'
        channel: '#critical-alerts'
        title: 'CRITICAL: {{ .GroupLabels.alertname }}'
        text: |
          {{ range .Alerts }}
          {{ .Annotations.summary }}
          {{ .Annotations.description }}
          {{ end }}
  
  - name: 'warning-alerts'
    email_configs:
      - to: 'team@company.com'
        subject: 'WARNING: {{ .GroupLabels.alertname }}'
        body: |
          {{ range .Alerts }}
          Alert: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          {{ end }}
```

## SNMP Monitoring

### Basic SNMP Commands
```bash
# Get system description
snmpget -v2c -c public localhost 1.3.6.1.2.1.1.1.0

# Get system uptime
snmpget -v2c -c public localhost 1.3.6.1.2.1.1.3.0

# Walk system information
snmpwalk -v2c -c public localhost 1.3.6.1.2.1.1

# Walk interface information
snmpwalk -v2c -c public localhost 1.3.6.1.2.1.2.2.1

# Get interface status
snmpget -v2c -c public localhost 1.3.6.1.2.1.2.2.1.8.1
```

### SNMP OIDs Reference
```bash
# System Information
1.3.6.1.2.1.1.1.0    # System Description
1.3.6.1.2.1.1.3.0    # System Uptime
1.3.6.1.2.1.1.5.0    # System Name
1.3.6.1.2.1.1.6.0    # System Location

# Interface Information
1.3.6.1.2.1.2.2.1.2  # Interface Description
1.3.6.1.2.1.2.2.1.7  # Interface Admin Status
1.3.6.1.2.1.2.2.1.8  # Interface Oper Status
1.3.6.1.2.1.2.2.1.10 # Interface In Octets
1.3.6.1.2.1.2.2.1.16 # Interface Out Octets

# CPU Information
1.3.6.1.4.1.2021.11.11.0  # CPU Load 1 minute
1.3.6.1.4.1.2021.11.11.1  # CPU Load 5 minutes
1.3.6.1.4.1.2021.11.11.2  # CPU Load 15 minutes

# Memory Information
1.3.6.1.4.1.2021.4.5.0    # Total RAM
1.3.6.1.4.1.2021.4.6.0    # Available RAM
1.3.6.1.4.1.2021.4.11.0   # Total Swap
1.3.6.1.4.1.2021.4.12.0   # Available Swap
```

## Log Monitoring

### Log Analysis Commands
```bash
# Search for errors
grep -i error /var/log/syslog
grep -i error /var/log/nginx/error.log

# Count log entries
wc -l /var/log/nginx/access.log
grep -c "ERROR" /var/log/application.log

# Monitor logs in real-time
tail -f /var/log/nginx/access.log
tail -f /var/log/application.log

# Search with context
grep -A 5 -B 5 "ERROR" /var/log/application.log

# Filter by time range
grep "2024-01-01" /var/log/nginx/access.log
```

### Logstash Configuration
```ruby
input {
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
```

## Performance Testing

### Load Testing Commands
```bash
# Apache Bench
ab -n 1000 -c 10 http://localhost:9090/
ab -n 1000 -c 10 http://localhost:3000/

# Load testing with curl
for i in {1..100}; do
  curl -s http://localhost:9090/ > /dev/null &
done
wait

# Stress testing
stress --cpu 4 --timeout 60s
stress --vm 2 --timeout 60s
stress --io 4 --timeout 60s
```

### Monitoring Performance
```bash
# Monitor system resources
htop
iotop
nethogs

# Monitor network connections
ss -tuna | wc -l
netstat -tuna | wc -l

# Monitor disk I/O
iostat -x 1
iotop -o

# Monitor memory usage
free -h
cat /proc/meminfo
```

## Docker Monitoring

### Container Monitoring
```bash
# List running containers
docker ps

# Container statistics
docker stats

# Container logs
docker logs container_name
docker logs -f container_name

# Container resource usage
docker exec container_name top
docker exec container_name free -h
```

### Docker Compose Monitoring
```yaml
version: '3.8'
services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:9090/"]
      interval: 30s
      timeout: 10s
      retries: 3
  
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:3000/api/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
```

## Common Use Cases

### System Monitoring Dashboard
```promql
# CPU Usage
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory Usage
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100

# Disk Usage
(node_filesystem_size_bytes - node_filesystem_free_bytes) / node_filesystem_size_bytes * 100

# Network Traffic
rate(node_network_receive_bytes_total[5m])
rate(node_network_transmit_bytes_total[5m])
```

### Application Monitoring Dashboard
```promql
# Request Rate
rate(http_requests_total[5m])

# Response Time
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# Error Rate
rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) * 100

# Active Connections
node_netstat_Tcp_CurrEstab
```

### Business Metrics Dashboard
```promql
# User Registrations
increase(user_registrations_total[1h])

# Order Volume
increase(orders_total[1h])

# Revenue
increase(revenue_total[1h])

# Conversion Rate
rate(orders_total[5m]) / rate(visitors_total[5m]) * 100
```

## Troubleshooting Commands

### Check Service Status
```bash
# System services
systemctl status prometheus
systemctl status grafana-server
systemctl status elasticsearch
systemctl status alertmanager

# Docker services
docker ps
docker logs container_name
docker exec container_name ps aux
```

### Check Configuration
```bash
# Prometheus configuration
promtool check config prometheus.yml

# Grafana configuration
grafana-cli admin reset-admin-password newpassword

# Alertmanager configuration
amtool check-config alertmanager.yml
```

### Check Connectivity
```bash
# Test HTTP endpoints
curl -I http://localhost:9090/
curl -I http://localhost:3000/
curl -I http://localhost:9200/

# Test API endpoints
curl http://localhost:9090/api/v1/query?query=up
curl http://localhost:3000/api/health
curl http://localhost:9200/_cluster/health
```

### Performance Analysis
```bash
# System resources
top -bn1 | head -20
free -h
df -h
ss -tuna | wc -l

# Process analysis
ps aux --sort=-%cpu | head -10
ps aux --sort=-%mem | head -10

# Network analysis
ss -tuna | grep -E ":(9090|3000|9200)"
netstat -tuna | grep -E ":(9090|3000|9200)"
```

## Best Practices

### Monitoring Best Practices
- **Set appropriate alert thresholds** based on baseline metrics
- **Use multiple alerting channels** (email, Slack, PagerDuty)
- **Implement alert grouping** to reduce noise
- **Regular review and tuning** of alert rules
- **Monitor the monitoring system** itself
- **Use proper retention policies** for metrics and logs

### Performance Best Practices
- **Optimize scrape intervals** based on metric importance
- **Use recording rules** for complex queries
- **Implement proper indexing** for log data
- **Monitor resource usage** of monitoring components
- **Use external storage** for long-term retention
- **Implement proper caching** strategies

### Security Best Practices
- **Secure communication** between monitoring components
- **Implement authentication** for monitoring interfaces
- **Use encryption** for sensitive metrics and logs
- **Regular security updates** for monitoring tools
- **Access control** for monitoring dashboards
- **Audit monitoring** access and changes

---

**Quick Tips:**
- Always test alert rules before deploying
- Use proper time ranges for queries
- Monitor the monitoring system itself
- Implement proper log rotation
- Regular backup of configurations
- Document alert procedures and runbooks

