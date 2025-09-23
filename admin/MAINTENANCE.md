# Maintenance Guide

## Overview

This guide covers the maintenance procedures, monitoring, and operational tasks for the Networking Learning Project.

## Maintenance Schedule

### Daily Tasks
- **Health Checks**: Verify all containers are running
- **Log Review**: Check for errors or warnings
- **Resource Monitoring**: Monitor CPU, memory, and disk usage
- **Backup Verification**: Ensure backups are completing successfully

### Weekly Tasks
- **Security Updates**: Check for and apply security patches
- **Performance Review**: Analyze performance metrics
- **Log Rotation**: Manage log file sizes
- **Documentation Updates**: Review and update documentation

### Monthly Tasks
- **Dependency Updates**: Update Python packages and system packages
- **Container Updates**: Update base container images
- **Security Audit**: Review security configurations
- **Performance Optimization**: Optimize system performance

### Quarterly Tasks
- **Major Updates**: Plan and execute major version updates
- **Architecture Review**: Review system architecture
- **Disaster Recovery**: Test backup and recovery procedures
- **Capacity Planning**: Plan for future resource needs

## Health Monitoring

### Container Health Checks

#### Automated Health Checks
```bash
#!/bin/bash
# health-check.sh

# Check if containers are running
check_containers() {
    local containers=("net-practice" "router" "web-server" "dns-server")
    
    for container in "${containers[@]}"; do
        if ! docker ps | grep -q "$container"; then
            echo "ERROR: Container $container is not running"
            return 1
        fi
    done
    
    echo "All containers are running"
    return 0
}

# Check container resources
check_resources() {
    local container="net-practice"
    
    # Check memory usage
    local memory_usage=$(docker stats --no-stream --format "table {{.MemUsage}}" "$container" | tail -1)
    echo "Memory usage: $memory_usage"
    
    # Check CPU usage
    local cpu_usage=$(docker stats --no-stream --format "table {{.CPUPerc}}" "$container" | tail -1)
    echo "CPU usage: $cpu_usage"
}

# Check network connectivity
check_connectivity() {
    local container="net-practice"
    
    # Test internet connectivity
    if docker exec "$container" ping -c 3 8.8.8.8 >/dev/null 2>&1; then
        echo "Internet connectivity: OK"
    else
        echo "Internet connectivity: FAILED"
        return 1
    fi
    
    # Test DNS resolution
    if docker exec "$container" nslookup google.com >/dev/null 2>&1; then
        echo "DNS resolution: OK"
    else
        echo "DNS resolution: FAILED"
        return 1
    fi
}

# Main health check
main() {
    echo "Starting health check..."
    check_containers
    check_resources
    check_connectivity
    echo "Health check completed"
}

main "$@"
```

#### Health Check Script
```python
#!/usr/bin/env python3
"""
Health check script for the Networking Learning Project.
"""

import subprocess
import sys
import json
from datetime import datetime

class HealthChecker:
    def __init__(self):
        self.results = {
            "timestamp": datetime.now().isoformat(),
            "status": "healthy",
            "checks": {}
        }
    
    def check_containers(self):
        """Check if all containers are running."""
        try:
            result = subprocess.run(
                ["docker", "ps", "--format", "{{.Names}}"],
                capture_output=True,
                text=True,
                check=True
            )
            
            running_containers = result.stdout.strip().split('\n')
            expected_containers = ["net-practice", "router", "web-server", "dns-server"]
            
            missing_containers = set(expected_containers) - set(running_containers)
            
            if missing_containers:
                self.results["checks"]["containers"] = {
                    "status": "unhealthy",
                    "message": f"Missing containers: {', '.join(missing_containers)}"
                }
                self.results["status"] = "unhealthy"
            else:
                self.results["checks"]["containers"] = {
                    "status": "healthy",
                    "message": "All containers are running"
                }
                
        except subprocess.CalledProcessError as e:
            self.results["checks"]["containers"] = {
                "status": "error",
                "message": f"Failed to check containers: {e}"
            }
            self.results["status"] = "unhealthy"
    
    def check_resources(self):
        """Check container resource usage."""
        try:
            result = subprocess.run(
                ["docker", "stats", "--no-stream", "--format", "json"],
                capture_output=True,
                text=True,
                check=True
            )
            
            stats = json.loads(result.stdout)
            
            for stat in stats:
                container_name = stat["Name"]
                memory_usage = stat["MemUsage"]
                cpu_usage = stat["CPUPerc"]
                
                self.results["checks"][f"resources_{container_name}"] = {
                    "status": "healthy",
                    "memory": memory_usage,
                    "cpu": cpu_usage
                }
                
        except (subprocess.CalledProcessError, json.JSONDecodeError) as e:
            self.results["checks"]["resources"] = {
                "status": "error",
                "message": f"Failed to check resources: {e}"
            }
    
    def check_connectivity(self):
        """Check network connectivity."""
        try:
            # Test internet connectivity
            result = subprocess.run(
                ["docker", "exec", "net-practice", "ping", "-c", "3", "8.8.8.8"],
                capture_output=True,
                text=True,
                check=True
            )
            
            self.results["checks"]["connectivity"] = {
                "status": "healthy",
                "message": "Internet connectivity OK"
            }
            
        except subprocess.CalledProcessError:
            self.results["checks"]["connectivity"] = {
                "status": "unhealthy",
                "message": "Internet connectivity failed"
            }
            self.results["status"] = "unhealthy"
    
    def run_all_checks(self):
        """Run all health checks."""
        self.check_containers()
        self.check_resources()
        self.check_connectivity()
        
        return self.results

def main():
    checker = HealthChecker()
    results = checker.run_all_checks()
    
    print(json.dumps(results, indent=2))
    
    if results["status"] != "healthy":
        sys.exit(1)

if __name__ == "__main__":
    main()
```

### System Monitoring

#### Resource Monitoring
```bash
#!/bin/bash
# monitor-resources.sh

# Monitor system resources
monitor_system() {
    echo "=== System Resources ==="
    echo "Memory usage:"
    free -h
    
    echo -e "\nDisk usage:"
    df -h
    
    echo -e "\nCPU usage:"
    top -bn1 | grep "Cpu(s)"
}

# Monitor Docker resources
monitor_docker() {
    echo -e "\n=== Docker Resources ==="
    echo "Docker system info:"
    docker system df
    
    echo -e "\nContainer stats:"
    docker stats --no-stream
}

# Monitor network
monitor_network() {
    echo -e "\n=== Network Monitoring ==="
    echo "Network interfaces:"
    ip link show
    
    echo -e "\nNetwork connections:"
    ss -tuln
}

# Main monitoring function
main() {
    monitor_system
    monitor_docker
    monitor_network
}

main "$@"
```

## Log Management

### Log Rotation

#### Logrotate Configuration
```bash
# /etc/logrotate.d/networking-learning
/var/log/networking-learning/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 root root
    postrotate
        docker-compose restart net-practice
    endscript
}
```

#### Log Cleanup Script
```bash
#!/bin/bash
# cleanup-logs.sh

# Clean up old logs
cleanup_logs() {
    local log_dir="/var/log/networking-learning"
    local days_to_keep=30
    
    echo "Cleaning up logs older than $days_to_keep days..."
    
    find "$log_dir" -name "*.log" -type f -mtime +$days_to_keep -delete
    
    echo "Log cleanup completed"
}

# Clean up Docker logs
cleanup_docker_logs() {
    echo "Cleaning up Docker logs..."
    
    # Remove old container logs
    docker system prune -f
    
    # Remove unused images
    docker image prune -f
    
    echo "Docker cleanup completed"
}

# Main cleanup function
main() {
    cleanup_logs
    cleanup_docker_logs
}

main "$@"
```

### Log Analysis

#### Log Analysis Script
```python
#!/usr/bin/env python3
"""
Log analysis script for the Networking Learning Project.
"""

import re
import json
from datetime import datetime, timedelta
from collections import defaultdict

class LogAnalyzer:
    def __init__(self, log_file):
        self.log_file = log_file
        self.errors = []
        self.warnings = []
        self.info = []
        self.stats = defaultdict(int)
    
    def parse_logs(self):
        """Parse log file and categorize entries."""
        with open(self.log_file, 'r') as f:
            for line in f:
                self.categorize_log_entry(line)
    
    def categorize_log_entry(self, line):
        """Categorize a log entry."""
        timestamp_match = re.search(r'(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})', line)
        
        if 'ERROR' in line:
            self.errors.append(line.strip())
            self.stats['errors'] += 1
        elif 'WARNING' in line:
            self.warnings.append(line.strip())
            self.stats['warnings'] += 1
        elif 'INFO' in line:
            self.info.append(line.strip())
            self.stats['info'] += 1
    
    def generate_report(self):
        """Generate analysis report."""
        report = {
            "timestamp": datetime.now().isoformat(),
            "log_file": self.log_file,
            "summary": dict(self.stats),
            "recent_errors": self.errors[-10:],  # Last 10 errors
            "recent_warnings": self.warnings[-10:],  # Last 10 warnings
        }
        
        return report

def main():
    analyzer = LogAnalyzer("/var/log/networking-learning/app.log")
    analyzer.parse_logs()
    report = analyzer.generate_report()
    
    print(json.dumps(report, indent=2))

if __name__ == "__main__":
    main()
```

## Backup and Recovery

### Backup Procedures

#### Automated Backup Script
```bash
#!/bin/bash
# backup.sh

# Configuration
BACKUP_DIR="/backups/networking-learning"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="networking-backup-$DATE"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup data
backup_data() {
    echo "Backing up data..."
    
    # Backup project files
    tar -czf "$BACKUP_DIR/$BACKUP_NAME-data.tar.gz" \
        --exclude='.git' \
        --exclude='node_modules' \
        --exclude='*.log' \
        .
    
    echo "Data backup completed: $BACKUP_DIR/$BACKUP_NAME-data.tar.gz"
}

# Backup configuration
backup_config() {
    echo "Backing up configuration..."
    
    # Backup Docker Compose files
    cp docker-compose.yml "$BACKUP_DIR/$BACKUP_NAME-compose.yml"
    cp .env "$BACKUP_DIR/$BACKUP_NAME-env"
    
    # Backup container configurations
    docker-compose config > "$BACKUP_DIR/$BACKUP_NAME-config.yml"
    
    echo "Configuration backup completed"
}

# Backup database (if applicable)
backup_database() {
    echo "Backing up database..."
    
    # Backup PostgreSQL database
    docker exec db-server pg_dump -U postgres networking_db > "$BACKUP_DIR/$BACKUP_NAME-db.sql"
    
    echo "Database backup completed"
}

# Cleanup old backups
cleanup_old_backups() {
    echo "Cleaning up old backups..."
    
    # Keep only last 30 days of backups
    find "$BACKUP_DIR" -name "networking-backup-*" -type f -mtime +30 -delete
    
    echo "Old backups cleaned up"
}

# Main backup function
main() {
    echo "Starting backup process..."
    
    backup_data
    backup_config
    backup_database
    cleanup_old_backups
    
    echo "Backup process completed"
}

main "$@"
```

#### Recovery Procedures
```bash
#!/bin/bash
# restore.sh

# Configuration
BACKUP_DIR="/backups/networking-learning"
BACKUP_NAME="$1"

if [ -z "$BACKUP_NAME" ]; then
    echo "Usage: $0 <backup-name>"
    echo "Available backups:"
    ls -la "$BACKUP_DIR" | grep "networking-backup-"
    exit 1
fi

# Restore data
restore_data() {
    echo "Restoring data from $BACKUP_NAME..."
    
    # Stop services
    docker-compose down
    
    # Restore project files
    tar -xzf "$BACKUP_DIR/$BACKUP_NAME-data.tar.gz"
    
    echo "Data restore completed"
}

# Restore configuration
restore_config() {
    echo "Restoring configuration..."
    
    # Restore Docker Compose files
    cp "$BACKUP_DIR/$BACKUP_NAME-compose.yml" docker-compose.yml
    cp "$BACKUP_DIR/$BACKUP_NAME-env" .env
    
    echo "Configuration restore completed"
}

# Restore database
restore_database() {
    echo "Restoring database..."
    
    # Start database container
    docker-compose up -d db-server
    
    # Wait for database to be ready
    sleep 30
    
    # Restore database
    docker exec -i db-server psql -U postgres networking_db < "$BACKUP_DIR/$BACKUP_NAME-db.sql"
    
    echo "Database restore completed"
}

# Main restore function
main() {
    echo "Starting restore process from $BACKUP_NAME..."
    
    restore_data
    restore_config
    restore_database
    
    # Start services
    docker-compose up -d
    
    echo "Restore process completed"
}

main "$@"
```

## Security Maintenance

### Security Updates

#### Update Script
```bash
#!/bin/bash
# security-update.sh

# Update system packages
update_system() {
    echo "Updating system packages..."
    
    # Update package lists
    apt update
    
    # Upgrade packages
    apt upgrade -y
    
    # Clean up
    apt autoremove -y
    apt autoclean
    
    echo "System packages updated"
}

# Update Docker images
update_docker() {
    echo "Updating Docker images..."
    
    # Pull latest images
    docker-compose pull
    
    # Rebuild containers
    docker-compose build --no-cache
    
    # Restart services
    docker-compose down
    docker-compose up -d
    
    echo "Docker images updated"
}

# Update Python packages
update_python() {
    echo "Updating Python packages..."
    
    # Update requirements.txt
    docker exec net-practice pip install --upgrade pip
    
    # Update packages
    docker exec net-practice pip install -r /scripts/requirements.txt --upgrade
    
    echo "Python packages updated"
}

# Security audit
security_audit() {
    echo "Running security audit..."
    
    # Check for security vulnerabilities
    docker exec net-practice pip audit
    
    # Check for outdated packages
    docker exec net-practice pip list --outdated
    
    echo "Security audit completed"
}

# Main update function
main() {
    echo "Starting security update process..."
    
    update_system
    update_docker
    update_python
    security_audit
    
    echo "Security update process completed"
}

main "$@"
```

### Security Monitoring

#### Security Monitoring Script
```python
#!/usr/bin/env python3
"""
Security monitoring script for the Networking Learning Project.
"""

import subprocess
import json
import re
from datetime import datetime

class SecurityMonitor:
    def __init__(self):
        self.alerts = []
        self.results = {
            "timestamp": datetime.now().isoformat(),
            "security_status": "secure",
            "alerts": []
        }
    
    def check_container_security(self):
        """Check container security configurations."""
        try:
            # Check for privileged containers
            result = subprocess.run(
                ["docker", "ps", "--format", "{{.Names}}\t{{.Command}}"],
                capture_output=True,
                text=True,
                check=True
            )
            
            for line in result.stdout.strip().split('\n'):
                if 'privileged' in line.lower():
                    self.alerts.append(f"Privileged container detected: {line}")
            
            # Check for root user in containers
            result = subprocess.run(
                ["docker", "exec", "net-practice", "whoami"],
                capture_output=True,
                text=True,
                check=True
            )
            
            if result.stdout.strip() == "root":
                self.alerts.append("Container running as root user")
                
        except subprocess.CalledProcessError as e:
            self.alerts.append(f"Failed to check container security: {e}")
    
    def check_network_security(self):
        """Check network security configurations."""
        try:
            # Check for exposed ports
            result = subprocess.run(
                ["docker", "ps", "--format", "{{.Names}}\t{{.Ports}}"],
                capture_output=True,
                text=True,
                check=True
            )
            
            for line in result.stdout.strip().split('\n'):
                if '0.0.0.0:' in line:
                    self.alerts.append(f"Exposed port detected: {line}")
                    
        except subprocess.CalledProcessError as e:
            self.alerts.append(f"Failed to check network security: {e}")
    
    def check_file_permissions(self):
        """Check file permissions."""
        try:
            # Check for world-writable files
            result = subprocess.run(
                ["find", ".", "-type", "f", "-perm", "-002"],
                capture_output=True,
                text=True,
                check=True
            )
            
            if result.stdout.strip():
                self.alerts.append("World-writable files detected")
                
        except subprocess.CalledProcessError:
            pass  # No world-writable files found
    
    def generate_report(self):
        """Generate security report."""
        if self.alerts:
            self.results["security_status"] = "at_risk"
            self.results["alerts"] = self.alerts
        
        return self.results

def main():
    monitor = SecurityMonitor()
    monitor.check_container_security()
    monitor.check_network_security()
    monitor.check_file_permissions()
    
    report = monitor.generate_report()
    print(json.dumps(report, indent=2))

if __name__ == "__main__":
    main()
```

## Performance Optimization

### Performance Monitoring

#### Performance Metrics Script
```python
#!/usr/bin/env python3
"""
Performance monitoring script for the Networking Learning Project.
"""

import subprocess
import json
import time
from datetime import datetime

class PerformanceMonitor:
    def __init__(self):
        self.metrics = {
            "timestamp": datetime.now().isoformat(),
            "system": {},
            "containers": {},
            "network": {}
        }
    
    def collect_system_metrics(self):
        """Collect system performance metrics."""
        try:
            # CPU usage
            result = subprocess.run(
                ["top", "-bn1", "|", "grep", "Cpu(s)"],
                shell=True,
                capture_output=True,
                text=True
            )
            
            cpu_match = re.search(r'(\d+\.\d+)%', result.stdout)
            if cpu_match:
                self.metrics["system"]["cpu_usage"] = float(cpu_match.group(1))
            
            # Memory usage
            result = subprocess.run(
                ["free", "-m"],
                capture_output=True,
                text=True,
                check=True
            )
            
            lines = result.stdout.strip().split('\n')
            mem_line = lines[1].split()
            total_mem = int(mem_line[1])
            used_mem = int(mem_line[2])
            
            self.metrics["system"]["memory_usage_percent"] = (used_mem / total_mem) * 100
            self.metrics["system"]["memory_total_mb"] = total_mem
            self.metrics["system"]["memory_used_mb"] = used_mem
            
            # Disk usage
            result = subprocess.run(
                ["df", "-h", "/"],
                capture_output=True,
                text=True,
                check=True
            )
            
            lines = result.stdout.strip().split('\n')
            disk_line = lines[1].split()
            self.metrics["system"]["disk_usage"] = disk_line[4]
            
        except subprocess.CalledProcessError as e:
            self.metrics["system"]["error"] = str(e)
    
    def collect_container_metrics(self):
        """Collect container performance metrics."""
        try:
            result = subprocess.run(
                ["docker", "stats", "--no-stream", "--format", "json"],
                capture_output=True,
                text=True,
                check=True
            )
            
            stats = json.loads(result.stdout)
            
            for stat in stats:
                container_name = stat["Name"]
                self.metrics["containers"][container_name] = {
                    "cpu_percent": stat["CPUPerc"],
                    "memory_usage": stat["MemUsage"],
                    "memory_percent": stat["MemPerc"],
                    "network_io": stat["NetIO"],
                    "block_io": stat["BlockIO"]
                }
                
        except (subprocess.CalledProcessError, json.JSONDecodeError) as e:
            self.metrics["containers"]["error"] = str(e)
    
    def collect_network_metrics(self):
        """Collect network performance metrics."""
        try:
            # Network interface statistics
            result = subprocess.run(
                ["cat", "/proc/net/dev"],
                capture_output=True,
                text=True,
                check=True
            )
            
            lines = result.stdout.strip().split('\n')
            for line in lines[2:]:  # Skip header lines
                if ':' in line:
                    interface = line.split(':')[0].strip()
                    stats = line.split(':')[1].split()
                    
                    self.metrics["network"][interface] = {
                        "rx_bytes": int(stats[0]),
                        "rx_packets": int(stats[1]),
                        "rx_errors": int(stats[2]),
                        "tx_bytes": int(stats[8]),
                        "tx_packets": int(stats[9]),
                        "tx_errors": int(stats[10])
                    }
                    
        except subprocess.CalledProcessError as e:
            self.metrics["network"]["error"] = str(e)
    
    def collect_all_metrics(self):
        """Collect all performance metrics."""
        self.collect_system_metrics()
        self.collect_container_metrics()
        self.collect_network_metrics()
        
        return self.metrics

def main():
    monitor = PerformanceMonitor()
    metrics = monitor.collect_all_metrics()
    
    print(json.dumps(metrics, indent=2))

if __name__ == "__main__":
    main()
```

## Disaster Recovery

### Recovery Procedures

#### Disaster Recovery Plan
```bash
#!/bin/bash
# disaster-recovery.sh

# Configuration
BACKUP_DIR="/backups/networking-learning"
RECOVERY_DIR="/recovery/networking-learning"

# Full system recovery
full_recovery() {
    echo "Starting full system recovery..."
    
    # Create recovery directory
    mkdir -p "$RECOVERY_DIR"
    
    # Stop all services
    docker-compose down
    
    # Remove all containers and images
    docker system prune -a -f
    
    # Restore from latest backup
    LATEST_BACKUP=$(ls -t "$BACKUP_DIR" | grep "networking-backup-" | head -1)
    
    if [ -z "$LATEST_BACKUP" ]; then
        echo "ERROR: No backup found"
        exit 1
    fi
    
    echo "Restoring from backup: $LATEST_BACKUP"
    
    # Restore data
    tar -xzf "$BACKUP_DIR/$LATEST_BACKUP-data.tar.gz" -C "$RECOVERY_DIR"
    
    # Restore configuration
    cp "$BACKUP_DIR/$LATEST_BACKUP-compose.yml" "$RECOVERY_DIR/docker-compose.yml"
    cp "$BACKUP_DIR/$LATEST_BACKUP-env" "$RECOVERY_DIR/.env"
    
    # Rebuild and start services
    cd "$RECOVERY_DIR"
    docker-compose build
    docker-compose up -d
    
    echo "Full system recovery completed"
}

# Partial recovery
partial_recovery() {
    echo "Starting partial recovery..."
    
    # Restart specific service
    docker-compose restart net-practice
    
    # Check service health
    docker-compose ps
    
    echo "Partial recovery completed"
}

# Main recovery function
main() {
    case "$1" in
        "full")
            full_recovery
            ;;
        "partial")
            partial_recovery
            ;;
        *)
            echo "Usage: $0 {full|partial}"
            exit 1
            ;;
    esac
}

main "$@"
```

## Maintenance Automation

### Automated Maintenance Script
```bash
#!/bin/bash
# automated-maintenance.sh

# Configuration
LOG_FILE="/var/log/networking-learning/maintenance.log"
BACKUP_DIR="/backups/networking-learning"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Daily maintenance
daily_maintenance() {
    log "Starting daily maintenance..."
    
    # Health check
    ./health-check.sh
    
    # Log rotation
    ./cleanup-logs.sh
    
    # Resource monitoring
    ./monitor-resources.sh
    
    log "Daily maintenance completed"
}

# Weekly maintenance
weekly_maintenance() {
    log "Starting weekly maintenance..."
    
    # Security updates
    ./security-update.sh
    
    # Performance monitoring
    ./performance-monitor.sh
    
    # Backup
    ./backup.sh
    
    log "Weekly maintenance completed"
}

# Monthly maintenance
monthly_maintenance() {
    log "Starting monthly maintenance..."
    
    # Dependency updates
    docker-compose pull
    docker-compose build --no-cache
    
    # Security audit
    ./security-monitor.sh
    
    # Performance optimization
    ./performance-optimizer.sh
    
    log "Monthly maintenance completed"
}

# Main maintenance function
main() {
    case "$1" in
        "daily")
            daily_maintenance
            ;;
        "weekly")
            weekly_maintenance
            ;;
        "monthly")
            monthly_maintenance
            ;;
        *)
            echo "Usage: $0 {daily|weekly|monthly}"
            exit 1
            ;;
    esac
}

main "$@"
```

### Cron Job Configuration
```bash
# /etc/crontab
# Daily maintenance at 2 AM
0 2 * * * root /opt/networking-learning/admin/automated-maintenance.sh daily

# Weekly maintenance on Sundays at 3 AM
0 3 * * 0 root /opt/networking-learning/admin/automated-maintenance.sh weekly

# Monthly maintenance on the 1st at 4 AM
0 4 1 * * root /opt/networking-learning/admin/automated-maintenance.sh monthly
```

---

*This maintenance guide provides comprehensive procedures for maintaining the Networking Learning Project in production environments.*
