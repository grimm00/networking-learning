#!/usr/bin/env python3
"""
Network Analysis Tool
Comprehensive network connectivity and performance analysis
"""

import subprocess
import sys
import time
import json
import statistics
import os
from datetime import datetime
from typing import List, Dict, Any
import argparse


class NetworkAnalyzer:
    def __init__(self, target: str):
        self.target = target
        self.results = {
            'target': target,
            'timestamp': datetime.now().isoformat(),
            'tests': []
        }

    def run_ping_test(self, count: int = 4, packet_size: int = 56) -> Dict[str, Any]:
        """Run ping test and parse results"""
        cmd = f"ping -c {count} -s {packet_size} {self.target}"
        
        try:
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=30)
            
            if result.returncode == 0:
                # Parse ping output
                lines = result.stdout.strip().split('\n')
                times = []
                
                for line in lines:
                    if 'time=' in line:
                        # Extract time value
                        time_part = line.split('time=')[1].split(' ')[0]
                        times.append(float(time_part))
                
                if times:
                    return {
                        'test_type': 'ping',
                        'packet_size': packet_size,
                        'count': count,
                        'success': True,
                        'times': times,
                        'min_time': min(times),
                        'max_time': max(times),
                        'avg_time': statistics.mean(times),
                        'std_dev': statistics.stdev(times) if len(times) > 1 else 0,
                        'packet_loss': 0
                    }
                else:
                    return {'test_type': 'ping', 'success': False, 'error': 'No valid responses'}
            else:
                return {'test_type': 'ping', 'success': False, 'error': result.stderr}
                
        except subprocess.TimeoutExpired:
            return {'test_type': 'ping', 'success': False, 'error': 'Timeout'}
        except Exception as e:
            return {'test_type': 'ping', 'success': False, 'error': str(e)}

    def run_traceroute_test(self) -> Dict[str, Any]:
        """Run traceroute test and parse results"""
        cmd = f"traceroute {self.target}"
        
        try:
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=60)
            
            if result.returncode == 0:
                lines = result.stdout.strip().split('\n')
                hops = []
                
                for line in lines[1:]:  # Skip first line
                    if line.strip():
                        parts = line.split()
                        if len(parts) >= 3:
                            hop_num = parts[0]
                            ip_addr = parts[1].strip('()')
                            times = []
                            
                            # Extract timing information
                            for part in parts[2:]:
                                if part.replace('.', '').replace('*', '').isdigit():
                                    if part != '*':
                                        times.append(float(part))
                                    else:
                                        times.append(None)
                            
                            hops.append({
                                'hop': int(hop_num),
                                'ip': ip_addr,
                                'times': times,
                                'avg_time': statistics.mean([t for t in times if t is not None]) if any(t is not None for t in times) else None
                            })
                
                return {
                    'test_type': 'traceroute',
                    'success': True,
                    'hops': hops,
                    'total_hops': len(hops)
                }
            else:
                return {'test_type': 'traceroute', 'success': False, 'error': result.stderr}
                
        except subprocess.TimeoutExpired:
            return {'test_type': 'traceroute', 'success': False, 'error': 'Timeout'}
        except Exception as e:
            return {'test_type': 'traceroute', 'success': False, 'error': str(e)}

    def run_comprehensive_test(self):
        """Run comprehensive network analysis"""
        print(f"Starting network analysis for {self.target}")
        print("=" * 50)
        
        # Test 1: Basic ping
        print("1. Basic ping test...")
        result = self.run_ping_test(count=4, packet_size=56)
        self.results['tests'].append(result)
        self.print_ping_result(result)
        
        # Test 2: Different packet sizes
        print("\n2. Testing different packet sizes...")
        for size in [32, 64, 128, 256, 512, 1024, 1500]:
            print(f"   Testing {size} byte packets...")
            result = self.run_ping_test(count=4, packet_size=size)
            self.results['tests'].append(result)
        
        # Test 3: Traceroute
        print("\n3. Running traceroute...")
        result = self.run_traceroute_test()
        self.results['tests'].append(result)
        self.print_traceroute_result(result)
        
        # Test 4: Continuous ping (5 samples)
        print("\n4. Continuous ping test...")
        for i in range(5):
            print(f"   Sample {i+1}/5...")
            result = self.run_ping_test(count=1, packet_size=56)
            self.results['tests'].append(result)
            time.sleep(1)

    def print_ping_result(self, result: Dict[str, Any]):
        """Print formatted ping results"""
        if result['success']:
            print(f"   Success: {result['count']} packets sent")
            print(f"   Min/Avg/Max: {result['min_time']:.2f}/{result['avg_time']:.2f}/{result['max_time']:.2f} ms")
            print(f"   Std Dev: {result['std_dev']:.2f} ms")
            print(f"   Packet Loss: {result['packet_loss']}%")
        else:
            print(f"   Failed: {result['error']}")

    def print_traceroute_result(self, result: Dict[str, Any]):
        """Print formatted traceroute results"""
        if result['success']:
            print(f"   Total hops: {result['total_hops']}")
            for hop in result['hops'][:10]:  # Show first 10 hops
                times_str = " ".join([f"{t:.2f}" if t is not None else "*" for t in hop['times']])
                print(f"   {hop['hop']:2d}. {hop['ip']:15s} {times_str} ms")
            if result['total_hops'] > 10:
                print(f"   ... and {result['total_hops'] - 10} more hops")
        else:
            print(f"   Failed: {result['error']}")

    def save_results(self, filename: str = None, output_dir: str = "output"):
        """Save results to JSON file in output directory"""
        # Create output directory if it doesn't exist
        os.makedirs(output_dir, exist_ok=True)
        
        if filename is None:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"network_analysis_{self.target}_{timestamp}.json"
        
        # Ensure filename has .json extension
        if not filename.endswith('.json'):
            filename += '.json'
        
        # Create full path in output directory
        filepath = os.path.join(output_dir, filename)
        
        with open(filepath, 'w') as f:
            json.dump(self.results, f, indent=2)
        
        print(f"\nResults saved to: {filepath}")
        print(f"Output directory: {os.path.abspath(output_dir)}")

    def generate_summary(self):
        """Generate analysis summary"""
        print("\n" + "=" * 50)
        print("ANALYSIS SUMMARY")
        print("=" * 50)
        
        ping_tests = [t for t in self.results['tests'] if t['test_type'] == 'ping' and t['success']]
        traceroute_tests = [t for t in self.results['tests'] if t['test_type'] == 'traceroute' and t['success']]
        
        if ping_tests:
            all_times = []
            for test in ping_tests:
                all_times.extend(test['times'])
            
            print(f"Ping Statistics:")
            print(f"  Total samples: {len(all_times)}")
            print(f"  Min time: {min(all_times):.2f} ms")
            print(f"  Max time: {max(all_times):.2f} ms")
            print(f"  Average time: {statistics.mean(all_times):.2f} ms")
            print(f"  Std deviation: {statistics.stdev(all_times):.2f} ms")
        
        if traceroute_tests:
            test = traceroute_tests[0]
            print(f"\nTraceroute Statistics:")
            print(f"  Total hops: {test['total_hops']}")
            
            # Find hops with high latency
            high_latency_hops = [h for h in test['hops'] if h['avg_time'] and h['avg_time'] > 50]
            if high_latency_hops:
                print(f"  High latency hops (>50ms): {len(high_latency_hops)}")
                for hop in high_latency_hops[:3]:
                    print(f"    Hop {hop['hop']}: {hop['ip']} ({hop['avg_time']:.2f} ms)")


def main():
    parser = argparse.ArgumentParser(description='Network Analysis Tool')
    parser.add_argument('target', help='Target host or IP address')
    parser.add_argument('--output', '-o', help='Output file for results')
    parser.add_argument('--output-dir', '-d', default='output', help='Output directory for results (default: output)')
    
    args = parser.parse_args()
    
    analyzer = NetworkAnalyzer(args.target)
    analyzer.run_comprehensive_test()
    analyzer.generate_summary()
    analyzer.save_results(args.output, args.output_dir)


if __name__ == "__main__":
    main()
