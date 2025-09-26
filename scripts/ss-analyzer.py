#!/usr/bin/env python3
"""
SS (Socket Statistics) Analyzer Tool
Analyzes network connections and statistics using ss command.
"""

import subprocess
import argparse
import json
import re
from collections import defaultdict, Counter
import time

class SSAnalyzer:
    def __init__(self):
        self.connections = []
        self.summary_stats = {}
        
    def run_ss(self, options):
        """Run ss command with specified options"""
        try:
            cmd = ['ss'] + options
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
            if result.returncode != 0:
                print(f"Error running ss: {result.stderr}")
                return None
            return result.stdout
        except subprocess.TimeoutExpired:
            print("ss command timed out")
            return None
        except Exception as e:
            print(f"Error running ss: {e}")
            return None
    
    def parse_connections(self, output):
        """Parse ss connection output"""
        connections = []
        lines = output.strip().split('\n')
        
        # Skip header lines
        data_lines = [line for line in lines if line and not line.startswith('State') and not line.startswith('Netid')]
        
        for line in data_lines:
            parts = line.split()
            if len(parts) >= 4:
                try:
                    conn = {
                        'state': parts[0],
                        'recv_q': parts[1],
                        'send_q': parts[2],
                        'local_address': parts[3],
                        'peer_address': parts[4] if len(parts) > 4 else 'N/A',
                        'process': ' '.join(parts[5:]) if len(parts) > 5 else 'N/A'
                    }
                    connections.append(conn)
                except Exception as e:
                    print(f"Error parsing connection line: {line} - {e}")
        
        return connections
    
    def parse_summary_stats(self, output):
        """Parse ss summary statistics"""
        stats = {}
        lines = output.strip().split('\n')
        
        for line in lines:
            if ':' in line:
                parts = line.split(':', 1)
                key = parts[0].strip()
                value = parts[1].strip()
                stats[key] = value
        
        return stats
    
    def analyze_connections(self):
        """Analyze network connections"""
        print("=== Socket Statistics Analysis ===")
        
        # Get all connections
        ss_output = self.run_ss(['-tuna'])
        if ss_output:
            connections = self.parse_connections(ss_output)
            
            print(f"Total Connections: {len(connections)}")
            
            # Connection state analysis
            states = Counter(conn['state'] for conn in connections)
            print(f"\nConnection States:")
            for state, count in states.most_common():
                print(f"  {state}: {count}")
            
            # Top local ports
            local_ports = Counter()
            for conn in connections:
                if ':' in conn['local_address']:
                    port = conn['local_address'].split(':')[-1]
                    local_ports[port] += 1
            
            print(f"\nTop Local Ports:")
            for port, count in local_ports.most_common(10):
                print(f"  Port {port}: {count} connections")
            
            # Top peer addresses
            peer_addrs = Counter()
            for conn in connections:
                if conn['peer_address'] != 'N/A' and conn['peer_address'] != '*:*':
                    addr = conn['peer_address'].split(':')[0]
                    peer_addrs[addr] += 1
            
            print(f"\nTop Peer Addresses:")
            for addr, count in peer_addrs.most_common(10):
                print(f"  {addr}: {count} connections")
            
            # Process analysis
            processes = Counter()
            for conn in connections:
                if conn['process'] != 'N/A':
                    # Extract process name from process info
                    process_match = re.search(r'\(([^,]+)', conn['process'])
                    if process_match:
                        process = process_match.group(1)
                        processes[process] += 1
            
            print(f"\nTop Processes:")
            for process, count in processes.most_common(10):
                print(f"  {process}: {count} connections")
    
    def analyze_listening_sockets(self):
        """Analyze listening sockets"""
        print("\n=== Listening Sockets Analysis ===")
        
        listening_output = self.run_ss(['-tuln'])
        if listening_output:
            connections = self.parse_connections(listening_output)
            
            print(f"Total Listening Sockets: {len(connections)}")
            
            # Port analysis
            ports = Counter()
            for conn in connections:
                if ':' in conn['local_address']:
                    port = conn['local_address'].split(':')[-1]
                    ports[port] += 1
            
            print(f"\nListening Ports:")
            for port, count in ports.most_common():
                print(f"  Port {port}: {count} sockets")
            
            # Address analysis
            addresses = Counter()
            for conn in connections:
                addr = conn['local_address'].split(':')[0]
                addresses[addr] += 1
            
            print(f"\nListening Addresses:")
            for addr, count in addresses.most_common():
                print(f"  {addr}: {count} sockets")
    
    def analyze_established_connections(self):
        """Analyze established connections"""
        print("\n=== Established Connections Analysis ===")
        
        established_output = self.run_ss(['-tuna', 'state', 'established'])
        if established_output:
            connections = self.parse_connections(established_output)
            
            print(f"Total Established Connections: {len(connections)}")
            
            # Remote address analysis
            remote_addrs = Counter()
            for conn in connections:
                if conn['peer_address'] != 'N/A':
                    addr = conn['peer_address'].split(':')[0]
                    remote_addrs[addr] += 1
            
            print(f"\nTop Remote Addresses:")
            for addr, count in remote_addrs.most_common(10):
                print(f"  {addr}: {count} connections")
            
            # Port analysis
            local_ports = Counter()
            for conn in connections:
                if ':' in conn['local_address']:
                    port = conn['local_address'].split(':')[-1]
                    local_ports[port] += 1
            
            print(f"\nTop Local Ports:")
            for port, count in local_ports.most_common(10):
                print(f"  Port {port}: {count} connections")
    
    def analyze_time_wait_connections(self):
        """Analyze TIME-WAIT connections"""
        print("\n=== TIME-WAIT Connections Analysis ===")
        
        timewait_output = self.run_ss(['-tuna', 'state', 'time-wait'])
        if timewait_output:
            connections = self.parse_connections(timewait_output)
            
            print(f"Total TIME-WAIT Connections: {len(connections)}")
            
            if len(connections) > 0:
                # Port analysis
                ports = Counter()
                for conn in connections:
                    if ':' in conn['local_address']:
                        port = conn['local_address'].split(':')[-1]
                        ports[port] += 1
                
                print(f"\nTIME-WAIT by Port:")
                for port, count in ports.most_common(10):
                    print(f"  Port {port}: {count} connections")
                
                # Check for potential connection leaks
                if len(connections) > 1000:
                    print(f"\n⚠️  WARNING: High number of TIME-WAIT connections ({len(connections)})")
                    print("   This may indicate connection leaks or high connection churn.")
    
    def analyze_summary_stats(self):
        """Analyze summary statistics"""
        print("\n=== Summary Statistics ===")
        
        summary_output = self.run_ss(['-s'])
        if summary_output:
            stats = self.parse_summary_stats(summary_output)
            
            for key, value in stats.items():
                print(f"  {key}: {value}")
    
    def analyze_socket_memory(self):
        """Analyze socket memory usage"""
        print("\n=== Socket Memory Analysis ===")
        
        memory_output = self.run_ss(['-m'])
        if memory_output:
            lines = memory_output.strip().split('\n')
            
            total_memory = 0
            for line in lines:
                if 'skmem:' in line:
                    # Parse memory usage from skmem: format
                    memory_match = re.search(r'skmem:\((\d+),(\d+),(\d+)\)', line)
                    if memory_match:
                        rmem = int(memory_match.group(1))
                        wmem = int(memory_match.group(2))
                        fmem = int(memory_match.group(3))
                        total_memory += rmem + wmem + fmem
                        print(f"  Socket Memory: R:{rmem} W:{wmem} F:{fmem}")
            
            print(f"  Total Socket Memory: {total_memory} bytes")
    
    def analyze_tcp_info(self):
        """Analyze TCP internal information"""
        print("\n=== TCP Internal Information ===")
        
        tcp_info_output = self.run_ss(['-i'])
        if tcp_info_output:
            lines = tcp_info_output.strip().split('\n')
            
            for line in lines:
                if 'tcp' in line.lower():
                    print(f"  {line}")
    
    def generate_report(self, output_file=None):
        """Generate comprehensive analysis report"""
        report = {
            'timestamp': time.strftime('%Y-%m-%d %H:%M:%S'),
            'connections': self.connections,
            'summary_stats': self.summary_stats
        }
        
        if output_file:
            with open(output_file, 'w') as f:
                json.dump(report, f, indent=2)
            print(f"\nReport saved to: {output_file}")
        else:
            print("\n=== JSON Report ===")
            print(json.dumps(report, indent=2))
    
    def run_full_analysis(self):
        """Run complete ss analysis"""
        print("🔍 Starting SS Analysis...")
        print("=" * 60)
        
        self.analyze_connections()
        self.analyze_listening_sockets()
        self.analyze_established_connections()
        self.analyze_time_wait_connections()
        self.analyze_summary_stats()
        self.analyze_socket_memory()
        self.analyze_tcp_info()
        
        print("\n✅ SS analysis complete!")

def main():
    parser = argparse.ArgumentParser(description="SS Analyzer Tool")
    parser.add_argument("-c", "--connections", action="store_true", 
                       help="Analyze network connections")
    parser.add_argument("-l", "--listening", action="store_true", 
                       help="Analyze listening sockets")
    parser.add_argument("-e", "--established", action="store_true", 
                       help="Analyze established connections")
    parser.add_argument("-t", "--timewait", action="store_true", 
                       help="Analyze TIME-WAIT connections")
    parser.add_argument("-s", "--stats", action="store_true", 
                       help="Analyze summary statistics")
    parser.add_argument("-m", "--memory", action="store_true", 
                       help="Analyze socket memory usage")
    parser.add_argument("-i", "--tcp-info", action="store_true", 
                       help="Analyze TCP internal information")
    parser.add_argument("-a", "--all", action="store_true", 
                       help="Run full analysis")
    parser.add_argument("-o", "--output", help="Output file for JSON report")
    
    args = parser.parse_args()
    
    analyzer = SSAnalyzer()
    
    if args.all:
        analyzer.run_full_analysis()
    else:
        if args.connections:
            analyzer.analyze_connections()
        if args.listening:
            analyzer.analyze_listening_sockets()
        if args.established:
            analyzer.analyze_established_connections()
        if args.timewait:
            analyzer.analyze_time_wait_connections()
        if args.stats:
            analyzer.analyze_summary_stats()
        if args.memory:
            analyzer.analyze_socket_memory()
        if args.tcp_info:
            analyzer.analyze_tcp_info()
        
        if not any([args.connections, args.listening, args.established, 
                   args.timewait, args.stats, args.memory, args.tcp_info]):
            print("Please specify analysis type. Use -h for help.")
            return
    
    if args.output:
        analyzer.generate_report(args.output)

if __name__ == "__main__":
    main()
