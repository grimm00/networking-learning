#!/usr/bin/env python3
"""
DNS Analyzer Tool
A comprehensive tool for analyzing DNS records and troubleshooting DNS issues.
"""

import subprocess
import json
import sys
import argparse
import time
from typing import Dict, List, Optional

class DNSAnalyzer:
    def __init__(self, domain: str, dns_server: str = None):
        self.domain = domain
        self.dns_server = dns_server
        self.results = {}
    
    def run_dig(self, record_type: str = "A", short: bool = False) -> str:
        """Run dig command and return output"""
        cmd = ["dig"]
        
        if self.dns_server:
            cmd.extend([f"@{self.dns_server}"])
        
        if short:
            cmd.append("+short")
        else:
            cmd.extend(["+noall", "+answer"])
        
        cmd.extend([self.domain, record_type])
        
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
            return result.stdout.strip()
        except subprocess.TimeoutExpired:
            return "Timeout"
        except Exception as e:
            return f"Error: {e}"
    
    def analyze_domain(self) -> Dict:
        """Perform comprehensive DNS analysis"""
        print(f"🔍 Analyzing DNS for: {self.domain}")
        print("=" * 50)
        
        # A Record
        print("\n📋 A Record (IPv4):")
        a_result = self.run_dig("A")
        print(a_result)
        self.results['A'] = a_result
        
        # AAAA Record
        print("\n📋 AAAA Record (IPv6):")
        aaaa_result = self.run_dig("AAAA")
        print(aaaa_result)
        self.results['AAAA'] = aaaa_result
        
        # MX Record
        print("\n📧 MX Record (Mail Exchange):")
        mx_result = self.run_dig("MX")
        print(mx_result)
        self.results['MX'] = mx_result
        
        # NS Record
        print("\n🌐 NS Record (Name Servers):")
        ns_result = self.run_dig("NS")
        print(ns_result)
        self.results['NS'] = ns_result
        
        # TXT Record
        print("\n📝 TXT Record (Text):")
        txt_result = self.run_dig("TXT")
        print(txt_result)
        self.results['TXT'] = txt_result
        
        # SOA Record
        print("\n🏛️ SOA Record (Start of Authority):")
        soa_result = self.run_dig("SOA")
        print(soa_result)
        self.results['SOA'] = soa_result
        
        # CNAME Record
        print("\n🔗 CNAME Record (Canonical Name):")
        cname_result = self.run_dig("CNAME")
        print(cname_result)
        self.results['CNAME'] = cname_result
        
        return self.results
    
    def trace_resolution(self) -> str:
        """Trace DNS resolution path"""
        print(f"\n🛤️ Tracing DNS resolution for: {self.domain}")
        print("=" * 50)
        
        cmd = ["dig", "+trace", self.domain]
        if self.dns_server:
            cmd.insert(1, f"@{self.dns_server}")
        
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
            print(result.stdout)
            return result.stdout
        except subprocess.TimeoutExpired:
            print("Timeout during trace")
            return "Timeout"
        except Exception as e:
            print(f"Error during trace: {e}")
            return f"Error: {e}"
    
    def test_dns_servers(self) -> Dict:
        """Test domain resolution with different DNS servers"""
        dns_servers = {
            "Google DNS": "8.8.8.8",
            "Cloudflare": "1.1.1.1",
            "Quad9": "9.9.9.9",
            "OpenDNS": "208.67.222.222"
        }
        
        print(f"\n🌐 Testing DNS resolution with different servers:")
        print("=" * 50)
        
        results = {}
        for name, server in dns_servers.items():
            print(f"\n{name} ({server}):")
            result = self.run_dig("A", short=True)
            print(f"  Result: {result}")
            results[name] = result
            time.sleep(0.5)  # Be nice to DNS servers
        
        return results
    
    def check_dnssec(self) -> str:
        """Check DNSSEC support"""
        print(f"\n🔒 Checking DNSSEC support for: {self.domain}")
        print("=" * 50)
        
        cmd = ["dig", "+dnssec", self.domain]
        if self.dns_server:
            cmd.insert(1, f"@{self.dns_server}")
        
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
            print(result.stdout)
            return result.stdout
        except Exception as e:
            print(f"Error checking DNSSEC: {e}")
            return f"Error: {e}"
    
    def reverse_dns_lookup(self, ip: str) -> str:
        """Perform reverse DNS lookup"""
        print(f"\n🔄 Reverse DNS lookup for: {ip}")
        print("=" * 50)
        
        cmd = ["dig", "-x", ip]
        if self.dns_server:
            cmd.insert(1, f"@{self.dns_server}")
        
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
            print(result.stdout)
            return result.stdout
        except Exception as e:
            print(f"Error in reverse lookup: {e}")
            return f"Error: {e}"
    
    def performance_test(self, iterations: int = 5) -> Dict:
        """Test DNS resolution performance"""
        print(f"\n⚡ Performance test ({iterations} iterations):")
        print("=" * 50)
        
        times = []
        for i in range(iterations):
            start_time = time.time()
            self.run_dig("A", short=True)
            end_time = time.time()
            duration = (end_time - start_time) * 1000  # Convert to milliseconds
            times.append(duration)
            print(f"  Iteration {i+1}: {duration:.2f}ms")
        
        avg_time = sum(times) / len(times)
        min_time = min(times)
        max_time = max(times)
        
        print(f"\n📊 Performance Summary:")
        print(f"  Average: {avg_time:.2f}ms")
        print(f"  Minimum: {min_time:.2f}ms")
        print(f"  Maximum: {max_time:.2f}ms")
        
        return {
            "times": times,
            "average": avg_time,
            "minimum": min_time,
            "maximum": max_time
        }

def main():
    parser = argparse.ArgumentParser(description="DNS Analyzer Tool")
    parser.add_argument("domain", nargs='?', help="Domain to analyze")
    parser.add_argument("-s", "--server", help="DNS server to use")
    parser.add_argument("-t", "--trace", action="store_true", help="Trace DNS resolution")
    parser.add_argument("-p", "--performance", type=int, default=0, help="Run performance test (number of iterations)")
    parser.add_argument("-d", "--dnssec", action="store_true", help="Check DNSSEC support")
    parser.add_argument("-r", "--reverse", help="Reverse DNS lookup for IP address")
    parser.add_argument("--test-servers", action="store_true", help="Test with different DNS servers")
    
    args = parser.parse_args()
    
    # Check if we have either a domain or reverse IP
    if not args.domain and not args.reverse:
        parser.error("Either domain or --reverse IP address is required")
    
    # Determine if this is reverse lookup only
    reverse_only = args.reverse and not args.domain
    
    # If doing reverse lookup, use the IP as the "domain" for display purposes
    if reverse_only:
        args.domain = args.reverse
    
    analyzer = DNSAnalyzer(args.domain or "reverse-lookup", args.server)
    
    # If doing reverse lookup only, skip domain analysis
    if reverse_only:
        print(f"🔄 Reverse DNS lookup for: {args.reverse}")
        print("=" * 50)
        analyzer.reverse_dns_lookup(args.reverse)
    else:
        # Basic analysis
        analyzer.analyze_domain()
        
        # Optional tests
        if args.trace:
            analyzer.trace_resolution()
        
        if args.test_servers:
            analyzer.test_dns_servers()
        
        if args.dnssec:
            analyzer.check_dnssec()
        
        if args.reverse:
            analyzer.reverse_dns_lookup(args.reverse)
        
        if args.performance > 0:
            analyzer.performance_test(args.performance)
    
    print(f"\n✅ Analysis complete for {args.domain or args.reverse}")

if __name__ == "__main__":
    main()
