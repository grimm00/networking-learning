#!/usr/bin/env python3
"""
Monitoring Analyzer Tool
Analyzes monitoring systems, metrics, and provides optimization recommendations.
"""

import subprocess
import argparse
import json
import re
import time
import requests
import psutil
import socket
from collections import defaultdict, Counter
from datetime import datetime, timedelta
import threading
from concurrent.futures import ThreadPoolExecutor

class MonitoringAnalyzer:
    def __init__(self):
        self.monitoring_systems = []
        self.metrics_data = {}
        self.alert_rules = {}
        self.dashboard_configs = {}
        
    def run_command(self, command):
        """Run shell command and return output"""
        try:
            result = subprocess.run(command, shell=True, capture_output=True, text=True, timeout=30)
            if result.returncode != 0:
                print(f"Error running command: {result.stderr}")
                return None
            return result.stdout
        except subprocess.TimeoutExpired:
            print("Command timed out")
            return None
        except Exception as e:
            print(f"Error running command: {e}")
            return None
    
    def check_prometheus_status(self):
        """Check Prometheus monitoring status"""
        print("=== Prometheus Monitoring Analysis ===")
        
        # Check if Prometheus is running
        prometheus_status = self.run_command("systemctl is-active prometheus 2>/dev/null || pgrep prometheus")
        if not prometheus_status:
            print("❌ Prometheus is not running")
            return
        
        print("✅ Prometheus is running")
        
        # Check Prometheus configuration
        config_test = self.run_command("promtool check config /etc/prometheus/prometheus.yml 2>&1")
        if config_test and "SUCCESS" in config_test:
            print("✅ Prometheus configuration is valid")
        else:
            print("❌ Prometheus configuration has errors")
            print(f"Errors: {config_test}")
        
        # Check Prometheus targets
        try:
            response = requests.get("http://localhost:9090/api/v1/targets", timeout=5)
            if response.status_code == 200:
                targets = response.json()
                print(f"\nPrometheus Targets:")
                for target in targets['data']['activeTargets']:
                    status = "✅" if target['health'] == 'up' else "❌"
                    print(f"  {status} {target['labels']['job']}: {target['scrapeUrl']}")
        except:
            print("Prometheus API not accessible")
        
        # Check Prometheus metrics
        try:
            response = requests.get("http://localhost:9090/api/v1/query?query=up", timeout=5)
            if response.status_code == 200:
                metrics = response.json()
                print(f"\nPrometheus Metrics Available: {len(metrics['data']['result'])}")
        except:
            print("Prometheus metrics not accessible")
    
    def check_grafana_status(self):
        """Check Grafana monitoring status"""
        print("\n=== Grafana Monitoring Analysis ===")
        
        # Check if Grafana is running
        grafana_status = self.run_command("systemctl is-active grafana-server 2>/dev/null || pgrep grafana")
        if not grafana_status:
            print("❌ Grafana is not running")
            return
        
        print("✅ Grafana is running")
        
        # Check Grafana API
        try:
            response = requests.get("http://localhost:3000/api/health", timeout=5)
            if response.status_code == 200:
                health = response.json()
                print(f"✅ Grafana health: {health.get('database', 'unknown')}")
        except:
            print("❌ Grafana API not accessible")
        
        # Check data sources
        try:
            response = requests.get("http://localhost:3000/api/datasources", 
                                 auth=('admin', 'admin'), timeout=5)
            if response.status_code == 200:
                datasources = response.json()
                print(f"\nGrafana Data Sources: {len(datasources)}")
                for ds in datasources:
                    print(f"  - {ds['name']}: {ds['type']}")
        except:
            print("Grafana data sources not accessible")
        
        # Check dashboards
        try:
            response = requests.get("http://localhost:3000/api/search?type=dash-db", 
                                 auth=('admin', 'admin'), timeout=5)
            if response.status_code == 200:
                dashboards = response.json()
                print(f"\nGrafana Dashboards: {len(dashboards)}")
                for db in dashboards[:5]:  # Show first 5
                    print(f"  - {db['title']}")
        except:
            print("Grafana dashboards not accessible")
    
    def analyze_system_metrics(self):
        """Analyze system metrics and performance"""
        print("\n=== System Metrics Analysis ===")
        
        # CPU metrics
        cpu_percent = psutil.cpu_percent(interval=1)
        cpu_count = psutil.cpu_count()
        cpu_freq = psutil.cpu_freq()
        
        print(f"CPU Usage: {cpu_percent}%")
        print(f"CPU Cores: {cpu_count}")
        if cpu_freq:
            print(f"CPU Frequency: {cpu_freq.current:.2f} MHz")
        
        # Memory metrics
        memory = psutil.virtual_memory()
        swap = psutil.swap_memory()
        
        print(f"\nMemory Usage:")
        print(f"  Total: {memory.total / (1024**3):.2f} GB")
        print(f"  Available: {memory.available / (1024**3):.2f} GB")
        print(f"  Used: {memory.used / (1024**3):.2f} GB ({memory.percent}%)")
        print(f"  Swap: {swap.used / (1024**3):.2f} GB / {swap.total / (1024**3):.2f} GB")
        
        # Disk metrics
        disk_usage = psutil.disk_usage('/')
        disk_io = psutil.disk_io_counters()
        
        print(f"\nDisk Usage:")
        print(f"  Total: {disk_usage.total / (1024**3):.2f} GB")
        print(f"  Used: {disk_usage.used / (1024**3):.2f} GB")
        print(f"  Free: {disk_usage.free / (1024**3):.2f} GB")
        print(f"  Usage: {(disk_usage.used / disk_usage.total) * 100:.1f}%")
        
        if disk_io:
            print(f"\nDisk I/O:")
            print(f"  Read: {disk_io.read_bytes / (1024**2):.2f} MB")
            print(f"  Write: {disk_io.write_bytes / (1024**2):.2f} MB")
            print(f"  Read Count: {disk_io.read_count}")
            print(f"  Write Count: {disk_io.write_count}")
        
        # Network metrics
        net_io = psutil.net_io_counters()
        connections = len(psutil.net_connections())
        
        print(f"\nNetwork:")
        print(f"  Bytes Received: {net_io.bytes_recv / (1024**2):.2f} MB")
        print(f"  Bytes Sent: {net_io.bytes_sent / (1024**2):.2f} MB")
        print(f"  Packets Received: {net_io.packets_recv}")
        print(f"  Packets Sent: {net_io.packets_sent}")
        print(f"  Active Connections: {connections}")
        
        # Process metrics
        processes = list(psutil.process_iter(['pid', 'name', 'cpu_percent', 'memory_percent']))
        total_processes = len(processes)
        
        # Top processes by CPU
        top_cpu = sorted(processes, key=lambda x: x.info['cpu_percent'] or 0, reverse=True)[:5]
        print(f"\nTop CPU Processes:")
        for proc in top_cpu:
            if proc.info['cpu_percent']:
                print(f"  {proc.info['name']}: {proc.info['cpu_percent']:.1f}%")
        
        # Top processes by memory
        top_memory = sorted(processes, key=lambda x: x.info['memory_percent'] or 0, reverse=True)[:5]
        print(f"\nTop Memory Processes:")
        for proc in top_memory:
            if proc.info['memory_percent']:
                print(f"  {proc.info['name']}: {proc.info['memory_percent']:.1f}%")
    
    def analyze_network_monitoring(self):
        """Analyze network monitoring capabilities"""
        print("\n=== Network Monitoring Analysis ===")
        
        # Check network interfaces
        interfaces = psutil.net_if_addrs()
        stats = psutil.net_if_stats()
        
        print("Network Interfaces:")
        for interface, addresses in interfaces.items():
            if interface == 'lo':
                continue
                
            print(f"\n{interface}:")
            
            # Interface addresses
            for addr in addresses:
                if addr.family == socket.AF_INET:
                    print(f"  IPv4: {addr.address}")
                elif addr.family == socket.AF_INET6:
                    print(f"  IPv6: {addr.address}")
                elif addr.family == psutil.AF_LINK:
                    print(f"  MAC: {addr.address}")
            
            # Interface statistics
            if interface in stats:
                stat = stats[interface]
                print(f"  Status: {'UP' if stat.isup else 'DOWN'}")
                print(f"  Speed: {stat.speed} Mbps")
                print(f"  MTU: {stat.mtu}")
                print(f"  Duplex: {stat.duplex}")
        
        # Check network connections
        connections = psutil.net_connections()
        connection_stats = defaultdict(int)
        
        for conn in connections:
            if conn.status:
                connection_stats[conn.status] += 1
        
        print(f"\nConnection Statistics:")
        for status, count in connection_stats.items():
            print(f"  {status}: {count}")
        
        # Check listening ports
        listening_ports = []
        for conn in connections:
            if conn.status == 'LISTEN':
                listening_ports.append(conn.laddr.port)
        
        print(f"\nListening Ports: {sorted(set(listening_ports))}")
        
        # Check SNMP availability
        snmp_available = self.run_command("which snmpwalk snmpget 2>/dev/null")
        if snmp_available:
            print("\n✅ SNMP tools available")
        else:
            print("\n❌ SNMP tools not available")
    
    def analyze_log_monitoring(self):
        """Analyze log monitoring capabilities"""
        print("\n=== Log Monitoring Analysis ===")
        
        # Check common log files
        log_files = [
            '/var/log/syslog',
            '/var/log/messages',
            '/var/log/auth.log',
            '/var/log/nginx/access.log',
            '/var/log/nginx/error.log',
            '/var/log/apache2/access.log',
            '/var/log/apache2/error.log'
        ]
        
        available_logs = []
        for log_file in log_files:
            if self.run_command(f"test -f {log_file} && echo 'exists'"):
                available_logs.append(log_file)
        
        print(f"Available Log Files: {len(available_logs)}")
        for log_file in available_logs:
            print(f"  - {log_file}")
        
        # Check log rotation
        logrotate_status = self.run_command("systemctl is-active logrotate 2>/dev/null")
        if logrotate_status:
            print(f"\n✅ Log rotation active")
        else:
            print(f"\n❌ Log rotation not active")
        
        # Check ELK stack
        elk_services = ['elasticsearch', 'logstash', 'kibana']
        elk_status = {}
        
        for service in elk_services:
            status = self.run_command(f"systemctl is-active {service} 2>/dev/null || pgrep {service}")
            elk_status[service] = bool(status)
        
        print(f"\nELK Stack Status:")
        for service, status in elk_status.items():
            icon = "✅" if status else "❌"
            print(f"  {icon} {service}")
        
        # Check log file sizes
        print(f"\nLog File Sizes:")
        for log_file in available_logs[:5]:  # Check first 5
            size = self.run_command(f"du -h {log_file} 2>/dev/null | cut -f1")
            if size:
                print(f"  {log_file}: {size.strip()}")
    
    def analyze_alerting_system(self):
        """Analyze alerting system configuration"""
        print("\n=== Alerting System Analysis ===")
        
        # Check Prometheus alert rules
        alert_rules_file = '/etc/prometheus/alert_rules.yml'
        if self.run_command(f"test -f {alert_rules_file}"):
            print("✅ Prometheus alert rules file found")
            
            # Parse alert rules
            with open(alert_rules_file, 'r') as f:
                content = f.read()
            
            # Count alert rules
            alert_count = content.count('alert:')
            print(f"  Alert rules: {alert_count}")
            
            # Extract alert names
            alert_names = re.findall(r'alert:\s+(\w+)', content)
            print(f"  Alert names: {', '.join(alert_names[:5])}")
        else:
            print("❌ Prometheus alert rules file not found")
        
        # Check Alertmanager
        alertmanager_status = self.run_command("systemctl is-active alertmanager 2>/dev/null || pgrep alertmanager")
        if alertmanager_status:
            print("✅ Alertmanager is running")
            
            # Check Alertmanager configuration
            try:
                response = requests.get("http://localhost:9093/api/v1/status", timeout=5)
                if response.status_code == 200:
                    status = response.json()
                    print(f"  Status: {status.get('status', 'unknown')}")
            except:
                print("  Alertmanager API not accessible")
        else:
            print("❌ Alertmanager is not running")
        
        # Check notification channels
        notification_channels = [
            'email',
            'slack',
            'webhook',
            'pagerduty'
        ]
        
        print(f"\nNotification Channels:")
        for channel in notification_channels:
            # Check if channel is configured
            if self.run_command(f"grep -i {channel} /etc/alertmanager/alertmanager.yml 2>/dev/null"):
                print(f"  ✅ {channel}")
            else:
                print(f"  ❌ {channel}")
    
    def analyze_dashboard_configuration(self):
        """Analyze dashboard configuration and setup"""
        print("\n=== Dashboard Configuration Analysis ===")
        
        # Check Grafana dashboards
        try:
            response = requests.get("http://localhost:3000/api/search?type=dash-db", 
                                 auth=('admin', 'admin'), timeout=5)
            if response.status_code == 200:
                dashboards = response.json()
                print(f"Grafana Dashboards: {len(dashboards)}")
                
                # Analyze dashboard types
                dashboard_types = defaultdict(int)
                for db in dashboards:
                    tags = db.get('tags', [])
                    if tags:
                        dashboard_types[tags[0]] += 1
                    else:
                        dashboard_types['untagged'] += 1
                
                print(f"Dashboard Types:")
                for db_type, count in dashboard_types.items():
                    print(f"  {db_type}: {count}")
                
                # Check dashboard health
                healthy_dashboards = 0
                for db in dashboards:
                    try:
                        db_response = requests.get(f"http://localhost:3000/api/dashboards/uid/{db['uid']}", 
                                                 auth=('admin', 'admin'), timeout=5)
                        if db_response.status_code == 200:
                            healthy_dashboards += 1
                    except:
                        pass
                
                print(f"Healthy Dashboards: {healthy_dashboards}/{len(dashboards)}")
                
        except:
            print("❌ Grafana dashboards not accessible")
        
        # Check data source health
        try:
            response = requests.get("http://localhost:3000/api/datasources", 
                                 auth=('admin', 'admin'), timeout=5)
            if response.status_code == 200:
                datasources = response.json()
                print(f"\nData Sources: {len(datasources)}")
                
                for ds in datasources:
                    try:
                        # Test data source
                        test_response = requests.get(f"http://localhost:3000/api/datasources/{ds['id']}/health", 
                                                   auth=('admin', 'admin'), timeout=5)
                        if test_response.status_code == 200:
                            print(f"  ✅ {ds['name']} ({ds['type']})")
                        else:
                            print(f"  ❌ {ds['name']} ({ds['type']})")
                    except:
                        print(f"  ❌ {ds['name']} ({ds['type']})")
                        
        except:
            print("❌ Grafana data sources not accessible")
    
    def analyze_metrics_quality(self):
        """Analyze metrics quality and coverage"""
        print("\n=== Metrics Quality Analysis ===")
        
        # Check Prometheus metrics
        try:
            response = requests.get("http://localhost:9090/api/v1/label/__name__/values", timeout=5)
            if response.status_code == 200:
                metrics = response.json()
                print(f"Total Metrics: {len(metrics['data'])}")
                
                # Categorize metrics
                metric_categories = defaultdict(int)
                for metric in metrics['data']:
                    if metric.startswith('node_'):
                        metric_categories['system'] += 1
                    elif metric.startswith('http_'):
                        metric_categories['http'] += 1
                    elif metric.startswith('process_'):
                        metric_categories['process'] += 1
                    elif metric.startswith('go_'):
                        metric_categories['go'] += 1
                    else:
                        metric_categories['other'] += 1
                
                print(f"Metric Categories:")
                for category, count in metric_categories.items():
                    print(f"  {category}: {count}")
                
                # Check for key metrics
                key_metrics = [
                    'up',
                    'node_cpu_seconds_total',
                    'node_memory_MemTotal_bytes',
                    'node_filesystem_size_bytes',
                    'node_network_receive_bytes_total'
                ]
                
                print(f"\nKey Metrics Availability:")
                for metric in key_metrics:
                    if metric in metrics['data']:
                        print(f"  ✅ {metric}")
                    else:
                        print(f"  ❌ {metric}")
                        
        except:
            print("❌ Prometheus metrics not accessible")
        
        # Check metrics freshness
        try:
            response = requests.get("http://localhost:9090/api/v1/query?query=up", timeout=5)
            if response.status_code == 200:
                result = response.json()
                if result['data']['result']:
                    print(f"\nMetrics Freshness:")
                    for metric in result['data']['result']:
                        timestamp = metric['value'][0]
                        age = time.time() - float(timestamp)
                        print(f"  {metric['metric']['instance']}: {age:.0f} seconds ago")
                        
        except:
            print("❌ Metrics freshness check failed")
    
    def generate_recommendations(self):
        """Generate monitoring optimization recommendations"""
        print(f"\n=== Monitoring Optimization Recommendations ===")
        
        recommendations = []
        
        # Check Prometheus configuration
        if not self.run_command("systemctl is-active prometheus 2>/dev/null"):
            recommendations.append("Install and configure Prometheus for metrics collection")
        
        # Check Grafana configuration
        if not self.run_command("systemctl is-active grafana-server 2>/dev/null"):
            recommendations.append("Install and configure Grafana for visualization")
        
        # Check alerting
        if not self.run_command("systemctl is-active alertmanager 2>/dev/null"):
            recommendations.append("Set up Alertmanager for alerting and notifications")
        
        # Check log monitoring
        if not self.run_command("systemctl is-active elasticsearch 2>/dev/null"):
            recommendations.append("Implement ELK stack for log aggregation and analysis")
        
        # Check SNMP monitoring
        if not self.run_command("which snmpwalk 2>/dev/null"):
            recommendations.append("Install SNMP tools for network device monitoring")
        
        # Check system metrics
        cpu_percent = psutil.cpu_percent(interval=1)
        if cpu_percent > 80:
            recommendations.append("High CPU usage detected - investigate performance issues")
        
        memory = psutil.virtual_memory()
        if memory.percent > 90:
            recommendations.append("High memory usage detected - consider memory optimization")
        
        disk_usage = psutil.disk_usage('/')
        if (disk_usage.used / disk_usage.total) > 0.9:
            recommendations.append("Disk space is low - implement log rotation and cleanup")
        
        # Check monitoring coverage
        try:
            response = requests.get("http://localhost:9090/api/v1/targets", timeout=5)
            if response.status_code == 200:
                targets = response.json()
                active_targets = len([t for t in targets['data']['activeTargets'] if t['health'] == 'up'])
                total_targets = len(targets['data']['activeTargets'])
                
                if active_targets < total_targets:
                    recommendations.append(f"Some monitoring targets are down ({active_targets}/{total_targets})")
        except:
            pass
        
        if recommendations:
            print("Recommendations:")
            for i, rec in enumerate(recommendations, 1):
                print(f"  {i}. {rec}")
        else:
            print("✅ No specific recommendations - monitoring setup looks good!")
    
    def generate_report(self, output_file=None):
        """Generate comprehensive monitoring analysis report"""
        report = {
            'timestamp': time.strftime('%Y-%m-%d %H:%M:%S'),
            'monitoring_systems': self.monitoring_systems,
            'metrics_data': self.metrics_data,
            'alert_rules': self.alert_rules,
            'dashboard_configs': self.dashboard_configs
        }
        
        if output_file:
            with open(output_file, 'w') as f:
                json.dump(report, f, indent=2)
            print(f"\nReport saved to: {output_file}")
        else:
            print("\n=== JSON Report ===")
            print(json.dumps(report, indent=2))
    
    def run_full_analysis(self):
        """Run complete monitoring analysis"""
        print("🔍 Starting Monitoring Analysis...")
        print("=" * 60)
        
        self.check_prometheus_status()
        self.check_grafana_status()
        self.analyze_system_metrics()
        self.analyze_network_monitoring()
        self.analyze_log_monitoring()
        self.analyze_alerting_system()
        self.analyze_dashboard_configuration()
        self.analyze_metrics_quality()
        self.generate_recommendations()
        
        print("\n✅ Monitoring analysis complete!")

def main():
    parser = argparse.ArgumentParser(description="Monitoring Analyzer Tool")
    parser.add_argument("-p", "--prometheus", action="store_true", 
                       help="Analyze Prometheus monitoring")
    parser.add_argument("-g", "--grafana", action="store_true", 
                       help="Analyze Grafana dashboards")
    parser.add_argument("-s", "--system", action="store_true", 
                       help="Analyze system metrics")
    parser.add_argument("-n", "--network", action="store_true", 
                       help="Analyze network monitoring")
    parser.add_argument("-l", "--logs", action="store_true", 
                       help="Analyze log monitoring")
    parser.add_argument("-a", "--alerts", action="store_true", 
                       help="Analyze alerting system")
    parser.add_argument("-d", "--dashboards", action="store_true", 
                       help="Analyze dashboard configuration")
    parser.add_argument("-m", "--metrics", action="store_true", 
                       help="Analyze metrics quality")
    parser.add_argument("-r", "--recommendations", action="store_true", 
                       help="Generate recommendations")
    parser.add_argument("--all", action="store_true", 
                       help="Run full analysis")
    parser.add_argument("-o", "--output", help="Output file for JSON report")
    
    args = parser.parse_args()
    
    analyzer = MonitoringAnalyzer()
    
    if args.all:
        analyzer.run_full_analysis()
    else:
        if args.prometheus:
            analyzer.check_prometheus_status()
        if args.grafana:
            analyzer.check_grafana_status()
        if args.system:
            analyzer.analyze_system_metrics()
        if args.network:
            analyzer.analyze_network_monitoring()
        if args.logs:
            analyzer.analyze_log_monitoring()
        if args.alerts:
            analyzer.analyze_alerting_system()
        if args.dashboards:
            analyzer.analyze_dashboard_configuration()
        if args.metrics:
            analyzer.analyze_metrics_quality()
        if args.recommendations:
            analyzer.generate_recommendations()
        
        if not any([args.prometheus, args.grafana, args.system, args.network, 
                   args.logs, args.alerts, args.dashboards, args.metrics, args.recommendations]):
            print("Please specify analysis type. Use -h for help.")
            return
    
    if args.output:
        analyzer.generate_report(args.output)

if __name__ == "__main__":
    main()

