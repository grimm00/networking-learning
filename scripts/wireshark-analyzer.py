#!/usr/bin/env python3
"""
Wireshark Packet Analyzer

A comprehensive tool for analyzing network packets using Wireshark's command-line
interface (tshark). This script provides detailed packet analysis, protocol
statistics, and network troubleshooting capabilities.

Author: Networking Learning Project
Version: 1.0.0
"""

import argparse
import json
import subprocess
import sys
import time
from datetime import datetime
from typing import Dict, List, Optional, Tuple
import re

class WiresharkAnalyzer:
    def __init__(self):
        self.packets = []
        self.analysis_results = {}
        self.output_dir = "output/wireshark-analysis"
        
    def log(self, message: str, level: str = "INFO") -> None:
        """Log messages with timestamp and level"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        print(f"[{timestamp}] {level}: {message}")
    
    def log_error(self, message: str) -> None:
        """Log error messages"""
        self.log(f"❌ {message}", "ERROR")
    
    def log_success(self, message: str) -> None:
        """Log success messages"""
        self.log(f"✅ {message}", "SUCCESS")
    
    def log_warning(self, message: str) -> None:
        """Log warning messages"""
        self.log(f"⚠️  {message}", "WARNING")
    
    def check_dependencies(self) -> bool:
        """Check if required tools are available"""
        required_tools = ['tshark']
        missing_tools = []
        
        for tool in required_tools:
            try:
                subprocess.run([tool, '--version'], capture_output=True, check=True)
            except (subprocess.CalledProcessError, FileNotFoundError):
                missing_tools.append(tool)
        
        if missing_tools:
            self.log_error(f"Missing required tools: {', '.join(missing_tools)}")
            self.log("Install with: sudo apt-get install tshark")
            return False
        
        return True
    
    def capture_packets(self, interface: str = "any", count: int = 100, 
                       duration: int = 30, filter_expr: str = "") -> List[Dict]:
        """Capture packets using tshark"""
        self.log(f"Capturing packets on interface {interface}")
        
        # Create output directory
        subprocess.run(['mkdir', '-p', self.output_dir], check=False)
        
        # Build tshark command
        cmd = [
            'tshark', '-i', interface, '-n', '-T', 'json',
            '-e', 'frame.number',
            '-e', 'frame.time',
            '-e', 'frame.len',
            '-e', 'frame.protocols',
            '-e', 'ip.src',
            '-e', 'ip.dst',
            '-e', 'ip.proto',
            '-e', 'ip.len',
            '-e', 'ip.ttl',
            '-e', 'ip.flags',
            '-e', 'ip.frag_offset',
            '-e', 'tcp.srcport',
            '-e', 'tcp.dstport',
            '-e', 'tcp.seq',
            '-e', 'tcp.ack',
            '-e', 'tcp.flags',
            '-e', 'tcp.window_size',
            '-e', 'tcp.len',
            '-e', 'udp.srcport',
            '-e', 'udp.dstport',
            '-e', 'udp.length',
            '-e', 'icmp.type',
            '-e', 'icmp.code',
            '-e', 'arp.opcode',
            '-e', 'arp.src.hw_mac',
            '-e', 'arp.dst.hw_mac',
            '-e', 'arp.src.proto_ipv4',
            '-e', 'arp.dst.proto_ipv4',
            '-e', 'dns.qry.name',
            '-e', 'dns.qry.type',
            '-e', 'dns.resp.name',
            '-e', 'dns.resp.type',
            '-e', 'dns.flags.response',
            '-e', 'dns.flags.rcode',
            '-e', 'http.request.method',
            '-e', 'http.request.uri',
            '-e', 'http.response.code',
            '-e', 'http.host',
            '-e', 'http.user_agent',
            '-e', 'tls.handshake.type',
            '-e', 'tls.record.version',
            '-e', 'dhcp.option.dhcp',
            '-e', 'dhcp.client_mac',
            '-e', 'dhcp.your_ip',
            '-e', 'dhcp.option.router',
            '-e', 'dhcp.option.domain_name_server'
        ]
        
        # Add capture filter if specified
        if filter_expr:
            cmd.extend(['-f', filter_expr])
        
        # Add count or duration
        if count > 0:
            cmd.extend(['-c', str(count)])
        elif duration > 0:
            cmd.extend(['-a', f'duration:{duration}'])
        
        try:
            self.log(f"Running: {' '.join(cmd)}")
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=duration + 30)
            
            if result.returncode != 0:
                self.log_error(f"tshark failed: {result.stderr}")
                return []
            
            # Parse JSON output
            try:
                packets = json.loads(result.stdout)
                self.log_success(f"Captured {len(packets)} packets")
                return packets
            except json.JSONDecodeError:
                self.log_error("Failed to parse tshark JSON output")
                return []
                
        except subprocess.TimeoutExpired:
            self.log_warning("Capture timed out")
            return []
        except Exception as e:
            self.log_error(f"Capture failed: {str(e)}")
            return []
    
    def analyze_packets(self, packets: List[Dict]) -> Dict:
        """Analyze captured packets and generate statistics"""
        self.log("Analyzing captured packets...")
        
        analysis = {
            'total_packets': len(packets),
            'total_bytes': 0,
            'protocols': {},
            'endpoints': {},
            'conversations': {},
            'top_talkers': {},
            'protocol_hierarchy': {},
            'timing_analysis': {},
            'error_analysis': {},
            'security_analysis': {}
        }
        
        for packet in packets:
            try:
                layers = packet.get('_source', {}).get('layers', {})
                
                # Extract packet information
                packet_info = {
                    'frame_number': layers.get('frame.number', [''])[0],
                    'timestamp': layers.get('frame.time', [''])[0],
                    'length': int(layers.get('frame.len', ['0'])[0]),
                    'protocols': layers.get('frame.protocols', [''])[0],
                    'src_ip': layers.get('ip.src', [''])[0],
                    'dst_ip': layers.get('ip.dst', [''])[0],
                    'ip_proto': layers.get('ip.proto', [''])[0],
                    'src_port': layers.get('tcp.srcport', layers.get('udp.srcport', [''])[0])[0],
                    'dst_port': layers.get('tcp.dstport', layers.get('udp.dstport', [''])[0])[0],
                    'tcp_flags': layers.get('tcp.flags', [''])[0],
                    'tcp_len': layers.get('tcp.len', [''])[0],
                    'udp_length': layers.get('udp.length', [''])[0],
                    'icmp_type': layers.get('icmp.type', [''])[0],
                    'icmp_code': layers.get('icmp.code', [''])[0],
                    'dns_query': layers.get('dns.qry.name', [''])[0],
                    'dns_response': layers.get('dns.resp.name', [''])[0],
                    'http_method': layers.get('http.request.method', [''])[0],
                    'http_uri': layers.get('http.request.uri', [''])[0],
                    'http_code': layers.get('http.response.code', [''])[0],
                    'http_host': layers.get('http.host', [''])[0],
                    'dhcp_type': layers.get('dhcp.option.dhcp', [''])[0]
                }
                
                # Update statistics
                analysis['total_bytes'] += packet_info['length']
                
                # Protocol analysis
                protocols = packet_info['protocols'].split(':') if packet_info['protocols'] else []
                for protocol in protocols:
                    if protocol:
                        analysis['protocols'][protocol] = analysis['protocols'].get(protocol, 0) + 1
                
                # Endpoint analysis
                if packet_info['src_ip']:
                    analysis['endpoints'][packet_info['src_ip']] = analysis['endpoints'].get(packet_info['src_ip'], 0) + 1
                if packet_info['dst_ip']:
                    analysis['endpoints'][packet_info['dst_ip']] = analysis['endpoints'].get(packet_info['dst_ip'], 0) + 1
                
                # Conversation analysis
                if packet_info['src_ip'] and packet_info['dst_ip']:
                    conv_key = tuple(sorted([packet_info['src_ip'], packet_info['dst_ip']]))
                    analysis['conversations'][conv_key] = analysis['conversations'].get(conv_key, 0) + 1
                
                # Top talkers analysis
                if packet_info['src_ip']:
                    analysis['top_talkers'][packet_info['src_ip']] = analysis['top_talkers'].get(packet_info['src_ip'], 0) + packet_info['length']
                
                # Protocol hierarchy
                self._update_protocol_hierarchy(analysis['protocol_hierarchy'], protocols)
                
                # Timing analysis
                self._analyze_timing(analysis['timing_analysis'], packet_info)
                
                # Error analysis
                self._analyze_errors(analysis['error_analysis'], packet_info)
                
                # Security analysis
                self._analyze_security(analysis['security_analysis'], packet_info)
                
            except Exception as e:
                self.log_warning(f"Error analyzing packet: {str(e)}")
                continue
        
        return analysis
    
    def _update_protocol_hierarchy(self, hierarchy: Dict, protocols: List[str]) -> None:
        """Update protocol hierarchy statistics"""
        current = hierarchy
        for protocol in protocols:
            if protocol:
                if protocol not in current:
                    current[protocol] = {'count': 0, 'children': {}}
                current[protocol]['count'] += 1
                current = current[protocol]['children']
    
    def _analyze_timing(self, timing: Dict, packet_info: Dict) -> None:
        """Analyze packet timing patterns"""
        if 'packet_times' not in timing:
            timing['packet_times'] = []
        
        try:
            # Parse timestamp (simplified)
            timestamp = packet_info['timestamp']
            timing['packet_times'].append(timestamp)
        except:
            pass
    
    def _analyze_errors(self, errors: Dict, packet_info: Dict) -> None:
        """Analyze network errors and issues"""
        # TCP errors
        if packet_info['tcp_flags']:
            if 'R' in packet_info['tcp_flags']:  # RST flag
                errors['tcp_resets'] = errors.get('tcp_resets', 0) + 1
        
        # ICMP errors
        if packet_info['icmp_type']:
            if packet_info['icmp_type'] == '3':  # Destination Unreachable
                errors['icmp_dest_unreach'] = errors.get('icmp_dest_unreach', 0) + 1
            elif packet_info['icmp_type'] == '11':  # Time Exceeded
                errors['icmp_time_exceeded'] = errors.get('icmp_time_exceeded', 0) + 1
        
        # DNS errors
        if packet_info['dns_response']:
            # This would need more detailed DNS analysis
            pass
    
    def _analyze_security(self, security: Dict, packet_info: Dict) -> None:
        """Analyze security-related patterns"""
        # Suspicious ports
        if packet_info['dst_port']:
            suspicious_ports = ['23', '21', '135', '139', '445', '1433', '3389']
            if packet_info['dst_port'] in suspicious_ports:
                security['suspicious_ports'] = security.get('suspicious_ports', 0) + 1
        
        # Large packets (potential data exfiltration)
        if packet_info['length'] > 1500:
            security['large_packets'] = security.get('large_packets', 0) + 1
        
        # HTTP analysis
        if packet_info['http_method']:
            if packet_info['http_method'] == 'POST':
                security['http_posts'] = security.get('http_posts', 0) + 1
    
    def generate_report(self, analysis: Dict) -> None:
        """Generate comprehensive analysis report"""
        self.log("Generating analysis report...")
        
        report_file = f"{self.output_dir}/wireshark_analysis_report_{int(time.time())}.json"
        
        # Save detailed analysis
        with open(report_file, 'w') as f:
            json.dump(analysis, f, indent=2, default=str)
        
        self.log_success(f"Detailed analysis saved to: {report_file}")
        
        # Print summary
        self._print_summary(analysis)
    
    def _print_summary(self, analysis: Dict) -> None:
        """Print analysis summary"""
        print("\n" + "="*60)
        print("🔍 WIRESHARK ANALYSIS SUMMARY")
        print("="*60)
        
        print(f"\n📊 PACKET STATISTICS:")
        print(f"   Total packets: {analysis['total_packets']}")
        print(f"   Total bytes: {analysis['total_bytes']:,}")
        print(f"   Average packet size: {analysis['total_bytes'] // max(analysis['total_packets'], 1):,} bytes")
        
        print(f"\n🌐 PROTOCOL DISTRIBUTION:")
        sorted_protocols = sorted(analysis['protocols'].items(), key=lambda x: x[1], reverse=True)
        for protocol, count in sorted_protocols[:10]:
            percentage = (count / analysis['total_packets']) * 100
            print(f"   {protocol}: {count} ({percentage:.1f}%)")
        
        print(f"\n👥 TOP ENDPOINTS:")
        sorted_endpoints = sorted(analysis['endpoints'].items(), key=lambda x: x[1], reverse=True)
        for endpoint, count in sorted_endpoints[:10]:
            print(f"   {endpoint}: {count} packets")
        
        print(f"\n💬 TOP CONVERSATIONS:")
        sorted_conversations = sorted(analysis['conversations'].items(), key=lambda x: x[1], reverse=True)
        for (src, dst), count in sorted_conversations[:10]:
            print(f"   {src} ↔ {dst}: {count} packets")
        
        print(f"\n📈 TOP TALKERS (BY BYTES):")
        sorted_talkers = sorted(analysis['top_talkers'].items(), key=lambda x: x[1], reverse=True)
        for endpoint, bytes_sent in sorted_talkers[:10]:
            print(f"   {endpoint}: {bytes_sent:,} bytes")
        
        # Error analysis
        if analysis['error_analysis']:
            print(f"\n⚠️  ERROR ANALYSIS:")
            for error_type, count in analysis['error_analysis'].items():
                print(f"   {error_type}: {count}")
        
        # Security analysis
        if analysis['security_analysis']:
            print(f"\n🔒 SECURITY ANALYSIS:")
            for security_type, count in analysis['security_analysis'].items():
                print(f"   {security_type}: {count}")
        
        print("\n" + "="*60)
    
    def run_analysis(self, interface: str = "any", count: int = 100, 
                    duration: int = 30, filter_expr: str = "") -> None:
        """Run complete Wireshark analysis"""
        self.log("Starting Wireshark analysis...")
        
        if not self.check_dependencies():
            return
        
        # Capture packets
        packets = self.capture_packets(interface, count, duration, filter_expr)
        if not packets:
            self.log_error("No packets captured")
            return
        
        # Analyze packets
        analysis = self.analyze_packets(packets)
        
        # Generate report
        self.generate_report(analysis)
        
        self.log_success("Wireshark analysis completed!")

def main():
    parser = argparse.ArgumentParser(description="Wireshark Packet Analyzer")
    parser.add_argument('-i', '--interface', default='any', 
                       help='Network interface to capture on (default: any)')
    parser.add_argument('-c', '--count', type=int, default=100,
                       help='Number of packets to capture (default: 100)')
    parser.add_argument('-d', '--duration', type=int, default=30,
                       help='Capture duration in seconds (default: 30)')
    parser.add_argument('-f', '--filter', default='',
                       help='Capture filter expression (BPF format)')
    parser.add_argument('-v', '--verbose', action='store_true',
                       help='Enable verbose output')
    
    args = parser.parse_args()
    
    analyzer = WiresharkAnalyzer()
    analyzer.run_analysis(args.interface, args.count, args.duration, args.filter)

if __name__ == "__main__":
    main()
