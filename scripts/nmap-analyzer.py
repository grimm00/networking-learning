#!/usr/bin/env python3
"""
Nmap Analyzer Tool
Comprehensive network scanning and analysis utility using nmap
"""

import subprocess
import json
import os
import sys
import argparse
import time
from datetime import datetime
from typing import List, Dict, Any, Optional
import re


class NmapAnalyzer:
    def __init__(self, target: str, scan_type: str = "basic", output_dir: str = "output", verbose: bool = False):
        self.target = target
        self.scan_type = scan_type
        self.output_dir = output_dir
        self.verbose = verbose
        self.results = {
            'target': target,
            'scan_type': scan_type,
            'scan_time': datetime.now().isoformat(),
            'hosts': [],
            'services': [],
            'vulnerabilities': [],
            'summary': {}
        }
        
        # Create output directory
        os.makedirs(output_dir, exist_ok=True)

    def check_nmap_availability(self) -> bool:
        """Check if nmap is available on the system"""
        try:
            result = subprocess.run(['nmap', '--version'], 
                                  capture_output=True, text=True, timeout=10)
            return result.returncode == 0
        except (subprocess.TimeoutExpired, FileNotFoundError):
            return False

    def run_host_discovery(self) -> Dict[str, Any]:
        """Perform host discovery scan"""
        print(f"🔍 Performing host discovery on {self.target}")
        
        cmd = ['nmap', '-sn', self.target]
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=60)
            
            if result.returncode == 0:
                hosts = self._parse_host_discovery(result.stdout)
                print(f"  ✅ Found {len(hosts)} active hosts")
                return {'hosts': hosts, 'raw_output': result.stdout}
            else:
                print(f"  ❌ Host discovery failed: {result.stderr}")
                return {'error': 'host_discovery_failed', 'stderr': result.stderr}
                
        except subprocess.TimeoutExpired:
            print(f"  ⏰ Host discovery timed out")
            return {'error': 'timeout'}
        except Exception as e:
            print(f"  ❌ Host discovery error: {e}")
            return {'error': str(e)}

    def run_port_scan(self, ports: str = None, scan_type: str = "syn") -> Dict[str, Any]:
        """Perform port scan"""
        print(f"🔍 Performing {scan_type} port scan on {self.target}")
        
        cmd = ['nmap']
        
        # Add scan type
        if scan_type == "syn":
            cmd.append('-sS')
        elif scan_type == "connect":
            cmd.append('-sT')
        elif scan_type == "udp":
            cmd.append('-sU')
        elif scan_type == "ack":
            cmd.append('-sA')
        
        # Add ports
        if ports:
            cmd.extend(['-p', ports])
        else:
            cmd.append('--top-ports')
            cmd.append('1000')
        
        cmd.append(self.target)
        
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
            
            if result.returncode == 0:
                ports_info = self._parse_port_scan(result.stdout)
                print(f"  ✅ Found {len(ports_info.get('open_ports', []))} open ports")
                return ports_info
            else:
                print(f"  ❌ Port scan failed: {result.stderr}")
                return {'error': 'port_scan_failed', 'stderr': result.stderr}
                
        except subprocess.TimeoutExpired:
            print(f"  ⏰ Port scan timed out")
            return {'error': 'timeout'}
        except Exception as e:
            print(f"  ❌ Port scan error: {e}")
            return {'error': str(e)}

    def run_service_detection(self) -> Dict[str, Any]:
        """Perform service detection and version enumeration"""
        print(f"🔍 Performing service detection on {self.target}")
        
        cmd = ['nmap', '-sV', '--version-intensity', '5', self.target]
        
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
            
            if result.returncode == 0:
                services = self._parse_service_detection(result.stdout)
                print(f"  ✅ Detected {len(services.get('services', []))} services")
                return services
            else:
                print(f"  ❌ Service detection failed: {result.stderr}")
                return {'error': 'service_detection_failed', 'stderr': result.stderr}
                
        except subprocess.TimeoutExpired:
            print(f"  ⏰ Service detection timed out")
            return {'error': 'timeout'}
        except Exception as e:
            print(f"  ❌ Service detection error: {e}")
            return {'error': str(e)}

    def run_os_detection(self) -> Dict[str, Any]:
        """Perform OS detection"""
        print(f"🔍 Performing OS detection on {self.target}")
        
        cmd = ['nmap', '-O', '--osscan-guess', self.target]
        
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
            
            if result.returncode == 0:
                os_info = self._parse_os_detection(result.stdout)
                print(f"  ✅ OS detection completed")
                return os_info
            else:
                print(f"  ❌ OS detection failed: {result.stderr}")
                return {'error': 'os_detection_failed', 'stderr': result.stderr}
                
        except subprocess.TimeoutExpired:
            print(f"  ⏰ OS detection timed out")
            return {'error': 'timeout'}
        except Exception as e:
            print(f"  ❌ OS detection error: {e}")
            return {'error': str(e)}

    def run_script_scan(self, script_category: str = "safe") -> Dict[str, Any]:
        """Run NSE scripts"""
        print(f"🔍 Running {script_category} scripts on {self.target}")
        
        cmd = ['nmap', '--script', script_category, self.target]
        
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=600)
            
            if result.returncode == 0:
                script_results = self._parse_script_output(result.stdout)
                print(f"  ✅ Script scan completed")
                return script_results
            else:
                print(f"  ❌ Script scan failed: {result.stderr}")
                return {'error': 'script_scan_failed', 'stderr': result.stderr}
                
        except subprocess.TimeoutExpired:
            print(f"  ⏰ Script scan timed out")
            return {'error': 'timeout'}
        except Exception as e:
            print(f"  ❌ Script scan error: {e}")
            return {'error': str(e)}

    def run_comprehensive_scan(self) -> Dict[str, Any]:
        """Run comprehensive scan with all techniques"""
        print(f"🔍 Running comprehensive scan on {self.target}")
        
        cmd = ['nmap', '-A', '-T4', '--script', 'safe,vuln', self.target]
        
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=900)
            
            if result.returncode == 0:
                comprehensive_results = self._parse_comprehensive_scan(result.stdout)
                print(f"  ✅ Comprehensive scan completed")
                return comprehensive_results
            else:
                print(f"  ❌ Comprehensive scan failed: {result.stderr}")
                return {'error': 'comprehensive_scan_failed', 'stderr': result.stderr}
                
        except subprocess.TimeoutExpired:
            print(f"  ⏰ Comprehensive scan timed out")
            return {'error': 'timeout'}
        except Exception as e:
            print(f"  ❌ Comprehensive scan error: {e}")
            return {'error': str(e)}

    def _parse_host_discovery(self, output: str) -> List[Dict[str, str]]:
        """Parse host discovery output"""
        hosts = []
        lines = output.split('\n')
        
        for line in lines:
            if 'Nmap scan report for' in line:
                # Extract IP and hostname
                match = re.search(r'Nmap scan report for (.+) \((.+)\)', line)
                if match:
                    hostname = match.group(1)
                    ip = match.group(2)
                    hosts.append({'ip': ip, 'hostname': hostname})
                else:
                    # IP only
                    match = re.search(r'Nmap scan report for (.+)', line)
                    if match:
                        ip = match.group(1)
                        hosts.append({'ip': ip, 'hostname': ''})
        
        return hosts

    def _parse_port_scan(self, output: str) -> Dict[str, Any]:
        """Parse port scan output"""
        ports_info = {
            'open_ports': [],
            'closed_ports': [],
            'filtered_ports': [],
            'raw_output': output
        }
        
        lines = output.split('\n')
        current_host = None
        
        for line in lines:
            if 'Nmap scan report for' in line:
                current_host = line.strip()
            elif '/tcp' in line or '/udp' in line:
                # Parse port line
                parts = line.split()
                if len(parts) >= 3:
                    port_proto = parts[0]
                    state = parts[1]
                    service = parts[2] if len(parts) > 2 else ''
                    
                    port_info = {
                        'port': port_proto,
                        'state': state,
                        'service': service,
                        'host': current_host
                    }
                    
                    if state == 'open':
                        ports_info['open_ports'].append(port_info)
                    elif state == 'closed':
                        ports_info['closed_ports'].append(port_info)
                    elif state == 'filtered':
                        ports_info['filtered_ports'].append(port_info)
        
        return ports_info

    def _parse_service_detection(self, output: str) -> Dict[str, Any]:
        """Parse service detection output"""
        services_info = {
            'services': [],
            'raw_output': output
        }
        
        lines = output.split('\n')
        current_host = None
        
        for line in lines:
            if 'Nmap scan report for' in line:
                current_host = line.strip()
            elif '/tcp' in line or '/udp' in line:
                # Parse service line
                parts = line.split()
                if len(parts) >= 4:
                    port_proto = parts[0]
                    state = parts[1]
                    service = parts[2]
                    version = ' '.join(parts[3:]) if len(parts) > 3 else ''
                    
                    service_info = {
                        'port': port_proto,
                        'state': state,
                        'service': service,
                        'version': version,
                        'host': current_host
                    }
                    services_info['services'].append(service_info)
        
        return services_info

    def _parse_os_detection(self, output: str) -> Dict[str, Any]:
        """Parse OS detection output"""
        os_info = {
            'os_guesses': [],
            'raw_output': output
        }
        
        lines = output.split('\n')
        in_os_section = False
        
        for line in lines:
            if 'OS details:' in line:
                in_os_section = True
                os_guess = line.replace('OS details:', '').strip()
                os_info['os_guesses'].append(os_guess)
            elif 'Aggressive OS guesses:' in line:
                in_os_section = True
            elif in_os_section and line.strip().startswith('OS CPE:'):
                os_info['os_cpe'] = line.replace('OS CPE:', '').strip()
            elif in_os_section and line.strip() and not line.startswith(' '):
                in_os_section = False
        
        return os_info

    def _parse_script_output(self, output: str) -> Dict[str, Any]:
        """Parse NSE script output"""
        script_results = {
            'scripts': [],
            'raw_output': output
        }
        
        lines = output.split('\n')
        current_script = None
        
        for line in lines:
            if '|_' in line:
                # Script output line
                if current_script:
                    current_script['output'].append(line.strip())
            elif '|' in line and not line.startswith('Nmap scan report'):
                # Script name line
                script_name = line.split('|')[0].strip()
                current_script = {
                    'name': script_name,
                    'output': [line.strip()]
                }
                script_results['scripts'].append(current_script)
        
        return script_results

    def _parse_comprehensive_scan(self, output: str) -> Dict[str, Any]:
        """Parse comprehensive scan output"""
        comprehensive_results = {
            'hosts': [],
            'services': [],
            'os_info': {},
            'scripts': [],
            'raw_output': output
        }
        
        # Parse hosts
        hosts = self._parse_host_discovery(output)
        comprehensive_results['hosts'] = hosts
        
        # Parse services
        services = self._parse_service_detection(output)
        comprehensive_results['services'] = services.get('services', [])
        
        # Parse OS info
        os_info = self._parse_os_detection(output)
        comprehensive_results['os_info'] = os_info
        
        # Parse scripts
        script_results = self._parse_script_output(output)
        comprehensive_results['scripts'] = script_results.get('scripts', [])
        
        return comprehensive_results

    def run_analysis(self) -> Dict[str, Any]:
        """Run complete analysis based on scan type"""
        print(f"🚀 Starting nmap analysis for {self.target}")
        print(f"Scan type: {self.scan_type}")
        print("=" * 60)
        
        if not self.check_nmap_availability():
            print("❌ Nmap is not available on this system")
            return {'error': 'nmap_not_available'}
        
        start_time = time.time()
        
        try:
            if self.scan_type == "discovery":
                self.results.update(self.run_host_discovery())
            elif self.scan_type == "ports":
                self.results.update(self.run_port_scan())
            elif self.scan_type == "services":
                self.results.update(self.run_service_detection())
            elif self.scan_type == "os":
                self.results.update(self.run_os_detection())
            elif self.scan_type == "scripts":
                self.results.update(self.run_script_scan())
            elif self.scan_type == "comprehensive":
                self.results.update(self.run_comprehensive_scan())
            else:  # basic
                # Run basic port scan
                port_results = self.run_port_scan()
                self.results.update(port_results)
                
                # Run service detection if ports found
                if port_results.get('open_ports'):
                    service_results = self.run_service_detection()
                    self.results.update(service_results)
            
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
            'total_hosts': len(self.results.get('hosts', [])),
            'total_open_ports': len(self.results.get('open_ports', [])),
            'total_services': len(self.results.get('services', [])),
            'total_scripts': len(self.results.get('scripts', [])),
            'scan_duration': self.results.get('scan_duration', 0)
        }
        
        # Count services by type
        service_counts = {}
        for service in self.results.get('services', []):
            service_name = service.get('service', 'unknown')
            service_counts[service_name] = service_counts.get(service_name, 0) + 1
        
        summary['service_counts'] = service_counts
        self.results['summary'] = summary

    def save_results(self, filename: str = None) -> str:
        """Save analysis results to JSON file"""
        if filename is None:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"nmap_analysis_{self.target.replace('/', '_')}_{timestamp}.json"
        
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
        print("NMAP ANALYSIS SUMMARY")
        print("=" * 60)
        print(f"Target: {self.target}")
        print(f"Scan Type: {self.scan_type}")
        print(f"Scan Duration: {summary.get('scan_duration', 0):.2f} seconds")
        print(f"Hosts Found: {summary.get('total_hosts', 0)}")
        print(f"Open Ports: {summary.get('total_open_ports', 0)}")
        print(f"Services Detected: {summary.get('total_services', 0)}")
        print(f"Scripts Executed: {summary.get('total_scripts', 0)}")
        
        # Show top services
        service_counts = summary.get('service_counts', {})
        if service_counts:
            print("\nTop Services:")
            for service, count in sorted(service_counts.items(), key=lambda x: x[1], reverse=True)[:5]:
                print(f"  {service}: {count}")
        
        # Show verbose details if requested
        if self.verbose:
            self.print_verbose_details()

    def print_verbose_details(self):
        """Print detailed analysis information"""
        print("\n" + "=" * 60)
        print("VERBOSE ANALYSIS DETAILS")
        print("=" * 60)
        
        # Show discovered hosts
        hosts = self.results.get('hosts', [])
        if hosts:
            print(f"\n📡 Discovered Hosts ({len(hosts)}):")
            for i, host in enumerate(hosts, 1):
                print(f"  {i}. {host.get('ip', 'Unknown')} - {host.get('hostname', 'No hostname')}")
        
        # Show open ports
        open_ports = self.results.get('open_ports', [])
        if open_ports:
            print(f"\n🔓 Open Ports ({len(open_ports)}):")
            for port in open_ports:
                print(f"  {port.get('port', 'Unknown')} - {port.get('state', 'Unknown')} - {port.get('service', 'Unknown')}")
        
        # Show services
        services = self.results.get('services', [])
        if services:
            print(f"\n🔧 Services ({len(services)}):")
            for service in services:
                print(f"  Port: {service.get('port', 'Unknown')}")
                print(f"    State: {service.get('state', 'Unknown')}")
                print(f"    Service: {service.get('service', 'Unknown')}")
                print(f"    Version: {service.get('version', 'Unknown')}")
                print(f"    Host: {service.get('host', 'Unknown')}")
                print()
        
        # Show OS information
        os_info = self.results.get('os_info', {})
        if os_info:
            print(f"\n💻 OS Information:")
            os_guesses = os_info.get('os_guesses', [])
            if os_guesses:
                print(f"  OS Guesses:")
                for guess in os_guesses:
                    print(f"    - {guess}")
            os_cpe = os_info.get('os_cpe', '')
            if os_cpe:
                print(f"  OS CPE: {os_cpe}")
        
        # Show script results
        scripts = self.results.get('scripts', [])
        if scripts:
            print(f"\n📜 Script Results ({len(scripts)}):")
            for script in scripts:
                print(f"  Script: {script.get('name', 'Unknown')}")
                output = script.get('output', [])
                if output:
                    print(f"    Output:")
                    for line in output[:5]:  # Show first 5 lines
                        print(f"      {line}")
                    if len(output) > 5:
                        print(f"      ... ({len(output) - 5} more lines)")
                print()
        
        # Show raw nmap output
        raw_output = self.results.get('raw_output', '')
        if raw_output and self.verbose:
            print(f"\n📄 Raw Nmap Output:")
            print("-" * 40)
            print(raw_output)
            print("-" * 40)


def main():
    parser = argparse.ArgumentParser(description='Nmap Analyzer Tool')
    parser.add_argument('target', help='Target host, IP, or network range')
    parser.add_argument('-t', '--scan-type', 
                       choices=['basic', 'discovery', 'ports', 'services', 'os', 'scripts', 'comprehensive'],
                       default='basic', help='Type of scan to perform')
    parser.add_argument('-p', '--ports', help='Ports to scan (e.g., 80,443 or 1-1000)')
    parser.add_argument('-o', '--output', help='Output file for results')
    parser.add_argument('-d', '--output-dir', default='output',
                       help='Output directory (default: output)')
    parser.add_argument('--script-category', default='safe',
                       help='NSE script category (default: safe)')
    parser.add_argument('-v', '--verbose', action='store_true',
                       help='Enable verbose output with detailed information')
    
    args = parser.parse_args()
    
    analyzer = NmapAnalyzer(args.target, args.scan_type, args.output_dir, args.verbose)
    results = analyzer.run_analysis()
    
    if 'error' not in results:
        analyzer.print_summary()
        analyzer.save_results(args.output)
    else:
        print(f"❌ Analysis failed: {results['error']}")
        sys.exit(1)


if __name__ == "__main__":
    main()
