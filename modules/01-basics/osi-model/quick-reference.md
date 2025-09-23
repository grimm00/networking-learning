# OSI Model Quick Reference

## The 7 Layers (Top to Bottom)

| Layer | Name | Purpose | Data Unit | Key Protocols | Devices |
|-------|------|---------|-----------|---------------|---------|
| 7 | Application | User interface, application services | Data | HTTP, HTTPS, FTP, SMTP, DNS, SSH | Gateways, Firewalls |
| 6 | Presentation | Data translation, encryption, compression | Data | SSL/TLS, JPEG, MPEG, ASCII | Gateways, Firewalls |
| 5 | Session | Session management, dialog control | Data | NetBIOS, RPC, SQL, NFS | Gateways, Firewalls |
| 4 | Transport | End-to-end reliability, flow control | Segments/Datagrams | TCP, UDP, SCTP | Firewalls, Load Balancers |
| 3 | Network | Logical addressing, routing | Packets | IP, ICMP, ARP, OSPF, BGP | Routers, Layer 3 Switches |
| 2 | Data Link | Physical addressing, error detection | Frames | Ethernet, WiFi, PPP | Switches, Bridges, NICs |
| 1 | Physical | Physical transmission | Bits | Ethernet cables, WiFi radio | Hubs, Repeaters, Cables |

## Memory Aids

### Mnemonics
- **Top to Bottom**: "All People Seem To Need Data Processing"
- **Bottom to Top**: "Please Do Not Throw Sausage Pizza Away"

### Layer Numbers
- **7**: Application (A)
- **6**: Presentation (P)
- **5**: Session (S)
- **4**: Transport (T)
- **3**: Network (N)
- **2**: Data Link (D)
- **1**: Physical (P)

## Data Flow

### Encapsulation (Sending)
```
User Data
    ↓ + App Header
Application Data
    ↓ + Presentation Header
Presentation Data
    ↓ + Session Header
Session Data
    ↓ + Transport Header
Transport Segment
    ↓ + Network Header
Network Packet
    ↓ + Data Link Header
Data Link Frame
    ↓ + Physical Transmission
Bits
```

### Decapsulation (Receiving)
```
Bits
    ↓ - Physical Transmission
Data Link Frame
    ↓ - Data Link Header
Network Packet
    ↓ - Network Header
Transport Segment
    ↓ - Transport Header
Session Data
    ↓ - Session Header
Presentation Data
    ↓ - Presentation Header
Application Data
    ↓ - App Header
User Data
```

## Common Protocols by Layer

### Layer 7 (Application)
- **HTTP/HTTPS**: Web browsing
- **FTP**: File transfer
- **SMTP**: Email sending
- **DNS**: Domain name resolution
- **SSH**: Secure shell
- **Telnet**: Remote terminal

### Layer 6 (Presentation)
- **SSL/TLS**: Encryption
- **JPEG/PNG**: Image formats
- **MPEG/AVI**: Video formats
- **ASCII/Unicode**: Text encoding

### Layer 5 (Session)
- **NetBIOS**: Windows networking
- **RPC**: Remote procedure calls
- **SQL**: Database sessions
- **NFS**: Network file system

### Layer 4 (Transport)
- **TCP**: Reliable, connection-oriented
- **UDP**: Unreliable, connectionless
- **SCTP**: Stream control transmission

### Layer 3 (Network)
- **IPv4/IPv6**: Internet Protocol
- **ICMP**: Internet Control Message
- **ARP**: Address Resolution Protocol
- **OSPF**: Open Shortest Path First
- **BGP**: Border Gateway Protocol

### Layer 2 (Data Link)
- **Ethernet**: Most common LAN protocol
- **WiFi (802.11)**: Wireless networking
- **PPP**: Point-to-Point Protocol
- **Frame Relay**: WAN protocol

### Layer 1 (Physical)
- **Ethernet cables**: Cat5, Cat6, Cat7
- **WiFi radio**: 2.4GHz, 5GHz
- **Fiber optic**: Single mode, multimode
- **Coaxial**: Cable internet

## Troubleshooting by Layer

### Layer 7 Issues
- Application not responding
- Authentication failures
- Protocol errors

### Layer 6 Issues
- Encryption/decryption problems
- Data format incompatibility
- Compression issues

### Layer 5 Issues
- Session timeouts
- Session hijacking
- Connection drops

### Layer 4 Issues
- Port not available
- Connection refused
- Timeout errors

### Layer 3 Issues
- Routing problems
- IP address conflicts
- Network unreachable

### Layer 2 Issues
- MAC address problems
- Switch port issues
- Duplex mismatches

### Layer 1 Issues
- Cable problems
- Interface down
- Physical damage

## Quick Commands

### Layer 7 (Application)
```bash
curl -v http://example.com          # HTTP request
ssh user@hostname                   # SSH connection
telnet hostname 80                  # Telnet connection
```

### Layer 4 (Transport)
```bash
netstat -tuln                       # Show listening ports
ss -tuln                           # Show listening ports (modern)
telnet hostname port                # Test TCP connection
```

### Layer 3 (Network)
```bash
ping hostname                       # Test connectivity
traceroute hostname                 # Trace route
ip route show                      # Show routing table
```

### Layer 2 (Data Link)
```bash
arp -a                             # Show ARP table
ifconfig                           # Show interfaces
ip link show                       # Show interfaces (modern)
```

### Layer 1 (Physical)
```bash
ifconfig                           # Show interface status
ethtool interface                  # Show interface details
iwconfig                           # Show wireless interfaces
```

## Key Concepts

### Encapsulation
- Each layer adds its own header to the data
- Headers contain layer-specific information
- Data becomes more complex as it goes down the stack

### Decapsulation
- Each layer removes its header
- Headers are processed and discarded
- Data becomes simpler as it goes up the stack

### Layer Independence
- Each layer operates independently
- Changes in one layer don't affect others
- Allows for modular network design

### Protocol Stacks
- Multiple protocols can work together
- Each layer can have multiple protocols
- Protocols are chosen based on requirements
