#!/usr/bin/env python3
"""
HTTP Server Manager
Comprehensive tool for managing HTTP servers (Nginx, Apache)
"""

import argparse
import subprocess
import sys
import os
import json
import time
import requests
from pathlib import Path
from typing import Dict, List, Optional, Tuple

class HTTPServerManager:
    """Manages HTTP server operations"""
    
    def __init__(self, verbose: bool = False):
        self.verbose = verbose
        self.config_dir = Path("modules/06-http-servers")
        self.nginx_configs_dir = self.config_dir / "nginx-configs"
        self.apache_configs_dir = self.config_dir / "apache-configs"
        
    def log(self, message: str):
        """Log message if verbose mode is enabled"""
        if self.verbose:
            print(f"🔍 {message}")
    
    def run_command(self, cmd: List[str], capture_output: bool = True) -> Tuple[int, str, str]:
        """Run a command and return exit code, stdout, stderr"""
        try:
            self.log(f"Running: {' '.join(cmd)}")
            result = subprocess.run(cmd, capture_output=capture_output, text=True)
            return result.returncode, result.stdout, result.stderr
        except Exception as e:
            print(f"❌ Error running command: {e}")
            return 1, "", str(e)
    
    def test_nginx_configuration(self, config_file: str) -> bool:
        """Test Nginx configuration file"""
        print(f"🧪 Testing Nginx configuration: {config_file}")
        
        if not os.path.exists(config_file):
            print(f"❌ Configuration file not found: {config_file}")
            return False
        
        # Test configuration syntax
        cmd = ["nginx", "-t", "-c", config_file]
        exit_code, stdout, stderr = self.run_command(cmd)
        
        if exit_code == 0:
            print("✅ Nginx configuration syntax is valid")
            return True
        else:
            print(f"❌ Nginx configuration test failed:")
            print(f"STDOUT: {stdout}")
            print(f"STDERR: {stderr}")
            return False
    
    def test_apache_configuration(self, config_file: str) -> bool:
        """Test Apache configuration file"""
        print(f"🧪 Testing Apache configuration: {config_file}")
        
        if not os.path.exists(config_file):
            print(f"❌ Configuration file not found: {config_file}")
            return False
        
        # Test configuration syntax
        cmd = ["apache2ctl", "configtest"]
        exit_code, stdout, stderr = self.run_command(cmd)
        
        if exit_code == 0:
            print("✅ Apache configuration syntax is valid")
            return True
        else:
            print(f"❌ Apache configuration test failed:")
            print(f"STDOUT: {stdout}")
            print(f"STDERR: {stderr}")
            return False
    
    def start_nginx_server(self, config_file: str) -> bool:
        """Start Nginx server"""
        print(f"🚀 Starting Nginx server with config: {config_file}")
        
        if not self.test_nginx_configuration(config_file):
            return False
        
        # Start Nginx server
        cmd = ["nginx", "-c", config_file]
        
        try:
            print(f"📡 Nginx starting with config: {config_file}")
            print("💡 Press Ctrl+C to stop the server")
            
            # Run in foreground for now
            process = subprocess.Popen(cmd)
            process.wait()
            
        except KeyboardInterrupt:
            print("\n⏹️ Stopping Nginx server...")
            process.terminate()
            process.wait()
            print("✅ Server stopped")
            return True
        except Exception as e:
            print(f"❌ Error starting server: {e}")
            return False
    
    def start_apache_server(self, config_file: str) -> bool:
        """Start Apache server"""
        print(f"🚀 Starting Apache server with config: {config_file}")
        
        if not self.test_apache_configuration(config_file):
            return False
        
        # Start Apache server
        cmd = ["apache2ctl", "start"]
        
        try:
            print(f"📡 Apache starting...")
            print("💡 Use 'apache2ctl stop' to stop the server")
            
            # Start Apache
            exit_code, stdout, stderr = self.run_command(cmd)
            
            if exit_code == 0:
                print("✅ Apache server started")
                return True
            else:
                print(f"❌ Failed to start Apache: {stderr}")
                return False
            
        except Exception as e:
            print(f"❌ Error starting server: {e}")
            return False
    
    def test_http_response(self, url: str, expected_status: int = 200) -> bool:
        """Test HTTP response"""
        print(f"🔍 Testing HTTP response for {url}")
        
        try:
            response = requests.get(url, timeout=10)
            
            if response.status_code == expected_status:
                print(f"✅ HTTP response successful: {response.status_code}")
                print(f"📋 Response headers:")
                for header, value in response.headers.items():
                    print(f"   {header}: {value}")
                return True
            else:
                print(f"❌ HTTP response failed: {response.status_code} (expected {expected_status})")
                return False
                
        except requests.exceptions.RequestException as e:
            print(f"❌ HTTP request failed: {e}")
            return False
    
    def check_server_status(self, server_type: str = "nginx") -> bool:
        """Check if HTTP server is running"""
        print(f"🔍 Checking {server_type} server status")
        
        if server_type == "nginx":
            cmd = ["nginx", "-t"]
        elif server_type == "apache":
            cmd = ["apache2ctl", "status"]
        else:
            print(f"❌ Unknown server type: {server_type}")
            return False
        
        exit_code, stdout, stderr = self.run_command(cmd)
        
        if exit_code == 0:
            print(f"✅ {server_type} server is running")
            return True
        else:
            print(f"❌ {server_type} server is not running")
            return False
    
    def generate_nginx_config(self, config_name: str, output_file: str) -> bool:
        """Generate an Nginx configuration file"""
        print(f"📝 Generating Nginx config: {config_name}")
        
        config_templates = {
            "basic": """# Basic Nginx Configuration
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;
    
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
    
    server {
        listen 80 default_server;
        server_name _;
        root /var/www/html;
        index index.html index.htm;
        
        location / {
            try_files $uri $uri/ =404;
        }
        
        location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
        
        location ~ /\. {
            deny all;
        }
    }
}
""",
            "ssl": """# SSL Nginx Configuration
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;
    
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    server {
        listen 443 ssl http2;
        server_name example.com www.example.com;
        root /var/www/example.com;
        index index.html index.htm;
        
        ssl_certificate /etc/ssl/certs/example.com.crt;
        ssl_certificate_key /etc/ssl/private/example.com.key;
        
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header X-Content-Type-Options "nosniff" always;
        
        location / {
            try_files $uri $uri/ =404;
        }
    }
    
    server {
        listen 80;
        server_name example.com www.example.com;
        return 301 https://$server_name$request_uri;
    }
}
""",
            "loadbalancer": """# Load Balancer Nginx Configuration
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    upstream backend {
        least_conn;
        server 192.168.1.10:8080 weight=3;
        server 192.168.1.11:8080 weight=2;
        server 192.168.1.12:8080 weight=1;
        keepalive 32;
    }
    
    server {
        listen 80;
        server_name api.example.com;
        
        location / {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
            proxy_connect_timeout 5s;
            proxy_send_timeout 10s;
            proxy_read_timeout 10s;
        }
    }
}
"""
        }
        
        if config_name not in config_templates:
            print(f"❌ Unknown config template: {config_name}")
            print(f"Available templates: {', '.join(config_templates.keys())}")
            return False
        
        try:
            with open(output_file, 'w') as f:
                f.write(config_templates[config_name])
            print(f"✅ Config file generated: {output_file}")
            return True
        except Exception as e:
            print(f"❌ Error generating config file: {e}")
            return False
    
    def generate_ssl_certificate(self, domain: str, output_dir: str) -> bool:
        """Generate self-signed SSL certificate"""
        print(f"📝 Generating SSL certificate for {domain}")
        
        try:
            # Create output directory
            os.makedirs(output_dir, exist_ok=True)
            
            # Generate private key
            key_file = os.path.join(output_dir, f"{domain}.key")
            cmd = ["openssl", "genrsa", "-out", key_file, "2048"]
            exit_code, stdout, stderr = self.run_command(cmd)
            
            if exit_code != 0:
                print(f"❌ Failed to generate private key: {stderr}")
                return False
            
            # Generate certificate
            crt_file = os.path.join(output_dir, f"{domain}.crt")
            cmd = ["openssl", "req", "-new", "-x509", "-key", key_file, "-out", crt_file, 
                   "-days", "365", "-subj", f"/C=US/ST=State/L=City/O=Organization/CN={domain}"]
            exit_code, stdout, stderr = self.run_command(cmd)
            
            if exit_code != 0:
                print(f"❌ Failed to generate certificate: {stderr}")
                return False
            
            print(f"✅ SSL certificate generated:")
            print(f"   Private key: {key_file}")
            print(f"   Certificate: {crt_file}")
            return True
            
        except Exception as e:
            print(f"❌ Error generating SSL certificate: {e}")
            return False
    
    def analyze_http_headers(self, url: str) -> bool:
        """Analyze HTTP headers for security and performance"""
        print(f"🔍 Analyzing HTTP headers for {url}")
        
        try:
            response = requests.get(url, timeout=10)
            
            print(f"📋 HTTP Response Analysis:")
            print(f"   Status Code: {response.status_code}")
            print(f"   Server: {response.headers.get('Server', 'Unknown')}")
            print(f"   Content-Type: {response.headers.get('Content-Type', 'Unknown')}")
            print(f"   Content-Length: {response.headers.get('Content-Length', 'Unknown')}")
            
            # Security headers analysis
            security_headers = {
                'Strict-Transport-Security': 'HSTS',
                'X-Frame-Options': 'Clickjacking protection',
                'X-XSS-Protection': 'XSS protection',
                'X-Content-Type-Options': 'MIME type sniffing protection',
                'Content-Security-Policy': 'Content Security Policy',
                'Referrer-Policy': 'Referrer policy'
            }
            
            print(f"\n🔒 Security Headers Analysis:")
            for header, description in security_headers.items():
                if header in response.headers:
                    print(f"   ✅ {header}: {response.headers[header]}")
                else:
                    print(f"   ❌ {header}: Missing ({description})")
            
            # Performance headers analysis
            performance_headers = {
                'Cache-Control': 'Caching policy',
                'ETag': 'Entity tag',
                'Last-Modified': 'Last modification time',
                'Content-Encoding': 'Content compression'
            }
            
            print(f"\n⚡ Performance Headers Analysis:")
            for header, description in performance_headers.items():
                if header in response.headers:
                    print(f"   ✅ {header}: {response.headers[header]}")
                else:
                    print(f"   ⚠️ {header}: Missing ({description})")
            
            return True
            
        except requests.exceptions.RequestException as e:
            print(f"❌ HTTP request failed: {e}")
            return False
    
    def list_configurations(self) -> List[str]:
        """List available configuration files"""
        configs = []
        if self.nginx_configs_dir.exists():
            for config_file in self.nginx_configs_dir.glob("*.conf"):
                configs.append(str(config_file))
        return configs
    
    def show_status(self):
        """Show HTTP server status and configuration"""
        print("📊 HTTP Server Status")
        print("=" * 50)
        
        # Check if Nginx is installed
        exit_code, stdout, stderr = self.run_command(["nginx", "-v"])
        if exit_code == 0:
            print("✅ Nginx is installed")
            print(f"   Version: {stdout.strip()}")
        else:
            print("❌ Nginx is not installed")
        
        # Check if Apache is installed
        exit_code, stdout, stderr = self.run_command(["apache2", "-v"])
        if exit_code == 0:
            print("✅ Apache is installed")
            print(f"   Version: {stdout.strip()}")
        else:
            print("❌ Apache is not installed")
        
        # Check server status
        if self.check_server_status("nginx"):
            print("✅ Nginx server is running")
        else:
            print("❌ Nginx server is not running")
        
        if self.check_server_status("apache"):
            print("✅ Apache server is running")
        else:
            print("❌ Apache server is not running")
        
        # List configurations
        configs = self.list_configurations()
        print(f"\n📁 Available configurations ({len(configs)}):")
        for config in configs:
            print(f"   {config}")

def main():
    parser = argparse.ArgumentParser(
        description="HTTP Server Manager - Manage HTTP servers (Nginx, Apache)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
    python3 http-server-manager.py --status
    python3 http-server-manager.py --test-nginx-config basic.conf
    python3 http-server-manager.py --start-nginx basic.conf
    python3 http-server-manager.py --test-http http://localhost
    python3 http-server-manager.py --generate-nginx-config basic
    python3 http-server-manager.py --generate-ssl-cert example.com
    python3 http-server-manager.py --analyze-headers http://example.com
        """
    )
    
    parser.add_argument('-v', '--verbose', action='store_true', help='Verbose output')
    parser.add_argument('--status', action='store_true', help='Show HTTP server status')
    parser.add_argument('--test-nginx-config', help='Test Nginx configuration file')
    parser.add_argument('--test-apache-config', help='Test Apache configuration file')
    parser.add_argument('--start-nginx', help='Start Nginx server with config file')
    parser.add_argument('--start-apache', help='Start Apache server')
    parser.add_argument('--test-http', help='Test HTTP response for URL')
    parser.add_argument('--generate-nginx-config', help='Generate Nginx config template')
    parser.add_argument('--generate-ssl-cert', help='Generate SSL certificate for domain')
    parser.add_argument('--analyze-headers', help='Analyze HTTP headers for URL')
    parser.add_argument('--output', help='Output file for generated content')
    
    args = parser.parse_args()
    
    if len(sys.argv) == 1:
        parser.print_help()
        return
    
    manager = HTTPServerManager(verbose=args.verbose)
    
    if args.status:
        manager.show_status()
    elif args.test_nginx_config:
        manager.test_nginx_configuration(args.test_nginx_config)
    elif args.test_apache_config:
        manager.test_apache_configuration(args.test_apache_config)
    elif args.start_nginx:
        manager.start_nginx_server(args.start_nginx)
    elif args.start_apache:
        manager.start_apache_server(args.start_apache)
    elif args.test_http:
        manager.test_http_response(args.test_http)
    elif args.generate_nginx_config:
        output_file = args.output or f"{args.generate_nginx_config}.conf"
        manager.generate_nginx_config(args.generate_nginx_config, output_file)
    elif args.generate_ssl_cert:
        output_dir = args.output or "ssl-certs"
        manager.generate_ssl_certificate(args.generate_ssl_cert, output_dir)
    elif args.analyze_headers:
        manager.analyze_http_headers(args.analyze_headers)
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
