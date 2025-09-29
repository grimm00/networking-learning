#!/usr/bin/env python3
"""
Load Balancer Analyzer Tool
Analyzes load balancer configurations, performance, and provides optimization recommendations.
"""

import subprocess
import argparse
import json
import re
import time
import requests
from collections import defaultdict, Counter
import socket
import threading
from concurrent.futures import ThreadPoolExecutor

class LoadBalancerAnalyzer:
    def __init__(self):
        self.load_balancers = []
        self.backend_servers = []
        self.performance_metrics = {}
        self.health_status = {}
        
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
    
    def check_nginx_status(self):
        """Check Nginx load balancer status"""
        print("=== Nginx Load Balancer Analysis ===")
        
        # Check if Nginx is running
        nginx_status = self.run_command("systemctl is-active nginx 2>/dev/null || pgrep nginx")
        if not nginx_status:
            print("❌ Nginx is not running")
            return
        
        print("✅ Nginx is running")
        
        # Check Nginx configuration
        config_test = self.run_command("nginx -t 2>&1")
        if config_test and "syntax is ok" in config_test:
            print("✅ Nginx configuration is valid")
        else:
            print("❌ Nginx configuration has errors")
            print(f"Errors: {config_test}")
        
        # Check upstream servers
        upstream_servers = self.run_command("nginx -T 2>/dev/null | grep -A 10 'upstream'")
        if upstream_servers:
            print(f"\nUpstream Configuration:")
            print(upstream_servers)
        
        # Check Nginx status page
        try:
            response = requests.get("http://localhost/nginx_status", timeout=5)
            if response.status_code == 200:
                print(f"\nNginx Status:")
                print(response.text)
        except:
            print("Nginx status page not available")
    
    def check_haproxy_status(self):
        """Check HAProxy load balancer status"""
        print("\n=== HAProxy Load Balancer Analysis ===")
        
        # Check if HAProxy is running
        haproxy_status = self.run_command("systemctl is-active haproxy 2>/dev/null || pgrep haproxy")
        if not haproxy_status:
            print("❌ HAProxy is not running")
            return
        
        print("✅ HAProxy is running")
        
        # Check HAProxy configuration
        config_test = self.run_command("haproxy -c -f /etc/haproxy/haproxy.cfg 2>&1")
        if config_test and "Configuration file is valid" in config_test:
            print("✅ HAProxy configuration is valid")
        else:
            print("❌ HAProxy configuration has errors")
            print(f"Errors: {config_test}")
        
        # Check HAProxy statistics
        try:
            response = requests.get("http://localhost:8080/stats", timeout=5)
            if response.status_code == 200:
                print(f"\nHAProxy Statistics:")
                print(response.text[:500] + "..." if len(response.text) > 500 else response.text)
        except:
            print("HAProxy statistics page not available")
    
    def analyze_load_balancing_algorithms(self):
        """Analyze load balancing algorithms and configurations"""
        print("\n=== Load Balancing Algorithm Analysis ===")
        
        # Check Nginx upstream configurations
        nginx_config = self.run_command("nginx -T 2>/dev/null")
        if nginx_config:
            upstream_blocks = re.findall(r'upstream\s+(\w+)\s*\{([^}]+)\}', nginx_config, re.MULTILINE)
            
            for upstream_name, config in upstream_blocks:
                print(f"\nUpstream: {upstream_name}")
                
                # Check for load balancing method
                if 'least_conn' in config:
                    print("  Algorithm: Least Connections")
                elif 'ip_hash' in config:
                    print("  Algorithm: IP Hash (Session Persistence)")
                elif 'hash' in config:
                    print("  Algorithm: Consistent Hash")
                else:
                    print("  Algorithm: Round Robin (Default)")
                
                # Extract server configurations
                servers = re.findall(r'server\s+([^;]+);', config)
                print(f"  Servers: {len(servers)}")
                
                for server in servers:
                    server_parts = server.split()
                    server_addr = server_parts[0]
                    
                    # Check for weight
                    weight = "1"
                    for part in server_parts[1:]:
                        if part.startswith('weight='):
                            weight = part.split('=')[1]
                    
                    # Check for health check parameters
                    max_fails = "1"
                    fail_timeout = "10s"
                    for part in server_parts[1:]:
                        if part.startswith('max_fails='):
                            max_fails = part.split('=')[1]
                        elif part.startswith('fail_timeout='):
                            fail_timeout = part.split('=')[1]
                    
                    print(f"    {server_addr} (weight: {weight}, max_fails: {max_fails}, fail_timeout: {fail_timeout})")
        
        # Check HAProxy configurations
        try:
            with open('/etc/haproxy/haproxy.cfg', 'r') as f:
                haproxy_config = f.read()
            
            backend_blocks = re.findall(r'backend\s+(\w+)\s*\{([^}]+)\}', haproxy_config, re.MULTILINE)
            
            for backend_name, config in backend_blocks:
                print(f"\nHAProxy Backend: {backend_name}")
                
                # Check for load balancing method
                balance_match = re.search(r'balance\s+(\w+)', config)
                if balance_match:
                    algorithm = balance_match.group(1)
                    print(f"  Algorithm: {algorithm}")
                
                # Extract server configurations
                servers = re.findall(r'server\s+(\w+)\s+([^\s]+)\s+([^\s]+)', config)
                print(f"  Servers: {len(servers)}")
                
                for server_name, server_addr, server_params in servers:
                    print(f"    {server_name}: {server_addr} ({server_params})")
        
        except FileNotFoundError:
            print("HAProxy configuration file not found")
    
    def test_backend_servers(self, servers):
        """Test backend server connectivity and performance"""
        print(f"\n=== Backend Server Testing ===")
        
        def test_server(server):
            try:
                # Parse server address
                if ':' in server:
                    host, port = server.split(':')
                    port = int(port)
                else:
                    host = server
                    port = 80
                
                # Test connectivity
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                sock.settimeout(5)
                result = sock.connect_ex((host, port))
                sock.close()
                
                if result == 0:
                    # Test HTTP response
                    try:
                        start_time = time.time()
                        response = requests.get(f"http://{server}/", timeout=5)
                        response_time = time.time() - start_time
                        
                        return {
                            'server': server,
                            'status': 'UP',
                            'response_time': response_time,
                            'status_code': response.status_code,
                            'content_length': len(response.content)
                        }
                    except:
                        return {
                            'server': server,
                            'status': 'UP',
                            'response_time': None,
                            'status_code': None,
                            'content_length': None
                        }
                else:
                    return {
                        'server': server,
                        'status': 'DOWN',
                        'response_time': None,
                        'status_code': None,
                        'content_length': None
                    }
            except Exception as e:
                return {
                    'server': server,
                    'status': 'ERROR',
                    'error': str(e),
                    'response_time': None,
                    'status_code': None,
                    'content_length': None
                }
        
        # Test servers concurrently
        with ThreadPoolExecutor(max_workers=10) as executor:
            results = list(executor.map(test_server, servers))
        
        # Display results
        for result in results:
            print(f"\nServer: {result['server']}")
            print(f"  Status: {result['status']}")
            
            if result['status'] == 'UP':
                if result['response_time']:
                    print(f"  Response Time: {result['response_time']:.3f}s")
                if result['status_code']:
                    print(f"  HTTP Status: {result['status_code']}")
                if result['content_length']:
                    print(f"  Content Length: {result['content_length']} bytes")
            elif result['status'] == 'ERROR':
                print(f"  Error: {result['error']}")
    
    def analyze_health_checks(self):
        """Analyze health check configurations and status"""
        print(f"\n=== Health Check Analysis ===")
        
        # Check Nginx health check configuration
        nginx_config = self.run_command("nginx -T 2>/dev/null")
        if nginx_config:
            # Look for health check related configurations
            health_check_patterns = [
                r'max_fails\s*=\s*(\d+)',
                r'fail_timeout\s*=\s*(\w+)',
                r'proxy_next_upstream\s+([^;]+)',
            ]
            
            print("Nginx Health Check Configuration:")
            for pattern in health_check_patterns:
                matches = re.findall(pattern, nginx_config)
                if matches:
                    print(f"  {pattern}: {matches}")
        
        # Check HAProxy health check configuration
        try:
            with open('/etc/haproxy/haproxy.cfg', 'r') as f:
                haproxy_config = f.read()
            
            print("\nHAProxy Health Check Configuration:")
            
            # Look for health check configurations
            health_check_patterns = [
                r'option\s+httpchk\s+([^\n]+)',
                r'http-check\s+([^\n]+)',
                r'check\s+([^\n]+)',
            ]
            
            for pattern in health_check_patterns:
                matches = re.findall(pattern, haproxy_config)
                if matches:
                    print(f"  {pattern}: {matches}")
        
        except FileNotFoundError:
            print("HAProxy configuration file not found")
    
    def analyze_performance_metrics(self):
        """Analyze load balancer performance metrics"""
        print(f"\n=== Performance Metrics Analysis ===")
        
        # Check connection statistics
        connection_stats = self.run_command("ss -tuna | grep :80 | wc -l")
        if connection_stats:
            print(f"Active connections on port 80: {connection_stats.strip()}")
        
        # Check Nginx worker processes
        nginx_workers = self.run_command("pgrep nginx | wc -l")
        if nginx_workers:
            print(f"Nginx worker processes: {nginx_workers.strip()}")
        
        # Check HAProxy processes
        haproxy_processes = self.run_command("pgrep haproxy | wc -l")
        if haproxy_processes:
            print(f"HAProxy processes: {haproxy_processes.strip()}")
        
        # Check system load
        load_avg = self.run_command("uptime | awk -F'load average:' '{print $2}'")
        if load_avg:
            print(f"System load average: {load_avg.strip()}")
        
        # Check memory usage
        memory_usage = self.run_command("free -h | grep Mem")
        if memory_usage:
            print(f"Memory usage: {memory_usage.strip()}")
    
    def analyze_session_persistence(self):
        """Analyze session persistence configurations"""
        print(f"\n=== Session Persistence Analysis ===")
        
        # Check Nginx session persistence
        nginx_config = self.run_command("nginx -T 2>/dev/null")
        if nginx_config:
            if 'ip_hash' in nginx_config:
                print("✅ IP Hash session persistence configured")
            else:
                print("❌ No IP Hash session persistence")
            
            if 'proxy_cookie' in nginx_config:
                print("✅ Cookie-based session persistence configured")
            else:
                print("❌ No cookie-based session persistence")
        
        # Check HAProxy session persistence
        try:
            with open('/etc/haproxy/haproxy.cfg', 'r') as f:
                haproxy_config = f.read()
            
            if 'cookie' in haproxy_config:
                print("✅ HAProxy cookie-based session persistence configured")
            else:
                print("❌ No HAProxy cookie-based session persistence")
        
        except FileNotFoundError:
            print("HAProxy configuration file not found")
    
    def analyze_security_configuration(self):
        """Analyze load balancer security configuration"""
        print(f"\n=== Security Configuration Analysis ===")
        
        # Check SSL/TLS configuration
        ssl_configs = self.run_command("nginx -T 2>/dev/null | grep -i ssl")
        if ssl_configs:
            print("SSL/TLS Configuration Found:")
            print(ssl_configs)
        else:
            print("❌ No SSL/TLS configuration found")
        
        # Check security headers
        security_headers = [
            'X-Frame-Options',
            'X-Content-Type-Options',
            'X-XSS-Protection',
            'Strict-Transport-Security',
            'Content-Security-Policy'
        ]
        
        nginx_config = self.run_command("nginx -T 2>/dev/null")
        if nginx_config:
            print("\nSecurity Headers Configuration:")
            for header in security_headers:
                if header.lower().replace('-', '_') in nginx_config.lower():
                    print(f"  ✅ {header} configured")
                else:
                    print(f"  ❌ {header} not configured")
    
    def generate_recommendations(self):
        """Generate load balancer optimization recommendations"""
        print(f"\n=== Load Balancer Optimization Recommendations ===")
        
        recommendations = []
        
        # Check for common issues
        nginx_config = self.run_command("nginx -T 2>/dev/null")
        if nginx_config:
            # Check for health checks
            if 'max_fails' not in nginx_config:
                recommendations.append("Implement health checks with max_fails and fail_timeout")
            
            # Check for session persistence
            if 'ip_hash' not in nginx_config and 'proxy_cookie' not in nginx_config:
                recommendations.append("Consider implementing session persistence for stateful applications")
            
            # Check for SSL
            if 'ssl' not in nginx_config.lower():
                recommendations.append("Implement SSL/TLS termination for secure communication")
            
            # Check for security headers
            security_headers = ['X-Frame-Options', 'X-Content-Type-Options', 'X-XSS-Protection']
            missing_headers = []
            for header in security_headers:
                if header.lower().replace('-', '_') not in nginx_config.lower():
                    missing_headers.append(header)
            
            if missing_headers:
                recommendations.append(f"Add security headers: {', '.join(missing_headers)}")
        
        # Check HAProxy configuration
        try:
            with open('/etc/haproxy/haproxy.cfg', 'r') as f:
                haproxy_config = f.read()
            
            if 'option httpchk' not in haproxy_config:
                recommendations.append("Implement HTTP health checks in HAProxy")
            
            if 'stats' not in haproxy_config:
                recommendations.append("Enable HAProxy statistics page for monitoring")
        
        except FileNotFoundError:
            pass
        
        # Performance recommendations
        connection_count = self.run_command("ss -tuna | grep :80 | wc -l")
        if connection_count and int(connection_count.strip()) > 1000:
            recommendations.append("High connection count detected - consider connection pooling optimization")
        
        if recommendations:
            print("Recommendations:")
            for i, rec in enumerate(recommendations, 1):
                print(f"  {i}. {rec}")
        else:
            print("✅ No specific recommendations - load balancer configuration looks good!")
    
    def generate_report(self, output_file=None):
        """Generate comprehensive analysis report"""
        report = {
            'timestamp': time.strftime('%Y-%m-%d %H:%M:%S'),
            'load_balancers': self.load_balancers,
            'backend_servers': self.backend_servers,
            'performance_metrics': self.performance_metrics,
            'health_status': self.health_status
        }
        
        if output_file:
            with open(output_file, 'w') as f:
                json.dump(report, f, indent=2)
            print(f"\nReport saved to: {output_file}")
        else:
            print("\n=== JSON Report ===")
            print(json.dumps(report, indent=2))
    
    def run_full_analysis(self):
        """Run complete load balancer analysis"""
        print("🔍 Starting Load Balancer Analysis...")
        print("=" * 60)
        
        self.check_nginx_status()
        self.check_haproxy_status()
        self.analyze_load_balancing_algorithms()
        self.analyze_health_checks()
        self.analyze_performance_metrics()
        self.analyze_session_persistence()
        self.analyze_security_configuration()
        self.generate_recommendations()
        
        print("\n✅ Load balancer analysis complete!")

def main():
    parser = argparse.ArgumentParser(description="Load Balancer Analyzer Tool")
    parser.add_argument("-n", "--nginx", action="store_true", 
                       help="Analyze Nginx load balancer")
    parser.add_argument("-h", "--haproxy", action="store_true", 
                       help="Analyze HAProxy load balancer")
    parser.add_argument("-a", "--algorithms", action="store_true", 
                       help="Analyze load balancing algorithms")
    parser.add_argument("-c", "--health-checks", action="store_true", 
                       help="Analyze health check configurations")
    parser.add_argument("-p", "--performance", action="store_true", 
                       help="Analyze performance metrics")
    parser.add_argument("-s", "--sessions", action="store_true", 
                       help="Analyze session persistence")
    parser.add_argument("-sec", "--security", action="store_true", 
                       help="Analyze security configuration")
    parser.add_argument("-r", "--recommendations", action="store_true", 
                       help="Generate recommendations")
    parser.add_argument("--all", action="store_true", 
                       help="Run full analysis")
    parser.add_argument("-o", "--output", help="Output file for JSON report")
    parser.add_argument("--test-servers", nargs="+", help="Test specific backend servers")
    
    args = parser.parse_args()
    
    analyzer = LoadBalancerAnalyzer()
    
    if args.all:
        analyzer.run_full_analysis()
    else:
        if args.nginx:
            analyzer.check_nginx_status()
        if args.haproxy:
            analyzer.check_haproxy_status()
        if args.algorithms:
            analyzer.analyze_load_balancing_algorithms()
        if args.health_checks:
            analyzer.analyze_health_checks()
        if args.performance:
            analyzer.analyze_performance_metrics()
        if args.sessions:
            analyzer.analyze_session_persistence()
        if args.security:
            analyzer.analyze_security_configuration()
        if args.recommendations:
            analyzer.generate_recommendations()
        
        if not any([args.nginx, args.haproxy, args.algorithms, args.health_checks, 
                   args.performance, args.sessions, args.security, args.recommendations]):
            print("Please specify analysis type. Use -h for help.")
            return
    
    if args.test_servers:
        analyzer.test_backend_servers(args.test_servers)
    
    if args.output:
        analyzer.generate_report(args.output)

if __name__ == "__main__":
    main()

