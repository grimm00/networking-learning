#!/usr/bin/env python3
"""
OSI Model Analyzer
Interactive tool to understand and analyze the OSI model layers
"""

import socket
import subprocess
import sys
import time
from typing import Dict, List, Any
import argparse
import json


class OSIAnalyzer:
    def __init__(self):
        self.layers = {
            7: {
                'name': 'Application',
                'purpose': 'Provides network services to user applications',
                'examples': ['HTTP', 'HTTPS', 'FTP', 'SMTP', 'DNS', 'SSH', 'Telnet'],
                'devices': ['Gateways', 'Firewalls'],
                'data_unit': 'Data'
            },
            6: {
                'name': 'Presentation',
                'purpose': 'Data translation, encryption, compression',
                'examples': ['SSL/TLS', 'JPEG', 'MPEG', 'ASCII', 'Unicode'],
                'devices': ['Gateways', 'Firewalls'],
                'data_unit': 'Data'
            },
            5: {
                'name': 'Session',
                'purpose': 'Establishes, manages, and terminates sessions',
                'examples': ['NetBIOS', 'RPC', 'SQL', 'NFS'],
                'devices': ['Gateways', 'Firewalls'],
                'data_unit': 'Data'
            },
            4: {
                'name': 'Transport',
                'purpose': 'End-to-end communication, reliability, flow control',
                'examples': ['TCP', 'UDP', 'SCTP'],
                'devices': ['Firewalls', 'Load Balancers'],
                'data_unit': 'Segments (TCP) or Datagrams (UDP)'
            },
            3: {
                'name': 'Network',
                'purpose': 'Logical addressing and routing',
                'examples': ['IP', 'ICMP', 'ARP', 'OSPF', 'BGP'],
                'devices': ['Routers', 'Layer 3 Switches'],
                'data_unit': 'Packets'
            },
            2: {
                'name': 'Data Link',
                'purpose': 'Physical addressing, error detection, frame synchronization',
                'examples': ['Ethernet', 'WiFi', 'PPP', 'Frame Relay'],
                'devices': ['Switches', 'Bridges', 'NICs'],
                'data_unit': 'Frames'
            },
            1: {
                'name': 'Physical',
                'purpose': 'Physical transmission of data',
                'examples': ['Ethernet cables', 'WiFi radio', 'Fiber optic'],
                'devices': ['Hubs', 'Repeaters', 'Cables', 'NICs'],
                'data_unit': 'Bits'
            }
        }

    def display_layer_info(self, layer_num: int):
        """Display detailed information about a specific layer"""
        if layer_num not in self.layers:
            print(f"Invalid layer number: {layer_num}")
            return
        
        layer = self.layers[layer_num]
        print(f"\n{'='*60}")
        print(f"OSI Layer {layer_num}: {layer['name']}")
        print(f"{'='*60}")
        print(f"Purpose: {layer['purpose']}")
        print(f"Data Unit: {layer['data_unit']}")
        print(f"Devices: {', '.join(layer['devices'])}")
        print(f"Examples: {', '.join(layer['examples'])}")
        print()

    def display_all_layers(self):
        """Display all OSI layers"""
        print("\n" + "="*80)
        print("OSI MODEL - 7 LAYERS OF NETWORKING")
        print("="*80)
        
        for layer_num in sorted(self.layers.keys(), reverse=True):
            layer = self.layers[layer_num]
            print(f"Layer {layer_num}: {layer['name']:12} | {layer['purpose']}")
        
        print("\n" + "="*80)

    def analyze_network_communication(self, target: str = "8.8.8.8"):
        """Analyze network communication through OSI layers"""
        print(f"\n{'='*60}")
        print(f"ANALYZING NETWORK COMMUNICATION TO {target}")
        print(f"{'='*60}")
        
        # Layer 1: Physical
        print("\nLayer 1 (Physical):")
        print("  - Data transmitted as electrical signals")
        print("  - Uses network cables or wireless radio")
        print("  - Data unit: Bits")
        
        # Layer 2: Data Link
        print("\nLayer 2 (Data Link):")
        print("  - Data organized into frames")
        print("  - MAC addresses used for addressing")
        print("  - Error detection and correction")
        print("  - Data unit: Frames")
        
        # Layer 3: Network
        print("\nLayer 3 (Network):")
        print("  - IP addresses used for logical addressing")
        print("  - Routing decisions made")
        print("  - Data unit: Packets")
        
        # Layer 4: Transport
        print("\nLayer 4 (Transport):")
        print("  - TCP or UDP used for transport")
        print("  - Port numbers identify services")
        print("  - Reliability and flow control")
        print("  - Data unit: Segments (TCP) or Datagrams (UDP)")
        
        # Layer 5: Session
        print("\nLayer 5 (Session):")
        print("  - Session establishment and management")
        print("  - Authentication and authorization")
        print("  - Data unit: Data")
        
        # Layer 6: Presentation
        print("\nLayer 6 (Presentation):")
        print("  - Data encryption/decryption")
        print("  - Data compression")
        print("  - Data format conversion")
        print("  - Data unit: Data")
        
        # Layer 7: Application
        print("\nLayer 7 (Application):")
        print("  - User interface and application services")
        print("  - HTTP, FTP, SMTP, etc.")
        print("  - Data unit: Data")

    def demonstrate_encapsulation(self):
        """Demonstrate data encapsulation through OSI layers"""
        print(f"\n{'='*60}")
        print("DATA ENCAPSULATION PROCESS")
        print(f"{'='*60}")
        
        print("\n1. Application Layer (Layer 7):")
        print("   User data: 'Hello World'")
        print("   + Application header (HTTP, FTP, etc.)")
        print("   = Application Data")
        
        print("\n2. Presentation Layer (Layer 6):")
        print("   Application Data")
        print("   + Encryption/compression header")
        print("   = Presentation Data")
        
        print("\n3. Session Layer (Layer 5):")
        print("   Presentation Data")
        print("   + Session header")
        print("   = Session Data")
        
        print("\n4. Transport Layer (Layer 4):")
        print("   Session Data")
        print("   + TCP/UDP header (ports, sequence numbers)")
        print("   = Transport Segment")
        
        print("\n5. Network Layer (Layer 3):")
        print("   Transport Segment")
        print("   + IP header (source/dest IP, TTL)")
        print("   = Network Packet")
        
        print("\n6. Data Link Layer (Layer 2):")
        print("   Network Packet")
        print("   + Ethernet header (MAC addresses)")
        print("   = Data Link Frame")
        
        print("\n7. Physical Layer (Layer 1):")
        print("   Data Link Frame")
        print("   + Physical transmission")
        print("   = Electrical signals (bits)")

    def test_layer_connectivity(self, target: str = "8.8.8.8"):
        """Test connectivity at different OSI layers"""
        print(f"\n{'='*60}")
        print(f"TESTING CONNECTIVITY TO {target}")
        print(f"{'='*60}")
        
        # Layer 3 test (Network)
        print("\nLayer 3 (Network) Test:")
        try:
            result = subprocess.run(['ping', '-c', '1', target], 
                                  capture_output=True, text=True, timeout=5)
            if result.returncode == 0:
                print(f"  ✓ Network layer connectivity successful")
                print(f"  Response time: {result.stdout.split('time=')[1].split(' ')[0] if 'time=' in result.stdout else 'N/A'}")
            else:
                print(f"  ✗ Network layer connectivity failed")
        except Exception as e:
            print(f"  ✗ Network layer test error: {e}")
        
        # Layer 4 test (Transport)
        print("\nLayer 4 (Transport) Test:")
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(5)
            result = sock.connect_ex((target, 80))
            sock.close()
            if result == 0:
                print(f"  ✓ Transport layer connectivity successful (TCP port 80)")
            else:
                print(f"  ✗ Transport layer connectivity failed (TCP port 80)")
        except Exception as e:
            print(f"  ✗ Transport layer test error: {e}")
        
        # Layer 7 test (Application)
        print("\nLayer 7 (Application) Test:")
        try:
            result = subprocess.run(['curl', '-s', '-o', '/dev/null', '-w', '%{http_code}', 
                                   f'http://{target}'], capture_output=True, text=True, timeout=10)
            if result.returncode == 0 and result.stdout.strip() in ['200', '301', '302']:
                print(f"  ✓ Application layer connectivity successful (HTTP)")
            else:
                print(f"  ✗ Application layer connectivity failed (HTTP)")
        except Exception as e:
            print(f"  ✗ Application layer test error: {e}")

    def interactive_mode(self):
        """Run interactive OSI model learning mode"""
        print("\n" + "="*80)
        print("INTERACTIVE OSI MODEL LEARNING")
        print("="*80)
        
        while True:
            print("\nOptions:")
            print("1. Display all layers")
            print("2. Show specific layer details")
            print("3. Analyze network communication")
            print("4. Demonstrate encapsulation")
            print("5. Test layer connectivity")
            print("6. Exit")
            
            choice = input("\nEnter your choice (1-6): ").strip()
            
            if choice == '1':
                self.display_all_layers()
            elif choice == '2':
                try:
                    layer_num = int(input("Enter layer number (1-7): "))
                    self.display_layer_info(layer_num)
                except ValueError:
                    print("Invalid input. Please enter a number between 1 and 7.")
            elif choice == '3':
                target = input("Enter target IP or hostname (default: 8.8.8.8): ").strip()
                if not target:
                    target = "8.8.8.8"
                self.analyze_network_communication(target)
            elif choice == '4':
                self.demonstrate_encapsulation()
            elif choice == '5':
                target = input("Enter target IP or hostname (default: 8.8.8.8): ").strip()
                if not target:
                    target = "8.8.8.8"
                self.test_layer_connectivity(target)
            elif choice == '6':
                print("Goodbye!")
                break
            else:
                print("Invalid choice. Please enter 1-6.")

    def generate_cheat_sheet(self):
        """Generate OSI model cheat sheet"""
        print("\n" + "="*80)
        print("OSI MODEL CHEAT SHEET")
        print("="*80)
        
        for layer_num in sorted(self.layers.keys(), reverse=True):
            layer = self.layers[layer_num]
            print(f"\nLayer {layer_num}: {layer['name']}")
            print(f"  Purpose: {layer['purpose']}")
            print(f"  Data Unit: {layer['data_unit']}")
            print(f"  Key Protocols: {', '.join(layer['examples'][:3])}")
            print(f"  Devices: {', '.join(layer['devices'])}")


def main():
    parser = argparse.ArgumentParser(description='OSI Model Analyzer')
    parser.add_argument('--layer', type=int, choices=range(1, 8), 
                       help='Show specific layer details')
    parser.add_argument('--target', default='8.8.8.8', 
                       help='Target for connectivity tests')
    parser.add_argument('--interactive', '-i', action='store_true',
                       help='Run in interactive mode')
    parser.add_argument('--cheat-sheet', action='store_true',
                       help='Generate cheat sheet')
    
    args = parser.parse_args()
    
    analyzer = OSIAnalyzer()
    
    if args.cheat_sheet:
        analyzer.generate_cheat_sheet()
    elif args.layer:
        analyzer.display_layer_info(args.layer)
    elif args.interactive:
        analyzer.interactive_mode()
    else:
        analyzer.display_all_layers()
        analyzer.analyze_network_communication(args.target)
        analyzer.demonstrate_encapsulation()
        analyzer.test_layer_connectivity(args.target)


if __name__ == "__main__":
    main()
