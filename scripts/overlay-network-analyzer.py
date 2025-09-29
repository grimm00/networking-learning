#!/usr/bin/env python3
"""
Overlay Network Analyzer Tool
Analyzes Docker Swarm overlay networks, services, and provides optimization recommendations.
"""

import subprocess
import argparse
import json
import re
import time
import requests
from collections import defaultdict, Counter
import socket
import threading
from concurrent.futures import ThreadPoolExecutor

class OverlayNetworkAnalyzer:
    def __init__(self):
        self.swarm_info = {}
        self.nodes = []
        self.services = []
        self.networks = []
        self.tasks = []
        
    def run_command(self, command):
        """Run shell command and return output"""
        try:
            result = subprocess.run(command, shell=True, capture_output=True, text=True, timeout=30)
            if result.returncode != 0:
                print(f"Error running command: {result.stderr}")
                return None
            return result.stdout
        except subprocess.TimeoutExpired:
            print("Command timed out")
            return None
        except Exception as e:
            print(f"Error running command: {e}")
            return None
    
    def check_swarm_status(self):
        """Check Docker Swarm status and configuration"""
        print("=== Docker Swarm Analysis ===")
        
        # Check if Docker is available
        docker_version = self.run_command("docker --version")
        if not docker_version:
            print("❌ Docker is not available")
            return False
        
        print("✅ Docker is available")
        
        # Check if Swarm is initialized
        swarm_info = self.run_command("docker info --format '{{.Swarm.LocalNodeState}}'")
        if swarm_info and "active" in swarm_info.strip():
            print("✅ Docker Swarm is active")
            
            # Get Swarm info
            swarm_id = self.run_command("docker info --format '{{.Swarm.Cluster.ID}}'")
            if swarm_id:
                print(f"Swarm ID: {swarm_id.strip()}")
            
            swarm_nodes = self.run_command("docker info --format '{{.Swarm.Nodes}}'")
            if swarm_nodes:
                print(f"Swarm Nodes: {swarm_nodes.strip()}")
            
            return True
        else:
            print("❌ Docker Swarm is not initialized")
            return False
    
    def analyze_swarm_nodes(self):
        """Analyze Swarm cluster nodes"""
        print("\n=== Swarm Nodes Analysis ===")
        
        # Get node information
        nodes_output = self.run_command("docker node ls --format '{{.ID}} {{.Hostname}} {{.Status}} {{.Availability}} {{.ManagerStatus}}'")
        if not nodes_output:
            print("❌ Unable to get node information")
            return
        
        nodes = []
        for line in nodes_output.strip().split('\n'):
            if line.strip():
                parts = line.strip().split()
                if len(parts) >= 5:
                    node_info = {
                        'id': parts[0],
                        'hostname': parts[1],
                        'status': parts[2],
                        'availability': parts[3],
                        'manager_status': parts[4] if parts[4] != '-' else 'Worker'
                    }
                    nodes.append(node_info)
        
        print(f"Total Nodes: {len(nodes)}")
        
        # Categorize nodes
        managers = [n for n in nodes if n['manager_status'] != 'Worker']
        workers = [n for n in nodes if n['manager_status'] == 'Worker']
        active_nodes = [n for n in nodes if n['status'] == 'Ready']
        inactive_nodes = [n for n in nodes if n['status'] != 'Ready']
        
        print(f"Manager Nodes: {len(managers)}")
        print(f"Worker Nodes: {len(workers)}")
        print(f"Active Nodes: {len(active_nodes)}")
        print(f"Inactive Nodes: {len(inactive_nodes)}")
        
        # Display node details
        print("\nNode Details:")
        for node in nodes:
            status_icon = "✅" if node['status'] == 'Ready' else "❌"
            role_icon = "👑" if node['manager_status'] != 'Worker' else "🔧"
            print(f"  {status_icon} {role_icon} {node['hostname']} ({node['status']}, {node['availability']})")
        
        # Check node resources
        print("\nNode Resources:")
        for node in active_nodes:
            node_id = node['id']
            node_info = self.run_command(f"docker node inspect {node_id} --format '{{{{.Status.Addr}}}} {{{{.Description.Resources.MemoryBytes}}}} {{{{.Description.Resources.NanoCPUs}}}}'")
            if node_info:
                parts = node_info.strip().split()
                if len(parts) >= 3:
                    addr = parts[0]
                    memory = int(parts[1]) / (1024**3)  # Convert to GB
                    cpus = int(parts[2]) / 1000000000  # Convert to cores
                    print(f"  {node['hostname']}: {memory:.1f}GB RAM, {cpus:.1f} CPUs")
    
    def analyze_overlay_networks(self):
        """Analyze overlay networks"""
        print("\n=== Overlay Networks Analysis ===")
        
        # Get network information
        networks_output = self.run_command("docker network ls --format '{{.ID}} {{.Name}} {{.Driver}} {{.Scope}}'")
        if not networks_output:
            print("❌ Unable to get network information")
            return
        
        overlay_networks = []
        for line in networks_output.strip().split('\n'):
            if line.strip():
                parts = line.strip().split()
                if len(parts) >= 4 and parts[2] == 'overlay':
                    network_info = {
                        'id': parts[0],
                        'name': parts[1],
                        'driver': parts[2],
                        'scope': parts[3]
                    }
                    overlay_networks.append(network_info)
        
        print(f"Overlay Networks: {len(overlay_networks)}")
        
        # Analyze each overlay network
        for network in overlay_networks:
            print(f"\nNetwork: {network['name']}")
            
            # Get detailed network information
            network_details = self.run_command(f"docker network inspect {network['id']}")
            if network_details:
                try:
                    network_data = json.loads(network_details)[0]
                    
                    # Network configuration
                    print(f"  ID: {network_data.get('Id', 'N/A')[:12]}...")
                    print(f"  Driver: {network_data.get('Driver', 'N/A')}")
                    print(f"  Scope: {network_data.get('Scope', 'N/A')}")
                    
                    # Network options
                    options = network_data.get('Options', {})
                    if options:
                        print(f"  Options:")
                        for key, value in options.items():
                            print(f"    {key}: {value}")
                    
                    # IP configuration
                    ipam = network_data.get('IPAM', {})
                    if ipam:
                        configs = ipam.get('Config', [])
                        if configs:
                            config = configs[0]
                            subnet = config.get('Subnet', 'N/A')
                            gateway = config.get('Gateway', 'N/A')
                            print(f"  Subnet: {subnet}")
                            print(f"  Gateway: {gateway}")
                    
                    # Connected containers
                    containers = network_data.get('Containers', {})
                    print(f"  Connected Containers: {len(containers)}")
                    
                    # Services using this network
                    services = self.run_command(f"docker service ls --filter network={network['name']} --format '{{.Name}}'")
                    if services:
                        service_list = [s.strip() for s in services.strip().split('\n') if s.strip()]
                        print(f"  Services: {', '.join(service_list) if service_list else 'None'}")
                    
                except json.JSONDecodeError:
                    print("  ❌ Unable to parse network details")
    
    def analyze_services(self):
        """Analyze Swarm services"""
        print("\n=== Swarm Services Analysis ===")
        
        # Get service information
        services_output = self.run_command("docker service ls --format '{{.ID}} {{.Name}} {{.Mode}} {{.Replicas}} {{.Image}}'")
        if not services_output:
            print("❌ Unable to get service information")
            return
        
        services = []
        for line in services_output.strip().split('\n'):
            if line.strip():
                parts = line.strip().split()
                if len(parts) >= 5:
                    service_info = {
                        'id': parts[0],
                        'name': parts[1],
                        'mode': parts[2],
                        'replicas': parts[3],
                        'image': parts[4]
                    }
                    services.append(service_info)
        
        print(f"Total Services: {len(services)}")
        
        # Analyze each service
        for service in services:
            print(f"\nService: {service['name']}")
            print(f"  Mode: {service['mode']}")
            print(f"  Replicas: {service['replicas']}")
            print(f"  Image: {service['image']}")
            
            # Get service details
            service_details = self.run_command(f"docker service inspect {service['id']}")
            if service_details:
                try:
                    service_data = json.loads(service_details)[0]
                    
                    # Service configuration
                    spec = service_data.get('Spec', {})
                    task_template = spec.get('TaskTemplate', {})
                    container_spec = task_template.get('ContainerSpec', {})
                    
                    # Networks
                    networks = container_spec.get('Networks', [])
                    if networks:
                        network_names = [n.get('Target', 'N/A') for n in networks]
                        print(f"  Networks: {', '.join(network_names)}")
                    
                    # Ports
                    ports = spec.get('EndpointSpec', {}).get('Ports', [])
                    if ports:
                        port_info = []
                        for port in ports:
                            published_port = port.get('PublishedPort', 'N/A')
                            target_port = port.get('TargetPort', 'N/A')
                            protocol = port.get('Protocol', 'tcp')
                            port_info.append(f"{published_port}:{target_port}/{protocol}")
                        print(f"  Ports: {', '.join(port_info)}")
                    
                    # Constraints
                    constraints = task_template.get('Placement', {}).get('Constraints', [])
                    if constraints:
                        print(f"  Constraints: {', '.join(constraints)}")
                    
                    # Update configuration
                    update_config = spec.get('UpdateConfig', {})
                    if update_config:
                        parallelism = update_config.get('Parallelism', 'N/A')
                        delay = update_config.get('Delay', 'N/A')
                        print(f"  Update Config: Parallelism={parallelism}, Delay={delay}")
                    
                    # Restart policy
                    restart_policy = task_template.get('RestartPolicy', {})
                    if restart_policy:
                        condition = restart_policy.get('Condition', 'N/A')
                        delay = restart_policy.get('Delay', 'N/A')
                        print(f"  Restart Policy: {condition}, Delay={delay}")
                    
                except json.JSONDecodeError:
                    print("  ❌ Unable to parse service details")
            
            # Get service tasks
            tasks_output = self.run_command(f"docker service ps {service['name']} --format '{{.ID}} {{.Name}} {{.Node}} {{.DesiredState}} {{.CurrentState}}'")
            if tasks_output:
                tasks = []
                for line in tasks_output.strip().split('\n'):
                    if line.strip():
                        parts = line.strip().split()
                        if len(parts) >= 5:
                            task_info = {
                                'id': parts[0],
                                'name': parts[1],
                                'node': parts[2],
                                'desired_state': parts[3],
                                'current_state': parts[4]
                            }
                            tasks.append(task_info)
                
                running_tasks = [t for t in tasks if t['current_state'] == 'Running']
                failed_tasks = [t for t in tasks if t['current_state'] == 'Failed']
                
                print(f"  Tasks: {len(running_tasks)} running, {len(failed_tasks)} failed")
                
                if failed_tasks:
                    print("  Failed Tasks:")
                    for task in failed_tasks:
                        print(f"    ❌ {task['name']} on {task['node']}")
    
    def analyze_service_discovery(self):
        """Analyze service discovery configuration"""
        print("\n=== Service Discovery Analysis ===")
        
        # Get all services
        services_output = self.run_command("docker service ls --format '{{.Name}}'")
        if not services_output:
            print("❌ Unable to get services for discovery analysis")
            return
        
        services = [s.strip() for s in services_output.strip().split('\n') if s.strip()]
        
        print(f"Services Available for Discovery: {len(services)}")
        
        # Test service discovery
        for service in services:
            print(f"\nService: {service}")
            
            # Check if service is accessible via DNS
            dns_test = self.run_command(f"nslookup {service} 2>/dev/null | grep -A 1 'Name:'")
            if dns_test:
                print(f"  ✅ DNS Resolution: Available")
            else:
                print(f"  ❌ DNS Resolution: Not available")
            
            # Check service endpoints
            endpoints = self.run_command(f"docker service inspect {service} --format '{{{{.Endpoint}}}}'")
            if endpoints:
                print(f"  Endpoints: {endpoints.strip()}")
            
            # Check service networks
            networks = self.run_command(f"docker service inspect {service} --format '{{{{range .Spec.TaskTemplate.ContainerSpec.Networks}}}}{{{{.Target}}}} {{end}}'")
            if networks:
                network_list = [n.strip() for n in networks.strip().split() if n.strip()]
                print(f"  Networks: {', '.join(network_list)}")
    
    def analyze_load_balancing(self):
        """Analyze load balancing configuration"""
        print("\n=== Load Balancing Analysis ===")
        
        # Get services with published ports
        services_output = self.run_command("docker service ls --format '{{.Name}}'")
        if not services_output:
            print("❌ Unable to get services for load balancing analysis")
            return
        
        services = [s.strip() for s in services_output.strip().split('\n') if s.strip()]
        
        load_balanced_services = []
        
        for service in services:
            # Check if service has published ports
            ports = self.run_command(f"docker service inspect {service} --format '{{{{.Spec.EndpointSpec.Ports}}}}'")
            if ports and ports.strip() != '[]':
                load_balanced_services.append(service)
        
        print(f"Load Balanced Services: {len(load_balanced_services)}")
        
        # Analyze each load balanced service
        for service in load_balanced_services:
            print(f"\nService: {service}")
            
            # Get port configuration
            ports = self.run_command(f"docker service inspect {service} --format '{{{{range .Spec.EndpointSpec.Ports}}}}{{{{.PublishedPort}}}}:{{{{.TargetPort}}}}/{{{{.Protocol}}}} {{end}}'")
            if ports:
                port_list = [p.strip() for p in ports.strip().split() if p.strip()]
                print(f"  Published Ports: {', '.join(port_list)}")
            
            # Get replica count
            replicas = self.run_command(f"docker service inspect {service} --format '{{{{.Spec.Mode.Replicated.Replicas}}}}'")
            if replicas:
                print(f"  Replicas: {replicas.strip()}")
            
            # Get service tasks
            tasks = self.run_command(f"docker service ps {service} --format '{{.Node}} {{.CurrentState}}'")
            if tasks:
                running_tasks = [t for t in tasks.strip().split('\n') if 'Running' in t]
                print(f"  Running Tasks: {len(running_tasks)}")
                
                # Show task distribution
                node_distribution = defaultdict(int)
                for task in running_tasks:
                    parts = task.strip().split()
                    if len(parts) >= 2:
                        node = parts[0]
                        node_distribution[node] += 1
                
                print(f"  Task Distribution:")
                for node, count in node_distribution.items():
                    print(f"    {node}: {count} tasks")
    
    def analyze_network_security(self):
        """Analyze network security configuration"""
        print("\n=== Network Security Analysis ===")
        
        # Get overlay networks
        networks_output = self.run_command("docker network ls --filter driver=overlay --format '{{.Name}}'")
        if not networks_output:
            print("❌ No overlay networks found")
            return
        
        networks = [n.strip() for n in networks_output.strip().split('\n') if n.strip()]
        
        print(f"Overlay Networks: {len(networks)}")
        
        encrypted_networks = 0
        unencrypted_networks = 0
        
        for network in networks:
            print(f"\nNetwork: {network}")
            
            # Check encryption
            network_details = self.run_command(f"docker network inspect {network}")
            if network_details:
                try:
                    network_data = json.loads(network_details)[0]
                    options = network_data.get('Options', {})
                    
                    if options.get('encrypted') == 'true':
                        print(f"  ✅ Encryption: Enabled")
                        encrypted_networks += 1
                    else:
                        print(f"  ❌ Encryption: Disabled")
                        unencrypted_networks += 1
                    
                    # Check other security options
                    if 'com.docker.network.driver.mtu' in options:
                        print(f"  MTU: {options['com.docker.network.driver.mtu']}")
                    
                    if 'com.docker.network.bridge.enable_icc' in options:
                        print(f"  Inter-container Communication: {options['com.docker.network.bridge.enable_icc']}")
                    
                except json.JSONDecodeError:
                    print("  ❌ Unable to parse network details")
        
        print(f"\nSecurity Summary:")
        print(f"  Encrypted Networks: {encrypted_networks}")
        print(f"  Unencrypted Networks: {unencrypted_networks}")
        
        if unencrypted_networks > 0:
            print(f"  ⚠️  Security Risk: {unencrypted_networks} networks without encryption")
        else:
            print(f"  ✅ All networks are encrypted")
    
    def analyze_performance(self):
        """Analyze overlay network performance"""
        print("\n=== Performance Analysis ===")
        
        # Check system resources
        print("System Resources:")
        
        # Memory usage
        memory_info = self.run_command("free -h | grep Mem")
        if memory_info:
            print(f"  Memory: {memory_info.strip()}")
        
        # CPU usage
        cpu_info = self.run_command("top -bn1 | grep 'Cpu(s)'")
        if cpu_info:
            print(f"  CPU: {cpu_info.strip()}")
        
        # Disk usage
        disk_info = self.run_command("df -h | grep -E '(/$|/var)'")
        if disk_info:
            print(f"  Disk: {disk_info.strip()}")
        
        # Network interfaces
        print("\nNetwork Interfaces:")
        interfaces = self.run_command("ip addr show | grep -E '^[0-9]+:|inet '")
        if interfaces:
            for line in interfaces.strip().split('\n'):
                if line.strip():
                    print(f"  {line.strip()}")
        
        # Docker daemon performance
        print("\nDocker Daemon Performance:")
        docker_info = self.run_command("docker system df")
        if docker_info:
            print(docker_info)
        
        # Swarm performance
        print("\nSwarm Performance:")
        swarm_info = self.run_command("docker info --format '{{.Swarm.Nodes}} {{.Swarm.Managers}}'")
        if swarm_info:
            print(f"  Swarm Info: {swarm_info.strip()}")
    
    def generate_recommendations(self):
        """Generate overlay network optimization recommendations"""
        print(f"\n=== Overlay Network Optimization Recommendations ===")
        
        recommendations = []
        
        # Check Swarm status
        if not self.check_swarm_status():
            recommendations.append("Initialize Docker Swarm for overlay networking")
        
        # Check overlay networks
        networks_output = self.run_command("docker network ls --filter driver=overlay --format '{{.Name}}'")
        if networks_output:
            networks = [n.strip() for n in networks_output.strip().split('\n') if n.strip()]
            if len(networks) == 0:
                recommendations.append("Create overlay networks for multi-host communication")
        
        # Check network encryption
        if networks_output:
            encrypted_count = 0
            total_count = 0
            for network in networks:
                total_count += 1
                network_details = self.run_command(f"docker network inspect {network}")
                if network_details:
                    try:
                        network_data = json.loads(network_details)[0]
                        options = network_data.get('Options', {})
                        if options.get('encrypted') == 'true':
                            encrypted_count += 1
                    except json.JSONDecodeError:
                        pass
            
            if total_count > 0 and encrypted_count < total_count:
                recommendations.append(f"Enable encryption on {total_count - encrypted_count} unencrypted overlay networks")
        
        # Check service scaling
        services_output = self.run_command("docker service ls --format '{{.Name}} {{.Replicas}}'")
        if services_output:
            for line in services_output.strip().split('\n'):
                if line.strip():
                    parts = line.strip().split()
                    if len(parts) >= 2:
                        service_name = parts[0]
                        replicas = parts[1]
                        if replicas == '0/0':
                            recommendations.append(f"Service '{service_name}' has no running replicas")
                        elif replicas.startswith('0/'):
                            recommendations.append(f"Service '{service_name}' has failed replicas")
        
        # Check node availability
        nodes_output = self.run_command("docker node ls --format '{{.Status}}'")
        if nodes_output:
            inactive_nodes = [line.strip() for line in nodes_output.strip().split('\n') if line.strip() and line.strip() != 'Ready']
            if inactive_nodes:
                recommendations.append(f"{len(inactive_nodes)} nodes are not ready")
        
        if recommendations:
            print("Recommendations:")
            for i, rec in enumerate(recommendations, 1):
                print(f"  {i}. {rec}")
        else:
            print("✅ No specific recommendations - overlay network setup looks good!")
    
    def generate_report(self, output_file=None):
        """Generate comprehensive overlay network analysis report"""
        report = {
            'timestamp': time.strftime('%Y-%m-%d %H:%M:%S'),
            'swarm_info': self.swarm_info,
            'nodes': self.nodes,
            'services': self.services,
            'networks': self.networks,
            'tasks': self.tasks
        }
        
        if output_file:
            with open(output_file, 'w') as f:
                json.dump(report, f, indent=2)
            print(f"\nReport saved to: {output_file}")
        else:
            print("\n=== JSON Report ===")
            print(json.dumps(report, indent=2))
    
    def run_full_analysis(self):
        """Run complete overlay network analysis"""
        print("🔍 Starting Overlay Network Analysis...")
        print("=" * 60)
        
        if self.check_swarm_status():
            self.analyze_swarm_nodes()
            self.analyze_overlay_networks()
            self.analyze_services()
            self.analyze_service_discovery()
            self.analyze_load_balancing()
            self.analyze_network_security()
            self.analyze_performance()
        else:
            print("❌ Docker Swarm not available - cannot analyze overlay networks")
        
        self.generate_recommendations()
        
        print("\n✅ Overlay network analysis complete!")

def main():
    parser = argparse.ArgumentParser(description="Overlay Network Analyzer Tool")
    parser.add_argument("-s", "--swarm", action="store_true", 
                       help="Analyze Docker Swarm status")
    parser.add_argument("-n", "--nodes", action="store_true", 
                       help="Analyze Swarm nodes")
    parser.add_argument("-net", "--networks", action="store_true", 
                       help="Analyze overlay networks")
    parser.add_argument("-svc", "--services", action="store_true", 
                       help="Analyze Swarm services")
    parser.add_argument("-sd", "--service-discovery", action="store_true", 
                       help="Analyze service discovery")
    parser.add_argument("-lb", "--load-balancing", action="store_true", 
                       help="Analyze load balancing")
    parser.add_argument("-sec", "--security", action="store_true", 
                       help="Analyze network security")
    parser.add_argument("-p", "--performance", action="store_true", 
                       help="Analyze performance")
    parser.add_argument("-r", "--recommendations", action="store_true", 
                       help="Generate recommendations")
    parser.add_argument("--all", action="store_true", 
                       help="Run full analysis")
    parser.add_argument("-o", "--output", help="Output file for JSON report")
    
    args = parser.parse_args()
    
    analyzer = OverlayNetworkAnalyzer()
    
    if args.all:
        analyzer.run_full_analysis()
    else:
        if args.swarm:
            analyzer.check_swarm_status()
        if args.nodes:
            analyzer.analyze_swarm_nodes()
        if args.networks:
            analyzer.analyze_overlay_networks()
        if args.services:
            analyzer.analyze_services()
        if args.service_discovery:
            analyzer.analyze_service_discovery()
        if args.load_balancing:
            analyzer.analyze_load_balancing()
        if args.security:
            analyzer.analyze_network_security()
        if args.performance:
            analyzer.analyze_performance()
        if args.recommendations:
            analyzer.generate_recommendations()
        
        if not any([args.swarm, args.nodes, args.networks, args.services, 
                   args.service_discovery, args.load_balancing, args.security, 
                   args.performance, args.recommendations]):
            print("Please specify analysis type. Use -h for help.")
            return
    
    if args.output:
        analyzer.generate_report(args.output)

if __name__ == "__main__":
    main()
