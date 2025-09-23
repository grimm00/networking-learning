#!/usr/bin/env python3
"""
DNS Server Manager
Comprehensive tool for managing CoreDNS servers and configurations
"""

import argparse
import subprocess
import sys
import os
import json
import time
from pathlib import Path
from typing import Dict, List, Optional, Tuple

class DNSServerManager:
    """Manages CoreDNS server operations"""
    
    def __init__(self, verbose: bool = False):
        self.verbose = verbose
        self.config_dir = Path("05-dns-server")
        self.zones_dir = self.config_dir / "zones"
        self.configs_dir = self.config_dir / "coredns-configs"
        
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
    
    def test_configuration(self, config_file: str) -> bool:
        """Test CoreDNS configuration file"""
        print(f"🧪 Testing CoreDNS configuration: {config_file}")
        
        if not os.path.exists(config_file):
            print(f"❌ Configuration file not found: {config_file}")
            return False
        
        # Test configuration syntax
        cmd = ["coredns", "-conf", config_file, "-test"]
        exit_code, stdout, stderr = self.run_command(cmd)
        
        if exit_code == 0:
            print("✅ Configuration syntax is valid")
            return True
        else:
            print(f"❌ Configuration test failed:")
            print(f"STDOUT: {stdout}")
            print(f"STDERR: {stderr}")
            return False
    
    def validate_zone_file(self, zone_file: str, domain: str) -> bool:
        """Validate DNS zone file"""
        print(f"🧪 Validating zone file: {zone_file}")
        
        if not os.path.exists(zone_file):
            print(f"❌ Zone file not found: {zone_file}")
            return False
        
        # Use named-checkzone if available
        cmd = ["named-checkzone", domain, zone_file]
        exit_code, stdout, stderr = self.run_command(cmd)
        
        if exit_code == 0:
            print("✅ Zone file is valid")
            return True
        else:
            print(f"❌ Zone file validation failed:")
            print(f"STDOUT: {stdout}")
            print(f"STDERR: {stderr}")
            return False
    
    def start_server(self, config_file: str, port: int = 53) -> bool:
        """Start CoreDNS server"""
        print(f"🚀 Starting CoreDNS server with config: {config_file}")
        
        if not self.test_configuration(config_file):
            return False
        
        # Start CoreDNS server
        cmd = ["coredns", "-conf", config_file, "-dns.port", str(port)]
        
        try:
            print(f"📡 CoreDNS starting on port {port}")
            print("💡 Press Ctrl+C to stop the server")
            
            # Run in foreground for now
            process = subprocess.Popen(cmd)
            process.wait()
            
        except KeyboardInterrupt:
            print("\n⏹️ Stopping CoreDNS server...")
            process.terminate()
            process.wait()
            print("✅ Server stopped")
            return True
        except Exception as e:
            print(f"❌ Error starting server: {e}")
            return False
    
    def test_dns_resolution(self, server: str = "localhost", domain: str = "example.com") -> bool:
        """Test DNS resolution"""
        print(f"🔍 Testing DNS resolution for {domain} via {server}")
        
        # Test with dig
        cmd = ["dig", f"@{server}", domain]
        exit_code, stdout, stderr = self.run_command(cmd)
        
        if exit_code == 0 and "ANSWER:" in stdout:
            print("✅ DNS resolution successful")
            print("📋 Response:")
            # Extract answer section
            lines = stdout.split('\n')
            in_answer = False
            for line in lines:
                if "ANSWER SECTION:" in line:
                    in_answer = True
                    continue
                if in_answer and line.strip():
                    if line.startswith(';') or line.startswith(';;'):
                        break
                    print(f"   {line.strip()}")
            return True
        else:
            print(f"❌ DNS resolution failed:")
            print(f"STDOUT: {stdout}")
            print(f"STDERR: {stderr}")
            return False
    
    def check_server_status(self, server: str = "localhost", port: int = 53) -> bool:
        """Check if DNS server is running"""
        print(f"🔍 Checking DNS server status: {server}:{port}")
        
        # Test with dig
        cmd = ["dig", f"@{server}", "-p", str(port), "google.com"]
        exit_code, stdout, stderr = self.run_command(cmd)
        
        if exit_code == 0:
            print("✅ DNS server is responding")
            return True
        else:
            print("❌ DNS server is not responding")
            return False
    
    def generate_zone_file(self, domain: str, output_file: str) -> bool:
        """Generate a basic zone file template"""
        print(f"📝 Generating zone file template for {domain}")
        
        zone_content = f"""; Zone file for {domain}
; Generated by DNS Server Manager

$TTL 3600
$ORIGIN {domain}.

; Start of Authority record
@       IN      SOA     ns1.{domain}. admin.{domain}. (
                        2024010101      ; Serial number
                        3600            ; Refresh interval
                        1800            ; Retry interval
                        604800          ; Expire time
                        86400           ; Minimum TTL
                        )

; Name servers
@       IN      NS      ns1.{domain}.
@       IN      NS      ns2.{domain}.

; A records
@       IN      A       192.168.1.100
ns1     IN      A       192.168.1.101
ns2     IN      A       192.168.1.102
www     IN      A       192.168.1.100
mail    IN      A       192.168.1.103

; CNAME records
web     IN      CNAME   www.{domain}.

; MX records
@       IN      MX      10 mail.{domain}.

; TXT records
@       IN      TXT     "v=spf1 mx ~all"
"""
        
        try:
            with open(output_file, 'w') as f:
                f.write(zone_content)
            print(f"✅ Zone file generated: {output_file}")
            return True
        except Exception as e:
            print(f"❌ Error generating zone file: {e}")
            return False
    
    def generate_config_file(self, config_name: str, output_file: str) -> bool:
        """Generate a CoreDNS configuration file"""
        print(f"📝 Generating CoreDNS config: {config_name}")
        
        config_templates = {
            "basic": """# Basic CoreDNS Configuration
.:53 {
    forward . 8.8.8.8 8.8.4.4
    cache
    log
    errors
}
""",
            "advanced": """# Advanced CoreDNS Configuration
example.com:53 {
    file /etc/coredns/zones/example.com.db
    log
    errors
}

.:53 {
    forward . 8.8.8.8 8.8.4.4 {
        except example.com
    }
    cache
    log
    errors
}
""",
            "secure": """# Secure CoreDNS Configuration
.:53 {
    forward . tls://8.8.8.8 tls://8.8.4.4 {
        tls_servername dns.google
    }
    cache
    rate_limit {
        window 1m
        max_requests 100
    }
    log
    errors
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
    
    def list_configurations(self) -> List[str]:
        """List available configuration files"""
        configs = []
        if self.configs_dir.exists():
            for config_file in self.configs_dir.glob("*.conf"):
                configs.append(str(config_file))
        return configs
    
    def list_zone_files(self) -> List[str]:
        """List available zone files"""
        zones = []
        if self.zones_dir.exists():
            for zone_file in self.zones_dir.glob("*.db"):
                zones.append(str(zone_file))
        return zones
    
    def show_status(self):
        """Show DNS server status and configuration"""
        print("📊 DNS Server Status")
        print("=" * 50)
        
        # Check if CoreDNS is installed
        exit_code, stdout, stderr = self.run_command(["coredns", "-version"])
        if exit_code == 0:
            print("✅ CoreDNS is installed")
            print(f"   Version: {stdout.strip()}")
        else:
            print("❌ CoreDNS is not installed")
        
        # Check server status
        if self.check_server_status():
            print("✅ DNS server is running")
        else:
            print("❌ DNS server is not running")
        
        # List configurations
        configs = self.list_configurations()
        print(f"\n📁 Available configurations ({len(configs)}):")
        for config in configs:
            print(f"   {config}")
        
        # List zone files
        zones = self.list_zone_files()
        print(f"\n📁 Available zone files ({len(zones)}):")
        for zone in zones:
            print(f"   {zone}")

def main():
    parser = argparse.ArgumentParser(
        description="DNS Server Manager - Manage CoreDNS servers and configurations",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
    python3 dns-server-manager.py --status
    python3 dns-server-manager.py --test-config basic.conf
    python3 dns-server-manager.py --start-server basic.conf
    python3 dns-server-manager.py --test-resolution example.com
    python3 dns-server-manager.py --generate-zone example.com
    python3 dns-server-manager.py --generate-config basic
        """
    )
    
    parser.add_argument('-v', '--verbose', action='store_true', help='Verbose output')
    parser.add_argument('--status', action='store_true', help='Show DNS server status')
    parser.add_argument('--test-config', help='Test CoreDNS configuration file')
    parser.add_argument('--validate-zone', nargs=2, metavar=('ZONE_FILE', 'DOMAIN'), 
                       help='Validate DNS zone file')
    parser.add_argument('--start-server', help='Start CoreDNS server with config file')
    parser.add_argument('--test-resolution', help='Test DNS resolution for domain')
    parser.add_argument('--generate-zone', help='Generate zone file template for domain')
    parser.add_argument('--generate-config', help='Generate CoreDNS config template')
    parser.add_argument('--output', help='Output file for generated content')
    
    args = parser.parse_args()
    
    if len(sys.argv) == 1:
        parser.print_help()
        return
    
    manager = DNSServerManager(verbose=args.verbose)
    
    if args.status:
        manager.show_status()
    elif args.test_config:
        manager.test_configuration(args.test_config)
    elif args.validate_zone:
        zone_file, domain = args.validate_zone
        manager.validate_zone_file(zone_file, domain)
    elif args.start_server:
        manager.start_server(args.start_server)
    elif args.test_resolution:
        manager.test_dns_resolution(domain=args.test_resolution)
    elif args.generate_zone:
        output_file = args.output or f"{args.generate_zone}.db"
        manager.generate_zone_file(args.generate_zone, output_file)
    elif args.generate_config:
        output_file = args.output or f"{args.generate_config}.conf"
        manager.generate_config_file(args.generate_config, output_file)
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
