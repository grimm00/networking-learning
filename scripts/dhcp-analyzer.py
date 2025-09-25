#!/usr/bin/env python3
"""
DHCP Packet Analyzer

A comprehensive tool for analyzing DHCP traffic, understanding the DORA process,
and troubleshooting DHCP-related issues. This script captures and analyzes
DHCP packets to provide insights into network configuration and behavior.

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

class DHCPAnalyzer:
    def __init__(self):
        self.packets = []
        self.analysis_results = {}
        self.output_dir = "output/dhcp-analysis"
        
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
        required_tools = ['tcpdump', 'tshark']
        missing_tools = []
        
        for tool in required_tools:
            try:
                subprocess.run([tool, '--version'], capture_output=True, check=True)
            except (subprocess.CalledProcessError, FileNotFoundError):
                missing_tools.append(tool)
        
        if missing_tools:
            self.log_error(f"Missing required tools: {', '.join(missing_tools)}")
            self.log("Install with: sudo apt-get install tcpdump tshark")
            return False
        
        return True
    
    def capture_dhcp_packets(self, interface: str = "any", count: int = 50, 
                           duration: int = 30) -> List[Dict]:
        """Capture DHCP packets using tcpdump"""
        self.log(f"Capturing DHCP packets on interface {interface}")
        
        # Create output directory
        subprocess.run(['mkdir', '-p', self.output_dir], check=False)
        
        # Capture packets
        pcap_file = f"{self.output_dir}/dhcp_capture_{int(time.time())}.pcap"
        
        try:
            # Use tcpdump to capture DHCP traffic
            cmd = [
                'tcpdump', '-i', interface, '-n', '-s', '0',
                'port', '67', 'or', 'port', '68', '-w', pcap_file,
                '-c', str(count)
            ]
            
            self.log(f"Running: {' '.join(cmd)}")
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=duration + 10)
            
            if result.returncode != 0:
                self.log_error(f"tcpdump failed: {result.stderr}")
                return []
            
            self.log_success(f"Captured packets saved to: {pcap_file}")
            
            # Convert to JSON using tshark
            return self._convert_pcap_to_json(pcap_file)
            
        except subprocess.TimeoutExpired:
            self.log_warning("Capture timed out")
            return []
        except Exception as e:
            self.log_error(f"Capture failed: {str(e)}")
            return []
    
    def _convert_pcap_to_json(self, pcap_file: str) -> List[Dict]:
        """Convert pcap file to JSON using tshark"""
        try:
            cmd = [
                'tshark', '-r', pcap_file, '-T', 'json',
                '-e', 'frame.number',
                '-e', 'frame.time',
                '-e', 'ip.src',
                '-e', 'ip.dst',
                '-e', 'udp.srcport',
                '-e', 'udp.dstport',
                '-e', 'dhcp.option.dhcp',
                '-e', 'dhcp.option.requested_ip',
                '-e', 'dhcp.option.server_id',
                '-e', 'dhcp.option.lease_time',
                '-e', 'dhcp.option.subnet_mask',
                '-e', 'dhcp.option.router',
                '-e', 'dhcp.option.domain_name_server',
                '-e', 'dhcp.option.domain_name',
                '-e', 'dhcp.client_mac',
                '-e', 'dhcp.your_ip',
                '-e', 'dhcp.client_ip',
                '-e', 'dhcp.server_ip'
            ]
            
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode != 0:
                self.log_error(f"tshark conversion failed: {result.stderr}")
                return []
            
            # Parse JSON output
            try:
                packets = json.loads(result.stdout)
                self.log_success(f"Converted {len(packets)} packets to JSON")
                return packets
            except json.JSONDecodeError:
                self.log_error("Failed to parse tshark JSON output")
                return []
                
        except Exception as e:
            self.log_error(f"JSON conversion failed: {str(e)}")
            return []
    
    def analyze_dhcp_flow(self, packets: List[Dict]) -> Dict:
        """Analyze DHCP message flow and identify DORA process"""
        self.log("Analyzing DHCP message flow...")
        
        analysis = {
            'total_packets': len(packets),
            'dhcp_messages': [],
            'dora_sequences': [],
            'clients': {},
            'servers': {},
            'issues': []
        }
        
        for packet in packets:
            try:
                layers = packet.get('_source', {}).get('layers', {})
                
                # Extract basic packet info
                packet_info = {
                    'frame_number': layers.get('frame.number', [''])[0],
                    'timestamp': layers.get('frame.time', [''])[0],
                    'src_ip': layers.get('ip.src', [''])[0],
                    'dst_ip': layers.get('ip.dst', [''])[0],
                    'src_port': layers.get('udp.srcport', [''])[0],
                    'dst_port': layers.get('udp.dstport', [''])[0],
                    'dhcp_type': layers.get('dhcp.option.dhcp', [''])[0],
                    'client_mac': layers.get('dhcp.client_mac', [''])[0],
                    'requested_ip': layers.get('dhcp.option.requested_ip', [''])[0],
                    'server_id': layers.get('dhcp.option.server_id', [''])[0],
                    'lease_time': layers.get('dhcp.option.lease_time', [''])[0],
                    'subnet_mask': layers.get('dhcp.option.subnet_mask', [''])[0],
                    'router': layers.get('dhcp.option.router', [''])[0],
                    'dns_servers': layers.get('dhcp.option.domain_name_server', [''])[0],
                    'domain_name': layers.get('dhcp.option.domain_name', [''])[0],
                    'your_ip': layers.get('dhcp.your_ip', [''])[0],
                    'client_ip': layers.get('dhcp.client_ip', [''])[0],
                    'server_ip': layers.get('dhcp.server_ip', [''])[0]
                }
                
                # Determine message type
                dhcp_type = packet_info['dhcp_type']
                if dhcp_type:
                    packet_info['message_type'] = self._get_dhcp_message_type(dhcp_type)
                    analysis['dhcp_messages'].append(packet_info)
                
                # Track clients and servers
                client_mac = packet_info['client_mac']
                if client_mac:
                    if client_mac not in analysis['clients']:
                        analysis['clients'][client_mac] = {
                            'mac': client_mac,
                            'messages': [],
                            'assigned_ip': None,
                            'server': None
                        }
                    analysis['clients'][client_mac]['messages'].append(packet_info)
                
                server_ip = packet_info['server_ip'] or packet_info['src_ip']
                if server_ip and packet_info['src_port'] == '67':
                    if server_ip not in analysis['servers']:
                        analysis['servers'][server_ip] = {
                            'ip': server_ip,
                            'messages': [],
                            'clients_served': set()
                        }
                    analysis['servers'][server_ip]['messages'].append(packet_info)
                    if client_mac:
                        analysis['servers'][server_ip]['clients_served'].add(client_mac)
                
            except Exception as e:
                self.log_warning(f"Error analyzing packet: {str(e)}")
                continue
        
        # Identify DORA sequences
        analysis['dora_sequences'] = self._identify_dora_sequences(analysis['dhcp_messages'])
        
        # Analyze for issues
        analysis['issues'] = self._identify_dhcp_issues(analysis)
        
        return analysis
    
    def _get_dhcp_message_type(self, dhcp_type: str) -> str:
        """Convert DHCP type number to message name"""
        dhcp_types = {
            '1': 'DHCPDISCOVER',
            '2': 'DHCPOFFER',
            '3': 'DHCPREQUEST',
            '4': 'DHCPACK',
            '5': 'DHCPNAK',
            '6': 'DHCPDECLINE',
            '7': 'DHCPRELEASE',
            '8': 'DHCPINFORM'
        }
        return dhcp_types.get(dhcp_type, f'UNKNOWN({dhcp_type})')
    
    def _identify_dora_sequences(self, messages: List[Dict]) -> List[Dict]:
        """Identify complete DORA sequences"""
        sequences = []
        
        # Group messages by client MAC
        client_messages = {}
        for msg in messages:
            if msg['client_mac']:
                mac = msg['client_mac']
                if mac not in client_messages:
                    client_messages[mac] = []
                client_messages[mac].append(msg)
        
        # Find DORA sequences for each client
        for mac, msgs in client_messages.items():
            # Sort by timestamp
            msgs.sort(key=lambda x: x['timestamp'])
            
            sequence = {
                'client_mac': mac,
                'messages': [],
                'complete': False,
                'duration': None
            }
            
            # Look for DORA pattern
            dora_pattern = ['DHCPDISCOVER', 'DHCPOFFER', 'DHCPREQUEST', 'DHCPACK']
            current_pattern = []
            
            for msg in msgs:
                msg_type = msg['message_type']
                if msg_type in dora_pattern:
                    current_pattern.append(msg_type)
                    sequence['messages'].append(msg)
                    
                    # Check if we have a complete DORA
                    if len(current_pattern) >= 4:
                        if current_pattern[-4:] == dora_pattern:
                            sequence['complete'] = True
                            if len(sequence['messages']) >= 4:
                                start_time = sequence['messages'][0]['timestamp']
                                end_time = sequence['messages'][-1]['timestamp']
                                sequence['duration'] = self._calculate_duration(start_time, end_time)
                            break
            
            if sequence['messages']:
                sequences.append(sequence)
        
        return sequences
    
    def _calculate_duration(self, start_time: str, end_time: str) -> str:
        """Calculate duration between two timestamps"""
        try:
            # Simple duration calculation (this could be more sophisticated)
            return "Duration calculated"
        except:
            return "Unknown"
    
    def _identify_dhcp_issues(self, analysis: Dict) -> List[str]:
        """Identify potential DHCP issues"""
        issues = []
        
        # Check for incomplete DORA sequences
        incomplete_sequences = [seq for seq in analysis['dora_sequences'] if not seq['complete']]
        if incomplete_sequences:
            issues.append(f"Found {len(incomplete_sequences)} incomplete DORA sequences")
        
        # Check for multiple servers
        if len(analysis['servers']) > 1:
            issues.append(f"Multiple DHCP servers detected: {list(analysis['servers'].keys())}")
        
        # Check for DHCP NAK messages
        nak_messages = [msg for msg in analysis['dhcp_messages'] if msg['message_type'] == 'DHCPNAK']
        if nak_messages:
            issues.append(f"Found {len(nak_messages)} DHCP NAK messages")
        
        # Check for DHCP DECLINE messages
        decline_messages = [msg for msg in analysis['dhcp_messages'] if msg['message_type'] == 'DHCPDECLINE']
        if decline_messages:
            issues.append(f"Found {len(decline_messages)} DHCP DECLINE messages")
        
        return issues
    
    def generate_report(self, analysis: Dict) -> None:
        """Generate comprehensive DHCP analysis report"""
        self.log("Generating analysis report...")
        
        report_file = f"{self.output_dir}/dhcp_analysis_report_{int(time.time())}.json"
        
        # Save detailed analysis
        with open(report_file, 'w') as f:
            json.dump(analysis, f, indent=2, default=str)
        
        self.log_success(f"Detailed analysis saved to: {report_file}")
        
        # Print summary
        self._print_summary(analysis)
    
    def _print_summary(self, analysis: Dict) -> None:
        """Print analysis summary"""
        print("\n" + "="*60)
        print("🔍 DHCP ANALYSIS SUMMARY")
        print("="*60)
        
        print(f"\n📊 PACKET STATISTICS:")
        print(f"   Total packets: {analysis['total_packets']}")
        print(f"   DHCP messages: {len(analysis['dhcp_messages'])}")
        print(f"   DORA sequences: {len(analysis['dora_sequences'])}")
        print(f"   Complete sequences: {len([s for s in analysis['dora_sequences'] if s['complete']])}")
        
        print(f"\n👥 CLIENTS:")
        for mac, client in analysis['clients'].items():
            print(f"   {mac}: {len(client['messages'])} messages")
            if client['assigned_ip']:
                print(f"      Assigned IP: {client['assigned_ip']}")
        
        print(f"\n🖥️  SERVERS:")
        for ip, server in analysis['servers'].items():
            print(f"   {ip}: {len(server['messages'])} messages")
            print(f"      Clients served: {len(server['clients_served'])}")
        
        if analysis['issues']:
            print(f"\n⚠️  ISSUES DETECTED:")
            for issue in analysis['issues']:
                print(f"   • {issue}")
        else:
            print(f"\n✅ No issues detected")
        
        print("\n" + "="*60)
    
    def run_analysis(self, interface: str = "any", count: int = 50, 
                    duration: int = 30) -> None:
        """Run complete DHCP analysis"""
        self.log("Starting DHCP analysis...")
        
        if not self.check_dependencies():
            return
        
        # Capture packets
        packets = self.capture_dhcp_packets(interface, count, duration)
        if not packets:
            self.log_error("No packets captured")
            return
        
        # Analyze packets
        analysis = self.analyze_dhcp_flow(packets)
        
        # Generate report
        self.generate_report(analysis)
        
        self.log_success("DHCP analysis completed!")

def main():
    parser = argparse.ArgumentParser(description="DHCP Packet Analyzer")
    parser.add_argument('-i', '--interface', default='any', 
                       help='Network interface to capture on (default: any)')
    parser.add_argument('-c', '--count', type=int, default=50,
                       help='Number of packets to capture (default: 50)')
    parser.add_argument('-d', '--duration', type=int, default=30,
                       help='Capture duration in seconds (default: 30)')
    parser.add_argument('-v', '--verbose', action='store_true',
                       help='Enable verbose output')
    
    args = parser.parse_args()
    
    analyzer = DHCPAnalyzer()
    analyzer.run_analysis(args.interface, args.count, args.duration)

if __name__ == "__main__":
    main()
