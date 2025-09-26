#!/usr/bin/env python3
"""
UDP Protocol Analyzer
A comprehensive tool for analyzing UDP connections, performance, and troubleshooting.
"""

import socket
import subprocess
import json
import argparse
import time
import psutil
import sys
from datetime import datetime
from typing import Dict, List, Optional, Tuple

class UDPAnalyzer:
    def __init__(self):
        self.results = {
            'timestamp': datetime.now().isoformat(),
            'udp_connections': [],
            'udp_statistics': {},
            'performance_metrics': {},
            'network_interfaces': [],
            'analysis_summary': {}
        }

    def get_udp_connections(self) -> List[Dict]:
        """Get all UDP connections using netstat"""
        try:
            # Use netstat to get UDP connections
            result = subprocess.run(['netstat', '-uln'], 
                                  capture_output=True, text=True)
            
            connections = []
            for line in result.stdout.split('\n'):
                if 'udp' in line:
                    parts = line.split()
                    if len(parts) >= 4:
                        local_addr = parts[3]
                        
                        # Parse local address
                        if ':' in local_addr:
                            host, port = local_addr.rsplit(':', 1)
                            connections.append({
                                'protocol': 'UDP',
                                'local_host': host,
                                'local_port': int(port),
                                'interface': '0.0.0.0' if host == '*' else host
                            })
            
            return connections
        except Exception as e:
            print(f"Error getting UDP connections: {e}")
            return []

    def get_udp_statistics(self) -> Dict:
        """Get UDP statistics from /proc/net/udp"""
        try:
            stats = {}
            
            # Read UDP statistics
            with open('/proc/net/udp', 'r') as f:
                lines = f.readlines()
            
            # Parse header
            if lines:
                stats['total_connections'] = len(lines) - 1
                
                # Parse UDP connections
                udp_connections = []
                for line in lines[1:]:
                    parts = line.split()
                    if len(parts) >= 4:
                        local_addr = parts[1]
                        remote_addr = parts[2]
                        state = parts[3]
                        
                        # Convert hex addresses to IP:port
                        local_ip, local_port = self._hex_to_addr(local_addr)
                        remote_ip, remote_port = self._hex_to_addr(remote_addr)
                        
                        udp_connections.append({
                            'local_ip': local_ip,
                            'local_port': local_port,
                            'remote_ip': remote_ip,
                            'remote_port': remote_port,
                            'state': state
                        })
                
                stats['udp_connections'] = udp_connections
            
            return stats
        except Exception as e:
            print(f"Error getting UDP statistics: {e}")
            return {}

    def _hex_to_addr(self, hex_addr: str) -> Tuple[str, int]:
        """Convert hexadecimal address to IP:port"""
        try:
            # Remove leading zeros and convert
            addr_parts = hex_addr.split(':')
            if len(addr_parts) >= 2:
                ip_hex = addr_parts[0]
                port_hex = addr_parts[1]
                
                # Convert IP (little-endian)
                ip_bytes = bytes.fromhex(ip_hex)
                ip = '.'.join(str(b) for b in reversed(ip_bytes))
                
                # Convert port (little-endian)
                port = int(port_hex, 16)
                
                return ip, port
        except:
            pass
        
        return "0.0.0.0", 0

    def analyze_udp_performance(self) -> Dict:
        """Analyze UDP performance metrics"""
        try:
            performance = {}
            
            # Get network statistics
            net_io = psutil.net_io_counters()
            performance['bytes_sent'] = net_io.bytes_sent
            performance['bytes_recv'] = net_io.bytes_recv
            performance['packets_sent'] = net_io.packets_sent
            performance['packets_recv'] = net_io.packets_recv
            performance['errin'] = net_io.errin
            performance['errout'] = net_io.errout
            performance['dropin'] = net_io.dropin
            performance['dropout'] = net_io.dropout
            
            # Get UDP-specific metrics from /proc/net/snmp
            try:
                with open('/proc/net/snmp', 'r') as f:
                    lines = f.readlines()
                
                for i, line in enumerate(lines):
                    if line.startswith('Udp:'):
                        if i + 1 < len(lines):
                            values = lines[i + 1].split()
                            udp_labels = line.split()[1:]
                            
                            for j, label in enumerate(udp_labels):
                                if j < len(values):
                                    performance[f'udp_{label.lower()}'] = int(values[j])
            except:
                pass
            
            return performance
        except Exception as e:
            print(f"Error analyzing UDP performance: {e}")
            return {}

    def test_udp_connection(self, host: str, port: int, timeout: int = 5) -> Dict:
        """Test UDP connection to a specific host and port"""
        try:
            start_time = time.time()
            
            # Test UDP connection
            sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            sock.settimeout(timeout)
            
            # Send a test packet
            test_data = b"UDP_TEST"
            sock.sendto(test_data, (host, port))
            
            # Try to receive response
            try:
                data, addr = sock.recvfrom(1024)
                end_time = time.time()
                sock.close()
                
                return {
                    'host': host,
                    'port': port,
                    'success': True,
                    'response_time': round((end_time - start_time) * 1000, 2),  # ms
                    'response_data': data.decode('utf-8', errors='ignore'),
                    'response_from': addr,
                    'timestamp': datetime.now().isoformat()
                }
            except socket.timeout:
                end_time = time.time()
                sock.close()
                
                return {
                    'host': host,
                    'port': port,
                    'success': False,
                    'response_time': round((end_time - start_time) * 1000, 2),  # ms
                    'error': 'Timeout - no response received',
                    'timestamp': datetime.now().isoformat()
                }
                
        except Exception as e:
            return {
                'host': host,
                'port': port,
                'success': False,
                'error': str(e),
                'timestamp': datetime.now().isoformat()
            }

    def analyze_udp_service(self, service: str) -> Dict:
        """Analyze specific UDP service"""
        udp_services = {
            'dns': 53,
            'dhcp': 67,
            'ntp': 123,
            'snmp': 161,
            'syslog': 514,
            'tftp': 69
        }
        
        if service.lower() in udp_services:
            port = udp_services[service.lower()]
            return self.test_udp_connection('127.0.0.1', port)
        else:
            return {
                'service': service,
                'error': f'Unknown UDP service: {service}',
                'available_services': list(udp_services.keys())
            }

    def monitor_udp_traffic(self, duration: int = 10) -> Dict:
        """Monitor UDP traffic for specified duration"""
        try:
            print(f"Monitoring UDP traffic for {duration} seconds...")
            
            # Use tcpdump to capture UDP traffic
            cmd = [
                'timeout', str(duration), 'tcpdump', '-i', 'any', '-n',
                'udp', '-c', '50'  # Limit to 50 packets
            ]
            
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            return {
                'duration': duration,
                'captured_packets': len(result.stdout.split('\n')) - 1,
                'raw_output': result.stdout,
                'timestamp': datetime.now().isoformat()
            }
        except Exception as e:
            return {
                'duration': duration,
                'error': str(e),
                'timestamp': datetime.now().isoformat()
            }

    def run_analysis(self, test_connections: List[Tuple[str, int]] = None, 
                    monitor_traffic: bool = False) -> Dict:
        """Run comprehensive UDP analysis"""
        print("🔍 Starting UDP analysis...")
        
        # Get UDP connections
        print("  📊 Gathering UDP connections...")
        self.results['udp_connections'] = self.get_udp_connections()
        
        # Get UDP statistics
        print("  📈 Collecting UDP statistics...")
        self.results['udp_statistics'] = self.get_udp_statistics()
        
        # Analyze performance
        print("  ⚡ Analyzing UDP performance...")
        self.results['performance_metrics'] = self.analyze_udp_performance()
        
        # Test specific connections if provided
        if test_connections:
            print("  🔗 Testing specific connections...")
            connection_tests = []
            for host, port in test_connections:
                test_result = self.test_udp_connection(host, port)
                connection_tests.append(test_result)
            self.results['connection_tests'] = connection_tests
        
        # Monitor traffic if requested
        if monitor_traffic:
            print("  📡 Monitoring UDP traffic...")
            self.results['traffic_monitor'] = self.monitor_udp_traffic(10)
        
        print("✅ UDP analysis complete!")
        return self.results

    def print_summary(self):
        """Print analysis summary"""
        print("\n" + "="*60)
        print("UDP ANALYSIS SUMMARY")
        print("="*60)
        print(f"Total UDP Connections: {len(self.results['udp_connections'])}")
        
        # Show listening ports
        print("UDP Listening Ports:")
        for conn in self.results['udp_connections']:
            print(f"  {conn['local_host']}:{conn['local_port']}")
        
        # Show performance metrics
        if self.results['performance_metrics']:
            perf = self.results['performance_metrics']
            print(f"\nNetwork Statistics:")
            print(f"  Bytes Sent: {perf.get('bytes_sent', 0):,}")
            print(f"  Bytes Received: {perf.get('bytes_recv', 0):,}")
            print(f"  Packets Sent: {perf.get('packets_sent', 0):,}")
            print(f"  Packets Received: {perf.get('packets_recv', 0):,}")
            print(f"  Errors In: {perf.get('errin', 0)}")
            print(f"  Errors Out: {perf.get('errout', 0)}")

def main():
    parser = argparse.ArgumentParser(description="UDP Protocol Analyzer")
    parser.add_argument("-c", "--connection", help="Test specific connection (host:port)")
    parser.add_argument("-s", "--service", help="Test specific UDP service (dns, dhcp, ntp, etc.)")
    parser.add_argument("-m", "--monitor", action="store_true", help="Monitor UDP traffic")
    parser.add_argument("-e", "--export", help="Export results to JSON file")
    parser.add_argument("-v", "--verbose", action="store_true", help="Verbose output")
    
    args = parser.parse_args()
    
    analyzer = UDPAnalyzer()
    
    # Test connections if specified
    test_connections = []
    if args.connection:
        try:
            host, port = args.connection.split(':')
            test_connections.append((host, int(port)))
        except ValueError:
            print("Error: Connection format should be 'host:port'")
            sys.exit(1)
    
    # Test service if specified
    if args.service:
        service_result = analyzer.analyze_udp_service(args.service)
        print(f"\nService Test Result:")
        print(json.dumps(service_result, indent=2))
    
    # Run analysis
    results = analyzer.run_analysis(test_connections, args.monitor)
    
    # Print results
    analyzer.print_summary()
    
    # Export results if requested
    if args.export:
        with open(args.export, 'w') as f:
            json.dump(results, f, indent=2)
        print(f"\n📁 Results exported to {args.export}")

if __name__ == "__main__":
    main()
