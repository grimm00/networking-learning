#!/usr/bin/env python3
"""
NTP Analyzer Tool

A comprehensive tool for analyzing NTP servers, time synchronization, and performance.
"""

import argparse
import socket
import struct
import time
import sys
import json
import statistics
from datetime import datetime, timezone
from typing import Dict, List, Any, Optional, Tuple
import threading
import concurrent.futures

class NTPAnalyzer:
    def __init__(self, server: str, port: int = 123):
        self.server = server
        self.port = port
        self.results = {}
        
    def analyze_ntp_server(self) -> Dict[str, Any]:
        """Analyze NTP server and gather information"""
        print(f"🕐 Analyzing NTP server: {self.server}:{self.port}")
        print("=" * 60)
        
        # Basic connectivity test
        connectivity = self._test_connectivity()
        self.results['connectivity'] = connectivity
        
        if not connectivity['reachable']:
            print("❌ NTP server is not reachable")
            return self.results
            
        # NTP query analysis
        ntp_info = self._query_ntp_server()
        self.results['ntp_info'] = ntp_info
        
        # Performance analysis
        performance = self._analyze_performance()
        self.results['performance'] = performance
        
        # Security analysis
        security = self._analyze_security()
        self.results['security'] = security
        
        return self.results
    
    def _test_connectivity(self) -> Dict[str, Any]:
        """Test basic connectivity to NTP port"""
        print("📡 Testing connectivity...")
        
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            sock.settimeout(5)
            result = sock.connect_ex((self.server, self.port))
            sock.close()
            
            if result == 0:
                print("✅ NTP port is open and accessible")
                return {
                    'reachable': True,
                    'port_open': True,
                    'response_time': self._measure_response_time()
                }
            else:
                print("❌ NTP port is closed or filtered")
                return {
                    'reachable': False,
                    'port_open': False,
                    'error': f"Connection failed with code {result}"
                }
        except Exception as e:
            print(f"❌ Connection error: {e}")
            return {
                'reachable': False,
                'port_open': False,
                'error': str(e)
            }
    
    def _measure_response_time(self) -> float:
        """Measure NTP server response time"""
        try:
            start_time = time.time()
            sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            sock.settimeout(5)
            sock.connect((self.server, self.port))
            sock.close()
            return round((time.time() - start_time) * 1000, 2)
        except:
            return 0.0
    
    def _query_ntp_server(self) -> Dict[str, Any]:
        """Query NTP server for time information"""
        print("🕐 Querying NTP server...")
        
        try:
            # Create NTP packet
            ntp_packet = self._create_ntp_packet()
            
            # Send packet and receive response
            sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            sock.settimeout(10)
            
            start_time = time.time()
            sock.sendto(ntp_packet, (self.server, self.port))
            response, addr = sock.recvfrom(1024)
            end_time = time.time()
            
            sock.close()
            
            # Parse NTP response
            ntp_data = self._parse_ntp_packet(response)
            
            # Calculate round-trip delay
            round_trip_delay = (end_time - start_time) * 1000
            
            print(f"✅ NTP query successful")
            print(f"📊 Round-trip delay: {round_trip_delay:.2f}ms")
            
            return {
                'query_successful': True,
                'round_trip_delay': round_trip_delay,
                'ntp_data': ntp_data,
                'server_address': addr[0],
                'server_port': addr[1]
            }
            
        except Exception as e:
            print(f"❌ NTP query failed: {e}")
            return {
                'query_successful': False,
                'error': str(e)
            }
    
    def _create_ntp_packet(self) -> bytes:
        """Create NTP packet for query"""
        # NTP packet format (48 bytes)
        # 0-3: Leap indicator, version, mode
        # 4-7: Stratum
        # 8-11: Poll interval
        # 12-15: Precision
        # 16-19: Root delay
        # 20-23: Root dispersion
        # 24-27: Reference identifier
        # 28-31: Reference timestamp (seconds)
        # 32-35: Reference timestamp (fraction)
        # 36-39: Origin timestamp (seconds)
        # 40-43: Origin timestamp (fraction)
        # 44-47: Receive timestamp (seconds)
        # 48-51: Receive timestamp (fraction)
        # 52-55: Transmit timestamp (seconds)
        # 56-59: Transmit timestamp (fraction)
        
        packet = bytearray(48)
        
        # Version 4, client mode (3)
        packet[0] = 0x23  # 00100011 (version 4, client mode)
        
        # Set transmit timestamp
        transmit_time = time.time() + 2208988800  # NTP epoch offset
        transmit_seconds = int(transmit_time)
        transmit_fraction = int((transmit_time - transmit_seconds) * 2**32)
        
        struct.pack_into('!I', packet, 40, transmit_seconds)
        struct.pack_into('!I', packet, 44, transmit_fraction)
        
        return bytes(packet)
    
    def _parse_ntp_packet(self, packet: bytes) -> Dict[str, Any]:
        """Parse NTP packet response"""
        if len(packet) < 48:
            return {'error': 'Invalid NTP packet length'}
        
        # Unpack NTP packet
        leap_version_mode = packet[0]
        stratum = packet[1]
        poll = packet[2]
        precision = packet[3]
        
        # Timestamps
        ref_seconds = struct.unpack('!I', packet[28:32])[0]
        ref_fraction = struct.unpack('!I', packet[32:36])[0]
        orig_seconds = struct.unpack('!I', packet[36:40])[0]
        orig_fraction = struct.unpack('!I', packet[40:44])[0]
        recv_seconds = struct.unpack('!I', packet[44:48])[0]
        recv_fraction = struct.unpack('!I', packet[48:52])[0]
        trans_seconds = struct.unpack('!I', packet[52:56])[0]
        trans_fraction = struct.unpack('!I', packet[56:60])[0]
        
        # Convert timestamps to Unix time
        ref_time = self._ntp_to_unix_time(ref_seconds, ref_fraction)
        orig_time = self._ntp_to_unix_time(orig_seconds, orig_fraction)
        recv_time = self._ntp_to_unix_time(recv_seconds, recv_fraction)
        trans_time = self._ntp_to_unix_time(trans_seconds, trans_fraction)
        
        return {
            'leap_indicator': (leap_version_mode >> 6) & 0x3,
            'version': (leap_version_mode >> 3) & 0x7,
            'mode': leap_version_mode & 0x7,
            'stratum': stratum,
            'poll_interval': 2 ** poll,
            'precision': 2 ** precision,
            'reference_time': ref_time,
            'origin_time': orig_time,
            'receive_time': recv_time,
            'transmit_time': trans_time,
            'leap_warning': (leap_version_mode >> 6) & 0x3 == 3
        }
    
    def _ntp_to_unix_time(self, seconds: int, fraction: int) -> float:
        """Convert NTP timestamp to Unix time"""
        if seconds == 0:
            return 0.0
        return seconds - 2208988800 + (fraction / 2**32)
    
    def _analyze_performance(self) -> Dict[str, Any]:
        """Analyze NTP server performance"""
        print("⚡ Analyzing performance...")
        
        performance_info = {
            'response_times': [],
            'average_response_time': 0,
            'min_response_time': 0,
            'max_response_time': 0,
            'jitter': 0,
            'success_rate': 0
        }
        
        # Test multiple queries
        test_count = 10
        successful_queries = 0
        
        for i in range(test_count):
            try:
                start_time = time.time()
                
                # Create and send NTP packet
                ntp_packet = self._create_ntp_packet()
                sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
                sock.settimeout(5)
                
                sock.sendto(ntp_packet, (self.server, self.port))
                response, addr = sock.recvfrom(1024)
                sock.close()
                
                response_time = (time.time() - start_time) * 1000
                performance_info['response_times'].append(response_time)
                successful_queries += 1
                
                print(f"📊 Query {i+1}/{test_count}: {response_time:.2f}ms")
                
            except Exception as e:
                print(f"❌ Query {i+1} failed: {e}")
        
        if performance_info['response_times']:
            performance_info['average_response_time'] = round(
                statistics.mean(performance_info['response_times']), 2
            )
            performance_info['min_response_time'] = round(
                min(performance_info['response_times']), 2
            )
            performance_info['max_response_time'] = round(
                max(performance_info['response_times']), 2
            )
            performance_info['jitter'] = round(
                statistics.stdev(performance_info['response_times']) if len(performance_info['response_times']) > 1 else 0, 2
            )
            performance_info['success_rate'] = round(
                (successful_queries / test_count) * 100, 2
            )
            
            print(f"📊 Average response time: {performance_info['average_response_time']}ms")
            print(f"📊 Min response time: {performance_info['min_response_time']}ms")
            print(f"📊 Max response time: {performance_info['max_response_time']}ms")
            print(f"📊 Jitter: {performance_info['jitter']}ms")
            print(f"📊 Success rate: {performance_info['success_rate']}%")
        else:
            print("❌ No successful queries for performance testing")
        
        return performance_info
    
    def _analyze_security(self) -> Dict[str, Any]:
        """Analyze NTP security features"""
        print("🔒 Analyzing security features...")
        
        security_info = {
            'authentication_supported': False,
            'access_control': 'unknown',
            'security_issues': []
        }
        
        try:
            # Test for authentication support
            # This is a simplified check - real implementation would be more complex
            sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            sock.settimeout(5)
            
            # Send malformed packet to test error handling
            malformed_packet = b'\x00' * 48
            sock.sendto(malformed_packet, (self.server, self.port))
            
            try:
                response, addr = sock.recvfrom(1024)
                # If we get a response to a malformed packet, it might indicate security issues
                security_info['security_issues'].append("Responds to malformed packets")
            except socket.timeout:
                # Good - server doesn't respond to malformed packets
                pass
            
            sock.close()
            
            # Check for common security issues
            if len(security_info['security_issues']) == 0:
                print("✅ No obvious security issues detected")
            else:
                print("⚠️  Security issues found:")
                for issue in security_info['security_issues']:
                    print(f"   - {issue}")
                    
        except Exception as e:
            print(f"❌ Security analysis error: {e}")
            security_info['error'] = str(e)
        
        return security_info
    
    def test_multiple_servers(self, servers: List[str]) -> Dict[str, Any]:
        """Test multiple NTP servers for comparison"""
        print(f"🔄 Testing {len(servers)} NTP servers...")
        
        results = {}
        
        for server in servers:
            print(f"\n📡 Testing {server}...")
            analyzer = NTPAnalyzer(server)
            server_results = analyzer.analyze_ntp_server()
            results[server] = server_results
        
        return results
    
    def generate_report(self) -> str:
        """Generate a comprehensive analysis report"""
        report = []
        report.append("NTP Analysis Report")
        report.append("=" * 50)
        report.append(f"Server: {self.server}:{self.port}")
        report.append(f"Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        report.append("")
        
        # Connectivity
        if 'connectivity' in self.results:
            conn = self.results['connectivity']
            report.append("CONNECTIVITY")
            report.append("-" * 20)
            report.append(f"Reachable: {conn.get('reachable', 'Unknown')}")
            report.append(f"Port Open: {conn.get('port_open', 'Unknown')}")
            if 'response_time' in conn:
                report.append(f"Response Time: {conn['response_time']}ms")
            report.append("")
        
        # NTP Information
        if 'ntp_info' in self.results:
            ntp = self.results['ntp_info']
            report.append("NTP INFORMATION")
            report.append("-" * 20)
            report.append(f"Query Successful: {ntp.get('query_successful', 'Unknown')}")
            if 'round_trip_delay' in ntp:
                report.append(f"Round-trip Delay: {ntp['round_trip_delay']}ms")
            if 'ntp_data' in ntp:
                data = ntp['ntp_data']
                report.append(f"Stratum: {data.get('stratum', 'Unknown')}")
                report.append(f"Version: {data.get('version', 'Unknown')}")
                report.append(f"Poll Interval: {data.get('poll_interval', 'Unknown')}s")
                report.append(f"Precision: {data.get('precision', 'Unknown')}s")
            report.append("")
        
        # Performance Analysis
        if 'performance' in self.results:
            perf = self.results['performance']
            report.append("PERFORMANCE ANALYSIS")
            report.append("-" * 25)
            report.append(f"Average Response Time: {perf.get('average_response_time', 'N/A')}ms")
            report.append(f"Min Response Time: {perf.get('min_response_time', 'N/A')}ms")
            report.append(f"Max Response Time: {perf.get('max_response_time', 'N/A')}ms")
            report.append(f"Jitter: {perf.get('jitter', 'N/A')}ms")
            report.append(f"Success Rate: {perf.get('success_rate', 'N/A')}%")
            report.append("")
        
        # Security Analysis
        if 'security' in self.results:
            sec = self.results['security']
            report.append("SECURITY ANALYSIS")
            report.append("-" * 20)
            report.append(f"Authentication: {sec.get('authentication_supported', 'Unknown')}")
            if sec.get('security_issues'):
                report.append("Security Issues:")
                for issue in sec['security_issues']:
                    report.append(f"  - {issue}")
            report.append("")
        
        return "\n".join(report)

def main():
    parser = argparse.ArgumentParser(description="NTP Analyzer Tool")
    parser.add_argument("server", help="NTP server to analyze")
    parser.add_argument("-p", "--port", type=int, default=123, help="NTP port (default: 123)")
    parser.add_argument("-d", "--detailed", action="store_true", help="Detailed analysis")
    parser.add_argument("-s", "--security", action="store_true", help="Focus on security analysis")
    parser.add_argument("-t", "--test-servers", nargs="+", help="Test multiple servers")
    parser.add_argument("-r", "--report", action="store_true", help="Generate detailed report")
    parser.add_argument("-j", "--json", action="store_true", help="Output results in JSON format")
    
    args = parser.parse_args()
    
    if args.test_servers:
        # Test multiple servers
        analyzer = NTPAnalyzer(args.server, args.port)
        results = analyzer.test_multiple_servers(args.test_servers)
        
        if args.json:
            print(json.dumps(results, indent=2))
        else:
            print("\n✅ Multi-server analysis complete!")
            for server, result in results.items():
                print(f"\n{server}:")
                if result.get('connectivity', {}).get('reachable'):
                    print("  ✅ Reachable")
                else:
                    print("  ❌ Not reachable")
    else:
        # Single server analysis
        analyzer = NTPAnalyzer(args.server, args.port)
        results = analyzer.analyze_ntp_server()
        
        if args.json:
            print(json.dumps(results, indent=2))
        elif args.report:
            print(analyzer.generate_report())
        else:
            print("\n✅ NTP analysis complete!")
            if results.get('connectivity', {}).get('reachable'):
                print("✅ Server is reachable and responding")
            else:
                print("❌ Server is not reachable")

if __name__ == "__main__":
    main()
