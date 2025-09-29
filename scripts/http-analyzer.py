#!/usr/bin/env python3
"""
HTTP/HTTPS Analyzer Tool
A comprehensive tool for analyzing HTTP requests, responses, and performance.
"""

import requests
import ssl
import socket
import json
import time
import argparse
import sys
from urllib.parse import urlparse
from datetime import datetime

class HTTPAnalyzer:
    def __init__(self, url, timeout=10, verbose=False, minimal=False):
        # Auto-add protocol if missing
        if not url.startswith(('http://', 'https://')):
            # Try HTTPS first, fall back to HTTP if HTTPS fails
            self.url = f"http://{url}"
        else:
            self.url = url
        self.timeout = timeout
        self.parsed_url = urlparse(self.url)
        self.session = requests.Session()
        self.verbose = verbose
        self.minimal = minimal
        
    def analyze_request(self):
        """Perform comprehensive HTTP analysis"""
        if not self.minimal:
            print(f"🔍 Analyzing HTTP/HTTPS for: {self.url}")
            print("=" * 60)
        
        try:
            # Basic request
            start_time = time.time()
            response = self.session.get(self.url, timeout=self.timeout)
            end_time = time.time()
            
            response_time = (end_time - start_time) * 1000  # Convert to milliseconds
            
            if self.minimal:
                # Minimal output - just essential info
                print(f"{response.status_code} {response.reason} | {response_time:.1f}ms | {len(response.content)} bytes | {response.headers.get('server', 'Unknown')}")
                return response
            
            # Request information
            print(f"\n📤 REQUEST INFORMATION:")
            print(f"  Method: {response.request.method}")
            print(f"  URL: {response.url}")
            print(f"  Protocol: {response.raw.version}")
            print(f"  Response Time: {response_time:.2f}ms")
            
            # Response information
            print(f"\n📥 RESPONSE INFORMATION:")
            print(f"  Status Code: {response.status_code} {response.reason}")
            print(f"  Content Length: {len(response.content)} bytes")
            print(f"  Content Type: {response.headers.get('content-type', 'Unknown')}")
            print(f"  Server: {response.headers.get('server', 'Unknown')}")
            
            # Headers analysis
            self.analyze_headers(response)
            
            # Security analysis
            if self.parsed_url.scheme == 'https':
                self.analyze_ssl()
            
            # Performance analysis
            self.analyze_performance(response)
            
            # Content analysis
            self.analyze_content(response)
            
            return response
            
        except requests.exceptions.RequestException as e:
            print(f"❌ Error: {e}")
            return None
    
    def analyze_headers(self, response):
        """Analyze HTTP headers"""
        print(f"\n📋 HEADERS ANALYSIS:")
        
        if self.verbose:
            # Verbose: Show all headers with full values
            print(f"  Request Headers:")
            for header, value in response.request.headers.items():
                print(f"    {header}: {value}")
            
            print(f"  Response Headers:")
            for header, value in response.headers.items():
                print(f"    {header}: {value}")
        else:
            # Default: Show important headers with truncated values
            important_headers = [
                'content-type', 'content-length', 'server', 'date', 'last-modified',
                'etag', 'cache-control', 'expires', 'location', 'set-cookie',
                'content-encoding', 'transfer-encoding', 'connection'
            ]
            
            print(f"  Key Response Headers:")
            for header in important_headers:
                value = response.headers.get(header)
                if value:
                    # Truncate long values for readability
                    if len(str(value)) > 60:
                        display_value = str(value)[:57] + "..."
                    else:
                        display_value = value
                    print(f"    {header}: {display_value}")
        
        # Security headers analysis
        security_headers = [
            'strict-transport-security',
            'content-security-policy',
            'x-frame-options',
            'x-content-type-options',
            'x-xss-protection',
            'referrer-policy'
        ]
        
        print(f"\n🔒 SECURITY HEADERS:")
        for header in security_headers:
            value = response.headers.get(header, 'Not Set')
            status = "✅" if value != 'Not Set' else "❌"
            
            if self.verbose and value != 'Not Set':
                # In verbose mode, show full security header values
                print(f"    {status} {header}: {value}")
            else:
                # In default mode, show summary
                if value != 'Not Set':
                    if header == 'content-security-policy' and len(value) > 50:
                        print(f"    {status} {header}: {value[:47]}...")
                    elif header == 'strict-transport-security' and len(value) > 30:
                        print(f"    {status} {header}: {value[:27]}...")
                    else:
                        print(f"    {status} {header}: {value}")
                else:
                    print(f"    {status} {header}: Not Set")
    
    def analyze_ssl(self):
        """Analyze SSL/TLS configuration"""
        print(f"\n🔐 SSL/TLS ANALYSIS:")
        
        try:
            hostname = self.parsed_url.hostname
            port = self.parsed_url.port or 443
            
            # Create SSL context
            context = ssl.create_default_context()
            
            # Connect and get certificate
            with socket.create_connection((hostname, port), timeout=self.timeout) as sock:
                with context.wrap_socket(sock, server_hostname=hostname) as ssock:
                    cert = ssock.getpeercert()
                    cipher = ssock.cipher()
                    version = ssock.version()
                    
                    print(f"  Protocol Version: {version}")
                    print(f"  Cipher Suite: {cipher[0] if cipher else 'Unknown'}")
                    print(f"  Key Length: {cipher[2] if cipher else 'Unknown'} bits")
                    
                    # Certificate details
                    print(f"\n📜 CERTIFICATE DETAILS:")
                    print(f"  Subject: {cert.get('subject', 'Unknown')}")
                    print(f"  Issuer: {cert.get('issuer', 'Unknown')}")
                    print(f"  Valid From: {cert.get('notBefore', 'Unknown')}")
                    print(f"  Valid Until: {cert.get('notAfter', 'Unknown')}")
                    print(f"  Serial Number: {cert.get('serialNumber', 'Unknown')}")
                    
                    # Check certificate validity
                    now = datetime.now()
                    not_after = datetime.strptime(cert['notAfter'], '%b %d %H:%M:%S %Y %Z')
                    days_until_expiry = (not_after - now).days
                    
                    if days_until_expiry > 30:
                        print(f"  ✅ Certificate expires in {days_until_expiry} days")
                    elif days_until_expiry > 0:
                        print(f"  ⚠️  Certificate expires in {days_until_expiry} days")
                    else:
                        print(f"  ❌ Certificate expired {abs(days_until_expiry)} days ago")
                        
        except Exception as e:
            print(f"  ❌ SSL Analysis failed: {e}")
    
    def analyze_performance(self, response):
        """Analyze performance characteristics"""
        print(f"\n⚡ PERFORMANCE ANALYSIS:")
        
        # Response time
        print(f"  Response Time: {response.elapsed.total_seconds() * 1000:.2f}ms")
        
        # Content size
        content_size = len(response.content)
        if content_size < 1024:
            print(f"  Content Size: {content_size} bytes")
        elif content_size < 1024 * 1024:
            print(f"  Content Size: {content_size / 1024:.2f} KB")
        else:
            print(f"  Content Size: {content_size / (1024 * 1024):.2f} MB")
        
        # Compression
        content_encoding = response.headers.get('content-encoding', 'None')
        print(f"  Compression: {content_encoding}")
        
        # Cache headers
        cache_control = response.headers.get('cache-control', 'Not Set')
        etag = response.headers.get('etag', 'Not Set')
        last_modified = response.headers.get('last-modified', 'Not Set')
        
        print(f"  Cache Control: {cache_control}")
        print(f"  ETag: {etag}")
        print(f"  Last Modified: {last_modified}")
    
    def analyze_content(self, response):
        """Analyze response content"""
        if self.minimal:
            return  # Skip content analysis in minimal mode
            
        print(f"\n📄 CONTENT ANALYSIS:")
        
        content_type = response.headers.get('content-type', '').lower()
        
        if 'html' in content_type:
            print(f"  Type: HTML Document")
            # Basic HTML analysis
            content = response.text
            if '<title>' in content:
                title_start = content.find('<title>') + 7
                title_end = content.find('</title>')
                title = content[title_start:title_end].strip()
                print(f"  Title: {title}")
            
            # Count elements
            links = content.count('<a ')
            images = content.count('<img ')
            scripts = content.count('<script')
            stylesheets = content.count('<link')
            
            print(f"  Links: {links}")
            print(f"  Images: {images}")
            print(f"  Scripts: {scripts}")
            print(f"  Stylesheets: {stylesheets}")
            
            if self.verbose:
                # In verbose mode, show more details
                print(f"  Content Length: {len(content)} characters")
                if '<meta' in content:
                    meta_count = content.count('<meta')
                    print(f"  Meta Tags: {meta_count}")
                if '<form' in content:
                    form_count = content.count('<form')
                    print(f"  Forms: {form_count}")
            
        elif 'json' in content_type:
            print(f"  Type: JSON Document")
            try:
                data = response.json()
                if self.verbose:
                    print(f"  Keys: {list(data.keys()) if isinstance(data, dict) else 'Array'}")
                    print(f"  Structure: {type(data).__name__}")
                else:
                    # Show just top-level keys
                    if isinstance(data, dict):
                        print(f"  Top-level Keys: {len(data)}")
                    elif isinstance(data, list):
                        print(f"  Array Length: {len(data)}")
            except:
                print(f"  Invalid JSON")
                
        elif 'xml' in content_type:
            print(f"  Type: XML Document")
            
        else:
            print(f"  Type: {content_type}")
            if self.verbose:
                print(f"  Content Length: {len(response.text)} characters")
    
    def test_methods(self):
        """Test different HTTP methods"""
        print(f"\n🔧 HTTP METHODS TEST:")
        
        methods = ['GET', 'POST', 'PUT', 'DELETE', 'HEAD', 'OPTIONS']
        
        for method in methods:
            try:
                response = self.session.request(method, self.url, timeout=self.timeout)
                status = "✅" if response.status_code < 400 else "❌"
                print(f"  {status} {method}: {response.status_code} {response.reason}")
            except Exception as e:
                print(f"  ❌ {method}: {e}")
    
    def test_redirects(self):
        """Test redirect handling"""
        print(f"\n🔄 REDIRECT TEST:")
        
        try:
            response = self.session.get(self.url, allow_redirects=True, timeout=self.timeout)
            if response.history:
                print(f"  Redirects: {len(response.history)}")
                for i, resp in enumerate(response.history, 1):
                    print(f"    {i}. {resp.status_code} {resp.url}")
                print(f"  Final URL: {response.url}")
            else:
                print(f"  No redirects")
        except Exception as e:
            print(f"  ❌ Redirect test failed: {e}")
    
    def performance_test(self, iterations=5):
        """Run performance test"""
        print(f"\n⚡ PERFORMANCE TEST ({iterations} iterations):")
        
        times = []
        
        for i in range(iterations):
            try:
                start_time = time.time()
                response = self.session.get(self.url, timeout=self.timeout)
                end_time = time.time()
                
                duration = (end_time - start_time) * 1000
                times.append(duration)
                
                status = "✅" if response.status_code == 200 else "❌"
                print(f"  {status} Iteration {i+1}: {duration:.2f}ms ({response.status_code})")
                
            except Exception as e:
                print(f"  ❌ Iteration {i+1}: {e}")
        
        if times:
            avg_time = sum(times) / len(times)
            min_time = min(times)
            max_time = max(times)
            
            print(f"\n📊 Performance Summary:")
            print(f"  Average: {avg_time:.2f}ms")
            print(f"  Minimum: {min_time:.2f}ms")
            print(f"  Maximum: {max_time:.2f}ms")

def main():
    parser = argparse.ArgumentParser(description="HTTP/HTTPS Analyzer Tool")
    parser.add_argument("url", help="URL to analyze")
    parser.add_argument("-t", "--timeout", type=int, default=10, help="Request timeout in seconds")
    parser.add_argument("-m", "--methods", action="store_true", help="Test different HTTP methods")
    parser.add_argument("-r", "--redirects", action="store_true", help="Test redirect handling")
    parser.add_argument("-p", "--performance", type=int, default=0, help="Run performance test (number of iterations)")
    parser.add_argument("-v", "--verbose", action="store_true", help="Verbose output (show all headers and detailed content)")
    parser.add_argument("--minimal", action="store_true", help="Minimal output (status, time, size, server only)")
    
    args = parser.parse_args()
    
    # Validate arguments
    if args.minimal and args.verbose:
        print("❌ Error: Cannot use both --minimal and --verbose flags")
        sys.exit(1)
    
    analyzer = HTTPAnalyzer(args.url, args.timeout, args.verbose, args.minimal)
    
    # Basic analysis
    response = analyzer.analyze_request()
    
    if response and not args.minimal:
        # Optional tests (skip in minimal mode)
        if args.methods:
            analyzer.test_methods()
        
        if args.redirects:
            analyzer.test_redirects()
        
        if args.performance > 0:
            analyzer.performance_test(args.performance)
    
    if not args.minimal:
        print(f"\n✅ Analysis complete for {args.url}")

if __name__ == "__main__":
    main()
