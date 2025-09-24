#!/usr/bin/env python3
"""
TLS/SSL Analyzer Tool
Comprehensive analysis of TLS/SSL configurations, certificates, and security
"""

import ssl
import socket
import json
import os
import subprocess
import argparse
from datetime import datetime, timedelta
from typing import Dict, List, Any, Optional
import re


class TLSAnalyzer:
    def __init__(self, hostname: str, port: int = 443, timeout: int = 10):
        self.hostname = hostname
        self.port = port
        self.timeout = timeout
        self.results = {
            'hostname': hostname,
            'port': port,
            'timestamp': datetime.now().isoformat(),
            'analysis': {}
        }

    def analyze_connection(self) -> Dict[str, Any]:
        """Analyze TLS connection and handshake"""
        print(f"🔍 Analyzing TLS connection to {self.hostname}:{self.port}")
        
        try:
            # Create SSL context
            context = ssl.create_default_context()
            context.check_hostname = False
            context.verify_mode = ssl.CERT_NONE
            
            # Connect and analyze
            with socket.create_connection((self.hostname, self.port), timeout=self.timeout) as sock:
                with context.wrap_socket(sock, server_hostname=self.hostname) as ssock:
                    # Get connection info
                    cipher = ssock.cipher()
                    version = ssock.version()
                    cert = ssock.getpeercert()
                    
                    connection_info = {
                        'protocol_version': version,
                        'cipher_suite': cipher[0] if cipher else 'Unknown',
                        'key_length': cipher[2] if cipher else 'Unknown',
                        'mac_algorithm': cipher[1] if cipher else 'Unknown',
                        'certificate': self._parse_certificate(cert) if cert else None,
                        'connection_successful': True
                    }
                    
                    print(f"  ✅ Protocol: {version}")
                    print(f"  ✅ Cipher: {connection_info['cipher_suite']}")
                    print(f"  ✅ Key Length: {connection_info['key_length']} bits")
                    
                    return connection_info
                    
        except Exception as e:
            print(f"  ❌ Connection failed: {e}")
            return {
                'connection_successful': False,
                'error': str(e)
            }

    def _parse_certificate(self, cert: Dict) -> Dict[str, Any]:
        """Parse certificate information"""
        if not cert:
            return None
            
        # Parse subject and issuer
        subject = self._parse_name(cert.get('subject', []))
        issuer = self._parse_name(cert.get('issuer', []))
        
        # Parse validity dates
        not_before = cert.get('notBefore', '')
        not_after = cert.get('notAfter', '')
        
        # Calculate expiration info
        expiration_info = self._calculate_expiration(not_after)
        
        # Parse extensions
        extensions = self._parse_extensions(cert.get('subjectAltName', []))
        
        return {
            'subject': subject,
            'issuer': issuer,
            'valid_from': not_before,
            'valid_until': not_after,
            'serial_number': cert.get('serialNumber', ''),
            'version': cert.get('version', ''),
            'signature_algorithm': cert.get('signatureAlgorithm', ''),
            'subject_alt_names': extensions,
            'expiration_info': expiration_info
        }

    def _parse_name(self, name_list: List) -> Dict[str, str]:
        """Parse certificate name fields"""
        result = {}
        for item in name_list:
            if isinstance(item, tuple) and len(item) == 2:
                key, value = item
                result[key] = value
        return result

    def _parse_extensions(self, san_list: List) -> List[str]:
        """Parse Subject Alternative Names"""
        if not san_list:
            return []
        return [san[1] for san in san_list if isinstance(san, tuple) and len(san) == 2]

    def _calculate_expiration(self, not_after: str) -> Dict[str, Any]:
        """Calculate certificate expiration information"""
        if not not_after:
            return {'status': 'unknown'}
            
        try:
            # Parse date (format: "Dec 31 23:59:59 2024 GMT")
            expiry_date = datetime.strptime(not_after, '%b %d %H:%M:%S %Y %Z')
            now = datetime.now()
            
            days_until_expiry = (expiry_date - now).days
            
            if days_until_expiry < 0:
                status = 'expired'
            elif days_until_expiry < 30:
                status = 'expiring_soon'
            elif days_until_expiry < 90:
                status = 'expiring_soon'
            else:
                status = 'valid'
                
            return {
                'status': status,
                'days_until_expiry': days_until_expiry,
                'expiry_date': expiry_date.isoformat(),
                'is_expired': days_until_expiry < 0,
                'is_expiring_soon': days_until_expiry < 30
            }
        except Exception as e:
            return {'status': 'parse_error', 'error': str(e)}

    def analyze_cipher_suites(self) -> Dict[str, Any]:
        """Analyze supported cipher suites using nmap"""
        print(f"🔍 Analyzing cipher suites for {self.hostname}")
        
        try:
            # Run nmap SSL enumeration
            cmd = ['nmap', '--script', 'ssl-enum-ciphers', '-p', str(self.port), self.hostname]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
            
            if result.returncode == 0:
                cipher_info = self._parse_nmap_output(result.stdout)
                print(f"  ✅ Found {len(cipher_info.get('supported_ciphers', []))} cipher suites")
                return cipher_info
            else:
                print(f"  ❌ Nmap failed: {result.stderr}")
                return {'error': 'nmap_failed', 'stderr': result.stderr}
                
        except subprocess.TimeoutExpired:
            print(f"  ❌ Nmap timeout")
            return {'error': 'timeout'}
        except FileNotFoundError:
            print(f"  ⚠️  Nmap not found, skipping cipher analysis")
            return {'error': 'nmap_not_found'}

    def _parse_nmap_output(self, output: str) -> Dict[str, Any]:
        """Parse nmap SSL enumeration output"""
        cipher_info = {
            'protocols': {},
            'supported_ciphers': [],
            'weak_ciphers': [],
            'recommended_ciphers': []
        }
        
        current_protocol = None
        
        for line in output.split('\n'):
            line = line.strip()
            
            # Protocol headers
            if 'TLSv1.0' in line:
                current_protocol = 'TLSv1.0'
            elif 'TLSv1.1' in line:
                current_protocol = 'TLSv1.1'
            elif 'TLSv1.2' in line:
                current_protocol = 'TLSv1.2'
            elif 'TLSv1.3' in line:
                current_protocol = 'TLSv1.3'
            elif 'SSLv2' in line:
                current_protocol = 'SSLv2'
            elif 'SSLv3' in line:
                current_protocol = 'SSLv3'
            
            # Cipher suite lines
            if '|' in line and 'cipher' in line.lower():
                cipher_match = re.search(r'(\w+-\w+-\w+-\w+)', line)
                if cipher_match:
                    cipher = cipher_match.group(1)
                    cipher_info['supported_ciphers'].append(cipher)
                    
                    # Categorize ciphers
                    if self._is_weak_cipher(cipher):
                        cipher_info['weak_ciphers'].append(cipher)
                    elif self._is_recommended_cipher(cipher):
                        cipher_info['recommended_ciphers'].append(cipher)
                    
                    if current_protocol:
                        if current_protocol not in cipher_info['protocols']:
                            cipher_info['protocols'][current_protocol] = []
                        cipher_info['protocols'][current_protocol].append(cipher)
        
        return cipher_info

    def _is_weak_cipher(self, cipher: str) -> bool:
        """Check if cipher suite is considered weak"""
        weak_patterns = [
            'RC4', 'DES', 'MD5', 'SHA1', 'EXPORT', 'NULL', 'ANON'
        ]
        return any(pattern in cipher.upper() for pattern in weak_patterns)

    def _is_recommended_cipher(self, cipher: str) -> bool:
        """Check if cipher suite is recommended"""
        recommended_patterns = [
            'AES256-GCM', 'AES128-GCM', 'CHACHA20', 'ECDHE'
        ]
        return any(pattern in cipher.upper() for pattern in recommended_patterns)

    def analyze_security_headers(self) -> Dict[str, Any]:
        """Analyze security headers"""
        print(f"🔍 Analyzing security headers for {self.hostname}")
        
        try:
            import requests
            
            # Test HTTPS
            url = f"https://{self.hostname}"
            response = requests.get(url, timeout=self.timeout, verify=False)
            
            headers_info = {
                'hsts': self._check_hsts_header(response.headers),
                'hpkp': self._check_hpkp_header(response.headers),
                'csp': self._check_csp_header(response.headers),
                'other_security_headers': self._check_other_headers(response.headers)
            }
            
            print(f"  ✅ Analyzed {len(response.headers)} headers")
            return headers_info
            
        except ImportError:
            print(f"  ⚠️  Requests library not available, skipping header analysis")
            return {'error': 'requests_not_available'}
        except Exception as e:
            print(f"  ❌ Header analysis failed: {e}")
            return {'error': str(e)}

    def _check_hsts_header(self, headers: Dict) -> Dict[str, Any]:
        """Check HSTS header"""
        hsts_header = headers.get('Strict-Transport-Security', '')
        if hsts_header:
            return {
                'present': True,
                'value': hsts_header,
                'max_age': self._extract_max_age(hsts_header),
                'include_subdomains': 'includeSubDomains' in hsts_header,
                'preload': 'preload' in hsts_header
            }
        return {'present': False}

    def _check_hpkp_header(self, headers: Dict) -> Dict[str, Any]:
        """Check HPKP header (deprecated but still analyzed)"""
        hpkp_header = headers.get('Public-Key-Pins', '')
        if hpkp_header:
            return {
                'present': True,
                'value': hpkp_header,
                'note': 'HPKP is deprecated'
            }
        return {'present': False}

    def _check_csp_header(self, headers: Dict) -> Dict[str, Any]:
        """Check Content Security Policy header"""
        csp_header = headers.get('Content-Security-Policy', '')
        if csp_header:
            return {
                'present': True,
                'value': csp_header
            }
        return {'present': False}

    def _check_other_headers(self, headers: Dict) -> Dict[str, Any]:
        """Check other security headers"""
        security_headers = [
            'X-Frame-Options',
            'X-Content-Type-Options',
            'X-XSS-Protection',
            'Referrer-Policy',
            'Permissions-Policy'
        ]
        
        found_headers = {}
        for header in security_headers:
            if header in headers:
                found_headers[header] = headers[header]
        
        return found_headers

    def _extract_max_age(self, hsts_value: str) -> Optional[int]:
        """Extract max-age value from HSTS header"""
        match = re.search(r'max-age=(\d+)', hsts_value)
        return int(match.group(1)) if match else None

    def run_comprehensive_analysis(self):
        """Run complete TLS analysis"""
        print(f"🚀 Starting comprehensive TLS analysis for {self.hostname}")
        print("=" * 60)
        
        # Connection analysis
        connection_info = self.analyze_connection()
        self.results['analysis']['connection'] = connection_info
        
        # Cipher suite analysis
        cipher_info = self.analyze_cipher_suites()
        self.results['analysis']['cipher_suites'] = cipher_info
        
        # Security headers analysis
        headers_info = self.analyze_security_headers()
        self.results['analysis']['security_headers'] = headers_info
        
        # Generate summary
        self.generate_summary()

    def generate_summary(self):
        """Generate analysis summary"""
        print("\n" + "=" * 60)
        print("TLS ANALYSIS SUMMARY")
        print("=" * 60)
        
        # Connection summary
        conn = self.results['analysis'].get('connection', {})
        if conn.get('connection_successful'):
            print(f"✅ Connection: {conn['protocol_version']}")
            print(f"✅ Cipher: {conn['cipher_suite']}")
            print(f"✅ Key Length: {conn['key_length']} bits")
            
            # Certificate summary
            cert = conn.get('certificate')
            if cert:
                exp_info = cert.get('expiration_info', {})
                status = exp_info.get('status', 'unknown')
                days = exp_info.get('days_until_expiry', 0)
                
                if status == 'expired':
                    print(f"❌ Certificate: EXPIRED ({abs(days)} days ago)")
                elif status == 'expiring_soon':
                    print(f"⚠️  Certificate: Expires in {days} days")
                else:
                    print(f"✅ Certificate: Valid ({days} days remaining)")
        else:
            print(f"❌ Connection failed: {conn.get('error', 'Unknown error')}")
        
        # Cipher summary
        cipher_info = self.results['analysis'].get('cipher_suites', {})
        if 'supported_ciphers' in cipher_info:
            total_ciphers = len(cipher_info['supported_ciphers'])
            weak_ciphers = len(cipher_info.get('weak_ciphers', []))
            recommended_ciphers = len(cipher_info.get('recommended_ciphers', []))
            
            print(f"📊 Cipher Suites: {total_ciphers} total")
            print(f"   Weak: {weak_ciphers}")
            print(f"   Recommended: {recommended_ciphers}")
        
        # Security headers summary
        headers_info = self.results['analysis'].get('security_headers', {})
        hsts = headers_info.get('hsts', {})
        if hsts.get('present'):
            print(f"✅ HSTS: Enabled")
        else:
            print(f"❌ HSTS: Not enabled")

    def save_results(self, filename: str = None, output_dir: str = "output"):
        """Save results to JSON file"""
        # Create output directory if it doesn't exist
        os.makedirs(output_dir, exist_ok=True)
        
        if filename is None:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"tls_analysis_{self.hostname}_{timestamp}.json"
        
        # Ensure filename has .json extension
        if not filename.endswith('.json'):
            filename += '.json'
        
        # Create full path in output directory
        filepath = os.path.join(output_dir, filename)
        
        with open(filepath, 'w') as f:
            json.dump(self.results, f, indent=2)
        
        print(f"\n📄 Results saved to: {filepath}")
        print(f"📁 Output directory: {os.path.abspath(output_dir)}")


def main():
    parser = argparse.ArgumentParser(description='TLS/SSL Analyzer Tool')
    parser.add_argument('hostname', help='Target hostname or IP address')
    parser.add_argument('--port', '-p', type=int, default=443, help='Port number (default: 443)')
    parser.add_argument('--timeout', '-t', type=int, default=10, help='Connection timeout (default: 10)')
    parser.add_argument('--output', '-o', help='Output file for results')
    parser.add_argument('--output-dir', '-d', default='output', help='Output directory (default: output)')
    
    args = parser.parse_args()
    
    analyzer = TLSAnalyzer(args.hostname, args.port, args.timeout)
    analyzer.run_comprehensive_analysis()
    analyzer.save_results(args.output, args.output_dir)


if __name__ == "__main__":
    main()
