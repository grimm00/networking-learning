#!/bin/bash

# Create Learning Interfaces Script
# Adds educational virtual interfaces to the container for networking practice

echo "🚀 Creating Educational Network Interfaces"
echo "============================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root (use sudo)"
    exit 1
fi

# Create TUN interface for user-space networking
echo "📡 Creating TUN interface (tun0)..."
ip tuntap add dev tun0 mode tun
ip link set tun0 up
echo "✅ Created tun0 - TUN interface for user-space applications"

# Create TAP interface for bridging
echo "📡 Creating TAP interface (tap0)..."
ip tuntap add dev tap0 mode tap
ip link set tap0 up
echo "✅ Created tap0 - TAP interface for bridging virtual machines"

# Create VLAN interface (requires parent interface)
echo "📡 Creating VLAN interface (vlan100)..."
if ip link show eth0 >/dev/null 2>&1; then
    ip link add link eth0 name vlan100 type vlan id 100
    ip link set vlan100 up
    echo "✅ Created vlan100 - VLAN interface on eth0"
else
    echo "⚠️  Skipping VLAN creation - no suitable parent interface found"
fi

# Create bridge interface
echo "📡 Creating bridge interface (br0)..."
ip link add name br0 type bridge
ip link set br0 up
echo "✅ Created br0 - Bridge interface for connecting networks"

# Create bond interface (requires multiple interfaces)
echo "📡 Creating bond interface (bond0)..."
if ip link show eth0 >/dev/null 2>&1 && ip link show eth1 >/dev/null 2>&1; then
    ip link add name bond0 type bond mode active-backup
    ip link set eth0 master bond0
    ip link set eth1 master bond0
    ip link set bond0 up
    echo "✅ Created bond0 - Bond interface for link aggregation"
else
    echo "⚠️  Skipping bond creation - insufficient interfaces for bonding"
fi

# Show all interfaces
echo ""
echo "📋 Current Network Interfaces:"
echo "=============================="
ip link show | grep -E "^[0-9]+:" | while read line; do
    interface=$(echo $line | cut -d: -f2 | tr -d ' ')
    echo "• $interface"
done

echo ""
echo "🎓 Educational Interfaces Created!"
echo "=================================="
echo "These interfaces demonstrate different networking concepts:"
echo "• TUN/TAP: User-space networking and virtualization"
echo "• VLAN: Virtual LAN segmentation"
echo "• Bridge: Network bridging and switching"
echo "• Bond: Link aggregation and redundancy"
echo ""
echo "Use 'interface-analyzer.py' to analyze these interfaces!"
