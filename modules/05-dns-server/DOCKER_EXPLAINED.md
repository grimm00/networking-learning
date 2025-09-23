# Docker Setup Explained - DNS Server Module

This document explains the Docker configuration for the DNS Server module in simple terms, perfect for networking learners.

## 🌐 What is DNS?

**DNS (Domain Name System)** is like the internet's phone book. It converts human-readable names like "google.com" into IP addresses like "142.250.191.14" that computers use to communicate.

**Think of it like this:**
- You know your friend's name: "John Smith"
- But to call him, you need his phone number: "555-1234"
- DNS does the same thing for websites!

## 🐳 What is CoreDNS?

**CoreDNS** is a DNS server software that:
- Answers DNS queries (like "What's the IP for google.com?")
- Can be configured with different plugins
- Runs in Docker containers for easy management
- Is lightweight and fast

## 📁 File Structure

```
05-dns-server/
├── docker-compose.yml          # Main configuration file
├── coredns-configs/            # DNS server configurations
│   ├── basic.conf             # Simple DNS forwarding
│   ├── advanced.conf          # Multiple zones and monitoring
│   └── secure.conf            # DNS over TLS
├── zones/                      # DNS zone files
│   ├── internal.local.db      # Internal network zone
│   └── example.com.db         # Example domain zone
└── README.md                  # Documentation
```

## 🔧 Docker Compose Configuration Explained

### **Basic Structure**
```yaml
services:                    # List of DNS servers to run
  coredns:                   # Name of our first DNS server
    image: coredns/coredns:latest  # Use CoreDNS software
    container_name: coredns-server  # Give it a friendly name
    ports:                   # Port mapping: host_port:container_port
      - "53:53/udp"         # Host port 53 → Container port 53 (DNS UDP)
      - "53:53/tcp"         # Host port 53 → Container port 53 (DNS TCP)
```

### **What Each Part Does:**

#### **1. Image Selection**
```yaml
image: coredns/coredns:latest
```
- **coredns** = DNS server software
- **latest** = Use the newest version
- **Why CoreDNS?** Lightweight, configurable, and perfect for learning

#### **2. Port Mapping**
```yaml
ports:
  - "53:53/udp"
  - "53:53/tcp"
```
- **53** = Standard DNS port (like port 80 for HTTP)
- **UDP** = Fast protocol for simple queries
- **TCP** = Reliable protocol for complex queries
- **Why both?** DNS uses UDP by default, but falls back to TCP for large responses

#### **3. Volume Mounting**
```yaml
volumes:
  - ./coredns-configs:/etc/coredns:ro
```
- **./coredns-configs** = DNS configuration files on your computer
- **:/etc/coredns** = Where they go inside the container
- **:ro** = "read-only" (container can't modify your config files)

#### **4. Command**
```yaml
command: [ "-conf", "/etc/coredns/basic.conf" ]
```
- **-conf** = Tell CoreDNS to use a specific configuration file
- **/etc/coredns/basic.conf** = Path to the config file inside the container

## 🚀 Different DNS Server Types Explained

### **1. Basic DNS Server (coredns)**
```yaml
coredns:
  image: coredns/coredns:latest
  ports:
    - "53:53/udp"
    - "53:53/tcp"
  volumes:
    - ./coredns-configs:/etc/coredns:ro
  command: [ "-conf", "/etc/coredns/basic.conf" ]
```
**What it does:**
- Runs a simple DNS server
- Forwards queries to public DNS servers (like Google DNS)
- **Access:** localhost:53
- **Purpose:** Learn basic DNS forwarding

### **2. Advanced DNS Server (coredns-advanced)**
```yaml
coredns-advanced:
  image: coredns/coredns:latest
  ports:
    - "5353:53/udp"
    - "5353:53/tcp"
  volumes:
    - ./coredns-configs:/etc/coredns:ro
  command: [ "-conf", "/etc/coredns/advanced.conf" ]
  profiles:
    - advanced
```
**What it does:**
- Runs multiple DNS zones
- Serves custom domains (like example.com)
- Has monitoring and logging
- **Access:** localhost:5353
- **Purpose:** Learn DNS zone management

### **3. Secure DNS Server (coredns-secure)**
```yaml
coredns-secure:
  image: coredns/coredns:latest
  ports:
    - "5354:53/udp"
    - "5354:53/tcp"
  volumes:
    - ./coredns-configs:/etc/coredns:ro
  command: [ "-conf", "/etc/coredns/secure.conf" ]
  profiles:
    - secure
```
**What it does:**
- Runs DNS over TLS (encrypted DNS)
- Provides secure DNS resolution
- **Access:** localhost:5354
- **Purpose:** Learn secure DNS protocols

## 🔄 How to Use This Setup

### **Start Basic DNS Server**
```bash
cd 05-dns-server
docker-compose up -d coredns
```
**What happens:**
1. Docker downloads coredns image
2. Creates a container named "coredns-server"
3. Maps port 53 on your computer to port 53 in the container
4. Mounts your DNS configuration files
5. Starts the DNS server

### **Start Advanced DNS Server**
```bash
docker-compose --profile advanced up -d
```
**What happens:**
1. Starts coredns-advanced container
2. Uses advanced configuration with multiple zones
3. Available on port 5353

### **Start All DNS Servers**
```bash
docker-compose up -d
```
**What happens:**
1. Starts coredns (always starts)
2. Starts other servers based on profiles

## 🧪 Testing Your DNS Setup

### **1. Test DNS Resolution**
```bash
nslookup google.com localhost
```
**Expected output:** IP address of google.com

### **2. Test with dig (more detailed)**
```bash
dig @localhost google.com
```
**Expected output:** Detailed DNS response

### **3. Test Custom Domain (Advanced Server)**
```bash
dig @localhost -p 5353 example.com
```
**Expected output:** IP address from your custom zone

### **4. Check Server Status**
```bash
docker-compose ps
```
**Expected output:** List of running DNS containers

## 🔍 DNS Configuration Explained

### **Basic Configuration (basic.conf)**
```
. {
    forward . 8.8.8.8 8.8.4.4
    log
}
```
**What this means:**
- **.** = Handle all domains
- **forward** = Send queries to Google DNS servers
- **8.8.8.8 8.8.4.4** = Google's public DNS servers
- **log** = Log all queries for learning

### **Advanced Configuration (advanced.conf)**
```
example.com {
    file /etc/coredns/zones/example.com.db
    log
}

. {
    forward . 8.8.8.8 8.8.4.4
    log
}
```
**What this means:**
- **example.com** = Handle queries for example.com domain
- **file** = Use zone file for answers
- **.** = Handle all other domains
- **forward** = Send other queries to Google DNS

## 🔍 Common Issues and Solutions

### **Port 53 Already in Use**
```
Error: Bind for 0.0.0.0:53 failed: port is already allocated
```
**Solution:** Your system DNS is using port 53. Use a different port:
```yaml
ports:
  - "5353:53/udp"  # Changed from 53 to 5353
```

### **DNS Not Responding**
```bash
nslookup google.com localhost
# No response
```
**Solution:** Check if container is running:
```bash
docker-compose ps
docker-compose logs coredns
```

### **Configuration Error**
```
CoreDNS failed to start
```
**Solution:** Check your configuration file syntax

## 🎯 Learning Objectives

After understanding this setup, you should be able to:

1. **Explain DNS Concepts**
   - What DNS does
   - How DNS queries work
   - What DNS zones are

2. **Understand DNS Server Configuration**
   - How to forward queries
   - How to create custom zones
   - How to enable logging

3. **Troubleshoot DNS Issues**
   - Port conflicts
   - Configuration errors
   - Query failures

## 🚀 Next Steps

1. **Try Different Queries**
   - Test different domains
   - Compare responses from different servers

2. **Create Custom Zones**
   - Add your own domains
   - Create custom DNS records

3. **Compare DNS Servers**
   - Test basic vs advanced configurations
   - See how logging works

## 💡 Key Takeaways

- **DNS** converts domain names to IP addresses
- **CoreDNS** is a lightweight, configurable DNS server
- **Port 53** is the standard DNS port
- **Zone files** contain DNS records for specific domains
- **Forwarding** sends queries to other DNS servers
- **Profiles** let you start only the services you need

This setup gives you a safe environment to learn DNS server management without affecting your main computer's DNS settings! 🎉
