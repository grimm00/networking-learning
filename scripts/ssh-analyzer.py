#!/usr/bin/env python3
"""
SSH Analyzer Tool

A comprehensive tool for analyzing SSH connections, security, and performance.
"""

import argparse
import socket
import subprocess
import sys
import time
import json
import os
import re
from datetime import datetime
from typing import Dict, List, Any, Optional, Tuple
import paramiko
import threading
import concurrent.futures

class SSHAnalyzer:
    def __init__(self, host: str, port: int = 22, username: str = None, key_file: str = None):
        self.host = host
        self.port = port
        self.username = username
        self.key_file = key_file
        self.results = {}
        
    def analyze_connection(self) -> Dict[str, Any]:
        """Analyze SSH connection and gather information"""
        print(f"🔍 Analyzing SSH connection to {self.host}:{self.port}")
        print("=" * 60)
        
        # Basic connectivity test
        connectivity = self._test_connectivity()
        self.results['connectivity'] = connectivity
        
        if not connectivity['reachable']:
            print("❌ Host is not reachable")
            return self.results
            
        # SSH service detection
        service_info = self._detect_ssh_service()
        self.results['service'] = service_info
        
        # Security analysis
        security = self._analyze_security()
        self.results['security'] = security
        
        # Performance analysis
        performance = self._analyze_performance()
        self.results['performance'] = performance
        
        # Key analysis (if key file provided)
        if self.key_file:
            key_info = self._analyze_key()
            self.results['key'] = key_info
            
        return self.results
    
    def _test_connectivity(self) -> Dict[str, Any]:
        """Test basic connectivity to SSH port"""
        print("📡 Testing connectivity...")
        
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(5)
            result = sock.connect_ex((self.host, self.port))
            sock.close()
            
            if result == 0:
                print("✅ Port is open and accessible")
                return {
                    'reachable': True,
                    'port_open': True,
                    'response_time': self._measure_response_time()
                }
            else:
                print("❌ Port is closed or filtered")
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
        """Measure SSH service response time"""
        try:
            start_time = time.time()
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(5)
            sock.connect((self.host, self.port))
            sock.close()
            return round((time.time() - start_time) * 1000, 2)
        except:
            return 0.0
    
    def _detect_ssh_service(self) -> Dict[str, Any]:
        """Detect SSH service and version"""
        print("🔍 Detecting SSH service...")
        
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(5)
            sock.connect((self.host, self.port))
            
            # Read SSH banner
            banner = sock.recv(1024).decode('utf-8', errors='ignore').strip()
            sock.close()
            
            print(f"📋 SSH Banner: {banner}")
            
            # Parse version information
            version_match = re.search(r'SSH-(\d+\.\d+)-(.+)', banner)
            if version_match:
                version = version_match.group(1)
                software = version_match.group(2)
                
                return {
                    'banner': banner,
                    'version': version,
                    'software': software,
                    'is_ssh1': version.startswith('1.'),
                    'is_ssh2': version.startswith('2.')
                }
            else:
                return {
                    'banner': banner,
                    'version': 'unknown',
                    'software': 'unknown',
                    'is_ssh1': False,
                    'is_ssh2': False
                }
                
        except Exception as e:
            print(f"❌ Error detecting SSH service: {e}")
            return {
                'banner': None,
                'version': 'unknown',
                'software': 'unknown',
                'error': str(e)
            }
    
    def _analyze_security(self) -> Dict[str, Any]:
        """Analyze SSH security features"""
        print("🔒 Analyzing security features...")
        
        security_info = {
            'supported_ciphers': [],
            'supported_macs': [],
            'supported_kex': [],
            'supported_keys': [],
            'security_issues': []
        }
        
        try:
            # Get supported algorithms
            result = subprocess.run(['ssh', '-Q', 'cipher'], capture_output=True, text=True, timeout=10)
            if result.returncode == 0:
                security_info['supported_ciphers'] = result.stdout.strip().split('\n')
            
            result = subprocess.run(['ssh', '-Q', 'mac'], capture_output=True, text=True, timeout=10)
            if result.returncode == 0:
                security_info['supported_macs'] = result.stdout.strip().split('\n')
            
            result = subprocess.run(['ssh', '-Q', 'kex'], capture_output=True, text=True, timeout=10)
            if result.returncode == 0:
                security_info['supported_kex'] = result.stdout.strip().split('\n')
            
            result = subprocess.run(['ssh', '-Q', 'key'], capture_output=True, text=True, timeout=10)
            if result.returncode == 0:
                security_info['supported_keys'] = result.stdout.strip().split('\n')
            
            # Check for weak algorithms
            weak_ciphers = ['des', '3des', 'arcfour', 'blowfish']
            weak_macs = ['md5', 'sha1']
            
            for cipher in security_info['supported_ciphers']:
                if any(weak in cipher.lower() for weak in weak_ciphers):
                    security_info['security_issues'].append(f"Weak cipher: {cipher}")
            
            for mac in security_info['supported_macs']:
                if any(weak in mac.lower() for weak in weak_macs):
                    security_info['security_issues'].append(f"Weak MAC: {mac}")
            
            print(f"✅ Found {len(security_info['supported_ciphers'])} ciphers")
            print(f"✅ Found {len(security_info['supported_macs'])} MACs")
            print(f"✅ Found {len(security_info['supported_kex'])} key exchange algorithms")
            print(f"✅ Found {len(security_info['supported_keys'])} key types")
            
            if security_info['security_issues']:
                print("⚠️  Security issues found:")
                for issue in security_info['security_issues']:
                    print(f"   - {issue}")
            else:
                print("✅ No obvious security issues detected")
                
        except Exception as e:
            print(f"❌ Error analyzing security: {e}")
            security_info['error'] = str(e)
        
        return security_info
    
    def _analyze_performance(self) -> Dict[str, Any]:
        """Analyze SSH connection performance"""
        print("⚡ Analyzing performance...")
        
        performance_info = {
            'connection_times': [],
            'average_connection_time': 0,
            'min_connection_time': 0,
            'max_connection_time': 0
        }
        
        # Test multiple connections
        test_count = 5
        for i in range(test_count):
            try:
                start_time = time.time()
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                sock.settimeout(5)
                sock.connect((self.host, self.port))
                sock.close()
                connection_time = (time.time() - start_time) * 1000
                performance_info['connection_times'].append(connection_time)
            except Exception as e:
                print(f"❌ Connection test {i+1} failed: {e}")
        
        if performance_info['connection_times']:
            performance_info['average_connection_time'] = round(
                sum(performance_info['connection_times']) / len(performance_info['connection_times']), 2
            )
            performance_info['min_connection_time'] = round(min(performance_info['connection_times']), 2)
            performance_info['max_connection_time'] = round(max(performance_info['connection_times']), 2)
            
            print(f"📊 Average connection time: {performance_info['average_connection_time']}ms")
            print(f"📊 Min connection time: {performance_info['min_connection_time']}ms")
            print(f"📊 Max connection time: {performance_info['max_connection_time']}ms")
        else:
            print("❌ No successful connections for performance testing")
        
        return performance_info
    
    def _analyze_key(self) -> Dict[str, Any]:
        """Analyze SSH key file"""
        print(f"🔑 Analyzing SSH key: {self.key_file}")
        
        if not os.path.exists(self.key_file):
            return {'error': 'Key file not found'}
        
        key_info = {
            'file_exists': True,
            'file_size': os.path.getsize(self.key_file),
            'permissions': oct(os.stat(self.key_file).st_mode)[-3:],
            'key_type': 'unknown',
            'key_size': 0,
            'fingerprint': None,
            'security_issues': []
        }
        
        try:
            # Get key information using ssh-keygen
            result = subprocess.run(['ssh-keygen', '-l', '-f', self.key_file], 
                                 capture_output=True, text=True, timeout=10)
            if result.returncode == 0:
                # Parse key information
                key_line = result.stdout.strip()
                parts = key_line.split()
                if len(parts) >= 4:
                    key_info['key_size'] = int(parts[0])
                    key_info['fingerprint'] = parts[1]
                    key_info['key_type'] = parts[3].split('@')[0] if '@' in parts[3] else parts[3]
                
                print(f"✅ Key type: {key_info['key_type']}")
                print(f"✅ Key size: {key_info['key_size']} bits")
                print(f"✅ Fingerprint: {key_info['fingerprint']}")
                
                # Check for security issues
                if key_info['key_size'] < 2048 and key_info['key_type'] == 'RSA':
                    key_info['security_issues'].append("RSA key size is less than 2048 bits")
                
                if key_info['permissions'] != '600':
                    key_info['security_issues'].append(f"Key file permissions should be 600, got {key_info['permissions']}")
                
                if key_info['security_issues']:
                    print("⚠️  Security issues found:")
                    for issue in key_info['security_issues']:
                        print(f"   - {issue}")
                else:
                    print("✅ No security issues with key file")
            else:
                print(f"❌ Error analyzing key: {result.stderr}")
                key_info['error'] = result.stderr
                
        except Exception as e:
            print(f"❌ Error analyzing key: {e}")
            key_info['error'] = str(e)
        
        return key_info
    
    def test_authentication(self, password: str = None) -> Dict[str, Any]:
        """Test SSH authentication methods"""
        print("🔐 Testing authentication methods...")
        
        auth_results = {
            'password_auth': False,
            'key_auth': False,
            'errors': []
        }
        
        if not self.username:
            print("❌ Username required for authentication testing")
            return auth_results
        
        try:
            # Test password authentication
            if password:
                print("🔑 Testing password authentication...")
                try:
                    client = paramiko.SSHClient()
                    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
                    client.connect(self.host, self.port, self.username, password, timeout=10)
                    client.close()
                    auth_results['password_auth'] = True
                    print("✅ Password authentication successful")
                except Exception as e:
                    print(f"❌ Password authentication failed: {e}")
                    auth_results['errors'].append(f"Password auth: {str(e)}")
            
            # Test key authentication
            if self.key_file and os.path.exists(self.key_file):
                print("🔑 Testing key authentication...")
                try:
                    client = paramiko.SSHClient()
                    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
                    key = paramiko.RSAKey.from_private_key_file(self.key_file)
                    client.connect(self.host, self.port, self.username, pkey=key, timeout=10)
                    client.close()
                    auth_results['key_auth'] = True
                    print("✅ Key authentication successful")
                except Exception as e:
                    print(f"❌ Key authentication failed: {e}")
                    auth_results['errors'].append(f"Key auth: {str(e)}")
        
        except Exception as e:
            print(f"❌ Authentication testing error: {e}")
            auth_results['errors'].append(str(e))
        
        return auth_results
    
    def generate_report(self) -> str:
        """Generate a comprehensive analysis report"""
        report = []
        report.append("SSH Analysis Report")
        report.append("=" * 50)
        report.append(f"Target: {self.host}:{self.port}")
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
        
        # Service Information
        if 'service' in self.results:
            service = self.results['service']
            report.append("SERVICE INFORMATION")
            report.append("-" * 25)
            report.append(f"Banner: {service.get('banner', 'Unknown')}")
            report.append(f"Version: {service.get('version', 'Unknown')}")
            report.append(f"Software: {service.get('software', 'Unknown')}")
            report.append(f"SSH-1: {service.get('is_ssh1', 'Unknown')}")
            report.append(f"SSH-2: {service.get('is_ssh2', 'Unknown')}")
            report.append("")
        
        # Security Analysis
        if 'security' in self.results:
            security = self.results['security']
            report.append("SECURITY ANALYSIS")
            report.append("-" * 20)
            report.append(f"Supported Ciphers: {len(security.get('supported_ciphers', []))}")
            report.append(f"Supported MACs: {len(security.get('supported_macs', []))}")
            report.append(f"Supported KEX: {len(security.get('supported_kex', []))}")
            report.append(f"Supported Keys: {len(security.get('supported_keys', []))}")
            
            if security.get('security_issues'):
                report.append("Security Issues:")
                for issue in security['security_issues']:
                    report.append(f"  - {issue}")
            report.append("")
        
        # Performance Analysis
        if 'performance' in self.results:
            perf = self.results['performance']
            report.append("PERFORMANCE ANALYSIS")
            report.append("-" * 22)
            report.append(f"Average Connection Time: {perf.get('average_connection_time', 'N/A')}ms")
            report.append(f"Min Connection Time: {perf.get('min_connection_time', 'N/A')}ms")
            report.append(f"Max Connection Time: {perf.get('max_connection_time', 'N/A')}ms")
            report.append("")
        
        # Key Analysis
        if 'key' in self.results:
            key = self.results['key']
            report.append("KEY ANALYSIS")
            report.append("-" * 15)
            report.append(f"Key Type: {key.get('key_type', 'Unknown')}")
            report.append(f"Key Size: {key.get('key_size', 'Unknown')} bits")
            report.append(f"Fingerprint: {key.get('fingerprint', 'Unknown')}")
            report.append(f"Permissions: {key.get('permissions', 'Unknown')}")
            
            if key.get('security_issues'):
                report.append("Key Security Issues:")
                for issue in key['security_issues']:
                    report.append(f"  - {issue}")
            report.append("")
        
        return "\n".join(report)

def main():
    parser = argparse.ArgumentParser(description="SSH Analyzer Tool")
    parser.add_argument("host", help="SSH host to analyze")
    parser.add_argument("-p", "--port", type=int, default=22, help="SSH port (default: 22)")
    parser.add_argument("-u", "--username", help="Username for authentication testing")
    parser.add_argument("-k", "--key", help="SSH private key file")
    parser.add_argument("-s", "--security", action="store_true", help="Focus on security analysis")
    parser.add_argument("-t", "--test-auth", action="store_true", help="Test authentication methods")
    parser.add_argument("--password", help="Password for authentication testing")
    parser.add_argument("-r", "--report", action="store_true", help="Generate detailed report")
    parser.add_argument("-j", "--json", action="store_true", help="Output results in JSON format")
    
    args = parser.parse_args()
    
    # Parse host:port format
    if ':' in args.host and not args.port:
        host, port = args.host.split(':', 1)
        args.host = host
        args.port = int(port)
    
    analyzer = SSHAnalyzer(args.host, args.port, args.username, args.key)
    
    # Perform analysis
    results = analyzer.analyze_connection()
    
    # Test authentication if requested
    if args.test_auth:
        auth_results = analyzer.test_authentication(args.password)
        results['authentication'] = auth_results
    
    # Output results
    if args.json:
        print(json.dumps(results, indent=2))
    elif args.report:
        print(analyzer.generate_report())
    else:
        print("\n✅ SSH analysis complete!")
        if args.security and 'security' in results:
            print("\n🔒 Security Summary:")
            security = results['security']
            print(f"   Ciphers: {len(security.get('supported_ciphers', []))}")
            print(f"   MACs: {len(security.get('supported_macs', []))}")
            print(f"   Issues: {len(security.get('security_issues', []))}")

if __name__ == "__main__":
    main()
