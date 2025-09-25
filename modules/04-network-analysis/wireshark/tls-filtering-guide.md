# TLS Traffic Filtering for Decryption

## 🎯 **Goal**: Filter TLS traffic to specific sites for decryption analysis

Instead of seeing ALL TLS traffic, let's focus on just a few specific sites.

## 🔍 **TLS Filtering Strategies**

### 1. **Filter by Specific IP Address**
```bash
# Filter TLS traffic to/from a specific IP
ip.addr == 142.250.191.14 and tls
```
- **142.250.191.14** is Google's IP
- This shows only TLS traffic to/from Google

### 2. **Filter by Domain Name (if you have the IP)**
```bash
# First, find the IP of the site you want
nslookup google.com

# Then filter by that IP
ip.addr == [IP_ADDRESS] and tls
```

### 3. **Filter by Port 443 (HTTPS)**
```bash
# Show only HTTPS traffic
tcp.port == 443
```
- This shows all HTTPS traffic (still a lot, but more focused)

### 4. **Filter by Specific Host in TLS Handshake**
```bash
# Filter by TLS Server Name Indication (SNI)
tls.handshake.extensions_server_name == "google.com"
```
- This shows TLS handshakes for specific domains

## 🎯 **Recommended Approach for Learning**

### **Step 1: Pick 2-3 Specific Sites**
Choose sites you can easily identify:
- **google.com** (easy to recognize)
- **github.com** (if you use it)
- **stackoverflow.com** (if you visit it)

### **Step 2: Find Their IP Addresses**
```bash
# Find IP addresses
nslookup google.com
nslookup github.com
nslookup stackoverflow.com
```

### **Step 3: Create Focused Filters**
```bash
# Filter for specific sites only
(ip.addr == 142.250.191.14 or ip.addr == 140.82.112.4) and tls
```

## 🛠️ **Practical TLS Decryption Lab**

### **Setup for Decryption**
1. **Choose a site you control** (like a local server)
2. **Generate your own TLS traffic**
3. **Use a site where you can get the private key**

### **Alternative: Use Sample Captures**
- Download sample TLS captures from Wireshark
- These often come with decryption keys
- Focus on learning the decryption process

## 🔍 **TLS Filter Examples**

### **Filter for Google Only**
```bash
ip.addr == 142.250.191.14 and tls
```

### **Filter for Multiple Sites**
```bash
(ip.addr == 142.250.191.14 or ip.addr == 140.82.112.4 or ip.addr == 151.101.1.69) and tls
```

### **Filter for TLS Handshakes Only**
```bash
tls.handshake.type == 1
```
- Shows only Client Hello messages

### **Filter for TLS Application Data**
```bash
tls.record.content_type == 23
```
- Shows only encrypted application data

## 💡 **Pro Tips for TLS Analysis**

1. **Start with handshakes** - they're not encrypted
2. **Use IP filters** - much more focused than domain filters
3. **Look for patterns** - TLS has predictable structures
4. **Use statistics** - see which sites generate the most TLS traffic

## 🎓 **Learning Progression**

1. **Basic TLS filtering** (this guide)
2. **TLS handshake analysis** (unencrypted parts)
3. **TLS decryption** (with private keys)
4. **TLS security analysis** (cipher suites, certificates)

## 🚀 **Quick Start**

1. **Pick one site** (like google.com)
2. **Find its IP**: `nslookup google.com`
3. **Filter**: `ip.addr == [IP] and tls`
4. **Visit the site** while capturing
5. **Analyze the TLS handshake** (unencrypted part)

---

**This approach gives you focused, manageable TLS traffic instead of the overwhelming flood!**
