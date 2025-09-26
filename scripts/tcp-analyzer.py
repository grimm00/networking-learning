#!/usr/bin/env python3
"""
TCP Protocol Analyzer
A comprehensive tool for analyzing TCP connections, performance, and troubleshooting.
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

class TCPAnalyzer:
    def __init__(self):
        self.results = {
            'timestamp': datetime.now().isoformat(),
            'tcp_connections': [],
            'tcp_statistics': {},
            'performance_metrics': {},
            'network_interfaces': [],
            'analysis_summary': {}
        }

    def get_tcp_connections(self) -> List[Dict]:
        """Get all TCP connections using netstat"""
        try:
            # Use netstat to get TCP connections
            result = subprocess.run(['netstat', '-tuln'], 
                                  capture_output=True, text=True)
            
            connections = []
            for line in result.stdout.split('\n'):
                if 'tcp' in line and 'LISTEN' in line:
                    parts = line.split()
                    if len(parts) >= 4:
                        local_addr = parts[3]
                        state = parts[5] if len(parts) > 5 else 'UNKNOWN'
                        
                        # Parse local address
                        if ':' in local_addr:
                            host, port = local_addr.rsplit(':', 1)
                            connections.append({
                                'protocol': 'TCP',
                                'local_host': host,
                                'local_port': int(port),
                                'state': state,
                                'interface': '0.0.0.0' if host == '*' else host
                            })
            
            return connections
        except Exception as e:
            print(f"Error getting TCP connections: {e}")
            return []

    def get_tcp_statistics(self) -> Dict:
        """Get TCP statistics from /proc/net/tcp"""
        try:
            stats = {}
            
            # Read TCP statistics
            with open('/proc/net/tcp', 'r') as f:
                lines = f.readlines()
            
            # Parse header
            if lines:
                header = lines[0].strip().split()
                stats['total_connections'] = len(lines) - 1
                
                # Count connections by state
                state_counts = {}
                for line in lines[1:]:
                    parts = line.split()
                    if len(parts) >= 4:
                        state = parts[3]
                        state_counts[state] = state_counts.get(state, 0) + 1
                
                stats['state_counts'] = state_counts
            
            return stats
        except Exception as e:
            print(f"Error getting TCP statistics: {e}")
            return {}

    def analyze_tcp_performance(self) -> Dict:
        """Analyze TCP performance metrics"""
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
            
            return performance
        except Exception as e:
            print(f"Error analyzing TCP performance: {e}")
            return {}

    def test_tcp_connection(self, host: str, port: int, timeout: int = 5) -> Dict:
        """Test TCP connection to a specific host and port"""
        try:
            start_time = time.time()
            
            # Test connection
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(timeout)
            
            result = sock.connect_ex((host, port))
            end_time = time.time()
            
            sock.close()
            
            return {
                'host': host,
                'port': port,
                'success': result == 0,
                'response_time': round((end_time - start_time) * 1000, 2),  # ms
                'error_code': result,
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

    def run_analysis(self, test_connections: List[Tuple[str, int]] = None) -> Dict:
        """Run comprehensive TCP analysis"""
        print("🔍 Starting TCP analysis...")
        
        # Get TCP connections
        print("  📊 Gathering TCP connections...")
        self.results['tcp_connections'] = self.get_tcp_connections()
        
        # Get TCP statistics
        print("  📈 Collecting TCP statistics...")
        self.results['tcp_statistics'] = self.get_tcp_statistics()
        
        # Analyze performance
        print("  ⚡ Analyzing TCP performance...")
        self.results['performance_metrics'] = self.analyze_tcp_performance()
        
        # Test specific connections if provided
        if test_connections:
            print("  🔗 Testing specific connections...")
            connection_tests = []
            for host, port in test_connections:
                test_result = self.test_tcp_connection(host, port)
                connection_tests.append(test_result)
            self.results['connection_tests'] = connection_tests
        
        print("✅ TCP analysis complete!")
        return self.results

    def print_summary(self):
        """Print analysis summary"""
        print("\n" + "="*60)
        print("TCP ANALYSIS SUMMARY")
        print("="*60)
        print(f"Total TCP Connections: {len(self.results['tcp_connections'])}")
        
        # Show listening ports
        listening = [c for c in self.results['tcp_connections'] if c['state'] == 'LISTEN']
        print(f"Listening Ports: {len(listening)}")
        for conn in listening:
            print(f"  {conn['local_host']}:{conn['local_port']}")

def main():
    parser = argparse.ArgumentParser(description="TCP Protocol Analyzer")
    parser.add_argument("-c", "--connection", help="Test specific connection (host:port)")
    parser.add_argument("-e", "--export", help="Export results to JSON file")
    parser.add_argument("-v", "--verbose", action="store_true", help="Verbose output")
    
    args = parser.parse_args()
    
    analyzer = TCPAnalyzer()
    
    # Test connections if specified
    test_connections = []
    if args.connection:
        try:
            host, port = args.connection.split(':')
            test_connections.append((host, int(port)))
        except ValueError:
            print("Error: Connection format should be 'host:port'")
            sys.exit(1)
    
    # Run analysis
    results = analyzer.run_analysis(test_connections)
    
    # Print results
    analyzer.print_summary()
    
    # Export results if requested
    if args.export:
        with open(args.export, 'w') as f:
            json.dump(results, f, indent=2)
        print(f"\n📁 Results exported to {args.export}")

if __name__ == "__main__":
    main()
