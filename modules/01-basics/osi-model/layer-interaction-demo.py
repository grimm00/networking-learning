#!/usr/bin/env python3
"""
OSI Layer Interaction Demonstration
Shows how you can only interact with layers through the layer above them
"""

import socket
import subprocess
import sys
import time
from typing import List, Dict, Any


class LayerInteractionDemo:
    def __init__(self):
        self.layers = {
            7: "Application",
            6: "Presentation", 
            5: "Session",
            4: "Transport",
            3: "Network",
            2: "Data Link",
            1: "Physical"
        }

    def demonstrate_layer_interaction(self):
        """Demonstrate how you can only interact with layers through the layer above"""
        
        print("=" * 80)
        print("OSI LAYER INTERACTION DEMONSTRATION")
        print("=" * 80)
        print()
        print("Key Principle: You can ONLY interact with a layer through the layer ABOVE it!")
        print("You cannot directly access lower layers - they're abstracted away.")
        print()
        
        # Layer 7 - Application Layer
        print("🔵 LAYER 7 (Application) - This is where YOU interact with the network")
        print("   You can directly use applications like:")
        print("   - Web browsers (HTTP)")
        print("   - Email clients (SMTP/POP3)")
        print("   - File transfer (FTP)")
        print("   - Remote access (SSH)")
        print()
        
        # Layer 6 - Presentation Layer
        print("🟢 LAYER 6 (Presentation) - You access this through Layer 7")
        print("   You CANNOT directly encrypt/decrypt data")
        print("   You access it through applications that handle:")
        print("   - SSL/TLS (through HTTPS in browser)")
        print("   - Image compression (through image viewers)")
        print("   - Character encoding (through text editors)")
        print()
        
        # Layer 5 - Session Layer
        print("🟡 LAYER 5 (Session) - You access this through Layer 7")
        print("   You CANNOT directly manage sessions")
        print("   You access it through applications that handle:")
        print("   - SSH sessions (through SSH client)")
        print("   - Database connections (through database clients)")
        print("   - RPC calls (through application APIs)")
        print()
        
        # Layer 4 - Transport Layer
        print("🟠 LAYER 4 (Transport) - You access this through Layer 7")
        print("   You CANNOT directly create TCP/UDP connections")
        print("   You access it through applications that handle:")
        print("   - TCP connections (through telnet, SSH, HTTP)")
        print("   - UDP communication (through DNS, DHCP)")
        print("   - Port management (through applications)")
        print()
        
        # Layer 3 - Network Layer
        print("🔴 LAYER 3 (Network) - You access this through Layer 7")
        print("   You CANNOT directly send IP packets")
        print("   You access it through applications that handle:")
        print("   - IP addressing (through ping, traceroute)")
        print("   - Routing (through routing applications)")
        print("   - ICMP messages (through ping)")
        print()
        
        # Layer 2 - Data Link Layer
        print("🟣 LAYER 2 (Data Link) - You access this through Layer 7")
        print("   You CANNOT directly send Ethernet frames")
        print("   You access it through applications that handle:")
        print("   - MAC addresses (through ARP, ifconfig)")
        print("   - Frame management (through network tools)")
        print("   - Switch configuration (through management tools)")
        print()
        
        # Layer 1 - Physical Layer
        print("⚫ LAYER 1 (Physical) - You access this through Layer 7")
        print("   You CANNOT directly manipulate bits")
        print("   You access it through applications that handle:")
        print("   - Interface status (through ifconfig, ip link)")
        print("   - Cable testing (through network tools)")
        print("   - Signal analysis (through specialized equipment)")
        print()
        
        print("=" * 80)
        print("KEY INSIGHT: You can't 'touch' the lower layers directly!")
        print("=" * 80)
        print()
        print("Even when you use commands like 'ping' or 'tcpdump', you're still")
        print("using Layer 7 applications that then interact with the lower layers.")
        print()
        print("The OSI model is like a building:")
        print("- You enter through the top floor (Layer 7)")
        print("- You can only go to lower floors through the floors above them")
        print("- You can't jump directly to the basement (Layer 1)")
        print("- Each floor handles its own responsibilities")

    def demonstrate_practical_examples(self):
        """Show practical examples of layer interaction"""
        
        print("\n" + "=" * 80)
        print("PRACTICAL EXAMPLES OF LAYER INTERACTION")
        print("=" * 80)
        print()
        
        print("Example 1: Web Browsing")
        print("-" * 40)
        print("1. You open a web browser (Layer 7 application)")
        print("2. Browser handles HTTP protocol (Layer 7)")
        print("3. Browser uses SSL/TLS (Layer 6) - you don't see this")
        print("4. Browser manages session (Layer 5) - you don't see this")
        print("5. Browser creates TCP connection (Layer 4) - you don't see this")
        print("6. Browser sends IP packets (Layer 3) - you don't see this")
        print("7. Browser sends Ethernet frames (Layer 2) - you don't see this")
        print("8. Browser sends bits over cable (Layer 1) - you don't see this")
        print()
        
        print("Example 2: Using 'ping' command")
        print("-" * 40)
        print("1. You type 'ping 8.8.8.8' (Layer 7 application)")
        print("2. Ping application handles ICMP protocol (Layer 7)")
        print("3. Ping uses IP addressing (Layer 3) - you don't directly control this")
        print("4. Ping sends Ethernet frames (Layer 2) - you don't directly control this")
        print("5. Ping sends bits over cable (Layer 1) - you don't directly control this")
        print()
        
        print("Example 3: Using 'tcpdump' command")
        print("-" * 40)
        print("1. You type 'tcpdump' (Layer 7 application)")
        print("2. Tcpdump captures packets at Layer 2/3")
        print("3. But you're still using a Layer 7 application to do it!")
        print("4. You can't directly access the raw bits - tcpdump does it for you")
        print()
        
        print("Example 4: Network Configuration")
        print("-" * 40)
        print("1. You use 'ifconfig' or 'ip' commands (Layer 7 applications)")
        print("2. These commands configure Layer 2/3 settings")
        print("3. But you're still using Layer 7 applications to do it!")
        print("4. You can't directly manipulate the physical layer")
        print()

    def demonstrate_abstraction(self):
        """Demonstrate the abstraction principle"""
        
        print("\n" + "=" * 80)
        print("ABSTRACTION PRINCIPLE IN ACTION")
        print("=" * 80)
        print()
        
        print("What you CAN do (Layer 7 interactions):")
        print("✅ Open a web browser and visit a website")
        print("✅ Send an email")
        print("✅ Transfer files with FTP")
        print("✅ Use SSH to connect to a server")
        print("✅ Use ping to test connectivity")
        print("✅ Use tcpdump to capture packets")
        print("✅ Configure network interfaces")
        print()
        
        print("What you CANNOT do (direct lower layer access):")
        print("❌ Directly send raw Ethernet frames")
        print("❌ Directly manipulate IP packet headers")
        print("❌ Directly control TCP sequence numbers")
        print("❌ Directly send bits over a cable")
        print("❌ Directly manage MAC addresses")
        print("❌ Directly control physical signals")
        print()
        
        print("Why this abstraction is important:")
        print("🔒 Security: Prevents accidental network damage")
        print("🛠️  Simplicity: You don't need to understand every detail")
        print("🔄 Compatibility: Applications work across different hardware")
        print("📈 Scalability: Changes to lower layers don't affect applications")
        print()

    def run_demo(self):
        """Run the complete demonstration"""
        self.demonstrate_layer_interaction()
        self.demonstrate_practical_examples()
        self.demonstrate_abstraction()
        
        print("\n" + "=" * 80)
        print("SUMMARY")
        print("=" * 80)
        print()
        print("The OSI model is like a building with 7 floors:")
        print("🏢 You can only enter through the top floor (Layer 7)")
        print("🏢 You can only access lower floors through the floors above them")
        print("🏢 You can't jump directly to the basement (Layer 1)")
        print("🏢 Each floor handles its own responsibilities")
        print("🏢 The lower floors are abstracted away from you")
        print()
        print("This is why you can't 'touch' or 'see' bits directly -")
        print("they're handled by the physical layer, which you access")
        print("through applications running at Layer 7!")


def main():
    demo = LayerInteractionDemo()
    demo.run_demo()


if __name__ == "__main__":
    main()
