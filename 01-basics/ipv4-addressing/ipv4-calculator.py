#!/usr/bin/env python3
"""
IPv4 Address Calculator
Comprehensive tool for IPv4 addressing, subnetting, and network calculations
"""

import ipaddress
import sys
import argparse
from typing import List, Dict, Any, Tuple
import json


class IPv4Calculator:
    def __init__(self):
        self.private_ranges = [
            ipaddress.IPv4Network('10.0.0.0/8'),
            ipaddress.IPv4Network('172.16.0.0/12'),
            ipaddress.IPv4Network('192.168.0.0/16')
        ]

    def analyze_address(self, address: str) -> Dict[str, Any]:
        """Analyze an IPv4 address and provide detailed information"""
        try:
            # Parse the address
            if '/' in address:
                network = ipaddress.IPv4Network(address, strict=False)
                ip = network.network_address
                prefix_len = network.prefixlen
            else:
                ip = ipaddress.IPv4Address(address)
                prefix_len = 32
                network = ipaddress.IPv4Network(f"{ip}/32")
            
            # Basic information
            info = {
                'address': str(ip),
                'prefix_length': prefix_len,
                'subnet_mask': str(network.netmask),
                'wildcard_mask': str(network.hostmask),
                'network_address': str(network.network_address),
                'broadcast_address': str(network.broadcast_address),
                'first_host': str(network.network_address + 1) if network.num_addresses > 2 else 'N/A',
                'last_host': str(network.broadcast_address - 1) if network.num_addresses > 2 else 'N/A',
                'total_addresses': network.num_addresses,
                'usable_hosts': max(0, network.num_addresses - 2),
                'is_private': self.is_private(ip),
                'is_loopback': ip.is_loopback,
                'is_link_local': ip.is_link_local,
                'is_multicast': ip.is_multicast,
                'is_reserved': ip.is_reserved,
                'class': self.get_address_class(ip),
                'binary': self.to_binary(ip),
                'hex': self.to_hex(ip)
            }
            
            return info
            
        except Exception as e:
            return {'error': str(e)}

    def is_private(self, ip: ipaddress.IPv4Address) -> bool:
        """Check if an IP address is private"""
        for private_net in self.private_ranges:
            if ip in private_net:
                return True
        return False

    def get_address_class(self, ip: ipaddress.IPv4Address) -> str:
        """Determine the IP address class"""
        first_octet = int(ip) >> 24
        
        if 1 <= first_octet <= 126:
            return 'A'
        elif 128 <= first_octet <= 191:
            return 'B'
        elif 192 <= first_octet <= 223:
            return 'C'
        elif 224 <= first_octet <= 239:
            return 'D (Multicast)'
        elif 240 <= first_octet <= 255:
            return 'E (Reserved)'
        else:
            return 'Unknown'

    def to_binary(self, ip: ipaddress.IPv4Address) -> str:
        """Convert IP address to binary representation"""
        return '.'.join(format(int(octet), '08b') for octet in ip.packed)

    def to_hex(self, ip: ipaddress.IPv4Address) -> str:
        """Convert IP address to hexadecimal representation"""
        return hex(int(ip))[2:].upper().zfill(8)

    def subnet_calculator(self, network: str, num_subnets: int = None, hosts_per_subnet: int = None) -> List[Dict[str, Any]]:
        """Calculate subnets based on requirements"""
        try:
            base_network = ipaddress.IPv4Network(network, strict=False)
            subnets = []
            
            if num_subnets:
                # Calculate based on number of subnets
                import math
                bits_needed = math.ceil(math.log2(num_subnets))
                new_prefix = base_network.prefixlen + bits_needed
                
                if new_prefix > 32:
                    raise ValueError("Too many subnets requested")
                
                new_network = ipaddress.IPv4Network(f"{base_network.network_address}/{new_prefix}")
                
                for i in range(num_subnets):
                    subnet = ipaddress.IPv4Network(f"{new_network.network_address + (i * new_network.num_addresses)}/{new_prefix}")
                    subnets.append(self.analyze_address(str(subnet)))
            
            elif hosts_per_subnet:
                # Calculate based on hosts per subnet
                import math
                bits_needed = math.ceil(math.log2(hosts_per_subnet + 2))  # +2 for network and broadcast
                new_prefix = 32 - bits_needed
                
                if new_prefix < base_network.prefixlen:
                    raise ValueError("Not enough address space for requested hosts")
                
                # Calculate how many subnets we can create
                subnet_size = 2 ** bits_needed
                num_subnets = base_network.num_addresses // subnet_size
                
                for i in range(num_subnets):
                    subnet = ipaddress.IPv4Network(f"{base_network.network_address + (i * subnet_size)}/{new_prefix}")
                    subnets.append(self.analyze_address(str(subnet)))
            
            return subnets
            
        except Exception as e:
            return [{'error': str(e)}]

    def vlsm_calculator(self, network: str, requirements: List[int]) -> List[Dict[str, Any]]:
        """Calculate VLSM subnets for different host requirements"""
        try:
            base_network = ipaddress.IPv4Network(network, strict=False)
            subnets = []
            current_address = base_network.network_address
            
            # Sort requirements in descending order for VLSM
            sorted_requirements = sorted(requirements, reverse=True)
            
            for hosts_needed in sorted_requirements:
                import math
                bits_needed = math.ceil(math.log2(hosts_needed + 2))
                prefix_len = 32 - bits_needed
                
                # Find the next available subnet
                while True:
                    try:
                        subnet = ipaddress.IPv4Network(f"{current_address}/{prefix_len}")
                        if subnet.network_address in base_network and subnet.broadcast_address in base_network:
                            break
                        current_address += 2 ** bits_needed
                    except:
                        current_address += 2 ** bits_needed
                
                subnet_info = self.analyze_address(str(subnet))
                subnet_info['required_hosts'] = hosts_needed
                subnets.append(subnet_info)
                
                current_address = subnet.broadcast_address + 1
            
            return subnets
            
        except Exception as e:
            return [{'error': str(e)}]

    def supernet_calculator(self, networks: List[str]) -> Dict[str, Any]:
        """Calculate supernet for multiple networks"""
        try:
            ip_networks = [ipaddress.IPv4Network(net) for net in networks]
            
            # Find the smallest network that contains all networks
            min_addr = min(net.network_address for net in ip_networks)
            max_addr = max(net.broadcast_address for net in ip_networks)
            
            # Calculate the prefix length needed
            import math
            addr_range = int(max_addr) - int(min_addr) + 1
            bits_needed = math.ceil(math.log2(addr_range))
            prefix_len = 32 - bits_needed
            
            supernet = ipaddress.IPv4Network(f"{min_addr}/{prefix_len}")
            
            return {
                'supernet': str(supernet),
                'network_address': str(supernet.network_address),
                'broadcast_address': str(supernet.broadcast_address),
                'prefix_length': supernet.prefixlen,
                'subnet_mask': str(supernet.netmask),
                'total_addresses': supernet.num_addresses,
                'covered_networks': [str(net) for net in ip_networks]
            }
            
        except Exception as e:
            return {'error': str(e)}

    def display_analysis(self, info: Dict[str, Any]):
        """Display address analysis in a formatted way"""
        if 'error' in info:
            print(f"Error: {info['error']}")
            return
        
        print("=" * 60)
        print("IPv4 ADDRESS ANALYSIS")
        print("=" * 60)
        print(f"Address: {info['address']}")
        print(f"Prefix Length: /{info['prefix_length']}")
        print(f"Subnet Mask: {info['subnet_mask']}")
        print(f"Wildcard Mask: {info['wildcard_mask']}")
        print(f"Network Address: {info['network_address']}")
        print(f"Broadcast Address: {info['broadcast_address']}")
        print(f"First Host: {info['first_host']}")
        print(f"Last Host: {info['last_host']}")
        print(f"Total Addresses: {info['total_addresses']}")
        print(f"Usable Hosts: {info['usable_hosts']}")
        print()
        print("Address Properties:")
        print(f"  Class: {info['class']}")
        print(f"  Private: {'Yes' if info['is_private'] else 'No'}")
        print(f"  Loopback: {'Yes' if info['is_loopback'] else 'No'}")
        print(f"  Link Local: {'Yes' if info['is_link_local'] else 'No'}")
        print(f"  Multicast: {'Yes' if info['is_multicast'] else 'No'}")
        print(f"  Reserved: {'Yes' if info['is_reserved'] else 'No'}")
        print()
        print("Binary Representation:")
        print(f"  Binary: {info['binary']}")
        print(f"  Hex: 0x{info['hex']}")

    def display_subnets(self, subnets: List[Dict[str, Any]]):
        """Display subnet information in a formatted way"""
        if not subnets or 'error' in subnets[0]:
            print(f"Error: {subnets[0]['error'] if subnets else 'No subnets calculated'}")
            return
        
        print("=" * 80)
        print("SUBNET CALCULATION RESULTS")
        print("=" * 80)
        print(f"{'Subnet':<20} {'Network':<15} {'Broadcast':<15} {'Hosts':<8} {'Range'}")
        print("-" * 80)
        
        for i, subnet in enumerate(subnets, 1):
            if 'error' in subnet:
                print(f"Subnet {i}: Error - {subnet['error']}")
                continue
            
            range_str = f"{subnet['first_host']} - {subnet['last_host']}" if subnet['usable_hosts'] > 0 else "N/A"
            print(f"Subnet {i:<15} {subnet['network_address']:<15} {subnet['broadcast_address']:<15} {subnet['usable_hosts']:<8} {range_str}")

    def interactive_mode(self):
        """Run interactive mode for the calculator"""
        print("=" * 60)
        print("IPv4 CALCULATOR - INTERACTIVE MODE")
        print("=" * 60)
        
        while True:
            print("\nOptions:")
            print("1. Analyze an IP address")
            print("2. Calculate subnets (by number)")
            print("3. Calculate subnets (by hosts)")
            print("4. VLSM calculation")
            print("5. Supernet calculation")
            print("6. Exit")
            
            choice = input("\nEnter your choice (1-6): ").strip()
            
            if choice == '1':
                address = input("Enter IP address (with or without CIDR): ").strip()
                info = self.analyze_address(address)
                self.display_analysis(info)
            
            elif choice == '2':
                network = input("Enter network (e.g., 192.168.1.0/24): ").strip()
                num_subnets = int(input("Enter number of subnets needed: "))
                subnets = self.subnet_calculator(network, num_subnets=num_subnets)
                self.display_subnets(subnets)
            
            elif choice == '3':
                network = input("Enter network (e.g., 192.168.1.0/24): ").strip()
                hosts = int(input("Enter hosts per subnet needed: "))
                subnets = self.subnet_calculator(network, hosts_per_subnet=hosts)
                self.display_subnets(subnets)
            
            elif choice == '4':
                network = input("Enter network (e.g., 192.168.1.0/24): ").strip()
                print("Enter host requirements (one per line, empty line to finish):")
                requirements = []
                while True:
                    req = input("Hosts needed: ").strip()
                    if not req:
                        break
                    requirements.append(int(req))
                
                if requirements:
                    subnets = self.vlsm_calculator(network, requirements)
                    self.display_subnets(subnets)
            
            elif choice == '5':
                print("Enter networks to supernet (one per line, empty line to finish):")
                networks = []
                while True:
                    net = input("Network: ").strip()
                    if not net:
                        break
                    networks.append(net)
                
                if networks:
                    result = self.supernet_calculator(networks)
                    if 'error' in result:
                        print(f"Error: {result['error']}")
                    else:
                        print("\nSupernet Result:")
                        print(f"Supernet: {result['supernet']}")
                        print(f"Network Address: {result['network_address']}")
                        print(f"Broadcast Address: {result['broadcast_address']}")
                        print(f"Prefix Length: /{result['prefix_length']}")
                        print(f"Subnet Mask: {result['subnet_mask']}")
                        print(f"Total Addresses: {result['total_addresses']}")
            
            elif choice == '6':
                print("Goodbye!")
                break
            
            else:
                print("Invalid choice. Please enter 1-6.")


def main():
    parser = argparse.ArgumentParser(description='IPv4 Address Calculator')
    parser.add_argument('address', nargs='?', help='IP address to analyze')
    parser.add_argument('--subnets', type=int, help='Number of subnets needed')
    parser.add_argument('--hosts', type=int, help='Hosts per subnet needed')
    parser.add_argument('--vlsm', nargs='+', type=int, help='VLSM host requirements')
    parser.add_argument('--supernet', nargs='+', help='Networks to supernet')
    parser.add_argument('--interactive', '-i', action='store_true', help='Run in interactive mode')
    parser.add_argument('--json', action='store_true', help='Output in JSON format')
    
    args = parser.parse_args()
    
    calculator = IPv4Calculator()
    
    if args.interactive:
        calculator.interactive_mode()
    elif args.address:
        if args.subnets:
            result = calculator.subnet_calculator(args.address, num_subnets=args.subnets)
            if args.json:
                print(json.dumps(result, indent=2))
            else:
                calculator.display_subnets(result)
        elif args.hosts:
            result = calculator.subnet_calculator(args.address, hosts_per_subnet=args.hosts)
            if args.json:
                print(json.dumps(result, indent=2))
            else:
                calculator.display_subnets(result)
        elif args.vlsm:
            result = calculator.vlsm_calculator(args.address, args.vlsm)
            if args.json:
                print(json.dumps(result, indent=2))
            else:
                calculator.display_subnets(result)
        else:
            result = calculator.analyze_address(args.address)
            if args.json:
                print(json.dumps(result, indent=2))
            else:
                calculator.display_analysis(result)
    elif args.supernet:
        result = calculator.supernet_calculator(args.supernet)
        if args.json:
            print(json.dumps(result, indent=2))
        else:
            print("\nSupernet Result:")
            print(f"Supernet: {result['supernet']}")
            print(f"Network Address: {result['network_address']}")
            print(f"Broadcast Address: {result['broadcast_address']}")
            print(f"Prefix Length: /{result['prefix_length']}")
            print(f"Subnet Mask: {result['subnet_mask']}")
            print(f"Total Addresses: {result['total_addresses']}")
    else:
        calculator.interactive_mode()


if __name__ == "__main__":
    main()
