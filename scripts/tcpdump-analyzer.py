#!/usr/bin/env python3
"""
TCP Dump Analyzer

A comprehensive tool for analyzing tcpdump output and packet captures.
Provides detailed analysis of network traffic patterns, protocols, and performance.

Version: 1.0.0
License: MIT

Usage:
    python3 tcpdump-analyzer.py [options] [file]

Options:
    -f, --file FILE          Analyze pcap file
    -i, --interface INTERFACE Capture from interface
    -c, --count COUNT        Number of packets to capture
    -t, --timeout SECONDS    Capture timeout
    -f, --filter FILTER      BPF filter expression
    -s, --stats              Show statistics only
    -p, --protocol PROTOCOL  Focus on specific protocol
    -h, --host HOST          Focus on specific host
    -v, --verbose            Verbose output
    --help                   Show this help message

Examples:
    python3 tcpdump-analyzer.py -i eth0 -c 100
    python3 tcpdump-analyzer.py -f capture.pcap -s
    python3 tcpdump-analyzer.py -i eth0 -f "tcp port 80" -v
"""

import argparse
import subprocess
import sys
import re
import json
from collections import defaultdict, Counter
from datetime import datetime
from typing import Dict, List, Optional, Tuple
import os

class PacketAnalyzer:
    """Analyzes network packets from tcpdump output"""
    
    def __init__(self, verbose: bool = False):
        self.verbose = verbose
        self.packets = []
        self.stats = {
            'total_packets': 0,
            'protocols': Counter(),
            'hosts': Counter(),
            'ports': Counter(),
            'packet_sizes': [],
            'timestamps': [],
            'connections': defaultdict(list),
            'errors': []
        }
    
    def capture_packets(self, interface: str, count: int = 100, 
                       filter_expr: str = "", timeout: int = 30) -> bool:
        """Capture packets using tcpdump"""
        import tempfile
        import os
        import time
        
        try:
            # Create temporary file for tcpdump output
            with tempfile.NamedTemporaryFile(mode='w+', delete=False, suffix='.pcap') as temp_file:
                temp_filename = temp_file.name
            
            # Check if running as root, if so don't use sudo
            if os.geteuid() == 0:
                # If interface is 'any' or empty, don't specify -i flag
                if interface and interface.lower() != 'any':
                    cmd = ['tcpdump', '-i', interface, '-c', str(count), '-n', '-w', temp_filename]
                else:
                    cmd = ['tcpdump', '-c', str(count), '-n', '-w', temp_filename]
            else:
                if interface and interface.lower() != 'any':
                    cmd = ['sudo', 'tcpdump', '-i', interface, '-c', str(count), '-n', '-w', temp_filename]
                else:
                    cmd = ['sudo', 'tcpdump', '-c', str(count), '-n', '-w', temp_filename]
            
            if filter_expr:
                cmd.extend(['-f', filter_expr])
            
            if self.verbose:
                cmd.append('-v')
            
            print(f"🔍 Capturing packets on {interface}...")
            print(f"Command: {' '.join(cmd)}")
            print(f"⏰ Starting capture for {timeout} seconds...")
            print(f"💡 Generate some network traffic now (ping, arping, etc.)")
            
            # Start tcpdump process in background
            process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            
            # Give tcpdump time to start
            time.sleep(1)
            
            try:
                # Wait for tcpdump to finish or timeout
                stdout, stderr = process.communicate(timeout=timeout)
                
                if process.returncode != 0:
                    print(f"❌ tcpdump failed: {stderr}")
                    return False
                
                # Check if pcap file was created and has content
                if os.path.exists(temp_filename) and os.path.getsize(temp_filename) > 0:
                    # Read the pcap file and convert to text
                    read_cmd = ['tcpdump', '-r', temp_filename, '-n']
                    if self.verbose:
                        read_cmd.append('-v')
                    
                    result = subprocess.run(read_cmd, capture_output=True, text=True)
                    if result.returncode == 0 and result.stdout.strip():
                        self.parse_tcpdump_output(result.stdout)
                        return True
                    else:
                        print("⚠️ No packets captured")
                        return False
                else:
                    print("⚠️ No packets captured")
                    return False
                    
            except subprocess.TimeoutExpired:
                process.kill()
                stdout, stderr = process.communicate()
                
                # Check if pcap file was created and has content
                if os.path.exists(temp_filename) and os.path.getsize(temp_filename) > 0:
                    # Read the pcap file and convert to text
                    read_cmd = ['tcpdump', '-r', temp_filename, '-n']
                    if self.verbose:
                        read_cmd.append('-v')
                    
                    result = subprocess.run(read_cmd, capture_output=True, text=True)
                    if result.returncode == 0 and result.stdout.strip():
                        self.parse_tcpdump_output(result.stdout)
                        return True
                    else:
                        print("⚠️ No packets captured")
                        return False
                else:
                    print(f"⏰ Capture timed out after {timeout} seconds")
                    return False
            
        except Exception as e:
            print(f"❌ Error capturing packets: {e}")
            return False
        finally:
            # Clean up temporary file
            if 'temp_filename' in locals() and os.path.exists(temp_filename):
                os.unlink(temp_filename)
    
    def analyze_file(self, filename: str) -> bool:
        """Analyze packets from a pcap file"""
        try:
            if not os.path.exists(filename):
                print(f"❌ File not found: {filename}")
                return False
            
            print(f"📁 Analyzing file: {filename}")
            
            # Read pcap file with tcpdump
            cmd = ['tcpdump', '-r', filename, '-n']
            if self.verbose:
                cmd.append('-v')
            
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode != 0:
                print(f"❌ Failed to read pcap file: {result.stderr}")
                return False
            
            self.parse_tcpdump_output(result.stdout)
            return True
            
        except Exception as e:
            print(f"❌ Error analyzing file: {e}")
            return False
    
    def parse_tcpdump_output(self, output: str):
        """Parse tcpdump output and extract packet information"""
        lines = output.strip().split('\n')
        
        for line in lines:
            if not line.strip():
                continue
            
            packet_info = self.parse_packet_line(line)
            if packet_info:
                self.packets.append(packet_info)
                self.update_stats(packet_info)
    
    def parse_packet_line(self, line: str) -> Optional[Dict]:
        """Parse a single tcpdump line"""
        try:
            # Basic tcpdump line format:
            # timestamp IP src > dst: protocol info
            
            # Extract timestamp
            timestamp_match = re.match(r'^(\d{2}:\d{2}:\d{2}\.\d+)', line)
            if not timestamp_match:
                return None
            
            timestamp = timestamp_match.group(1)
            
            # Extract IP addresses and protocol
            ip_match = re.search(r'IP (\d+\.\d+\.\d+\.\d+)\.(\d+) > (\d+\.\d+\.\d+\.\d+)\.(\d+):', line)
            if ip_match:
                src_ip, src_port, dst_ip, dst_port = ip_match.groups()
                protocol = 'TCP'
            else:
                # Try UDP
                udp_match = re.search(r'IP (\d+\.\d+\.\d+\.\d+)\.(\d+) > (\d+\.\d+\.\d+\.\d+)\.(\d+): UDP', line)
                if udp_match:
                    src_ip, src_port, dst_ip, dst_port = udp_match.groups()
                    protocol = 'UDP'
                else:
                    # Try ICMP
                    icmp_match = re.search(r'IP (\d+\.\d+\.\d+\.\d+) > (\d+\.\d+\.\d+\.\d+): ICMP', line)
                    if icmp_match:
                        src_ip, dst_ip = icmp_match.groups()
                        src_port, dst_port = '0', '0'
                        protocol = 'ICMP'
                    else:
                        return None
            
            # Extract packet size
            size_match = re.search(r'length (\d+)', line)
            packet_size = int(size_match.group(1)) if size_match else 0
            
            # Extract flags for TCP
            flags = []
            if protocol == 'TCP':
                if 'Flags [S]' in line:
                    flags.append('SYN')
                if 'Flags [.]' in line:
                    flags.append('ACK')
                if 'Flags [F]' in line:
                    flags.append('FIN')
                if 'Flags [R]' in line:
                    flags.append('RST')
            
            return {
                'timestamp': timestamp,
                'src_ip': src_ip,
                'src_port': src_port,
                'dst_ip': dst_ip,
                'dst_port': dst_port,
                'protocol': protocol,
                'size': packet_size,
                'flags': flags,
                'raw_line': line
            }
            
        except Exception as e:
            if self.verbose:
                print(f"⚠️ Error parsing line: {line[:50]}... - {e}")
            return None
    
    def update_stats(self, packet_info: Dict):
        """Update statistics with packet information"""
        self.stats['total_packets'] += 1
        self.stats['protocols'][packet_info['protocol']] += 1
        self.stats['hosts'][packet_info['src_ip']] += 1
        self.stats['hosts'][packet_info['dst_ip']] += 1
        
        if packet_info['src_port'] != '0':
            self.stats['ports'][packet_info['src_port']] += 1
        if packet_info['dst_port'] != '0':
            self.stats['ports'][packet_info['dst_port']] += 1
        
        self.stats['packet_sizes'].append(packet_info['size'])
        self.stats['timestamps'].append(packet_info['timestamp'])
        
        # Track connections
        connection = f"{packet_info['src_ip']}:{packet_info['src_port']} -> {packet_info['dst_ip']}:{packet_info['dst_port']}"
        self.stats['connections'][connection].append(packet_info)
    
    def analyze_protocols(self) -> Dict:
        """Analyze protocol distribution"""
        protocol_stats = {}
        
        for protocol, count in self.stats['protocols'].items():
            percentage = (count / self.stats['total_packets']) * 100
            protocol_stats[protocol] = {
                'count': count,
                'percentage': round(percentage, 2)
            }
        
        return protocol_stats
    
    def analyze_hosts(self, top_n: int = 10) -> List[Tuple[str, int]]:
        """Analyze top talking hosts"""
        return self.stats['hosts'].most_common(top_n)
    
    def analyze_ports(self, top_n: int = 10) -> List[Tuple[str, int]]:
        """Analyze most used ports"""
        return self.stats['ports'].most_common(top_n)
    
    def analyze_connections(self) -> Dict:
        """Analyze connection patterns"""
        connection_stats = {}
        
        for connection, packets in self.stats['connections'].items():
            if len(packets) > 1:  # Only connections with multiple packets
                connection_stats[connection] = {
                    'packet_count': len(packets),
                    'protocols': list(set(p['protocol'] for p in packets)),
                    'duration': self.calculate_connection_duration(packets)
                }
        
        return connection_stats
    
    def calculate_connection_duration(self, packets: List[Dict]) -> float:
        """Calculate connection duration in seconds"""
        if len(packets) < 2:
            return 0.0
        
        timestamps = [self.parse_timestamp(p['timestamp']) for p in packets]
        return max(timestamps) - min(timestamps)
    
    def parse_timestamp(self, timestamp: str) -> float:
        """Parse timestamp to seconds since epoch"""
        try:
            # Convert HH:MM:SS.mmm to seconds
            time_parts = timestamp.split(':')
            hours = int(time_parts[0])
            minutes = int(time_parts[1])
            seconds_parts = time_parts[2].split('.')
            seconds = int(seconds_parts[0])
            milliseconds = int(seconds_parts[1]) if len(seconds_parts) > 1 else 0
            
            total_seconds = hours * 3600 + minutes * 60 + seconds + milliseconds / 1000
            return total_seconds
        except:
            return 0.0
    
    def detect_anomalies(self) -> List[str]:
        """Detect potential network anomalies"""
        anomalies = []
        
        # Check for high number of RST packets
        rst_packets = sum(1 for p in self.packets if 'RST' in p.get('flags', []))
        if rst_packets > self.stats['total_packets'] * 0.1:  # More than 10% RST
            anomalies.append(f"High number of RST packets: {rst_packets}")
        
        # Check for unusual port usage
        if self.stats['ports']:
            most_common_port = self.stats['ports'].most_common(1)[0]
            if most_common_port[1] > self.stats['total_packets'] * 0.5:  # More than 50% on one port
                anomalies.append(f"Concentrated traffic on port {most_common_port[0]}: {most_common_port[1]} packets")
        
        # Check for large packets
        if self.stats['packet_sizes']:
            avg_size = sum(self.stats['packet_sizes']) / len(self.stats['packet_sizes'])
            large_packets = sum(1 for size in self.stats['packet_sizes'] if size > avg_size * 2)
            if large_packets > 0:
                anomalies.append(f"Unusually large packets detected: {large_packets}")
        
        return anomalies
    
    def generate_report(self) -> str:
        """Generate comprehensive analysis report"""
        report = []
        report.append("=" * 60)
        report.append("📊 TCP DUMP ANALYSIS REPORT")
        report.append("=" * 60)
        report.append(f"📅 Analysis Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        report.append(f"📦 Total Packets: {self.stats['total_packets']}")
        report.append("")
        
        # Protocol Analysis
        report.append("🔍 PROTOCOL ANALYSIS")
        report.append("-" * 30)
        protocol_stats = self.analyze_protocols()
        for protocol, stats in protocol_stats.items():
            report.append(f"{protocol:8} {stats['count']:6} packets ({stats['percentage']:5.1f}%)")
        report.append("")
        
        # Top Hosts
        report.append("🌐 TOP TALKING HOSTS")
        report.append("-" * 30)
        top_hosts = self.analyze_hosts()
        for host, count in top_hosts:
            report.append(f"{host:15} {count:6} packets")
        report.append("")
        
        # Top Ports
        report.append("🔌 MOST USED PORTS")
        report.append("-" * 30)
        top_ports = self.analyze_ports()
        for port, count in top_ports:
            report.append(f"Port {port:5} {count:6} packets")
        report.append("")
        
        # Connection Analysis
        report.append("🔗 CONNECTION ANALYSIS")
        report.append("-" * 30)
        connections = self.analyze_connections()
        if connections:
            for connection, stats in list(connections.items())[:5]:  # Top 5
                report.append(f"{connection}")
                report.append(f"  Packets: {stats['packet_count']}, Duration: {stats['duration']:.2f}s")
        report.append("")
        
        # Anomalies
        report.append("⚠️  ANOMALY DETECTION")
        report.append("-" * 30)
        anomalies = self.detect_anomalies()
        if anomalies:
            for anomaly in anomalies:
                report.append(f"• {anomaly}")
        else:
            report.append("No significant anomalies detected")
        report.append("")
        
        # Packet Size Statistics
        if self.stats['packet_sizes']:
            report.append("📏 PACKET SIZE STATISTICS")
            report.append("-" * 30)
            sizes = self.stats['packet_sizes']
            report.append(f"Average: {sum(sizes)/len(sizes):.1f} bytes")
            report.append(f"Minimum: {min(sizes)} bytes")
            report.append(f"Maximum: {max(sizes)} bytes")
            report.append("")
        
        return "\n".join(report)
    
    def save_report(self, filename: str):
        """Save analysis report to file"""
        report = self.generate_report()
        try:
            with open(filename, 'w') as f:
                f.write(report)
            print(f"📄 Report saved to: {filename}")
        except Exception as e:
            print(f"❌ Error saving report: {e}")

def main():
    parser = argparse.ArgumentParser(
        description="TCP Dump Analyzer - Comprehensive packet analysis tool",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__
    )
    
    parser.add_argument('-f', '--file', help='Analyze pcap file')
    parser.add_argument('-i', '--interface', default='any', help='Capture from interface (default: any)')
    parser.add_argument('-c', '--count', type=int, default=100, help='Number of packets to capture')
    parser.add_argument('-t', '--timeout', type=int, default=30, help='Capture timeout in seconds')
    parser.add_argument('--filter', help='BPF filter expression')
    parser.add_argument('-s', '--stats', action='store_true', help='Show statistics only')
    parser.add_argument('-p', '--protocol', help='Focus on specific protocol')
    parser.add_argument('--host', help='Focus on specific host')
    parser.add_argument('-v', '--verbose', action='store_true', help='Verbose output')
    parser.add_argument('--save-report', help='Save report to file')
    
    args = parser.parse_args()
    
    # Create analyzer
    analyzer = PacketAnalyzer(verbose=args.verbose)
    
    # Determine analysis method
    if args.file:
        success = analyzer.analyze_file(args.file)
    elif args.interface:
        success = analyzer.capture_packets(
            args.interface, 
            args.count, 
            args.filter or "", 
            args.timeout
        )
    else:
        print("❌ Please specify either -f (file) or -i (interface)")
        sys.exit(1)
    
    if not success:
        sys.exit(1)
    
    # Generate and display report
    if args.stats:
        print(analyzer.generate_report())
    else:
        print(analyzer.generate_report())
        
        if args.verbose and analyzer.packets:
            print("\n📋 DETAILED PACKET LIST")
            print("-" * 60)
            for i, packet in enumerate(analyzer.packets[:20]):  # Show first 20 packets
                print(f"{i+1:3}. {packet['timestamp']} {packet['src_ip']}:{packet['src_port']} -> {packet['dst_ip']}:{packet['dst_port']} {packet['protocol']} {packet['size']} bytes")
    
    # Save report if requested
    if args.save_report:
        analyzer.save_report(args.save_report)

if __name__ == "__main__":
    main()
