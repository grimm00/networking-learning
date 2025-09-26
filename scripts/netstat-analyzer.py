#!/usr/bin/env python3
"""
Netstat Analyzer Tool
Analyzes network connections and statistics using netstat command.
"""

import subprocess
import argparse
import json
import re
from collections import defaultdict, Counter
import time

class NetstatAnalyzer:
    def __init__(self):
        self.connections = []
        self.routing_table = []
        self.interface_stats = []
        self.protocol_stats = {}
        
    def run_netstat(self, options):
        """Run netstat command with specified options"""
        try:
            cmd = ['netstat'] + options
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
            if result.returncode != 0:
                print(f"Error running netstat: {result.stderr}")
                return None
            return result.stdout
        except subprocess.TimeoutExpired:
            print("netstat command timed out")
            return None
        except Exception as e:
            print(f"Error running netstat: {e}")
            return None
    
    def parse_connections(self, output):
        """Parse netstat connection output"""
        connections = []
        lines = output.strip().split('\n')
        
        # Skip header lines
        data_lines = [line for line in lines if line and not line.startswith('Active') and not line.startswith('Proto')]
        
        for line in data_lines:
            parts = line.split()
            if len(parts) >= 6:
                try:
                    conn = {
                        'proto': parts[0],
                        'recv_q': parts[1],
                        'send_q': parts[2],
                        'local_address': parts[3],
                        'foreign_address': parts[4],
                        'state': parts[5] if len(parts) > 5 else 'N/A',
                        'pid_program': ' '.join(parts[6:]) if len(parts) > 6 else 'N/A'
                    }
                    connections.append(conn)
                except Exception as e:
                    print(f"Error parsing connection line: {line} - {e}")
        
        return connections
    
    def parse_routing_table(self, output):
        """Parse netstat routing table output"""
        routes = []
        lines = output.strip().split('\n')
        
        # Skip header lines
        data_lines = [line for line in lines if line and not line.startswith('Kernel') and not line.startswith('Destination')]
        
        for line in data_lines:
            parts = line.split()
            if len(parts) >= 8:
                try:
                    route = {
                        'destination': parts[0],
                        'gateway': parts[1],
                        'genmask': parts[2],
                        'flags': parts[3],
                        'metric': parts[4],
                        'ref': parts[5],
                        'use': parts[6],
                        'interface': parts[7]
                    }
                    routes.append(route)
                except Exception as e:
                    print(f"Error parsing route line: {line} - {e}")
        
        return routes
    
    def parse_interface_stats(self, output):
        """Parse netstat interface statistics"""
        interfaces = []
        lines = output.strip().split('\n')
        
        # Skip header lines
        data_lines = [line for line in lines if line and not line.startswith('Kernel') and not line.startswith('Iface')]
        
        for line in data_lines:
            parts = line.split()
            if len(parts) >= 11:
                try:
                    interface = {
                        'name': parts[0],
                        'mtu': parts[1],
                        'rx_ok': parts[2],
                        'rx_err': parts[3],
                        'rx_drp': parts[4],
                        'rx_ovr': parts[5],
                        'tx_ok': parts[6],
                        'tx_err': parts[7],
                        'tx_drp': parts[8],
                        'tx_ovr': parts[9],
                        'flg': parts[10]
                    }
                    interfaces.append(interface)
                except Exception as e:
                    print(f"Error parsing interface line: {line} - {e}")
        
        return interfaces
    
    def analyze_connections(self):
        """Analyze network connections"""
        print("=== Network Connections Analysis ===")
        
        # Get TCP connections
        tcp_output = self.run_netstat(['-tuna'])
        if tcp_output:
            tcp_connections = self.parse_connections(tcp_output)
            
            # Connection state analysis
            states = Counter(conn['state'] for conn in tcp_connections)
            print(f"\nConnection States:")
            for state, count in states.most_common():
                print(f"  {state}: {count}")
            
            # Protocol analysis
            protocols = Counter(conn['proto'] for conn in tcp_connections)
            print(f"\nProtocols:")
            for proto, count in protocols.most_common():
                print(f"  {proto}: {count}")
            
            # Top local ports
            local_ports = Counter()
            for conn in tcp_connections:
                if ':' in conn['local_address']:
                    port = conn['local_address'].split(':')[-1]
                    local_ports[port] += 1
            
            print(f"\nTop Local Ports:")
            for port, count in local_ports.most_common(10):
                print(f"  Port {port}: {count} connections")
            
            # Top remote addresses
            remote_addrs = Counter()
            for conn in tcp_connections:
                if conn['foreign_address'] != '*:*':
                    addr = conn['foreign_address'].split(':')[0]
                    remote_addrs[addr] += 1
            
            print(f"\nTop Remote Addresses:")
            for addr, count in remote_addrs.most_common(10):
                print(f"  {addr}: {count} connections")
            
            # Process analysis
            processes = Counter()
            for conn in tcp_connections:
                if conn['pid_program'] != 'N/A':
                    process = conn['pid_program'].split('/')[-1] if '/' in conn['pid_program'] else conn['pid_program']
                    processes[process] += 1
            
            print(f"\nTop Processes:")
            for process, count in processes.most_common(10):
                print(f"  {process}: {count} connections")
    
    def analyze_routing(self):
        """Analyze routing table"""
        print("\n=== Routing Table Analysis ===")
        
        routing_output = self.run_netstat(['-rn'])
        if routing_output:
            routes = self.parse_routing_table(routing_output)
            
            print(f"Total Routes: {len(routes)}")
            
            # Default routes
            default_routes = [r for r in routes if r['destination'] == '0.0.0.0']
            print(f"Default Routes: {len(default_routes)}")
            
            # Interface analysis
            interfaces = Counter(r['interface'] for r in routes)
            print(f"\nRoutes by Interface:")
            for interface, count in interfaces.most_common():
                print(f"  {interface}: {count} routes")
            
            # Gateway analysis
            gateways = Counter(r['gateway'] for r in routes if r['gateway'] != '0.0.0.0')
            print(f"\nGateways:")
            for gateway, count in gateways.most_common():
                print(f"  {gateway}: {count} routes")
    
    def analyze_interfaces(self):
        """Analyze interface statistics"""
        print("\n=== Interface Statistics Analysis ===")
        
        interface_output = self.run_netstat(['-i'])
        if interface_output:
            interfaces = self.parse_interface_stats(interface_output)
            
            print(f"Total Interfaces: {len(interfaces)}")
            
            for interface in interfaces:
                print(f"\nInterface: {interface['name']}")
                print(f"  MTU: {interface['mtu']}")
                print(f"  RX OK: {interface['rx_ok']}, ERR: {interface['rx_err']}, DROP: {interface['rx_drp']}")
                print(f"  TX OK: {interface['tx_ok']}, ERR: {interface['tx_err']}, DROP: {interface['tx_drp']}")
                print(f"  Flags: {interface['flg']}")
                
                # Calculate error rates
                rx_total = int(interface['rx_ok']) + int(interface['rx_err']) + int(interface['rx_drp'])
                tx_total = int(interface['tx_ok']) + int(interface['tx_err']) + int(interface['tx_drp'])
                
                if rx_total > 0:
                    rx_error_rate = (int(interface['rx_err']) + int(interface['rx_drp'])) / rx_total * 100
                    print(f"  RX Error Rate: {rx_error_rate:.2f}%")
                
                if tx_total > 0:
                    tx_error_rate = (int(interface['tx_err']) + int(interface['tx_drp'])) / tx_total * 100
                    print(f"  TX Error Rate: {tx_error_rate:.2f}%")
    
    def analyze_protocol_stats(self):
        """Analyze protocol statistics"""
        print("\n=== Protocol Statistics Analysis ===")
        
        stats_output = self.run_netstat(['-s'])
        if stats_output:
            lines = stats_output.strip().split('\n')
            
            # Parse TCP statistics
            tcp_stats = {}
            in_tcp_section = False
            
            for line in lines:
                line = line.strip()
                if line.startswith('Tcp:'):
                    in_tcp_section = True
                    continue
                elif line.startswith('Udp:') or line.startswith('Ip:') or line.startswith('Icmp:'):
                    in_tcp_section = False
                    continue
                
                if in_tcp_section and line:
                    parts = line.split()
                    if len(parts) >= 2:
                        try:
                            value = int(parts[0])
                            key = ' '.join(parts[1:])
                            tcp_stats[key] = value
                        except ValueError:
                            continue
            
            print("TCP Statistics:")
            for key, value in tcp_stats.items():
                print(f"  {key}: {value}")
    
    def generate_report(self, output_file=None):
        """Generate comprehensive analysis report"""
        report = {
            'timestamp': time.strftime('%Y-%m-%d %H:%M:%S'),
            'connections': self.connections,
            'routing': self.routing_table,
            'interfaces': self.interface_stats,
            'protocol_stats': self.protocol_stats
        }
        
        if output_file:
            with open(output_file, 'w') as f:
                json.dump(report, f, indent=2)
            print(f"\nReport saved to: {output_file}")
        else:
            print("\n=== JSON Report ===")
            print(json.dumps(report, indent=2))
    
    def run_full_analysis(self):
        """Run complete netstat analysis"""
        print("🔍 Starting Netstat Analysis...")
        print("=" * 60)
        
        self.analyze_connections()
        self.analyze_routing()
        self.analyze_interfaces()
        self.analyze_protocol_stats()
        
        print("\n✅ Netstat analysis complete!")

def main():
    parser = argparse.ArgumentParser(description="Netstat Analyzer Tool")
    parser.add_argument("-c", "--connections", action="store_true", 
                       help="Analyze network connections")
    parser.add_argument("-r", "--routing", action="store_true", 
                       help="Analyze routing table")
    parser.add_argument("-i", "--interfaces", action="store_true", 
                       help="Analyze interface statistics")
    parser.add_argument("-s", "--stats", action="store_true", 
                       help="Analyze protocol statistics")
    parser.add_argument("-a", "--all", action="store_true", 
                       help="Run full analysis")
    parser.add_argument("-o", "--output", help="Output file for JSON report")
    
    args = parser.parse_args()
    
    analyzer = NetstatAnalyzer()
    
    if args.all:
        analyzer.run_full_analysis()
    else:
        if args.connections:
            analyzer.analyze_connections()
        if args.routing:
            analyzer.analyze_routing()
        if args.interfaces:
            analyzer.analyze_interfaces()
        if args.stats:
            analyzer.analyze_protocol_stats()
        
        if not any([args.connections, args.routing, args.interfaces, args.stats]):
            print("Please specify analysis type. Use -h for help.")
            return
    
    if args.output:
        analyzer.generate_report(args.output)

if __name__ == "__main__":
    main()
