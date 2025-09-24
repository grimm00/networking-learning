#!/usr/bin/env python3
"""
Tshark Packet Analyzer

A comprehensive tool for analyzing network packets using tshark.
Provides capture, analysis, and reporting capabilities for network troubleshooting.

Usage:
    python3 tshark-analyzer.py [options] [target]

Examples:
    python3 tshark-analyzer.py -i eth0 -c 100
    python3 tshark-analyzer.py -f "port 80" -Y "http"
    python3 tshark-analyzer.py -r capture.pcap -s protocol
    python3 tshark-analyzer.py -i any -a duration:30 -e performance
"""

import subprocess
import json
import sys
import argparse
import time
import os
import tempfile
from pathlib import Path
from typing import Dict, List, Optional, Tuple
import re

class TsharkAnalyzer:
    """Comprehensive tshark packet analyzer"""
    
    def __init__(self, verbose: bool = False):
        self.verbose = verbose
        self.output_dir = "output"
        self.ensure_output_dir()
        
    def ensure_output_dir(self):
        """Create output directory if it doesn't exist"""
        Path(self.output_dir).mkdir(exist_ok=True)
        
    def check_tshark_availability(self) -> bool:
        """Check if tshark is available and get version"""
        try:
            result = subprocess.run(['tshark', '--version'], 
                                  capture_output=True, text=True, timeout=10)
            if result.returncode == 0:
                version_line = result.stdout.split('\n')[0]
                print(f"✅ Tshark available: {version_line}")
                return True
            else:
                print("❌ Tshark not available")
                return False
        except (subprocess.TimeoutExpired, FileNotFoundError):
            print("❌ Tshark not found or not accessible")
            return False
    
    def list_interfaces(self) -> List[Dict[str, str]]:
        """List available capture interfaces"""
        try:
            result = subprocess.run(['tshark', '-D'], 
                                  capture_output=True, text=True, timeout=10)
            if result.returncode == 0:
                interfaces = []
                for line in result.stdout.strip().split('\n'):
                    if line.strip():
                        parts = line.split('.', 1)
                        if len(parts) == 2:
                            interfaces.append({
                                'number': parts[0].strip(),
                                'name': parts[1].strip(),
                                'description': parts[1].strip()
                            })
                return interfaces
            else:
                print("❌ Failed to list interfaces")
                return []
        except subprocess.TimeoutExpired:
            print("❌ Timeout listing interfaces")
            return []
    
    def capture_packets(self, interface: str = "any", count: int = 100, 
                       capture_filter: str = "", duration: int = 0, 
                       output_file: str = None) -> str:
        """Capture packets using tshark"""
        print(f"🔍 Capturing packets on interface: {interface}")
        
        # Build tshark command
        cmd = ['tshark', '-i', interface]
        
        if count > 0:
            cmd.extend(['-c', str(count)])
        
        if duration > 0:
            cmd.extend(['-a', f'duration:{duration}'])
        
        if capture_filter:
            cmd.extend(['-f', capture_filter])
        
        # If output file is specified, write to pcap file
        if output_file:
            cmd.extend(['-w', output_file])
            print(f"📁 Saving capture to: {output_file}")
        else:
            # Add JSON output for analysis
            cmd.extend(['-T', 'json'])
        
        try:
            print(f"Running: {' '.join(cmd)}")
            timeout_val = max(duration + 30, 60)  # Minimum 60 seconds
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout_val)
            
            if result.returncode == 0:
                if output_file:
                    # For pcap files, just confirm capture
                    print(f"✅ Captured packets and saved to {output_file}")
                    return f"pcap_file:{output_file}"
                else:
                    packet_count = len(result.stdout.split('\n'))
                    print(f"✅ Captured {packet_count} packets")
                    return result.stdout
            else:
                print(f"❌ Capture failed: {result.stderr}")
                return ""
        except subprocess.TimeoutExpired:
            print("❌ Capture timeout")
            return ""
    
    def analyze_packets(self, packet_data: str) -> Dict:
        """Analyze captured packet data"""
        if not packet_data.strip():
            return {"error": "No packet data to analyze"}
        
        try:
            # Try to parse as JSON array first
            try:
                packets = json.loads(packet_data.strip())
                if not isinstance(packets, list):
                    packets = [packets]
            except json.JSONDecodeError:
                # Fallback to line-by-line parsing
                packets = []
                for line in packet_data.strip().split('\n'):
                    if line.strip():
                        try:
                            packet = json.loads(line)
                            packets.append(packet)
                        except json.JSONDecodeError:
                            continue
            
            analysis = {
                "total_packets": len(packets),
                "protocols": {},
                "hosts": {},
                "ports": {},
                "packet_sizes": [],
                "timestamps": [],
                "errors": []
            }
            
            for packet in packets:
                self._analyze_packet(packet, analysis)
            
            return analysis
            
        except Exception as e:
            return {"error": f"Analysis failed: {str(e)}"}
    
    def _analyze_packet(self, packet: Dict, analysis: Dict):
        """Analyze individual packet"""
        try:
            # Extract basic information - handle both direct and _source structures
            if '_source' in packet:
                frame_info = packet.get('_source', {}).get('layers', {})
            else:
                frame_info = packet.get('layers', {})
            
            # Protocol analysis
            if 'frame' in frame_info:
                frame_protocols = frame_info['frame'].get('frame.protocols', '')
                for protocol in frame_protocols.split(':'):
                    if protocol:
                        analysis['protocols'][protocol] = analysis['protocols'].get(protocol, 0) + 1
            
            # Host analysis
            if 'ip' in frame_info:
                src_ip = frame_info['ip'].get('ip.src', '')
                dst_ip = frame_info['ip'].get('ip.dst', '')
                
                if src_ip:
                    analysis['hosts'][src_ip] = analysis['hosts'].get(src_ip, 0) + 1
                if dst_ip:
                    analysis['hosts'][dst_ip] = analysis['hosts'].get(dst_ip, 0) + 1
            
            # Port analysis
            if 'tcp' in frame_info:
                src_port = frame_info['tcp'].get('tcp.srcport', '')
                dst_port = frame_info['tcp'].get('tcp.dstport', '')
                
                if src_port:
                    analysis['ports'][f"TCP:{src_port}"] = analysis['ports'].get(f"TCP:{src_port}", 0) + 1
                if dst_port:
                    analysis['ports'][f"TCP:{dst_port}"] = analysis['ports'].get(f"TCP:{dst_port}", 0) + 1
            
            elif 'udp' in frame_info:
                src_port = frame_info['udp'].get('udp.srcport', '')
                dst_port = frame_info['udp'].get('udp.dstport', '')
                
                if src_port:
                    analysis['ports'][f"UDP:{src_port}"] = analysis['ports'].get(f"UDP:{src_port}", 0) + 1
                if dst_port:
                    analysis['ports'][f"UDP:{dst_port}"] = analysis['ports'].get(f"UDP:{dst_port}", 0) + 1
            
            # Packet size analysis
            if 'frame' in frame_info:
                frame_len = frame_info['frame'].get('frame.len', '0')
                try:
                    size = int(frame_len)
                    analysis['packet_sizes'].append(size)
                except ValueError:
                    pass
            
            # Timestamp analysis
            if 'frame' in frame_info:
                timestamp = frame_info['frame'].get('frame.time', '')
                if timestamp:
                    analysis['timestamps'].append(timestamp)
            
        except Exception as e:
            analysis['errors'].append(f"Packet analysis error: {str(e)}")
    
    def generate_statistics(self, analysis: Dict) -> Dict:
        """Generate statistical analysis"""
        stats = {
            "packet_count": analysis.get('total_packets', 0),
            "protocol_distribution": {},
            "top_hosts": [],
            "top_ports": [],
            "packet_size_stats": {},
            "time_range": {}
        }
        
        # Protocol distribution
        total_packets = analysis.get('total_packets', 1)
        for protocol, count in analysis.get('protocols', {}).items():
            stats['protocol_distribution'][protocol] = {
                'count': count,
                'percentage': round((count / total_packets) * 100, 2)
            }
        
        # Top hosts
        hosts = analysis.get('hosts', {})
        stats['top_hosts'] = sorted(hosts.items(), key=lambda x: x[1], reverse=True)[:10]
        
        # Top ports
        ports = analysis.get('ports', {})
        stats['top_ports'] = sorted(ports.items(), key=lambda x: x[1], reverse=True)[:10]
        
        # Packet size statistics
        sizes = analysis.get('packet_sizes', [])
        if sizes:
            stats['packet_size_stats'] = {
                'min': min(sizes),
                'max': max(sizes),
                'avg': round(sum(sizes) / len(sizes), 2),
                'total_bytes': sum(sizes)
            }
        
        # Time range
        timestamps = analysis.get('timestamps', [])
        if timestamps:
            stats['time_range'] = {
                'start': min(timestamps),
                'end': max(timestamps),
                'duration_packets': len(timestamps)
            }
        
        return stats
    
    def print_analysis(self, analysis: Dict, stats: Dict):
        """Print analysis results"""
        print("\n" + "="*60)
        print("📊 TSHARK PACKET ANALYSIS RESULTS")
        print("="*60)
        
        print(f"\n📈 PACKET SUMMARY")
        print(f"Total Packets: {stats['packet_count']}")
        
        if stats['packet_size_stats']:
            size_stats = stats['packet_size_stats']
            print(f"Total Bytes: {size_stats['total_bytes']:,}")
            print(f"Average Packet Size: {size_stats['avg']} bytes")
            print(f"Min Packet Size: {size_stats['min']} bytes")
            print(f"Max Packet Size: {size_stats['max']} bytes")
        
        print(f"\n🌐 PROTOCOL DISTRIBUTION")
        for protocol, data in stats['protocol_distribution'].items():
            print(f"{protocol:20} {data['count']:6} packets ({data['percentage']:5.1f}%)")
        
        print(f"\n🏠 TOP HOSTS")
        for host, count in stats['top_hosts'][:5]:
            print(f"{host:20} {count:6} packets")
        
        print(f"\n🔌 TOP PORTS")
        for port, count in stats['top_ports'][:5]:
            print(f"{port:20} {count:6} packets")
        
        if stats['time_range']:
            print(f"\n⏰ TIME RANGE")
            print(f"Start: {stats['time_range']['start']}")
            print(f"End: {stats['time_range']['end']}")
            print(f"Duration: {stats['time_range']['duration_packets']} packets")
        
        if analysis.get('errors'):
            print(f"\n⚠️  ERRORS")
            for error in analysis['errors'][:5]:
                print(f"  {error}")
    
    def save_results(self, analysis: Dict, stats: Dict, output_file: str = None):
        """Save analysis results to file"""
        if not output_file:
            timestamp = time.strftime("%Y%m%d_%H%M%S")
            output_file = f"{self.output_dir}/tshark_analysis_{timestamp}.json"
        
        results = {
            "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
            "analysis": analysis,
            "statistics": stats
        }
        
        try:
            with open(output_file, 'w') as f:
                json.dump(results, f, indent=2)
            print(f"\n💾 Results saved to: {output_file}")
        except Exception as e:
            print(f"❌ Failed to save results: {e}")
    
    def run_capture_analysis(self, interface: str = "any", count: int = 100, 
                           capture_filter: str = "", duration: int = 0, 
                           output_file: str = None) -> bool:
        """Run complete capture and analysis"""
        print("🚀 Starting Tshark Analysis")
        print("="*40)
        
        # Check tshark availability
        if not self.check_tshark_availability():
            return False
        
        # List interfaces
        interfaces = self.list_interfaces()
        if interfaces:
            print(f"\n📡 Available Interfaces:")
            for iface in interfaces[:5]:
                print(f"  {iface['number']}. {iface['name']}")
        
        # Capture packets
        packet_data = self.capture_packets(interface, count, capture_filter, duration, output_file)
        if not packet_data:
            print("❌ No packets captured")
            return False
        
        # If output file was specified, we just saved a pcap file
        if output_file and packet_data.startswith("pcap_file:"):
            print(f"✅ Pcap file saved successfully: {output_file}")
            return True
        
        # Analyze packets
        print("\n🔍 Analyzing packets...")
        analysis = self.analyze_packets(packet_data)
        
        # Generate statistics
        stats = self.generate_statistics(analysis)
        
        # Print results
        self.print_analysis(analysis, stats)
        
        # Save results
        self.save_results(analysis, stats)
        
        return True
    
    def run_file_analysis(self, pcap_file: str) -> bool:
        """Analyze packets from pcap file"""
        print(f"📁 Analyzing pcap file: {pcap_file}")
        
        if not os.path.exists(pcap_file):
            print(f"❌ File not found: {pcap_file}")
            return False
        
        try:
            # Read pcap file with tshark
            cmd = ['tshark', '-r', pcap_file, '-T', 'json']
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=60)
            
            if result.returncode == 0:
                analysis = self.analyze_packets(result.stdout)
                stats = self.generate_statistics(analysis)
                
                self.print_analysis(analysis, stats)
                self.save_results(analysis, stats)
                return True
            else:
                print(f"❌ Failed to read pcap file: {result.stderr}")
                return False
                
        except subprocess.TimeoutExpired:
            print("❌ Timeout reading pcap file")
            return False

def main():
    parser = argparse.ArgumentParser(description='Tshark Packet Analyzer')
    parser.add_argument('-i', '--interface', default='any', 
                       help='Network interface to capture on (default: any)')
    parser.add_argument('-c', '--count', type=int, default=100,
                       help='Number of packets to capture (default: 100)')
    parser.add_argument('-f', '--filter', default='',
                       help='Capture filter (BPF syntax)')
    parser.add_argument('-d', '--duration', type=int, default=0,
                       help='Capture duration in seconds (0 = unlimited)')
    parser.add_argument('-r', '--read', 
                       help='Read packets from pcap file')
    parser.add_argument('-o', '--output',
                       help='Output file for results')
    parser.add_argument('-v', '--verbose', action='store_true',
                       help='Verbose output')
    
    args = parser.parse_args()
    
    analyzer = TsharkAnalyzer(verbose=args.verbose)
    
    if args.read:
        # Analyze pcap file
        success = analyzer.run_file_analysis(args.read)
    else:
        # Live capture and analysis
        success = analyzer.run_capture_analysis(
            interface=args.interface,
            count=args.count,
            capture_filter=args.filter,
            duration=args.duration,
            output_file=args.output
        )
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
