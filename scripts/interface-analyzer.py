#!/usr/bin/env python3
"""
Network Interface Analyzer

A comprehensive tool for analyzing network interfaces, their configuration,
performance, and connectivity. Provides detailed information about interface
states, IP addresses, routing, and network statistics.

Usage:
    python3 interface-analyzer.py [options]

Options:
    -i, --interface INTERFACE    Analyze specific interface
    -a, --all                    Analyze all interfaces (default)
    -s, --statistics            Show detailed statistics
    -r, --routing               Show routing information
    -t, --test                  Test connectivity
    -v, --verbose               Verbose output
    -h, --help                  Show this help message

Examples:
    python3 interface-analyzer.py                    # Analyze all interfaces
    python3 interface-analyzer.py -i eth0            # Analyze specific interface
    python3 interface-analyzer.py -s -r              # Show statistics and routing
    python3 interface-analyzer.py -t -v              # Test connectivity with verbose output
"""

import argparse
import subprocess
import json
import re
import sys
import time
import socket
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass
from pathlib import Path

@dataclass
class InterfaceInfo:
    """Network interface information"""
    name: str
    state: str
    mtu: int
    mac_address: str
    ip_addresses: List[str]
    is_up: bool
    is_loopback: bool
    is_wireless: bool
    speed: Optional[str] = None
    duplex: Optional[str] = None
    errors: Dict[str, int] = None

@dataclass
class RouteInfo:
    """Routing information"""
    destination: str
    gateway: str
    interface: str
    metric: int
    is_default: bool

class InterfaceAnalyzer:
    """Network interface analyzer"""
    
    def __init__(self, verbose: bool = False):
        self.verbose = verbose
        self.interfaces = {}
        self.routes = []
        self.is_container = self._detect_container_environment()
    
    def _detect_container_environment(self) -> bool:
        """Detect if running inside a container"""
        try:
            # Check for common container indicators
            with open('/proc/1/cgroup', 'r') as f:
                content = f.read()
                if 'docker' in content or 'containerd' in content:
                    return True
            
            # Check for .dockerenv file
            if Path('/.dockerenv').exists():
                return True
            
            # Check environment variables
            import os
            if os.environ.get('container') or os.environ.get('DOCKER_CONTAINER'):
                return True
            
            return False
        except Exception:
            return False
        
    def run_command(self, command: List[str], capture_output: bool = True) -> Tuple[int, str, str]:
        """Run a command and return exit code, stdout, stderr"""
        try:
            result = subprocess.run(
                command,
                capture_output=capture_output,
                text=True,
                timeout=10
            )
            return result.returncode, result.stdout, result.stderr
        except subprocess.TimeoutExpired:
            return -1, "", "Command timed out"
        except Exception as e:
            return -1, "", str(e)
    
    def get_interface_list(self) -> List[str]:
        """Get list of network interfaces"""
        # Try ip command first (Linux)
        exit_code, stdout, stderr = self.run_command(['ip', 'link', 'show'])
        if exit_code == 0:
            # Parse ip command output
            interfaces = []
            for line in stdout.split('\n'):
                if ':' in line and ('state' in line or 'mtu' in line):
                    match = re.search(r'(\d+):\s+([^:]+):', line)
                    if match:
                        interface_name = match.group(2)
                        # Filter out Docker internal interfaces and virtual interfaces
                        if self._should_analyze_interface(interface_name):
                            interfaces.append(interface_name)
            return interfaces
        
        # Fallback to ifconfig (macOS, older Linux)
        exit_code, stdout, stderr = self.run_command(['ifconfig', '-a'])
        if exit_code != 0:
            print(f"❌ Error getting interface list: {stderr}")
            return []
        
        # Parse ifconfig output
        interfaces = []
        for line in stdout.split('\n'):
            if line and not line.startswith('\t') and not line.startswith(' '):
                # Look for interface name (first word before colon or space)
                if ':' in line:
                    interface = line.split(':')[0]
                elif ' ' in line:
                    interface = line.split()[0]
                else:
                    continue
                
                if interface and self._should_analyze_interface(interface):
                    interfaces.append(interface)
        
        return interfaces
    
    def _should_analyze_interface(self, interface_name: str) -> bool:
        """Determine if an interface should be analyzed"""
        if self.is_container:
            # In container: educational filtering - show more interfaces for learning
            # Skip Docker internal interfaces (contain @if followed by numbers)
            if '@if' in interface_name and interface_name.split('@')[1].isdigit():
                return False
            
            # Include educational virtual interfaces
            educational_interfaces = [
                'tunl0',    # IP-in-IP tunnel
                'gre0',     # Generic Routing Encapsulation
                'gretap0',  # GRE TAP interface
                'sit0',     # Simple Internet Transition (IPv6 over IPv4)
                'tun0',     # TUN interface
                'tap0'      # TAP interface
            ]
            
            # Include educational interfaces
            if interface_name in educational_interfaces:
                return True
            
            # Skip interfaces that start with virtual prefixes (except educational ones)
            virtual_prefixes = ['veth', 'docker', 'br-', 'virbr']
            for prefix in virtual_prefixes:
                if interface_name.startswith(prefix):
                    return False
        else:
            # On host system: more permissive filtering
            # Skip only obvious virtual interfaces that aren't useful for learning
            virtual_interfaces = [
                'tunl0', 'gre0', 'gretap0', 'erspan0', 'ip_vti0', 'ip6_vti0',
                'sit0', 'ip6tnl0', 'ip6gre0'
            ]
            
            if interface_name in virtual_interfaces:
                return False
            
            # Skip Docker bridge interfaces on host
            if interface_name.startswith('br-') and 'docker' in interface_name:
                return False
        
        # Include loopback, ethernet, wireless, and useful virtual interfaces
        return True
    
    def _get_interface_type(self, interface_name: str) -> str:
        """Get educational interface type description"""
        # Clean interface name (remove @suffix)
        clean_name = interface_name.split('@')[0]
        
        if clean_name.startswith('lo'):
            return 'Loopback'
        elif clean_name.startswith('eth') or clean_name.startswith('en'):
            return 'Ethernet'
        elif clean_name.startswith('wlan') or clean_name.startswith('wl'):
            return 'Wireless'
        elif clean_name == 'tunl0':
            return 'IP-in-IP Tunnel'
        elif clean_name == 'gre0':
            return 'GRE Tunnel'
        elif clean_name == 'gretap0':
            return 'GRE TAP Interface'
        elif clean_name == 'sit0':
            return 'IPv6-over-IPv4 Tunnel'
        elif clean_name.startswith('tun'):
            return 'TUN Interface'
        elif clean_name.startswith('tap'):
            return 'TAP Interface'
        elif clean_name.startswith('br'):
            return 'Bridge Interface'
        elif clean_name.startswith('bond'):
            return 'Bond Interface'
        elif clean_name.startswith('ip_vti'):
            return 'IPv4 VTI Tunnel'
        elif clean_name.startswith('ip6_vti'):
            return 'IPv6 VTI Tunnel'
        elif clean_name.startswith('ip6tnl'):
            return 'IPv6 Tunnel'
        elif clean_name.startswith('ip6gre'):
            return 'IPv6 GRE Tunnel'
        elif clean_name.startswith('erspan'):
            return 'ERSPAN Tunnel'
        else:
            return 'Network Interface'
    
    def _get_interface_description(self, interface_name: str) -> str:
        """Get educational description for virtual interfaces"""
        # Clean interface name (remove @suffix)
        clean_name = interface_name.split('@')[0]
        
        descriptions = {
            'tunl0': 'Used for IP-in-IP tunneling, encapsulates IPv4 packets in IPv4',
            'gre0': 'Generic Routing Encapsulation tunnel for point-to-point connections',
            'gretap0': 'GRE TAP interface for layer 2 tunneling over GRE',
            'sit0': 'Simple Internet Transition for IPv6 over IPv4 tunneling',
            'tun0': 'TUN interface for user-space network applications',
            'tap0': 'TAP interface for bridging virtual machines',
            'ip_vti0': 'IPv4 Virtual Tunnel Interface for IPsec VPNs',
            'ip6_vti0': 'IPv6 Virtual Tunnel Interface for IPsec VPNs',
            'ip6tnl0': 'IPv6 tunnel interface for IPv6 over IPv4',
            'ip6gre0': 'IPv6 GRE tunnel for IPv6 over IPv4',
            'erspan0': 'ERSPAN tunnel for network monitoring and analysis'
        }
        return descriptions.get(clean_name, 'Virtual network interface for advanced networking')
    
    def get_interface_info(self, interface: str) -> Optional[InterfaceInfo]:
        """Get detailed information about a specific interface"""
        # For interfaces with @ in the name, parse from full ip addr show output
        if '@' in interface:
            return self._get_interface_from_full_output(interface)
        
        # Try ip addr show first (Linux)
        exit_code, stdout, stderr = self.run_command(['ip', 'addr', 'show', interface])
        if exit_code == 0:
            return self._parse_ip_addr_output(interface, stdout)
        
        # Fallback to ip link show (Linux)
        exit_code, stdout, stderr = self.run_command(['ip', 'link', 'show', interface])
        if exit_code == 0:
            return self._parse_ip_output(interface, stdout)
        
        # Fallback to ifconfig (macOS, older Linux)
        exit_code, stdout, stderr = self.run_command(['ifconfig', interface])
        if exit_code != 0:
            return None
        
        return self._parse_ifconfig_output(interface, stdout)
    
    def _get_interface_from_full_output(self, interface: str) -> Optional[InterfaceInfo]:
        """Get interface info by parsing full ip addr show output"""
        # Get full ip addr show output
        exit_code, stdout, stderr = self.run_command(['ip', 'addr', 'show'])
        if exit_code != 0:
            return None
        
        # Parse the full output to find our specific interface
        return self._parse_full_ip_addr_output(interface, stdout)
    
    def _parse_full_ip_addr_output(self, interface: str, stdout: str) -> Optional[InterfaceInfo]:
        """Parse full ip addr show output to find specific interface"""
        state = "UNKNOWN"
        mtu = 1500
        mac_address = ""
        is_up = False
        is_loopback = interface.startswith('lo')
        is_wireless = any(x in interface.lower() for x in ['wlan', 'wifi', 'wireless'])
        ip_addresses = []
        
        lines = stdout.split('\n')
        current_interface = None
        
        for i, line in enumerate(lines):
            # Check if this line starts a new interface (format: "N: interface:")
            if re.match(r'^\s*\d+:\s*' + re.escape(interface) + r':', line):
                current_interface = interface
                # Parse the interface header line
                if 'UP' in line:
                    state = "UP"
                    is_up = True
                elif 'DOWN' in line:
                    state = "DOWN"
                    is_up = False
                
                # Extract MTU
                match = re.search(r'mtu (\d+)', line)
                if match:
                    mtu = int(match.group(1))
                
                # Continue parsing this interface's details
                continue
            
            # If we're parsing our target interface
            if current_interface == interface:
                # Parse MAC address
                if 'link/ether' in line:
                    match = re.search(r'link/ether ([a-f0-9:]+)', line)
                    if match:
                        mac_address = match.group(1)
                
                # Parse IP addresses
                if 'inet ' in line:
                    match = re.search(r'inet (\d+\.\d+\.\d+\.\d+/\d+)', line)
                    if match:
                        ip_addresses.append(match.group(1))
                
                # Stop parsing when we hit the next interface
                if line.strip() and not line.startswith(' ') and not line.startswith('\t') and ':' in line and interface not in line:
                    break
        
        if current_interface is None:
            return None
        
        return InterfaceInfo(
            name=interface,
            state=state,
            mtu=mtu,
            mac_address=mac_address,
            ip_addresses=ip_addresses,
            is_up=is_up,
            is_loopback=is_loopback,
            is_wireless=is_wireless,
            errors={}
        )
    
    def _parse_ip_addr_output(self, interface: str, stdout: str) -> Optional[InterfaceInfo]:
        """Parse ip addr show command output"""
        state = "UNKNOWN"
        mtu = 1500
        mac_address = ""
        is_up = False
        is_loopback = interface.startswith('lo')
        is_wireless = any(x in interface.lower() for x in ['wlan', 'wifi', 'wireless'])
        ip_addresses = []
        
        for line in stdout.split('\n'):
            # Parse interface status line
            if interface in line and 'mtu' in line:
                if 'UP' in line:
                    state = "UP"
                    is_up = True
                elif 'DOWN' in line:
                    state = "DOWN"
                    is_up = False
                
                # Extract MTU
                match = re.search(r'mtu (\d+)', line)
                if match:
                    mtu = int(match.group(1))
            
            # Parse MAC address
            if 'link/ether' in line:
                match = re.search(r'link/ether ([a-f0-9:]+)', line)
                if match:
                    mac_address = match.group(1)
            
            # Parse IP addresses
            if 'inet ' in line:
                match = re.search(r'inet (\d+\.\d+\.\d+\.\d+/\d+)', line)
                if match:
                    ip_addresses.append(match.group(1))
        
        return InterfaceInfo(
            name=interface,
            state=state,
            mtu=mtu,
            mac_address=mac_address,
            ip_addresses=ip_addresses,
            is_up=is_up,
            is_loopback=is_loopback,
            is_wireless=is_wireless,
            errors={}
        )
    
    def _parse_ip_output(self, interface: str, stdout: str) -> Optional[InterfaceInfo]:
        """Parse ip command output"""
        state = "UNKNOWN"
        mtu = 1500
        mac_address = ""
        is_up = False
        is_loopback = interface.startswith('lo')
        is_wireless = any(x in interface.lower() for x in ['wlan', 'wifi', 'wireless'])
        
        for line in stdout.split('\n'):
            if 'state' in line:
                if 'UP' in line:
                    state = "UP"
                    is_up = True
                elif 'DOWN' in line:
                    state = "DOWN"
                    is_up = False
            elif 'status' in line:
                # macOS ip command format
                if 'UP' in line:
                    state = "UP"
                    is_up = True
                elif 'DOWN' in line:
                    state = "DOWN"
                    is_up = False
            
            if 'mtu' in line:
                match = re.search(r'mtu (\d+)', line)
                if match:
                    mtu = int(match.group(1))
            
            if 'link/ether' in line:
                match = re.search(r'link/ether ([a-f0-9:]+)', line)
                if match:
                    mac_address = match.group(1)
        
        # Get IP addresses
        ip_addresses = self.get_interface_ip_addresses(interface)
        
        # Get interface statistics
        errors = self.get_interface_errors(interface)
        
        return InterfaceInfo(
            name=interface,
            state=state,
            mtu=mtu,
            mac_address=mac_address,
            ip_addresses=ip_addresses,
            is_up=is_up,
            is_loopback=is_loopback,
            is_wireless=is_wireless,
            errors=errors
        )
    
    def _parse_ifconfig_output(self, interface: str, stdout: str) -> Optional[InterfaceInfo]:
        """Parse ifconfig command output"""
        state = "UNKNOWN"
        mtu = 1500
        mac_address = ""
        is_up = False
        is_loopback = interface.startswith('lo')
        is_wireless = any(x in interface.lower() for x in ['wlan', 'wifi', 'wireless'])
        
        for line in stdout.split('\n'):
            if 'status:' in line:
                if 'active' in line:
                    state = "UP"
                    is_up = True
                else:
                    state = "DOWN"
                    is_up = False
            
            if 'mtu' in line:
                match = re.search(r'mtu (\d+)', line)
                if match:
                    mtu = int(match.group(1))
            
            if 'ether' in line:
                match = re.search(r'ether ([a-f0-9:]+)', line)
                if match:
                    mac_address = match.group(1)
        
        # Get IP addresses
        ip_addresses = self.get_interface_ip_addresses(interface)
        
        # Get interface statistics
        errors = self.get_interface_errors(interface)
        
        return InterfaceInfo(
            name=interface,
            state=state,
            mtu=mtu,
            mac_address=mac_address,
            ip_addresses=ip_addresses,
            is_up=is_up,
            is_loopback=is_loopback,
            is_wireless=is_wireless,
            errors=errors
        )
    
    def get_interface_ip_addresses(self, interface: str) -> List[str]:
        """Get IP addresses assigned to an interface"""
        # Try ip command first (Linux)
        exit_code, stdout, stderr = self.run_command(['ip', 'addr', 'show', interface])
        if exit_code == 0:
            # Parse ip command output
            ip_addresses = []
            for line in stdout.split('\n'):
                if 'inet ' in line:
                    match = re.search(r'inet (\d+\.\d+\.\d+\.\d+/\d+)', line)
                    if match:
                        ip_addresses.append(match.group(1))
            return ip_addresses
        
        # Fallback to ifconfig (macOS, older Linux)
        exit_code, stdout, stderr = self.run_command(['ifconfig', interface])
        if exit_code != 0:
            return []
        
        # Parse ifconfig output
        ip_addresses = []
        for line in stdout.split('\n'):
            if 'inet ' in line:
                match = re.search(r'inet (\d+\.\d+\.\d+\.\d+)', line)
                if match:
                    ip_addresses.append(match.group(1))
        
        return ip_addresses
    
    def get_interface_errors(self, interface: str) -> Dict[str, int]:
        """Get interface error statistics"""
        errors = {}
        
        # Try Linux /proc/net/dev first
        try:
            with open(f'/proc/net/dev', 'r') as f:
                for line in f:
                    if interface in line:
                        parts = line.split()
                        if len(parts) >= 17:
                            errors = {
                                'rx_bytes': int(parts[1]),
                                'rx_packets': int(parts[2]),
                                'rx_errors': int(parts[3]),
                                'rx_dropped': int(parts[4]),
                                'tx_bytes': int(parts[9]),
                                'tx_packets': int(parts[10]),
                                'tx_errors': int(parts[11]),
                                'tx_dropped': int(parts[12])
                            }
                        break
        except FileNotFoundError:
            # /proc/net/dev doesn't exist (macOS, etc.)
            # Try to get statistics from ifconfig or netstat
            errors = self._get_interface_stats_alternative(interface)
        except Exception as e:
            if self.verbose:
                print(f"⚠️  Could not read interface statistics: {e}")
        
        return errors
    
    def _get_interface_stats_alternative(self, interface: str) -> Dict[str, int]:
        """Get interface statistics using alternative methods (macOS, etc.)"""
        errors = {}
        
        try:
            # Try netstat for interface statistics (works on macOS)
            exit_code, stdout, stderr = self.run_command(['netstat', '-i'])
            if exit_code == 0:
                # Parse netstat output for statistics
                lines = stdout.split('\n')
                for line in lines:
                    if interface in line and not line.startswith('Name') and '<Link#' in line:
                        parts = line.split()
                        if len(parts) >= 9:
                            try:
                                errors = {
                                    'rx_bytes': 0,  # netstat doesn't show bytes
                                    'rx_packets': int(parts[4]) if parts[4].isdigit() else 0,  # Ipkts
                                    'rx_errors': int(parts[5]) if parts[5].isdigit() else 0,   # Ierrs
                                    'rx_dropped': 0,  # netstat doesn't show dropped
                                    'tx_bytes': 0,  # netstat doesn't show bytes
                                    'tx_packets': int(parts[6]) if parts[6].isdigit() else 0,  # Opkts
                                    'tx_errors': int(parts[7]) if parts[7].isdigit() else 0,   # Oerrs
                                    'tx_dropped': 0   # netstat doesn't show dropped
                                }
                                break
                            except (ValueError, IndexError):
                                pass
            
            # If netstat didn't work, try ifconfig with verbose output
            if not errors:
                exit_code, stdout, stderr = self.run_command(['ifconfig', interface])
                if exit_code == 0:
                    # Parse ifconfig output for statistics
                    for line in stdout.split('\n'):
                        if 'packets:' in line.lower():
                            # Look for packet statistics
                            parts = line.split()
                            for i, part in enumerate(parts):
                                if 'packets:' in part.lower():
                                    if i + 1 < len(parts):
                                        try:
                                            packets = int(parts[i + 1])
                                            if 'rx' in line.lower() or 'input' in line.lower():
                                                errors['rx_packets'] = packets
                                            elif 'tx' in line.lower() or 'output' in line.lower():
                                                errors['tx_packets'] = packets
                                        except ValueError:
                                            pass
                                elif 'bytes:' in part.lower():
                                    if i + 1 < len(parts):
                                        try:
                                            bytes_val = int(parts[i + 1])
                                            if 'rx' in line.lower() or 'input' in line.lower():
                                                errors['rx_bytes'] = bytes_val
                                            elif 'tx' in line.lower() or 'output' in line.lower():
                                                errors['tx_bytes'] = bytes_val
                                        except ValueError:
                                            pass
                                elif 'errors:' in part.lower():
                                    if i + 1 < len(parts):
                                        try:
                                            error_count = int(parts[i + 1])
                                            if 'rx' in line.lower() or 'input' in line.lower():
                                                errors['rx_errors'] = error_count
                                            elif 'tx' in line.lower() or 'output' in line.lower():
                                                errors['tx_errors'] = error_count
                                        except ValueError:
                                            pass
        except Exception as e:
            if self.verbose:
                print(f"⚠️  Could not get alternative interface statistics: {e}")
        
        return errors
    
    def get_routing_info(self) -> List[RouteInfo]:
        """Get routing table information"""
        exit_code, stdout, stderr = self.run_command(['ip', 'route', 'show'])
        if exit_code != 0:
            # Fallback to route command
            exit_code, stdout, stderr = self.run_command(['route', '-n'])
            if exit_code != 0:
                return []
        
        routes = []
        if 'ip' in ' '.join(['ip', 'route', 'show']):
            # Parse ip route output
            for line in stdout.split('\n'):
                if line.strip():
                    parts = line.split()
                    if len(parts) >= 3:
                        destination = parts[0]
                        gateway = ""
                        interface = ""
                        metric = 0
                        is_default = destination == "default"
                        
                        for i, part in enumerate(parts):
                            if part == "via":
                                gateway = parts[i + 1]
                            elif part == "dev":
                                interface = parts[i + 1]
                            elif part == "metric":
                                metric = int(parts[i + 1])
                        
                        routes.append(RouteInfo(
                            destination=destination,
                            gateway=gateway,
                            interface=interface,
                            metric=metric,
                            is_default=is_default
                        ))
        else:
            # Parse route command output
            for line in stdout.split('\n'):
                if line.strip() and not line.startswith('Kernel'):
                    parts = line.split()
                    if len(parts) >= 8:
                        destination = parts[0]
                        gateway = parts[1]
                        interface = parts[7]
                        metric = int(parts[6]) if parts[6].isdigit() else 0
                        is_default = destination == "0.0.0.0"
                        
                        routes.append(RouteInfo(
                            destination=destination,
                            gateway=gateway,
                            interface=interface,
                            metric=metric,
                            is_default=is_default
                        ))
        
        return routes
    
    def test_connectivity(self, interface: str, target: str = "8.8.8.8") -> bool:
        """Test connectivity from a specific interface"""
        try:
            # Create a socket bound to the interface
            sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            sock.settimeout(5)
            
            # Try to send a packet
            sock.sendto(b'test', (target, 53))
            sock.close()
            return True
        except Exception as e:
            if self.verbose:
                print(f"❌ Connectivity test failed: {e}")
            return False
    
    def analyze_interface(self, interface: str) -> None:
        """Analyze a specific interface"""
        print(f"\n🔍 Analyzing interface: {interface}")
        print("=" * 50)
        
        info = self.get_interface_info(interface)
        if not info:
            # Determine if this is a known educational interface
            clean_name = interface.split('@')[0]
            interface_type = self._get_interface_type(interface)
            
            if interface_type in ['IP-in-IP Tunnel', 'GRE Tunnel', 'GRE TAP Interface', 'IPv6-over-IPv4 Tunnel', 'IPv4 VTI Tunnel', 'IPv6 VTI Tunnel', 'IPv6 Tunnel', 'IPv6 GRE Tunnel', 'ERSPAN Tunnel']:
                print(f"📡 Interface: {interface} ({interface_type})")
                print(f"🔌 State: DOWN (requires configuration)")
            elif '@if' in interface and interface_type == 'Ethernet':
                print(f"📡 Interface: {interface} (Docker Internal)")
                print(f"🔌 State: Active (Docker managed)")
            else:
                print(f"❌ Could not get information for interface {interface}")
                if self.verbose:
                    print(f"   This may be a virtual or Docker internal interface")
            
            # Show educational information
            if interface_type in ['IP-in-IP Tunnel', 'GRE Tunnel', 'GRE TAP Interface', 'IPv6-over-IPv4 Tunnel', 'IPv4 VTI Tunnel', 'IPv6 VTI Tunnel', 'IPv6 Tunnel', 'IPv6 GRE Tunnel', 'ERSPAN Tunnel']:
                print(f"💡 Educational: {self._get_interface_description(interface)}")
                print(f"📝 Note: This interface is in DOWN state and requires configuration to be active")
            elif '@if' in interface and interface_type == 'Ethernet':
                print(f"💡 Educational: Docker internal network interface")
                print(f"📝 Note: This is Docker's internal networking - connects container to host network")
                print(f"🔗 Purpose: Provides network connectivity between container and Docker bridge")
            return
        
        # Basic information
        print(f"📡 Interface: {info.name}")
        print(f"🔌 State: {info.state}")
        print(f"📏 MTU: {info.mtu}")
        print(f"🔗 MAC Address: {info.mac_address}")
        
        # Enhanced type description
        interface_type = self._get_interface_type(info.name)
        print(f"🌐 Type: {interface_type}")
        
        # Add educational context for virtual interfaces
        if self.is_container and interface_type in ['IP-in-IP Tunnel', 'GRE Tunnel', 'GRE TAP Interface', 'IPv6-over-IPv4 Tunnel']:
            print(f"💡 Educational: {self._get_interface_description(info.name)}")
        
        # IP addresses
        if info.ip_addresses:
            print(f"📍 IP Addresses:")
            for ip in info.ip_addresses:
                print(f"   • {ip}")
        else:
            print("📍 IP Addresses: None assigned")
        
        # Statistics
        if info.errors:
            print(f"📊 Statistics:")
            print(f"   • RX Bytes: {info.errors.get('rx_bytes', 0):,}")
            print(f"   • RX Packets: {info.errors.get('rx_packets', 0):,}")
            print(f"   • RX Errors: {info.errors.get('rx_errors', 0):,}")
            print(f"   • TX Bytes: {info.errors.get('tx_bytes', 0):,}")
            print(f"   • TX Packets: {info.errors.get('tx_packets', 0):,}")
            print(f"   • TX Errors: {info.errors.get('tx_errors', 0):,}")
        
        # Connectivity test
        if info.is_up and not info.is_loopback:
            print(f"🔗 Connectivity Test:")
            if self.test_connectivity(interface):
                print("   ✅ Interface can send packets")
            else:
                print("   ❌ Interface cannot send packets")
    
    def analyze_all_interfaces(self) -> None:
        """Analyze all network interfaces"""
        print("🔍 Analyzing all network interfaces")
        print("=" * 50)
        
        # Show environment context
        if self.is_container:
            print("🐳 Running in container environment")
        else:
            print("🖥️  Running on host system")
        
        interfaces = self.get_interface_list()
        if not interfaces:
            print("❌ No network interfaces found")
            return
        
        print(f"📡 Found {len(interfaces)} analyzable interfaces: {', '.join(interfaces)}")
        if self.verbose:
            if self.is_container:
                print("ℹ️  Note: Docker internal interfaces and virtual tunnels are filtered out")
            else:
                print("ℹ️  Note: Only useful interfaces are shown (virtual tunnels filtered)")
        
        for interface in interfaces:
            self.analyze_interface(interface)
    
    def show_routing_info(self) -> None:
        """Show routing table information"""
        print("\n🛣️  Routing Table")
        print("=" * 50)
        
        routes = self.get_routing_info()
        if not routes:
            print("❌ Could not get routing information")
            return
        
        print(f"📍 Found {len(routes)} routes:")
        for route in routes:
            route_type = "DEFAULT" if route.is_default else "ROUTE"
            print(f"   {route_type}: {route.destination} via {route.gateway} dev {route.interface} (metric: {route.metric})")
    
    def show_statistics(self) -> None:
        """Show detailed network statistics"""
        print("\n📊 Network Statistics")
        print("=" * 50)
        
        try:
            with open('/proc/net/dev', 'r') as f:
                lines = f.readlines()
                print("Interface Statistics:")
                for line in lines[2:]:  # Skip header lines
                    if line.strip():
                        parts = line.split(':')
                        if len(parts) == 2:
                            interface = parts[0].strip()
                            stats = parts[1].strip().split()
                            if len(stats) >= 16:
                                print(f"   {interface}:")
                                print(f"     RX: {stats[0]} bytes, {stats[1]} packets, {stats[2]} errors")
                                print(f"     TX: {stats[8]} bytes, {stats[9]} packets, {stats[10]} errors")
        except Exception as e:
            print(f"❌ Could not read network statistics: {e}")
    
    def run_analysis(self, interface: Optional[str] = None, show_routing: bool = False, 
                    show_statistics: bool = False, test_connectivity: bool = False) -> None:
        """Run the complete analysis"""
        print("🚀 Network Interface Analyzer")
        print("=" * 50)
        
        # Show environment detection
        if self.verbose:
            if self.is_container:
                print("🐳 Container environment detected")
            else:
                print("🖥️  Host system environment detected")
        
        if interface:
            self.analyze_interface(interface)
        else:
            self.analyze_all_interfaces()
        
        if show_routing:
            self.show_routing_info()
        
        if show_statistics:
            self.show_statistics()
        
        if test_connectivity:
            print("\n🔗 Connectivity Tests")
            print("=" * 50)
            interfaces = self.get_interface_list()
            for iface in interfaces:
                info = self.get_interface_info(iface)
                if info and info.is_up and not info.is_loopback:
                    print(f"Testing {iface}...")
                    if self.test_connectivity(iface):
                        print(f"   ✅ {iface}: OK")
                    else:
                        print(f"   ❌ {iface}: Failed")

def main():
    """Main function"""
    parser = argparse.ArgumentParser(
        description="Network Interface Analyzer",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__
    )
    
    parser.add_argument(
        '-i', '--interface',
        help='Analyze specific interface'
    )
    
    parser.add_argument(
        '-a', '--all',
        action='store_true',
        help='Analyze all interfaces (default)'
    )
    
    parser.add_argument(
        '-l', '--list',
        action='store_true',
        help='List all available interfaces'
    )
    
    parser.add_argument(
        '-s', '--statistics',
        action='store_true',
        help='Show detailed statistics'
    )
    
    parser.add_argument(
        '-r', '--routing',
        action='store_true',
        help='Show routing information'
    )
    
    parser.add_argument(
        '-t', '--test',
        action='store_true',
        help='Test connectivity'
    )
    
    parser.add_argument(
        '-v', '--verbose',
        action='store_true',
        help='Verbose output'
    )
    
    args = parser.parse_args()
    
    # Create analyzer
    analyzer = InterfaceAnalyzer(verbose=args.verbose)
    
    # Run analysis
    try:
        if args.list:
            # List all available interfaces
            print("📋 Available Network Interfaces")
            print("=" * 50)
            
            # Show environment context
            if analyzer.is_container:
                print("🐳 Running in container environment")
            else:
                print("🖥️  Running on host system")
            
            all_interfaces = analyzer.get_interface_list()
            analyzable_interfaces = [iface for iface in all_interfaces if analyzer._should_analyze_interface(iface)]
            
            print(f"\n📡 All interfaces found: {len(all_interfaces)}")
            for iface in all_interfaces:
                status = "✅ Analyzable" if analyzer._should_analyze_interface(iface) else "⏭️  Filtered"
                interface_type = analyzer._get_interface_type(iface)
                print(f"   • {iface} ({interface_type}) - {status}")
            
            print(f"\n🎯 Analyzable interfaces: {len(analyzable_interfaces)}")
            for iface in analyzable_interfaces:
                interface_type = analyzer._get_interface_type(iface)
                print(f"   • {iface} ({interface_type})")
            
            if analyzer.is_container:
                print(f"\n💡 Educational interfaces available:")
                educational = ['tunl0', 'gre0', 'gretap0', 'sit0', 'tun0', 'tap0']
                for iface in educational:
                    if iface in all_interfaces:
                        desc = analyzer._get_interface_description(iface)
                        print(f"   • {iface}: {desc}")
        else:
            analyzer.run_analysis(
                interface=args.interface,
                show_routing=args.routing,
                show_statistics=args.statistics,
                test_connectivity=args.test
            )
            print("\n✅ Analysis completed successfully")
    except KeyboardInterrupt:
        print("\n⏹️  Analysis interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Analysis failed: {e}")
        if args.verbose:
            import traceback
            traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()
