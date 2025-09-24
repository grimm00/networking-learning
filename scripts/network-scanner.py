#!/usr/bin/env python3
"""
Network Scanner Tool
Comprehensive network discovery and port scanning utility
"""

import socket
import subprocess
import sys
import threading
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import List, Dict, Any, Tuple
import argparse
import json
import os
from datetime import datetime


class NetworkScanner:
    def __init__(self, target: str, ports: List[int] = None, threads: int = 100):
        self.target = target
        self.ports = ports or [21, 22, 23, 25, 53, 80, 110, 143, 443, 993, 995, 3389, 5432, 6379, 8080, 8443]
        self.threads = threads
        self.results = {
            'target': target,
            'scan_time': datetime.now().isoformat(),
            'open_ports': [],
            'closed_ports': [],
            'filtered_ports': [],
            'host_info': {}
        }

    def ping_host(self) -> bool:
        """Check if host is reachable"""
        try:
            if sys.platform.startswith('win'):
                result = subprocess.run(['ping', '-n', '1', self.target], 
                                      capture_output=True, timeout=5)
            else:
                result = subprocess.run(['ping', '-c', '1', self.target], 
                                      capture_output=True, timeout=5)
            return result.returncode == 0
        except (subprocess.TimeoutExpired, FileNotFoundError):
            return False

    def scan_port(self, port: int) -> Tuple[int, str, str]:
        """Scan a single port"""
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(1)
            result = sock.connect_ex((self.target, port))
            sock.close()
            
            if result == 0:
                return port, 'open', self.get_service_name(port)
            else:
                return port, 'closed', ''
        except socket.gaierror:
            return port, 'error', 'Hostname resolution failed'
        except Exception as e:
            return port, 'error', str(e)

    def get_service_name(self, port: int) -> str:
        """Get common service name for port"""
        services = {
            21: 'FTP', 22: 'SSH', 23: 'Telnet', 25: 'SMTP', 53: 'DNS',
            80: 'HTTP', 110: 'POP3', 143: 'IMAP', 443: 'HTTPS', 993: 'IMAPS',
            995: 'POP3S', 3389: 'RDP', 5432: 'PostgreSQL', 6379: 'Redis',
            8080: 'HTTP-Alt', 8443: 'HTTPS-Alt'
        }
        return services.get(port, 'Unknown')

    def get_host_info(self) -> Dict[str, Any]:
        """Get host information"""
        info = {}
        
        try:
            # Get hostname
            hostname = socket.gethostbyaddr(self.target)[0]
            info['hostname'] = hostname
        except socket.herror:
            info['hostname'] = 'Unknown'
        
        try:
            # Get MAC address (if on local network)
            result = subprocess.run(['arp', '-n', self.target], 
                                  capture_output=True, text=True, timeout=5)
            if result.returncode == 0:
                lines = result.stdout.strip().split('\n')
                for line in lines:
                    if self.target in line:
                        parts = line.split()
                        if len(parts) >= 3:
                            info['mac_address'] = parts[2]
                            break
        except (subprocess.TimeoutExpired, FileNotFoundError):
            pass
        
        return info

    def scan_ports(self) -> None:
        """Scan all ports using threading"""
        print(f"Scanning {self.target} on ports {self.ports}")
        print(f"Using {self.threads} threads")
        print("-" * 50)
        
        with ThreadPoolExecutor(max_workers=self.threads) as executor:
            # Submit all port scans
            future_to_port = {executor.submit(self.scan_port, port): port 
                            for port in self.ports}
            
            # Process results as they complete
            for future in as_completed(future_to_port):
                port, status, service = future.result()
                
                if status == 'open':
                    self.results['open_ports'].append({
                        'port': port,
                        'service': service,
                        'status': status
                    })
                    print(f"Port {port:5d}: OPEN    ({service})")
                elif status == 'closed':
                    self.results['closed_ports'].append(port)
                elif status == 'error':
                    self.results['filtered_ports'].append({
                        'port': port,
                        'error': service
                    })
                    print(f"Port {port:5d}: ERROR   ({service})")

    def run_scan(self) -> None:
        """Run complete network scan"""
        print(f"Network Scanner - Target: {self.target}")
        print(f"Started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print("=" * 60)
        
        # Check if host is reachable
        print("Checking host reachability...")
        if not self.ping_host():
            print(f"Warning: Host {self.target} may not be reachable")
            print("Continuing with port scan anyway...")
        else:
            print(f"Host {self.target} is reachable")
        
        print()
        
        # Get host information
        print("Gathering host information...")
        self.results['host_info'] = self.get_host_info()
        for key, value in self.results['host_info'].items():
            print(f"{key.replace('_', ' ').title()}: {value}")
        
        print()
        
        # Scan ports
        start_time = time.time()
        self.scan_ports()
        end_time = time.time()
        
        # Print summary
        print("\n" + "=" * 60)
        print("SCAN SUMMARY")
        print("=" * 60)
        print(f"Target: {self.target}")
        print(f"Open ports: {len(self.results['open_ports'])}")
        print(f"Closed ports: {len(self.results['closed_ports'])}")
        print(f"Filtered ports: {len(self.results['filtered_ports'])}")
        print(f"Scan duration: {end_time - start_time:.2f} seconds")
        
        if self.results['open_ports']:
            print("\nOpen Ports:")
            for port_info in self.results['open_ports']:
                print(f"  {port_info['port']:5d}: {port_info['service']}")

    def save_results(self, filename: str = None, output_dir: str = "output") -> None:
        """Save scan results to JSON file"""
        # Create output directory if it doesn't exist
        os.makedirs(output_dir, exist_ok=True)
        
        if filename is None:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"network_scan_{self.target}_{timestamp}.json"
        
        # Ensure filename has .json extension
        if not filename.endswith('.json'):
            filename += '.json'
        
        # Create full path
        filepath = os.path.join(output_dir, filename)
        
        with open(filepath, 'w') as f:
            json.dump(self.results, f, indent=2)
        
        print(f"\nResults saved to: {filepath}")
        print(f"Output directory: {os.path.abspath(output_dir)}")


def main():
    parser = argparse.ArgumentParser(description='Network Scanner Tool')
    parser.add_argument('target', help='Target host or IP address')
    parser.add_argument('-p', '--ports', nargs='+', type=int, 
                       help='Ports to scan (default: common ports)')
    parser.add_argument('-t', '--threads', type=int, default=100,
                       help='Number of threads (default: 100)')
    parser.add_argument('-o', '--output', help='Output file for results')
    parser.add_argument('-d', '--output-dir', default='output',
                       help='Output directory (default: output)')
    
    args = parser.parse_args()
    
    scanner = NetworkScanner(args.target, args.ports, args.threads)
    scanner.run_scan()
    scanner.save_results(args.output, args.output_dir)


if __name__ == "__main__":
    main()
