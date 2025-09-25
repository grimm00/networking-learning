#!/usr/bin/env python3
"""
HTTP Methods Testing Tool
Advanced tool for testing specific HTTP methods with custom data.
"""

import requests
import json
import argparse
import sys
from urllib.parse import urlparse

class HTTPMethodsTester:
    def __init__(self, url, timeout=10):
        self.url = url
        self.timeout = timeout
        self.session = requests.Session()
        
    def test_method(self, method, data=None, headers=None, params=None):
        """Test a specific HTTP method"""
        print(f"\n🔧 Testing {method} method:")
        print(f"  URL: {self.url}")
        
        try:
            if data:
                print(f"  Data: {data}")
            if headers:
                print(f"  Headers: {headers}")
            if params:
                print(f"  Params: {params}")
            
            # Handle JSON data properly
            json_data = None
            if data and isinstance(data, dict):
                json_data = data
                data = None
            
            response = self.session.request(
                method, 
                self.url, 
                data=data,
                json=json_data,
                headers=headers,
                params=params,
                timeout=self.timeout
            )
            
            status = "✅" if response.status_code < 400 else "❌"
            print(f"  {status} Status: {response.status_code} {response.reason}")
            print(f"  Response Headers: {dict(response.headers)}")
            
            if response.text:
                print(f"  Response Body: {response.text[:200]}{'...' if len(response.text) > 200 else ''}")
                
            return response
            
        except Exception as e:
            print(f"  ❌ Error: {e}")
            return None
    
    def test_custom_methods(self):
        """Test various HTTP methods with different scenarios"""
        
        # GET request
        self.test_method('GET')
        
        # POST with JSON data
        json_data = {"test": "data", "method": "POST"}
        self.test_method('POST', 
                        data=json.dumps(json_data),
                        headers={'Content-Type': 'application/json'})
        
        # POST with form data
        form_data = {"username": "test", "password": "test123"}
        self.test_method('POST', data=form_data)
        
        # PUT with JSON data
        put_data = {"id": 1, "name": "updated", "method": "PUT"}
        self.test_method('PUT',
                        data=json.dumps(put_data),
                        headers={'Content-Type': 'application/json'})
        
        # DELETE request
        self.test_method('DELETE')
        
        # HEAD request
        self.test_method('HEAD')
        
        # OPTIONS request
        self.test_method('OPTIONS')
        
        # PATCH request
        patch_data = {"status": "updated", "method": "PATCH"}
        self.test_method('PATCH',
                        data=json.dumps(patch_data),
                        headers={'Content-Type': 'application/json'})
        
        # Custom method (if server supports it)
        self.test_method('TRACE')
        
        # GET with query parameters
        self.test_method('GET', params={"param1": "value1", "param2": "value2"})

def main():
    parser = argparse.ArgumentParser(description='HTTP Methods Testing Tool')
    parser.add_argument('url', help='URL to test')
    parser.add_argument('-t', '--timeout', type=int, default=10, help='Request timeout')
    parser.add_argument('-m', '--method', help='Test specific method only')
    parser.add_argument('-d', '--data', help='Data to send (JSON string)')
    parser.add_argument('-H', '--header', action='append', help='Add custom header (key:value)')
    parser.add_argument('-p', '--params', help='Query parameters (JSON string)')
    
    args = parser.parse_args()
    
    print(f"🚀 HTTP Methods Testing Tool")
    print(f"Target: {args.url}")
    print("=" * 60)
    
    tester = HTTPMethodsTester(args.url, args.timeout)
    
    if args.method:
        # Test specific method
        data = None
        if args.data:
            try:
                data = json.loads(args.data)
            except json.JSONDecodeError:
                # If not valid JSON, treat as plain text
                data = args.data
        
        headers = {}
        if args.header:
            for header in args.header:
                key, value = header.split(':', 1)
                headers[key.strip()] = value.strip()
        
        params = None
        if args.params:
            try:
                params = json.loads(args.params)
            except json.JSONDecodeError:
                # If not valid JSON, treat as plain text
                params = args.params
        
        tester.test_method(args.method, data, headers, params)
    else:
        # Test all methods
        tester.test_custom_methods()
    
    print(f"\n✅ Testing complete!")

if __name__ == "__main__":
    main()
