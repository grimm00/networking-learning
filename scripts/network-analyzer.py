#!/usr/bin/env python3
"""
Docker Network Analyzer Tool
Analyzes Docker networks, their configurations, and provides insights for optimization and troubleshooting.
"""

import subprocess
import argparse
import json
import re
from collections import defaultdict, Counter
import time
import sys

class DockerNetworkAnalyzer:
    def __init__(self):
        self.networks = []
        self.containers = []
        self.network_stats = {}
        
    def run_docker_command(self, command):
        """Run Docker command and return output"""
        try:
            cmd = ['docker'] + command
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
            if result.returncode != 0:
                print(f"Error running docker command: {result.stderr}")
                return None
            return result.stdout
        except subprocess.TimeoutExpired:
            print("Docker command timed out")
            return None
        except Exception as e:
            print(f"Error running docker command: {e}")
            return None
    
    def get_networks(self):
        """Get all Docker networks"""
        output = self.run_docker_command(['network', 'ls', '--format', 'json'])
        if not output:
            return []
        
        networks = []
        for line in output.strip().split('\n'):
            if line:
                try:
                    network = json.loads(line)
                    networks.append(network)
                except json.JSONDecodeError:
                    continue
        
        return networks
    
    def get_network_details(self, network_name):
        """Get detailed information about a specific network"""
        output = self.run_docker_command(['network', 'inspect', network_name])
        if not output:
            return None
        
        try:
            details = json.loads(output)
            return details[0] if details else None
        except json.JSONDecodeError:
            return None
    
    def get_containers(self):
        """Get all running containers"""
        output = self.run_docker_command(['ps', '--format', 'json'])
        if not output:
            return []
        
        containers = []
        for line in output.strip().split('\n'):
            if line:
                try:
                    container = json.loads(line)
                    containers.append(container)
                except json.JSONDecodeError:
                    continue
        
        return containers
    
    def get_container_networks(self, container_id):
        """Get network information for a specific container"""
        output = self.run_docker_command(['inspect', container_id])
        if not output:
            return None
        
        try:
            details = json.loads(output)
            if details and 'NetworkSettings' in details[0]:
                return details[0]['NetworkSettings']
            return None
        except json.JSONDecodeError:
            return None
    
    def analyze_network_types(self):
        """Analyze network types and their usage"""
        print("=== Network Types Analysis ===")
        
        networks = self.get_networks()
        if not networks:
            print("No networks found or Docker not available")
            return
        
        # Count by driver
        drivers = Counter(network['Driver'] for network in networks)
        print(f"\nNetwork Drivers:")
        for driver, count in drivers.most_common():
            print(f"  {driver}: {count} networks")
        
        # Analyze custom vs default networks
        custom_networks = [n for n in networks if not n['Name'].startswith('bridge') and n['Name'] != 'host' and n['Name'] != 'none']
        default_networks = [n for n in networks if n['Name'].startswith('bridge') or n['Name'] in ['host', 'none']]
        
        print(f"\nNetwork Categories:")
        print(f"  Custom Networks: {len(custom_networks)}")
        print(f"  Default Networks: {len(default_networks)}")
        
        # Analyze network scopes
        scopes = Counter(network.get('Scope', 'local') for network in networks)
        print(f"\nNetwork Scopes:")
        for scope, count in scopes.most_common():
            print(f"  {scope}: {count} networks")
    
    def analyze_network_configurations(self):
        """Analyze network configurations and settings"""
        print("\n=== Network Configuration Analysis ===")
        
        networks = self.get_networks()
        custom_networks = [n for n in networks if not n['Name'].startswith('bridge') and n['Name'] != 'host' and n['Name'] != 'none']
        
        if not custom_networks:
            print("No custom networks found")
            return
        
        print(f"Analyzing {len(custom_networks)} custom networks...")
        
        for network in custom_networks:
            network_name = network['Name']
            details = self.get_network_details(network_name)
            
            if not details:
                continue
            
            print(f"\nNetwork: {network_name}")
            print(f"  Driver: {details.get('Driver', 'N/A')}")
            print(f"  Scope: {details.get('Scope', 'N/A')}")
            
            # IPAM configuration
            ipam = details.get('IPAM', {})
            if ipam:
                configs = ipam.get('Config', [])
                if configs:
                    config = configs[0]
                    print(f"  Subnet: {config.get('Subnet', 'N/A')}")
                    print(f"  Gateway: {config.get('Gateway', 'N/A')}")
                    print(f"  IP Range: {config.get('IPRange', 'N/A')}")
            
            # Network options
            options = details.get('Options', {})
            if options:
                print(f"  Options:")
                for key, value in options.items():
                    print(f"    {key}: {value}")
            
            # Container count
            containers = details.get('Containers', {})
            print(f"  Active Containers: {len(containers)}")
            
            if containers:
                print(f"  Container Details:")
                for container_id, container_info in containers.items():
                    container_name = container_info.get('Name', 'Unknown')
                    container_ip = container_info.get('IPv4Address', 'N/A')
                    print(f"    {container_name}: {container_ip}")
    
    def analyze_network_security(self):
        """Analyze network security configurations"""
        print("\n=== Network Security Analysis ===")
        
        networks = self.get_networks()
        custom_networks = [n for n in networks if not n['Name'].startswith('bridge') and n['Name'] != 'host' and n['Name'] != 'none']
        
        security_issues = []
        
        for network in custom_networks:
            network_name = network['Name']
            details = self.get_network_details(network_name)
            
            if not details:
                continue
            
            print(f"\nAnalyzing {network_name}...")
            
            # Check for internal networks
            internal = details.get('Internal', False)
            print(f"  Internal Network: {internal}")
            
            # Check ICC settings
            options = details.get('Options', {})
            icc_enabled = options.get('com.docker.network.bridge.enable_icc', 'true')
            print(f"  Inter-container Communication: {icc_enabled}")
            
            # Check IP masquerading
            masq_enabled = options.get('com.docker.network.bridge.enable_ip_masquerade', 'true')
            print(f"  IP Masquerading: {masq_enabled}")
            
            # Security recommendations
            if not internal and masq_enabled == 'true':
                security_issues.append(f"{network_name}: External access enabled")
            
            if icc_enabled == 'true':
                security_issues.append(f"{network_name}: ICC enabled - consider disabling for sensitive services")
        
        if security_issues:
            print(f"\n⚠️  Security Recommendations:")
            for issue in security_issues:
                print(f"  - {issue}")
        else:
            print(f"\n✅ No obvious security issues found")
    
    def analyze_container_networks(self):
        """Analyze container network usage"""
        print("\n=== Container Network Analysis ===")
        
        containers = self.get_containers()
        if not containers:
            print("No running containers found")
            return
        
        print(f"Analyzing {len(containers)} running containers...")
        
        # Analyze network usage patterns
        network_usage = defaultdict(list)
        multi_network_containers = []
        
        for container in containers:
            container_id = container['ID']
            container_name = container['Names']
            
            network_info = self.get_container_networks(container_id)
            if not network_info:
                continue
            
            networks = network_info.get('Networks', {})
            network_names = list(networks.keys())
            
            # Track network usage
            for network_name in network_names:
                network_usage[network_name].append(container_name)
            
            # Check for multi-network containers
            if len(network_names) > 1:
                multi_network_containers.append({
                    'name': container_name,
                    'networks': network_names
                })
        
        # Display network usage
        print(f"\nNetwork Usage:")
        for network_name, containers in network_usage.items():
            print(f"  {network_name}: {len(containers)} containers")
            for container in containers:
                print(f"    - {container}")
        
        # Display multi-network containers
        if multi_network_containers:
            print(f"\nMulti-Network Containers:")
            for container in multi_network_containers:
                print(f"  {container['name']}: {', '.join(container['networks'])}")
        else:
            print(f"\nNo containers using multiple networks")
    
    def analyze_network_performance(self):
        """Analyze network performance characteristics"""
        print("\n=== Network Performance Analysis ===")
        
        networks = self.get_networks()
        custom_networks = [n for n in networks if not n['Name'].startswith('bridge') and n['Name'] != 'host' and n['Name'] != 'none']
        
        performance_metrics = {}
        
        for network in custom_networks:
            network_name = network['Name']
            details = self.get_network_details(network_name)
            
            if not details:
                continue
            
            print(f"\nAnalyzing {network_name}...")
            
            # Driver analysis
            driver = details.get('Driver', 'unknown')
            print(f"  Driver: {driver}")
            
            # Performance characteristics by driver
            if driver == 'bridge':
                print(f"  Performance: Good for single-host, moderate overhead")
            elif driver == 'host':
                print(f"  Performance: Maximum performance, no isolation")
            elif driver == 'overlay':
                print(f"  Performance: Multi-host capable, higher overhead")
            elif driver == 'macvlan':
                print(f"  Performance: Direct physical access, low overhead")
            elif driver == 'ipvlan':
                print(f"  Performance: VLAN support, moderate overhead")
            
            # MTU analysis
            options = details.get('Options', {})
            mtu = options.get('com.docker.network.driver.mtu', '1500')
            print(f"  MTU: {mtu}")
            
            if mtu != '1500':
                print(f"    Note: Custom MTU may affect performance")
            
            # Container density
            containers = details.get('Containers', {})
            container_count = len(containers)
            print(f"  Container Density: {container_count}")
            
            if container_count > 50:
                print(f"    Warning: High container density may impact performance")
            elif container_count > 20:
                print(f"    Note: Moderate container density")
            else:
                print(f"    Good: Low container density")
    
    def analyze_network_isolation(self):
        """Analyze network isolation and segmentation"""
        print("\n=== Network Isolation Analysis ===")
        
        networks = self.get_networks()
        custom_networks = [n for n in networks if not n['Name'].startswith('bridge') and n['Name'] != 'host' and n['Name'] != 'none']
        
        isolation_score = 0
        total_networks = len(custom_networks)
        
        if total_networks == 0:
            print("No custom networks to analyze")
            return
        
        for network in custom_networks:
            network_name = network['Name']
            details = self.get_network_details(network_name)
            
            if not details:
                continue
            
            print(f"\nAnalyzing {network_name}...")
            
            # Check isolation features
            internal = details.get('Internal', False)
            options = details.get('Options', {})
            icc_enabled = options.get('com.docker.network.bridge.enable_icc', 'true')
            
            isolation_features = []
            
            if internal:
                isolation_features.append("Internal network")
                isolation_score += 2
            
            if icc_enabled == 'false':
                isolation_features.append("ICC disabled")
                isolation_score += 1
            
            # Check for network segmentation patterns
            if 'db' in network_name.lower() or 'database' in network_name.lower():
                isolation_features.append("Database network")
                isolation_score += 1
            
            if 'frontend' in network_name.lower() or 'web' in network_name.lower():
                isolation_features.append("Frontend network")
                isolation_score += 1
            
            if 'backend' in network_name.lower() or 'api' in network_name.lower():
                isolation_features.append("Backend network")
                isolation_score += 1
            
            print(f"  Isolation Features: {', '.join(isolation_features) if isolation_features else 'None'}")
        
        # Overall isolation score
        max_score = total_networks * 3  # Maximum possible score
        isolation_percentage = (isolation_score / max_score) * 100 if max_score > 0 else 0
        
        print(f"\nOverall Isolation Score: {isolation_score}/{max_score} ({isolation_percentage:.1f}%)")
        
        if isolation_percentage >= 70:
            print("✅ Good network isolation")
        elif isolation_percentage >= 40:
            print("⚠️  Moderate network isolation - consider improvements")
        else:
            print("❌ Poor network isolation - significant improvements needed")
    
    def generate_recommendations(self):
        """Generate network optimization recommendations"""
        print("\n=== Network Optimization Recommendations ===")
        
        networks = self.get_networks()
        custom_networks = [n for n in networks if not n['Name'].startswith('bridge') and n['Name'] != 'host' and n['Name'] != 'none']
        
        recommendations = []
        
        # Check for default bridge usage
        default_bridge_containers = 0
        containers = self.get_containers()
        for container in containers:
            container_id = container['ID']
            network_info = self.get_container_networks(container_id)
            if network_info:
                networks = network_info.get('Networks', {})
                if 'bridge' in networks:
                    default_bridge_containers += 1
        
        if default_bridge_containers > 0:
            recommendations.append(f"Consider moving {default_bridge_containers} containers from default bridge to custom networks")
        
        # Check for network segmentation
        if len(custom_networks) < 3:
            recommendations.append("Implement network segmentation with separate networks for frontend, backend, and database tiers")
        
        # Check for security improvements
        for network in custom_networks:
            network_name = network['Name']
            details = self.get_network_details(network_name)
            if details:
                options = details.get('Options', {})
                icc_enabled = options.get('com.docker.network.bridge.enable_icc', 'true')
                if icc_enabled == 'true' and 'db' in network_name.lower():
                    recommendations.append(f"Consider disabling ICC for database network '{network_name}'")
        
        # Check for performance optimizations
        for network in custom_networks:
            network_name = network['Name']
            details = self.get_network_details(network_name)
            if details:
                driver = details.get('Driver', 'bridge')
                containers = details.get('Containers', {})
                if driver == 'bridge' and len(containers) > 20:
                    recommendations.append(f"Consider using host networking for high-performance network '{network_name}'")
        
        if recommendations:
            print("Recommendations:")
            for i, rec in enumerate(recommendations, 1):
                print(f"  {i}. {rec}")
        else:
            print("✅ No specific recommendations - network configuration looks good!")
    
    def generate_report(self, output_file=None):
        """Generate comprehensive analysis report"""
        report = {
            'timestamp': time.strftime('%Y-%m-%d %H:%M:%S'),
            'networks': self.networks,
            'containers': self.containers,
            'network_stats': self.network_stats
        }
        
        if output_file:
            with open(output_file, 'w') as f:
                json.dump(report, f, indent=2)
            print(f"\nReport saved to: {output_file}")
        else:
            print("\n=== JSON Report ===")
            print(json.dumps(report, indent=2))
    
    def run_full_analysis(self):
        """Run complete Docker network analysis"""
        print("🔍 Starting Docker Network Analysis...")
        print("=" * 60)
        
        # Check if Docker is available
        if not self.run_docker_command(['--version']):
            print("❌ Docker is not available or not running")
            return
        
        self.analyze_network_types()
        self.analyze_network_configurations()
        self.analyze_network_security()
        self.analyze_container_networks()
        self.analyze_network_performance()
        self.analyze_network_isolation()
        self.generate_recommendations()
        
        print("\n✅ Docker network analysis complete!")

def main():
    parser = argparse.ArgumentParser(description="Docker Network Analyzer Tool")
    parser.add_argument("-t", "--types", action="store_true", 
                       help="Analyze network types")
    parser.add_argument("-c", "--config", action="store_true", 
                       help="Analyze network configurations")
    parser.add_argument("-s", "--security", action="store_true", 
                       help="Analyze network security")
    parser.add_argument("-n", "--containers", action="store_true", 
                       help="Analyze container networks")
    parser.add_argument("-p", "--performance", action="store_true", 
                       help="Analyze network performance")
    parser.add_argument("-i", "--isolation", action="store_true", 
                       help="Analyze network isolation")
    parser.add_argument("-r", "--recommendations", action="store_true", 
                       help="Generate recommendations")
    parser.add_argument("-a", "--all", action="store_true", 
                       help="Run full analysis")
    parser.add_argument("-o", "--output", help="Output file for JSON report")
    
    args = parser.parse_args()
    
    analyzer = DockerNetworkAnalyzer()
    
    if args.all:
        analyzer.run_full_analysis()
    else:
        if args.types:
            analyzer.analyze_network_types()
        if args.config:
            analyzer.analyze_network_configurations()
        if args.security:
            analyzer.analyze_network_security()
        if args.containers:
            analyzer.analyze_container_networks()
        if args.performance:
            analyzer.analyze_network_performance()
        if args.isolation:
            analyzer.analyze_network_isolation()
        if args.recommendations:
            analyzer.generate_recommendations()
        
        if not any([args.types, args.config, args.security, args.containers, 
                   args.performance, args.isolation, args.recommendations]):
            print("Please specify analysis type. Use -h for help.")
            return
    
    if args.output:
        analyzer.generate_report(args.output)

if __name__ == "__main__":
    main()
