#!/usr/bin/env python3
"""
Netcat Analyzer Tool
Comprehensive network connectivity and communication utility using netcat
"""

import subprocess
import json
import os
import sys
import argparse
import time
import threading
from datetime import datetime
from typing import List, Dict, Any, Optional
import socket


class NetcatAnalyzer:
    def __init__(self, target: str, port: int = None, output_dir: str = "output", verbose: bool = False):
        self.target = target
        self.port = port
        self.output_dir = output_dir
        self.verbose = verbose
        self.results = {
            'target': target,
            'port': port,
            'scan_time': datetime.now().isoformat(),
            'connectivity_tests': [],
            'port_scan_results': [],
            'service_tests': [],
            'file_transfer_tests': [],
            'summary': {}
        }
        
        # Create output directory
        os.makedirs(output_dir, exist_ok=True)

    def check_netcat_availability(self) -> bool:
        """Check if netcat is available on the system"""
        try:
            result = subprocess.run(['nc', '-h'], 
                                  capture_output=True, text=True, timeout=10)
            return result.returncode == 0
        except (subprocess.TimeoutExpired, FileNotFoundError):
            try:
                result = subprocess.run(['netcat', '-h'], 
                                      capture_output=True, text=True, timeout=10)
                return result.returncode == 0
            except (subprocess.TimeoutExpired, FileNotFoundError):
                return False

    def test_connectivity(self, port: int, protocol: str = "tcp") -> Dict[str, Any]:
        """Test basic connectivity to a port"""
        print(f"🔍 Testing {protocol.upper()} connectivity to {self.target}:{port}")
        
        cmd = ['nc', '-v', '-z', '-w', '5']  # Add 5-second timeout
        if protocol.lower() == "udp":
            cmd.append('-u')
        
        cmd.extend([self.target, str(port)])
        
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=8)
            
            connectivity_info = {
                'port': port,
                'protocol': protocol,
                'success': result.returncode == 0,
                'stdout': result.stdout,
                'stderr': result.stderr,
                'raw_output': result.stdout + result.stderr
            }
            
            if result.returncode == 0:
                print(f"  ✅ {protocol.upper()} port {port} is open")
            else:
                print(f"  ❌ {protocol.upper()} port {port} is closed or filtered")
            
            return connectivity_info
            
        except subprocess.TimeoutExpired:
            print(f"  ⏰ Connection to {protocol.upper()} port {port} timed out")
            return {
                'port': port,
                'protocol': protocol,
                'success': False,
                'error': 'timeout'
            }
        except Exception as e:
            print(f"  ❌ Error testing {protocol.upper()} port {port}: {e}")
            return {
                'port': port,
                'protocol': protocol,
                'success': False,
                'error': str(e)
            }

    def scan_ports(self, ports: List[int], protocol: str = "tcp") -> List[Dict[str, Any]]:
        """Scan multiple ports using netcat"""
        print(f"🔍 Scanning {len(ports)} {protocol.upper()} ports on {self.target}")
        
        results = []
        for port in ports:
            result = self.test_connectivity(port, protocol)
            results.append(result)
            time.sleep(0.1)  # Small delay between scans
        
        open_ports = [r for r in results if r.get('success', False)]
        print(f"  ✅ Found {len(open_ports)} open {protocol.upper()} ports")
        
        return results

    def test_http_service(self, port: int = 80) -> Dict[str, Any]:
        """Test HTTP service using netcat"""
        print(f"🔍 Testing HTTP service on {self.target}:{port}")
        
        http_request = f"GET / HTTP/1.1\r\nHost: {self.target}\r\n\r\n"
        
        try:
            # Use netcat to send HTTP request
            process = subprocess.Popen(
                ['nc', self.target, str(port)],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            
            stdout, stderr = process.communicate(input=http_request, timeout=10)
            
            http_info = {
                'port': port,
                'protocol': 'http',
                'request': http_request,
                'response': stdout,
                'error': stderr,
                'success': 'HTTP' in stdout or '200' in stdout or '404' in stdout
            }
            
            if http_info['success']:
                print(f"  ✅ HTTP service responded on port {port}")
                if self.verbose:
                    print(f"    Response: {stdout[:200]}...")
            else:
                print(f"  ❌ No HTTP response on port {port}")
            
            return http_info
            
        except subprocess.TimeoutExpired:
            print(f"  ⏰ HTTP test on port {port} timed out")
            return {
                'port': port,
                'protocol': 'http',
                'success': False,
                'error': 'timeout'
            }
        except Exception as e:
            print(f"  ❌ Error testing HTTP on port {port}: {e}")
            return {
                'port': port,
                'protocol': 'http',
                'success': False,
                'error': str(e)
            }

    def test_smtp_service(self, port: int = 25) -> Dict[str, Any]:
        """Test SMTP service using netcat"""
        print(f"🔍 Testing SMTP service on {self.target}:{port}")
        
        smtp_commands = [
            "EHLO test.com\r\n",
            "QUIT\r\n"
        ]
        
        try:
            process = subprocess.Popen(
                ['nc', self.target, str(port)],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            
            stdout, stderr = process.communicate(input=''.join(smtp_commands), timeout=10)
            
            smtp_info = {
                'port': port,
                'protocol': 'smtp',
                'commands': smtp_commands,
                'response': stdout,
                'error': stderr,
                'success': '220' in stdout or 'SMTP' in stdout
            }
            
            if smtp_info['success']:
                print(f"  ✅ SMTP service responded on port {port}")
            else:
                print(f"  ❌ No SMTP response on port {port}")
            
            return smtp_info
            
        except subprocess.TimeoutExpired:
            print(f"  ⏰ SMTP test on port {port} timed out")
            return {
                'port': port,
                'protocol': 'smtp',
                'success': False,
                'error': 'timeout'
            }
        except Exception as e:
            print(f"  ❌ Error testing SMTP on port {port}: {e}")
            return {
                'port': port,
                'protocol': 'smtp',
                'success': False,
                'error': str(e)
            }

    def test_file_transfer(self, port: int = 1234) -> Dict[str, Any]:
        """Test file transfer capabilities"""
        print(f"🔍 Testing file transfer on port {port}")
        
        # Create test file
        test_file = f"/tmp/netcat_test_{int(time.time())}.txt"
        test_content = f"Netcat file transfer test at {datetime.now().isoformat()}"
        
        try:
            with open(test_file, 'w') as f:
                f.write(test_content)
            
            # Start receiver in background
            receiver_process = subprocess.Popen(
                ['nc', '-l', '-p', str(port)],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            
            time.sleep(1)  # Give receiver time to start
            
            # Send file
            sender_process = subprocess.Popen(
                ['nc', 'localhost', str(port)],
                stdin=open(test_file, 'r'),
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            
            sender_process.wait()
            receiver_process.terminate()
            
            # Clean up
            os.remove(test_file)
            
            transfer_info = {
                'port': port,
                'test_file': test_file,
                'test_content': test_content,
                'success': True
            }
            
            print(f"  ✅ File transfer test completed on port {port}")
            return transfer_info
            
        except Exception as e:
            print(f"  ❌ File transfer test failed: {e}")
            return {
                'port': port,
                'success': False,
                'error': str(e)
            }

    def test_ssh_service(self, port: int = 22) -> Dict[str, Any]:
        """Test SSH service using netcat"""
        print(f"🔍 Testing SSH service on {self.target}:{port}")
        
        try:
            # Use netcat to test SSH connection
            process = subprocess.Popen(
                ['nc', '-w', '5', self.target, str(port)],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            
            stdout, stderr = process.communicate(timeout=10)
            
            ssh_info = {
                'port': port,
                'protocol': 'ssh',
                'response': stdout,
                'error': stderr,
                'success': 'SSH' in stdout or 'OpenSSH' in stdout or 'SSH-2.0' in stdout
            }
            
            if ssh_info['success']:
                print(f"  ✅ SSH service responded on port {port}")
            else:
                print(f"  ❌ No SSH response on port {port}")
            
            return ssh_info
            
        except subprocess.TimeoutExpired:
            print(f"  ⏰ SSH test on port {port} timed out")
            return {
                'port': port,
                'protocol': 'ssh',
                'success': False,
                'error': 'timeout'
            }
        except Exception as e:
            print(f"  ❌ Error testing SSH on port {port}: {e}")
            return {
                'port': port,
                'protocol': 'ssh',
                'success': False,
                'error': str(e)
            }

    def test_generic_service(self, port: int) -> Dict[str, Any]:
        """Test generic service using netcat"""
        print(f"🔍 Testing generic service on {self.target}:{port}")
        
        try:
            # Use netcat to test generic connection
            process = subprocess.Popen(
                ['nc', '-w', '5', self.target, str(port)],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            
            stdout, stderr = process.communicate(timeout=10)
            
            generic_info = {
                'port': port,
                'protocol': 'generic',
                'response': stdout,
                'error': stderr,
                'success': len(stdout) > 0 or process.returncode == 0
            }
            
            if generic_info['success']:
                print(f"  ✅ Service responded on port {port}")
            else:
                print(f"  ❌ No response on port {port}")
            
            return generic_info
            
        except subprocess.TimeoutExpired:
            print(f"  ⏰ Generic test on port {port} timed out")
            return {
                'port': port,
                'protocol': 'generic',
                'success': False,
                'error': 'timeout'
            }
        except Exception as e:
            print(f"  ❌ Error testing generic service on port {port}: {e}")
            return {
                'port': port,
                'protocol': 'generic',
                'success': False,
                'error': str(e)
            }

    def run_specific_port_analysis(self) -> Dict[str, Any]:
        """Run analysis for a specific port"""
        print(f"🚀 Starting netcat analysis for {self.target}:{self.port}")
        print("=" * 60)
        
        if not self.check_netcat_availability():
            print("❌ Netcat is not available on this system")
            return {'error': 'netcat_not_available'}
        
        start_time = time.time()
        
        try:
            # Test specific port connectivity
            print(f"\n🔍 Testing connectivity to port {self.port}...")
            connectivity_result = self.test_connectivity(self.port, "tcp")
            self.results['connectivity_tests'] = [connectivity_result]
            
            # Test specific services based on port
            service_tests = []
            
            if self.port == 80:
                print(f"\n🔍 Testing HTTP service on port {self.port}...")
                http_result = self.test_http_service(self.port)
                service_tests.append(http_result)
            elif self.port == 25:
                print(f"\n🔍 Testing SMTP service on port {self.port}...")
                smtp_result = self.test_smtp_service(self.port)
                service_tests.append(smtp_result)
            elif self.port == 22:
                print(f"\n🔍 Testing SSH service on port {self.port}...")
                ssh_result = self.test_ssh_service(self.port)
                service_tests.append(ssh_result)
            else:
                print(f"\n🔍 Testing generic service on port {self.port}...")
                generic_result = self.test_generic_service(self.port)
                service_tests.append(generic_result)
            
            self.results['service_tests'] = service_tests
            
            # Calculate scan duration
            scan_duration = time.time() - start_time
            self.results['scan_duration'] = scan_duration
            
            # Generate summary
            self._generate_summary()
            
            print("=" * 60)
            print("✅ Analysis completed successfully")
            print(f"Scan duration: {scan_duration:.2f} seconds")
            
            return self.results
            
        except Exception as e:
            print(f"❌ Analysis failed: {e}")
            return {'error': str(e)}

    def run_comprehensive_analysis(self) -> Dict[str, Any]:
        """Run comprehensive netcat analysis"""
        print(f"🚀 Starting netcat analysis for {self.target}")
        print("=" * 60)
        
        if not self.check_netcat_availability():
            print("❌ Netcat is not available on this system")
            return {'error': 'netcat_not_available'}
        
        start_time = time.time()
        
        try:
            # Common ports to test
            common_ports = [22, 23, 25, 53, 80, 110, 143, 443, 993, 995]
            
            # Test connectivity to common ports
            print("\n🔍 Testing connectivity to common ports...")
            connectivity_results = self.scan_ports(common_ports, "tcp")
            self.results['connectivity_tests'] = connectivity_results
            
            # Test specific services
            print("\n🔍 Testing specific services...")
            service_tests = []
            
            # Test HTTP if port 80 is open
            http_result = self.test_http_service(80)
            service_tests.append(http_result)
            
            # Test SMTP if port 25 is open
            smtp_result = self.test_smtp_service(25)
            service_tests.append(smtp_result)
            
            self.results['service_tests'] = service_tests
            
            # Test file transfer
            print("\n🔍 Testing file transfer capabilities...")
            transfer_result = self.test_file_transfer(1234)
            self.results['file_transfer_tests'] = [transfer_result]
            
            # Calculate scan duration
            scan_duration = time.time() - start_time
            self.results['scan_duration'] = scan_duration
            
            # Generate summary
            self._generate_summary()
            
            print("=" * 60)
            print("✅ Analysis completed successfully")
            print(f"Scan duration: {scan_duration:.2f} seconds")
            
            return self.results
            
        except Exception as e:
            print(f"❌ Analysis failed: {e}")
            return {'error': str(e)}

    def _generate_summary(self):
        """Generate analysis summary"""
        summary = {
            'total_tests': 0,
            'successful_tests': 0,
            'open_ports': 0,
            'services_tested': 0,
            'file_transfer_success': False,
            'scan_duration': self.results.get('scan_duration', 0)
        }
        
        # Count connectivity tests
        connectivity_tests = self.results.get('connectivity_tests', [])
        summary['total_tests'] += len(connectivity_tests)
        summary['successful_tests'] += len([t for t in connectivity_tests if t.get('success', False)])
        summary['open_ports'] = len([t for t in connectivity_tests if t.get('success', False)])
        
        # Count service tests
        service_tests = self.results.get('service_tests', [])
        summary['services_tested'] = len(service_tests)
        
        # Check file transfer
        transfer_tests = self.results.get('file_transfer_tests', [])
        summary['file_transfer_success'] = any(t.get('success', False) for t in transfer_tests)
        
        self.results['summary'] = summary

    def save_results(self, filename: str = None) -> str:
        """Save analysis results to JSON file"""
        if filename is None:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"netcat_analysis_{self.target.replace('/', '_')}_{timestamp}.json"
        
        # Ensure filename has .json extension
        if not filename.endswith('.json'):
            filename += '.json'
        
        # Create full path
        filepath = os.path.join(self.output_dir, filename)
        
        with open(filepath, 'w') as f:
            json.dump(self.results, f, indent=2)
        
        print(f"\nResults saved to: {filepath}")
        print(f"Output directory: {os.path.abspath(self.output_dir)}")
        
        return filepath

    def print_summary(self):
        """Print analysis summary"""
        summary = self.results.get('summary', {})
        
        print("\n" + "=" * 60)
        print("NETCAT ANALYSIS SUMMARY")
        print("=" * 60)
        print(f"Target: {self.target}")
        print(f"Scan Duration: {summary.get('scan_duration', 0):.2f} seconds")
        print(f"Total Tests: {summary.get('total_tests', 0)}")
        print(f"Successful Tests: {summary.get('successful_tests', 0)}")
        print(f"Open Ports: {summary.get('open_ports', 0)}")
        print(f"Services Tested: {summary.get('services_tested', 0)}")
        print(f"File Transfer: {'✅ Success' if summary.get('file_transfer_success', False) else '❌ Failed'}")
        
        # Show verbose details if requested
        if self.verbose:
            self.print_verbose_details()

    def print_verbose_details(self):
        """Print detailed analysis information"""
        print("\n" + "=" * 60)
        print("VERBOSE ANALYSIS DETAILS")
        print("=" * 60)
        
        # Show connectivity results
        connectivity_tests = self.results.get('connectivity_tests', [])
        if connectivity_tests:
            print(f"\n🔗 Connectivity Tests ({len(connectivity_tests)}):")
            for test in connectivity_tests:
                status = "✅" if test.get('success', False) else "❌"
                print(f"  {status} Port {test.get('port', 'Unknown')} ({test.get('protocol', 'tcp').upper()})")
                if self.verbose and test.get('raw_output'):
                    print(f"    Output: {test.get('raw_output', '').strip()}")
        
        # Show service tests
        service_tests = self.results.get('service_tests', [])
        if service_tests:
            print(f"\n🔧 Service Tests ({len(service_tests)}):")
            for test in service_tests:
                status = "✅" if test.get('success', False) else "❌"
                print(f"  {status} {test.get('protocol', 'Unknown').upper()} on port {test.get('port', 'Unknown')}")
                if self.verbose and test.get('response'):
                    print(f"    Response: {test.get('response', '')[:200]}...")
        
        # Show file transfer tests
        transfer_tests = self.results.get('file_transfer_tests', [])
        if transfer_tests:
            print(f"\n📁 File Transfer Tests ({len(transfer_tests)}):")
            for test in transfer_tests:
                status = "✅" if test.get('success', False) else "❌"
                print(f"  {status} Port {test.get('port', 'Unknown')}")
                if test.get('error'):
                    print(f"    Error: {test.get('error', '')}")


def main():
    parser = argparse.ArgumentParser(description='Netcat Analyzer Tool')
    parser.add_argument('target', help='Target host or IP address')
    parser.add_argument('-p', '--port', type=int, help='Specific port to test')
    parser.add_argument('-o', '--output', help='Output file for results')
    parser.add_argument('-d', '--output-dir', default='output',
                       help='Output directory (default: output)')
    parser.add_argument('-v', '--verbose', action='store_true',
                       help='Enable verbose output with detailed information')
    
    args = parser.parse_args()
    
    analyzer = NetcatAnalyzer(args.target, args.port, args.output_dir, args.verbose)
    
    # Choose analysis type based on whether port is specified
    if args.port:
        results = analyzer.run_specific_port_analysis()
    else:
        results = analyzer.run_comprehensive_analysis()
    
    if 'error' not in results:
        analyzer.print_summary()
        analyzer.save_results(args.output)
    else:
        print(f"❌ Analysis failed: {results['error']}")
        sys.exit(1)


if __name__ == "__main__":
    main()
