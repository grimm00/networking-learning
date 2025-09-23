#!/usr/bin/env python3
"""
ARP Traffic Simulator

A tool for simulating ARP traffic in containerized environments.
Generates various ARP scenarios for learning and testing.

Version: 1.0.0
License: MIT

Usage:
    python3 arp-simulator.py [options]

Options:
    -s, --scenario SCENARIO    ARP scenario to simulate
    -i, --interface INTERFACE  Network interface to use
    -c, --count COUNT          Number of ARP packets to send
    -t, --target TARGET        Target IP address
    -v, --verbose              Verbose output
    -h, --help                 Show this help message

Scenarios:
    discovery     - ARP discovery (who has IP?)
    announcement  - ARP announcement (gratuitous ARP)
    conflict      - ARP conflict simulation
    flood         - ARP flood test
    spoofing      - ARP spoofing simulation (educational)
    cleanup       - Send ARP requests to clean ARP table

Examples:
    python3 arp-simulator.py -s discovery -t 192.168.1.100
    python3 arp-simulator.py -s announcement -c 5
    python3 arp-simulator.py -s conflict -t 192.168.1.1
"""

import argparse
import subprocess
import sys
import time
import random
import socket
from scapy.all import *
from scapy.layers.l2 import ARP, Ether
from scapy.layers.inet import IP
import threading

class ARPSimulator:
    """Simulates various ARP scenarios for educational purposes"""
    
    def __init__(self, verbose=False):
        self.verbose = verbose
        self.interface = None
        self.running = False
    
    def log(self, message):
        """Log message if verbose mode is enabled"""
        if self.verbose:
            print(f"[ARP-SIM] {message}")
    
    def get_interface_info(self):
        """Get network interface information"""
        try:
            # Get default interface
            result = subprocess.run(['ip', 'route', 'show', 'default'], 
                                  capture_output=True, text=True)
            if result.returncode == 0:
                lines = result.stdout.strip().split('\n')
                for line in lines:
                    if 'default via' in line:
                        parts = line.split()
                        for i, part in enumerate(parts):
                            if part == 'dev':
                                self.interface = parts[i + 1]
                                break
                        break
            
            if not self.interface:
                self.interface = 'eth0'  # Default fallback
            
            self.log(f"Using interface: {self.interface}")
            return True
            
        except Exception as e:
            print(f"❌ Error getting interface info: {e}")
            return False
    
    def get_my_ip(self):
        """Get our IP address"""
        try:
            result = subprocess.run(['ip', 'addr', 'show', self.interface], 
                                  capture_output=True, text=True)
            if result.returncode == 0:
                for line in result.stdout.split('\n'):
                    if 'inet ' in line and not '127.0.0.1' in line:
                        ip = line.split()[1].split('/')[0]
                        return ip
            return None
        except Exception as e:
            self.log(f"Error getting IP: {e}")
            return None
    
    def get_my_mac(self):
        """Get our MAC address"""
        try:
            result = subprocess.run(['ip', 'link', 'show', self.interface], 
                                  capture_output=True, text=True)
            if result.returncode == 0:
                for line in result.stdout.split('\n'):
                    if 'link/ether' in line:
                        mac = line.split()[1]
                        return mac
            return None
        except Exception as e:
            self.log(f"Error getting MAC: {e}")
            return None
    
    def send_arp_request(self, target_ip, source_ip=None, source_mac=None):
        """Send ARP request"""
        if not source_ip:
            source_ip = self.get_my_ip()
        if not source_mac:
            source_mac = self.get_my_mac()
        
        if not all([source_ip, source_mac]):
            print("❌ Could not determine source IP/MAC")
            return False
        
        try:
            # Create ARP request packet with Ethernet layer
            arp_request = Ether(dst="ff:ff:ff:ff:ff:ff") / ARP(
                op=1,  # ARP request
                psrc=source_ip,
                pdst=target_ip,
                hwsrc=source_mac
            )
            
            # Send packet
            sendp(arp_request, iface=self.interface, verbose=0)
            self.log(f"Sent ARP request: Who has {target_ip}? Tell {source_ip}")
            return True
            
        except Exception as e:
            print(f"❌ Error sending ARP request: {e}")
            return False
    
    def send_arp_reply(self, target_ip, target_mac, source_ip=None, source_mac=None):
        """Send ARP reply"""
        if not source_ip:
            source_ip = self.get_my_ip()
        if not source_mac:
            source_mac = self.get_my_mac()
        
        if not all([source_ip, source_mac]):
            print("❌ Could not determine source IP/MAC")
            return False
        
        try:
            # Create ARP reply packet with Ethernet layer
            arp_reply = Ether(dst=target_mac) / ARP(
                op=2,  # ARP reply
                psrc=source_ip,
                pdst=target_ip,
                hwsrc=source_mac,
                hwdst=target_mac
            )
            
            # Send packet
            sendp(arp_reply, iface=self.interface, verbose=0)
            self.log(f"Sent ARP reply: {source_ip} is at {source_mac}")
            return True
            
        except Exception as e:
            print(f"❌ Error sending ARP reply: {e}")
            return False
    
    def send_gratuitous_arp(self, ip_address, mac_address=None):
        """Send gratuitous ARP (ARP announcement)"""
        if not mac_address:
            mac_address = self.get_my_mac()
        
        if not mac_address:
            print("❌ Could not determine MAC address")
            return False
        
        try:
            # Create gratuitous ARP with Ethernet layer
            garp = Ether(dst="ff:ff:ff:ff:ff:ff") / ARP(
                op=2,  # ARP reply
                psrc=ip_address,
                pdst=ip_address,
                hwsrc=mac_address,
                hwdst="ff:ff:ff:ff:ff:ff"  # Broadcast
            )
            
            # Send packet
            sendp(garp, iface=self.interface, verbose=0)
            self.log(f"Sent gratuitous ARP: {ip_address} is at {mac_address}")
            return True
            
        except Exception as e:
            print(f"❌ Error sending gratuitous ARP: {e}")
            return False
    
    def simulate_discovery(self, target_ip, count=1):
        """Simulate ARP discovery scenario"""
        if not target_ip:
            print("❌ Target IP is required for ARP discovery")
            return
        
        print(f"🔍 Simulating ARP discovery for {target_ip}")
        
        for i in range(count):
            if self.send_arp_request(target_ip):
                print(f"✅ ARP request {i+1}/{count} sent")
            else:
                print(f"❌ ARP request {i+1}/{count} failed")
            
            if i < count - 1:
                time.sleep(1)
    
    def simulate_announcement(self, ip_address, count=1):
        """Simulate ARP announcement scenario"""
        print(f"📢 Simulating ARP announcement for {ip_address}")
        
        for i in range(count):
            if self.send_gratuitous_arp(ip_address):
                print(f"✅ Gratuitous ARP {i+1}/{count} sent")
            else:
                print(f"❌ Gratuitous ARP {i+1}/{count} failed")
            
            if i < count - 1:
                time.sleep(2)
    
    def simulate_conflict(self, target_ip, count=3):
        """Simulate ARP conflict scenario"""
        print(f"⚔️ Simulating ARP conflict for {target_ip}")
        
        # Generate fake MAC addresses
        fake_macs = []
        for i in range(count):
            fake_mac = ":".join([f"{random.randint(0, 255):02x}" for _ in range(6)])
            fake_macs.append(fake_mac)
        
        print(f"Using fake MAC addresses: {fake_macs}")
        
        for i, fake_mac in enumerate(fake_macs):
            if self.send_gratuitous_arp(target_ip, fake_mac):
                print(f"✅ Conflict ARP {i+1}/{count} sent with MAC {fake_mac}")
            else:
                print(f"❌ Conflict ARP {i+1}/{count} failed")
            
            time.sleep(1)
    
    def simulate_flood(self, count=10):
        """Simulate ARP flood scenario"""
        print(f"🌊 Simulating ARP flood with {count} packets")
        
        my_ip = self.get_my_ip()
        if not my_ip:
            print("❌ Could not determine our IP address")
            return
        
        # Generate random IP addresses in our subnet
        base_ip = ".".join(my_ip.split('.')[:-1])
        
        for i in range(count):
            # Generate random IP in our subnet
            random_ip = f"{base_ip}.{random.randint(1, 254)}"
            
            if self.send_arp_request(random_ip):
                print(f"✅ Flood ARP {i+1}/{count} sent for {random_ip}")
            else:
                print(f"❌ Flood ARP {i+1}/{count} failed")
            
            time.sleep(0.1)  # Small delay to avoid overwhelming
    
    def simulate_spoofing(self, target_ip, fake_ip, count=5):
        """Simulate ARP spoofing (educational purposes only)"""
        print(f"🎭 Simulating ARP spoofing: {fake_ip} -> {target_ip}")
        print("⚠️  WARNING: This is for educational purposes only!")
        
        my_mac = self.get_my_mac()
        if not my_mac:
            print("❌ Could not determine our MAC address")
            return
        
        for i in range(count):
            # Send ARP reply claiming fake_ip is at our MAC
            if self.send_arp_reply(target_ip, "ff:ff:ff:ff:ff:ff", fake_ip, my_mac):
                print(f"✅ Spoof ARP {i+1}/{count} sent: {fake_ip} is at {my_mac}")
            else:
                print(f"❌ Spoof ARP {i+1}/{count} failed")
            
            time.sleep(1)
    
    def cleanup_arp_table(self, count=5):
        """Send ARP requests to clean ARP table"""
        print(f"🧹 Cleaning ARP table with {count} requests")
        
        my_ip = self.get_my_ip()
        if not my_ip:
            print("❌ Could not determine our IP address")
            return
        
        # Generate IPs in our subnet
        base_ip = ".".join(my_ip.split('.')[:-1])
        
        for i in range(count):
            random_ip = f"{base_ip}.{random.randint(1, 254)}"
            
            if self.send_arp_request(random_ip):
                print(f"✅ Cleanup ARP {i+1}/{count} sent for {random_ip}")
            else:
                print(f"❌ Cleanup ARP {i+1}/{count} failed")
            
            time.sleep(0.5)
    
    def run_scenario(self, scenario, **kwargs):
        """Run specified ARP scenario"""
        if not self.get_interface_info():
            return False
        
        print(f"🚀 Starting ARP scenario: {scenario}")
        print(f"📡 Interface: {self.interface}")
        
        if scenario == "discovery":
            target = kwargs.get('target', '192.168.1.1')
            count = kwargs.get('count', 1)
            self.simulate_discovery(target, count)
        
        elif scenario == "announcement":
            ip = kwargs.get('target') or self.get_my_ip()
            if not ip:
                print("❌ Could not determine IP address for announcement")
                return False
            count = kwargs.get('count', 1)
            self.simulate_announcement(ip, count)
        
        elif scenario == "conflict":
            target = kwargs.get('target', '192.168.1.1')
            count = kwargs.get('count', 3)
            self.simulate_conflict(target, count)
        
        elif scenario == "flood":
            count = kwargs.get('count', 10)
            self.simulate_flood(count)
        
        elif scenario == "spoofing":
            target = kwargs.get('target', '192.168.1.1')
            fake_ip = kwargs.get('fake_ip', '192.168.1.100')
            count = kwargs.get('count', 5)
            self.simulate_spoofing(target, fake_ip, count)
        
        elif scenario == "cleanup":
            count = kwargs.get('count', 5)
            self.cleanup_arp_table(count)
        
        else:
            print(f"❌ Unknown scenario: {scenario}")
            return False
        
        print("✅ ARP simulation completed")
        return True

def main():
    parser = argparse.ArgumentParser(
        description="ARP Traffic Simulator for educational purposes",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__
    )
    
    parser.add_argument('-s', '--scenario', 
                       choices=['discovery', 'announcement', 'conflict', 'flood', 'spoofing', 'cleanup'],
                       default='discovery',
                       help='ARP scenario to simulate')
    
    parser.add_argument('-i', '--interface', 
                       help='Network interface to use')
    
    parser.add_argument('-c', '--count', type=int, default=1,
                       help='Number of ARP packets to send')
    
    parser.add_argument('-t', '--target', 
                       help='Target IP address')
    
    parser.add_argument('-f', '--fake-ip',
                       help='Fake IP for spoofing scenario')
    
    parser.add_argument('-v', '--verbose', action='store_true',
                       help='Verbose output')
    
    args = parser.parse_args()
    
    # Check if running as root
    if os.geteuid() != 0:
        print("❌ This script requires root privileges for packet sending")
        print("Please run with sudo: sudo python3 arp-simulator.py")
        sys.exit(1)
    
    # Create simulator
    simulator = ARPSimulator(verbose=args.verbose)
    
    # Set interface if provided
    if args.interface:
        simulator.interface = args.interface
    
    # Prepare kwargs
    kwargs = {
        'count': args.count,
        'target': args.target
    }
    
    if args.fake_ip:
        kwargs['fake_ip'] = args.fake_ip
    
    # Run scenario
    success = simulator.run_scenario(args.scenario, **kwargs)
    
    if not success:
        sys.exit(1)

if __name__ == "__main__":
    main()
