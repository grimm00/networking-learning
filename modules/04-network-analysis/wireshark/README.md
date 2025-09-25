# Wireshark Network Protocol Analyzer

## Overview

Wireshark is the world's most widely used network protocol analyzer. It lets you see what's happening on your network at a microscopic level and is the de facto standard across many commercial and non-profit enterprises, government agencies, and educational institutions.

**🎯 Primary Learning Focus**: This module emphasizes the **graphical user interface (GUI)** version of Wireshark, which provides the most intuitive and powerful experience for network analysis. While command-line tools (tshark) are covered for automation and scripting, the GUI is where most learning and analysis happens.

## Table of Contents

- [Wireshark Fundamentals](#wireshark-fundamentals)
- [Installation and Setup](#installation-and-setup)
- [User Interface Overview](#user-interface-overview)
- [Packet Capture](#packet-capture)
- [Display Filters](#display-filters)
- [Protocol Analysis](#protocol-analysis)
- [Statistical Analysis](#statistical-analysis)
- [Advanced Features](#advanced-features)
- [Troubleshooting Networks](#troubleshooting-networks)
- [Security Analysis](#security-analysis)
- [Performance Analysis](#performance-analysis)
- [Practical Labs](#practical-labs)
- [Troubleshooting](#troubleshooting)

## Wireshark Fundamentals

### What is Wireshark?

Wireshark is a network packet analyzer that captures network packets and displays them in a human-readable format. It provides:

- **Real-time packet capture** from live network interfaces
- **Offline analysis** of previously captured packet files
- **Deep inspection** of hundreds of protocols
- **Powerful filtering** and search capabilities
- **Statistical analysis** and reporting tools

### Key Features

1. **Multi-Platform**: Runs on Windows, macOS, Linux, and Unix
2. **Live Capture**: Real-time packet capture from network interfaces
3. **Offline Analysis**: Analyze previously captured packet files
4. **Protocol Support**: Hundreds of protocols supported
5. **Powerful Filtering**: Display and capture filters
6. **Statistical Analysis**: Built-in statistics and graphs
7. **Export Capabilities**: Export to various formats
8. **Decryption Support**: Decrypt encrypted protocols

### When to Use Wireshark

- **Network Troubleshooting**: Diagnose connectivity and performance issues
- **Security Analysis**: Detect malicious traffic and attacks
- **Protocol Learning**: Understand how network protocols work
- **Performance Analysis**: Identify bottlenecks and latency issues
- **Compliance**: Monitor network traffic for compliance requirements
- **Development**: Debug network applications

### GUI vs Command-Line Interface

#### **Wireshark GUI (Recommended for Learning)**
- **Visual Interface**: Intuitive point-and-click analysis
- **Real-time Visualization**: See packets as they're captured
- **Interactive Filtering**: Easy display filter application
- **Protocol Decoding**: Automatic protocol field highlighting
- **Statistical Tools**: Built-in graphs and analysis tools
- **Stream Following**: Visual stream reconstruction
- **Color Coding**: Automatic packet coloring by protocol
- **Best For**: Learning, interactive analysis, troubleshooting

#### **tshark Command-Line (Advanced/Automation)**
- **Scripting**: Automated analysis and reporting
- **Remote Capture**: Capture from remote systems
- **Batch Processing**: Process multiple files
- **Integration**: Embed in other tools and scripts
- **Resource Efficiency**: Lower memory and CPU usage
- **Best For**: Automation, scripting, server environments

**💡 Learning Recommendation**: Start with the GUI for hands-on learning, then use command-line tools for automation and advanced scripting.

## Installation and Setup

### System Requirements

#### Minimum Requirements
- **CPU**: 1 GHz processor
- **RAM**: 512 MB (1 GB recommended)
- **Storage**: 100 MB for installation
- **Network**: Network interface for packet capture

#### Recommended Requirements
- **CPU**: Multi-core processor
- **RAM**: 4 GB or more
- **Storage**: 1 GB for installation and captures
- **Network**: Gigabit network interface

### Installation Methods

#### Windows
```powershell
# Download from official website
# https://www.wireshark.org/download.html

# Or using Chocolatey
choco install wireshark

# Or using winget
winget install WiresharkFoundation.Wireshark
```

#### macOS
```bash
# Using Homebrew
brew install wireshark

# Or download from official website
# https://www.wireshark.org/download.html
```

#### Linux (Ubuntu/Debian)
```bash
# Install Wireshark
sudo apt-get update
sudo apt-get install wireshark

# Add user to wireshark group for packet capture
sudo usermod -a -G wireshark $USER

# Log out and back in for group changes to take effect
```

#### Linux (CentOS/RHEL/Fedora)
```bash
# Install Wireshark
sudo yum install wireshark
# or
sudo dnf install wireshark

# Add user to wireshark group
sudo usermod -a -G wireshark $USER
```

### Initial Configuration

#### 1. Interface Selection
- **Identify available interfaces**: `ip link show` (Linux) or `ifconfig` (macOS)
- **Choose appropriate interface**: Usually `eth0`, `wlan0`, or `en0`
- **Consider promiscuous mode**: Captures all packets, not just destined to your machine

#### 2. Capture Permissions
```bash
# Linux: Add user to wireshark group
sudo usermod -a -G wireshark $USER

# Or run with sudo (not recommended for GUI)
sudo wireshark

# macOS: Grant permissions in System Preferences
# System Preferences > Security & Privacy > Privacy > Full Disk Access
```

#### 3. Basic Settings
- **Capture buffer size**: Default is usually sufficient
- **Capture file size**: Set appropriate limits for long captures
- **Capture file format**: PCAPNG (recommended) or PCAP

## User Interface Overview

### 🖥️ **Wireshark GUI - Your Primary Learning Environment**

The Wireshark graphical interface is designed for intuitive network analysis. Here's your complete guide to navigating and using the GUI effectively.

### Main Window Components

#### 1. Menu Bar
- **File**: Open, save, export, and print functions
- **Edit**: Find, preferences, and configuration
- **View**: Display options and zoom controls
- **Go**: Navigation between packets
- **Capture**: Start/stop capture and interface selection
- **Analyze**: Display filters and follow streams
- **Statistics**: Various statistical analysis tools
- **Telephony**: Voice and video analysis tools
- **Wireless**: Wireless network analysis
- **Tools**: Additional tools and utilities
- **Help**: Documentation and support

**💡 Pro Tip**: Most common tasks can be accessed through the toolbar or right-click menus - you don't need to memorize every menu item!

#### 2. Toolbar
- **Interface Selection**: Choose capture interface
- **Start/Stop Capture**: Control packet capture
- **Capture Options**: Configure capture settings
- **Display Filter**: Apply display filters
- **Colorize**: Enable/disable packet coloring
- **Zoom**: Adjust packet list size

#### 3. Packet List Pane
- **No.**: Packet number in capture
- **Time**: Timestamp of packet
- **Source**: Source IP address
- **Destination**: Destination IP address
- **Protocol**: Highest layer protocol
- **Length**: Packet length in bytes
- **Info**: Summary information about packet

#### 4. Packet Details Pane
- **Protocol Tree**: Hierarchical view of packet contents
- **Expandable Fields**: Click to expand/collapse sections
- **Field Information**: Details about selected field
- **Right-click Menu**: Additional options for fields

#### 5. Packet Bytes Pane
- **Hex Dump**: Hexadecimal representation of packet
- **ASCII View**: ASCII representation of packet data
- **Highlighting**: Selected field highlighted in both views

### Navigation and Selection

#### Packet Navigation
- **Up/Down Arrows**: Move between packets
- **Page Up/Down**: Move by page
- **Home/End**: Go to first/last packet
- **Ctrl+G**: Go to specific packet number
- **Ctrl+F**: Find packets

#### Field Selection
- **Click**: Select field in protocol tree
- **Double-click**: Follow protocol stream
- **Right-click**: Context menu with options
- **Ctrl+Click**: Add to display filter

## Packet Capture

### Starting a Capture

#### 1. Interface Selection
```
Capture → Options → Select Interface
```
- **Available Interfaces**: List of network interfaces
- **Traffic**: Real-time traffic indicator
- **Link-layer Header**: Type of link-layer protocol
- **Capture Filter**: Pre-capture filtering

#### 2. Capture Options
```
Capture → Options → Capture Options
```
- **Interface**: Select capture interface
- **Promiscuous Mode**: Capture all packets (recommended)
- **Capture Filter**: BPF filter for pre-capture filtering
- **File**: Save capture to file
- **Ring Buffer**: Rotate capture files
- **Stop Conditions**: Automatic stop conditions

#### 3. Capture Filters
```bash
# Common capture filters
host 192.168.1.100          # Traffic to/from specific host
net 192.168.1.0/24          # Traffic to/from network
port 80                     # Traffic on specific port
tcp port 80                 # TCP traffic on port 80
udp port 53                 # DNS traffic
icmp                        # ICMP traffic only
not broadcast               # Exclude broadcast traffic
```

### Capture Best Practices

#### 1. Interface Selection
- **Wired vs Wireless**: Wired interfaces typically more reliable
- **Promiscuous Mode**: Enable for complete packet capture
- **Interface Speed**: Match capture to network speed

#### 2. Filtering Strategy
- **Pre-capture Filtering**: Use capture filters to reduce noise
- **Post-capture Filtering**: Use display filters for analysis
- **Combination**: Use both for optimal performance

#### 3. Storage Management
- **File Size Limits**: Set appropriate file size limits
- **Ring Buffer**: Use for continuous monitoring
- **Compression**: Enable for long-term storage

## Display Filters

### Filter Syntax

#### Basic Syntax
```
protocol.field operator value
```

#### Operators
- **==**: Equal to
- **!=**: Not equal to
- **>**: Greater than
- **<**: Less than
- **>=**: Greater than or equal
- **<=**: Less than or equal
- **contains**: Contains substring
- **matches**: Regular expression match

#### Logical Operators
- **and**: Logical AND
- **or**: Logical OR
- **not**: Logical NOT
- **in**: Value in list

### Common Display Filters

#### IP Filters
```bash
# IP address filters
ip.addr == 192.168.1.100
ip.src == 192.168.1.100
ip.dst == 192.168.1.100
ip.addr == 192.168.1.0/24

# IP version filters
ip.version == 4
ip.version == 6
```

#### Protocol Filters
```bash
# Protocol filters
tcp
udp
icmp
arp
dns
http
https
ftp
ssh
telnet
```

#### Port Filters
```bash
# Port filters
tcp.port == 80
udp.port == 53
tcp.srcport == 80
tcp.dstport == 443
tcp.port in {80, 443, 8080}
```

#### Advanced Filters
```bash
# Complex filters
tcp and ip.addr == 192.168.1.100
http and http.request.method == "GET"
dns and dns.flags.response == 0
tcp.flags.syn == 1 and tcp.flags.ack == 0
```

### Filter Examples by Use Case

#### Web Traffic Analysis
```bash
# HTTP traffic
http

# HTTPS traffic
tls or ssl

# Web requests only
http.request

# Specific website
http.host contains "example.com"

# POST requests
http.request.method == "POST"
```

#### Network Troubleshooting
```bash
# Connection issues
tcp.flags.reset == 1

# Slow connections
tcp.analysis.retransmission

# DNS issues
dns and dns.flags.response == 0

# ICMP errors
icmp.type == 3
```

#### Security Analysis
```bash
# Suspicious traffic
tcp.port == 23 or tcp.port == 21

# Large packets
frame.len > 1500

# Unusual protocols
not (tcp or udp or icmp or arp)

# Failed connections
tcp.flags.reset == 1 and tcp.flags.syn == 1
```

## Protocol Analysis

### OSI Model Analysis

#### Layer 1 (Physical)
- **Ethernet**: Frame structure, MAC addresses
- **WiFi**: 802.11 frames, signal strength
- **PPP**: Point-to-point protocol

#### Layer 2 (Data Link)
- **Ethernet**: MAC addresses, VLAN tags
- **ARP**: Address resolution protocol
- **STP**: Spanning tree protocol

#### Layer 3 (Network)
- **IP**: IP addresses, fragmentation
- **ICMP**: Ping, traceroute, error messages
- **IGMP**: Multicast group management

#### Layer 4 (Transport)
- **TCP**: Connection-oriented, reliable
- **UDP**: Connectionless, fast
- **SCTP**: Stream control transmission protocol

#### Layer 5-7 (Session/Presentation/Application)
- **HTTP/HTTPS**: Web traffic
- **DNS**: Domain name resolution
- **FTP**: File transfer
- **SSH**: Secure shell
- **SMTP**: Email

### Deep Packet Inspection

#### TCP Analysis
```bash
# TCP connection establishment
tcp.flags.syn == 1 and tcp.flags.ack == 0

# TCP connection teardown
tcp.flags.fin == 1

# TCP retransmissions
tcp.analysis.retransmission

# TCP window size
tcp.window_size

# TCP sequence numbers
tcp.seq
tcp.ack
```

#### HTTP Analysis
```bash
# HTTP requests
http.request

# HTTP responses
http.response

# HTTP methods
http.request.method == "GET"
http.request.method == "POST"

# HTTP status codes
http.response.code == 200
http.response.code == 404

# HTTP headers
http.user_agent
http.referer
```

#### DNS Analysis
```bash
# DNS queries
dns and dns.flags.response == 0

# DNS responses
dns and dns.flags.response == 1

# DNS record types
dns.qry.type == 1    # A record
dns.qry.type == 28   # AAAA record
dns.qry.type == 15   # MX record

# DNS response codes
dns.flags.rcode == 0  # No error
dns.flags.rcode == 3  # NXDOMAIN
```

## Statistical Analysis

### Built-in Statistics

#### 1. Protocol Hierarchy
```
Statistics → Protocol Hierarchy
```
- **Protocol Distribution**: Percentage of each protocol
- **Byte Count**: Total bytes per protocol
- **Packet Count**: Total packets per protocol

#### 2. Conversations
```
Statistics → Conversations
```
- **Endpoint Statistics**: Traffic between specific hosts
- **Protocol Statistics**: Traffic by protocol
- **Byte/Packet Counts**: Volume statistics

#### 3. I/O Graphs
```
Statistics → I/O Graphs
```
- **Time-based Analysis**: Traffic over time
- **Multiple Filters**: Compare different traffic types
- **Custom Intervals**: Adjustable time intervals

#### 4. Flow Graph
```
Statistics → Flow Graph
```
- **Connection Flow**: Visual representation of connections
- **Sequence Numbers**: TCP sequence analysis
- **Timing Information**: Connection timing

### Advanced Statistics

#### 1. Expert Information
```
Analyze → Expert Information
```
- **Warnings**: Potential issues
- **Notes**: Informational messages
- **Errors**: Protocol errors
- **Chats**: Normal communication

#### 2. Service Response Time
```
Statistics → Service Response Time
```
- **HTTP Response Time**: Web server response times
- **DNS Response Time**: DNS server response times
- **SMB Response Time**: File server response times

#### 3. TCP Stream Analysis
```
Statistics → TCP Stream Graphs
```
- **Time Sequence**: TCP sequence over time
- **Throughput**: Data transfer rate
- **Round Trip Time**: Network latency

## Advanced Features

### Follow Streams

#### TCP Streams
```
Analyze → Follow → TCP Stream
```
- **Bidirectional**: Both directions of communication
- **Unidirectional**: Single direction only
- **Raw Data**: Binary data view
- **ASCII Data**: Text data view

#### UDP Streams
```
Analyze → Follow → UDP Stream
```
- **UDP Communication**: Connectionless protocol analysis
- **DNS Queries**: DNS request/response pairs
- **DHCP Communication**: DHCP client/server exchange

### Decryption Support

#### SSL/TLS Decryption
```
Edit → Preferences → Protocols → TLS
```
- **RSA Keys**: Private key files
- **Pre-master Secrets**: Log files
- **Session Keys**: Key log files

#### WEP/WPA Decryption
```
Edit → Preferences → Protocols → IEEE 802.11
```
- **WEP Keys**: Static WEP keys
- **WPA Passphrases**: WPA/WPA2 passphrases
- **Key Management**: Dynamic key management

### Custom Protocols

#### Protocol Dissectors
- **Lua Scripts**: Custom protocol parsing
- **C Plugins**: High-performance dissectors
- **Built-in**: Hundreds of supported protocols

#### Custom Fields
- **Field Definitions**: Define custom protocol fields
- **Display Filters**: Use custom fields in filters
- **Statistics**: Include custom fields in statistics

## Troubleshooting Networks

### Common Network Issues

#### 1. Connectivity Problems
```bash
# No response to ping
icmp.type == 3

# DNS resolution issues
dns and dns.flags.response == 0

# ARP problems
arp and arp.opcode == 1

# DHCP issues
dhcp and dhcp.option.dhcp == 1
```

#### 2. Performance Issues
```bash
# TCP retransmissions
tcp.analysis.retransmission

# TCP window size problems
tcp.window_size < 1000

# Large packets
frame.len > 1500

# Duplicate packets
tcp.analysis.duplicate_ack
```

#### 3. Security Issues
```bash
# Port scans
tcp.flags.syn == 1 and tcp.flags.ack == 0

# Failed connections
tcp.flags.reset == 1

# Unusual traffic patterns
not (tcp or udp or icmp or arp)

# Large data transfers
tcp.len > 1000
```

### Diagnostic Workflow

#### 1. Capture Strategy
- **Duration**: Capture for sufficient time
- **Filtering**: Use appropriate filters
- **Multiple Interfaces**: Capture from different points

#### 2. Analysis Approach
- **Top-down**: Start with high-level protocols
- **Bottom-up**: Start with low-level protocols
- **Time-based**: Analyze chronological sequence

#### 3. Documentation
- **Screenshots**: Capture important findings
- **Notes**: Document observations
- **Export**: Save relevant packets

## Security Analysis

### Threat Detection

#### 1. Network Scanning
```bash
# Port scans
tcp.flags.syn == 1 and tcp.flags.ack == 0

# Host discovery
arp and arp.opcode == 1

# Service enumeration
tcp.flags.syn == 1 and tcp.flags.ack == 1
```

#### 2. Malicious Traffic
```bash
# Suspicious protocols
tcp.port == 23 or tcp.port == 21

# Unusual patterns
frame.len > 1500 and tcp.port == 80

# Failed authentication
tcp.port == 22 and tcp.flags.reset == 1
```

#### 3. Data Exfiltration
```bash
# Large data transfers
tcp.len > 1000

# Unusual protocols
not (tcp.port in {80, 443, 53, 25, 110, 143})

# Encrypted traffic
tls or ssl
```

### Incident Response

#### 1. Evidence Collection
- **Full Packet Capture**: Complete network traffic
- **Filtered Capture**: Specific traffic of interest
- **Metadata**: Packet timestamps and sizes

#### 2. Analysis Techniques
- **Timeline Analysis**: Chronological event reconstruction
- **Correlation**: Cross-reference multiple sources
- **Pattern Recognition**: Identify attack patterns

#### 3. Reporting
- **Executive Summary**: High-level findings
- **Technical Details**: Detailed analysis
- **Evidence**: Supporting packet captures

## Performance Analysis

### Network Performance Metrics

#### 1. Latency Analysis
```bash
# Round-trip time
tcp.analysis.ack_rtt

# One-way delay
tcp.time_delta

# Jitter
tcp.analysis.ack_lost_segment
```

#### 2. Throughput Analysis
```bash
# Data transfer rate
tcp.len

# Window size
tcp.window_size

# Congestion control
tcp.analysis.retransmission
```

#### 3. Error Analysis
```bash
# Packet loss
tcp.analysis.lost_segment

# Duplicate packets
tcp.analysis.duplicate_ack

# Out-of-order packets
tcp.analysis.out_of_order
```

### Application Performance

#### 1. HTTP Performance
```bash
# Response time
http.time

# Request/response pairs
http.request and http.response

# Status codes
http.response.code
```

#### 2. DNS Performance
```bash
# Query time
dns.time

# Response codes
dns.flags.rcode

# Record types
dns.qry.type
```

## Practical Labs

### 🎯 **GUI-Focused Learning Labs**

These labs are designed to teach you Wireshark through the graphical interface, which is the most effective way to learn network analysis.

### Lab 1: Basic Packet Capture (GUI Workflow)
**Objective**: Learn to capture packets using the Wireshark GUI

**Steps**:
1. **Launch Wireshark GUI**:
   - Open Wireshark from your applications menu
   - You'll see the main Wireshark window

2. **Select Capture Interface**:
   - Click the **shark fin icon** (🦈) in the toolbar
   - Or go to `Capture → Options`
   - Choose your network interface (usually `eth0`, `wlan0`, or `en0`)

3. **Start Capture**:
   - Click the **red shark fin** button to start capturing
   - Watch packets appear in real-time in the packet list

4. **Generate Traffic**:
   - Open a web browser and visit `http://httpbin.org/get`
   - Or run `ping google.com` in a terminal
   - Watch the packets appear in Wireshark

5. **Stop Capture**:
   - Click the **red square** button to stop capturing
   - You now have a captured packet trace to analyze

**🎓 Learning Outcome**: You can capture and view network traffic in real-time

### Lab 2: Display Filters (Interactive Filtering)
**Objective**: Learn to filter packets using the GUI display filter bar

**Steps**:
1. **Open a Capture File**:
   - Use the capture from Lab 1, or open a sample file
   - Go to `File → Open` to load a `.pcap` file

2. **Apply Basic Filters**:
   - Click in the **display filter bar** (top of the window)
   - Type `tcp` and press Enter
   - Notice only TCP packets are shown

3. **Try Common Filters**:
   - `ip.addr == 192.168.1.100` - Filter by IP address
   - `tcp.port == 80` - Filter by port
   - `http` - Show only HTTP traffic
   - `dns` - Show only DNS traffic

4. **Use Filter Suggestions**:
   - Type `tcp.` and see autocomplete suggestions
   - Click the **bookmark icon** (🔖) for saved filters
   - Use the **expression button** for visual filter builder

5. **Clear Filters**:
   - Click the **X** button in the filter bar to clear
   - Or press `Ctrl+Shift+C`

**🎓 Learning Outcome**: You can filter packets to focus on specific traffic

### Lab 3: Protocol Analysis (Deep Dive)
**Objective**: Learn to analyze protocols using the GUI's three-pane view

**Steps**:
1. **Select a Packet**:
   - Click on any packet in the packet list
   - Notice the three-pane view: List, Details, Bytes

2. **Explore Protocol Details**:
   - In the **packet details pane** (middle), expand different protocol layers
   - Click on fields to see them highlighted in the **bytes pane** (bottom)
   - Try expanding: Ethernet → IP → TCP → HTTP

3. **Follow a Stream**:
   - Right-click on a TCP packet
   - Select `Follow → TCP Stream`
   - See the complete conversation between client and server

4. **Analyze Different Protocols**:
   - Find HTTP packets and examine headers
   - Look at DNS packets and see query/response details
   - Examine ARP packets for address resolution

5. **Use Color Coding**:
   - Notice how different protocols are color-coded
   - Go to `View → Coloring Rules` to customize colors
   - Right-click on a packet to change its color

**🎓 Learning Outcome**: You can analyze protocol details and follow conversations

### Lab 4: Statistical Analysis (Built-in Tools)
**Objective**: Learn to use Wireshark's built-in statistical analysis tools

**Steps**:
1. **Open Statistics Menu**:
   - Go to `Statistics` in the menu bar
   - Explore the various analysis tools available

2. **Protocol Hierarchy**:
   - Go to `Statistics → Protocol Hierarchy`
   - See the breakdown of protocols by percentage
   - This shows what types of traffic are on your network

3. **Conversations**:
   - Go to `Statistics → Conversations`
   - See which hosts are talking to each other
   - Click on different tabs (Ethernet, IP, TCP, UDP)

4. **I/O Graphs**:
   - Go to `Statistics → I/O Graphs`
   - Create graphs showing traffic over time
   - Add multiple filters to compare different traffic types

5. **Flow Graph**:
   - Go to `Statistics → Flow Graph`
   - See a visual representation of TCP connections
   - This is great for understanding connection patterns

**🎓 Learning Outcome**: You can use statistical tools to understand network behavior

### Lab 5: Troubleshooting (Real-World Scenarios)
**Objective**: Learn to troubleshoot network issues using GUI analysis

**Steps**:
1. **Identify the Problem**:
   - Look for red or black packets (errors)
   - Check for unusual traffic patterns
   - Look for failed connections

2. **Use Expert Information**:
   - Go to `Analyze → Expert Information`
   - This shows warnings, errors, and notes about your capture
   - Click on items to jump to the relevant packets

3. **Find Connection Issues**:
   - Use filter: `tcp.flags.reset == 1`
   - Look for TCP RST packets indicating failed connections
   - Right-click and follow the stream to see what went wrong

4. **Analyze Performance**:
   - Use filter: `tcp.analysis.retransmission`
   - Look for retransmitted packets indicating network problems
   - Check `tcp.analysis.duplicate_ack` for duplicate acknowledgments

5. **Check DNS Issues**:
   - Use filter: `dns and dns.flags.response == 0`
   - Look for DNS queries that didn't get responses
   - Check response codes in DNS responses

**🎓 Learning Outcome**: You can diagnose network problems using Wireshark's analysis tools

### Lab 6: Advanced GUI Features
**Objective**: Learn advanced GUI features for professional analysis

**Steps**:
1. **Customize the Interface**:
   - Go to `View → Layout` to change pane arrangement
   - Drag column headers to reorder columns
   - Right-click column headers to add/remove columns

2. **Use Bookmarks**:
   - Right-click on interesting packets
   - Select `Mark Packet` to bookmark them
   - Go to `Go → Next Bookmark` to navigate between bookmarks

3. **Export and Save**:
   - Select packets and go to `File → Export Specified Packets`
   - Save filtered packets to a new file
   - Export packet details to CSV or other formats

4. **Use Profiles**:
   - Go to `Edit → Configuration Profiles`
   - Create different profiles for different types of analysis
   - Switch between profiles as needed

5. **Remote Capture**:
   - Go to `Capture → Options`
   - Use remote capture to capture from other machines
   - Configure SSH or other remote access methods

**🎓 Learning Outcome**: You can use advanced GUI features for professional analysis

## Troubleshooting

### Common Issues

#### 1. No Packets Captured
**Symptoms**: Empty packet list
**Causes**:
- Wrong interface selected
- No network traffic
- Insufficient permissions
- Capture filter too restrictive

**GUI Solutions**:
1. **Check Interface Selection**:
   - Go to `Capture → Options`
   - Verify the correct interface is selected
   - Look for traffic indicators (green/red dots)

2. **Verify Permissions**:
   - On Linux: `sudo usermod -a -G wireshark $USER`
   - On macOS: Grant permissions in System Preferences
   - On Windows: Run as Administrator if needed

3. **Check Capture Filter**:
   - Go to `Capture → Options`
   - Clear any capture filters
   - Try capturing without filters first

4. **Generate Test Traffic**:
   - Open a web browser and visit a website
   - Or run `ping google.com` in a terminal
   - Watch for packets in Wireshark

#### 2. GUI Performance Issues
**Symptoms**: Slow interface, frozen windows, high CPU usage
**Causes**:
- High network load
- Insufficient system resources
- Inefficient display filters
- Large capture files

**GUI Solutions**:
1. **Use Capture Filters**:
   - Go to `Capture → Options`
   - Add capture filters to reduce load
   - Example: `host 192.168.1.100`

2. **Optimize Display**:
   - Go to `View → Layout` and choose a simpler layout
   - Disable packet coloring: `View → Coloring Rules → Disable`
   - Hide the bytes pane if not needed

3. **Limit Packet Count**:
   - Go to `Capture → Options`
   - Set a packet count limit
   - Use ring buffer for continuous capture

4. **Close Unnecessary Applications**:
   - Free up system resources
   - Close other network-intensive applications

#### 3. Display Issues
**Symptoms**: Packets not displaying correctly, missing information
**Causes**:
- Corrupted capture file
- Unsupported protocol
- Display filter issues
- GUI rendering problems

**GUI Solutions**:
1. **Check File Integrity**:
   - Go to `File → Properties`
   - Verify file size and packet count
   - Try opening with a different tool

2. **Disable Display Filters**:
   - Clear the display filter bar
   - Press `Ctrl+Shift+C` to clear all filters
   - Check if packets appear without filters

3. **Update Wireshark**:
   - Go to `Help → About Wireshark`
   - Check for updates
   - Update to the latest version

4. **Reset Preferences**:
   - Go to `Edit → Preferences`
   - Reset to default settings
   - Restart Wireshark

#### 4. GUI-Specific Issues
**Symptoms**: Interface not responding, menus not working
**Causes**:
- GUI framework issues
- Display driver problems
- System compatibility issues

**GUI Solutions**:
1. **Restart Wireshark**:
   - Close all Wireshark windows
   - Restart the application
   - Check if the issue persists

2. **Check Display Settings**:
   - Verify display resolution
   - Check for display scaling issues
   - Try different display modes

3. **Update Graphics Drivers**:
   - Update display drivers
   - Check for system updates
   - Restart the system if needed

4. **Use Command Line**:
   - If GUI is completely broken, use `tshark`
   - Export data and analyze elsewhere
   - Report the issue to Wireshark developers

### GUI Best Practices

#### 1. **Interface Layout**
- **Three-pane view**: Keep packet list, details, and bytes visible
- **Customize columns**: Add/remove columns based on your analysis needs
- **Save layouts**: Use different layouts for different types of analysis

#### 2. **Efficient Filtering**
- **Start broad**: Begin with no filters, then narrow down
- **Use autocomplete**: Let Wireshark suggest filter syntax
- **Save common filters**: Bookmark frequently used filters
- **Test filters**: Use the expression builder for complex filters

#### 3. **Performance Optimization**
- **Use capture filters**: Reduce load before packets reach the display
- **Limit packet count**: Set reasonable limits for long captures
- **Disable coloring**: Turn off packet coloring for better performance
- **Close unused panes**: Hide the bytes pane if not needed

#### 4. **Analysis Workflow**
- **Mark interesting packets**: Use bookmarks for important findings
- **Follow streams**: Right-click to follow TCP/UDP streams
- **Use statistics**: Leverage built-in statistical tools
- **Export findings**: Save filtered packets and analysis results

#### 5. **Learning Tips**
- **Start with sample captures**: Use provided sample files to learn
- **Practice with real traffic**: Capture your own network traffic
- **Use the help system**: Built-in help and documentation
- **Join the community**: Wireshark mailing lists and forums

---

## Next Steps

1. **Practice**: Use the provided lab scripts to gain hands-on experience
2. **Analysis**: Use Wireshark to analyze real network traffic
3. **Troubleshooting**: Practice diagnosing network issues
4. **Security**: Learn to identify security threats

For hands-on practice, run:
```bash
# Interactive Wireshark lab
./wireshark-lab.sh

# Wireshark packet analysis
python3 wireshark-analyzer.py

# Troubleshooting guide
./wireshark-troubleshoot.sh
```
