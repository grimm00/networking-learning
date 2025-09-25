# HTTP Filter Troubleshooting - Why You're Not Seeing HTTP Packets

## 🚨 **The #1 Reason: You're Looking at HTTPS, Not HTTP**

Most websites today use **HTTPS** (encrypted), not **HTTP** (unencrypted). When you visit `google.com`, `facebook.com`, or `amazon.com`, you're using HTTPS.

### What You'll See:
- **HTTPS traffic**: Shows as "TLS" or "TLSv1.3" in Wireshark
- **HTTP traffic**: Shows as "HTTP" in Wireshark

## 🔍 **Quick Test - Does Your Filter Work?**

### Step 1: Visit an HTTP Site
Go to: `http://httpbin.org/get` (note: **http**, not https)

### Step 2: Apply the Filter
In Wireshark, type: `http` (lowercase)

### Step 3: You Should See
- Packets with "HTTP" in the Protocol column
- "GET /get HTTP/1.1" in the Info column

## 🛠️ **Common Issues & Solutions**

### Issue 1: "I see packets but no HTTP"
**Cause**: You're visiting HTTPS sites
**Solution**: Visit `http://httpbin.org/get` instead

### Issue 2: "I don't see any packets at all"
**Cause**: Wrong network interface selected
**Solution**: 
1. Look for the interface with green bars (traffic)
2. Try `wlan0`, `eth0`, or `Wi-Fi`
3. Start capture, then browse

### Issue 3: "The filter doesn't work"
**Cause**: Wrong filter syntax
**Solution**:
- Use `http` (not `HTTP` or `Http`)
- Use `tls` for HTTPS traffic
- Use `tcp.port == 80` for HTTP port

### Issue 4: "I see TLS but want to see the content"
**Cause**: HTTPS is encrypted
**Solution**: 
- You can't see HTTPS content (it's encrypted by design)
- Use `http://httpbin.org/get` to see unencrypted content
- Or look at the TLS handshake process

## 🎯 **Working Examples**

### See HTTP Traffic (Unencrypted)
1. Visit: `http://httpbin.org/get`
2. Filter: `http`
3. Result: You'll see the actual web request

### See HTTPS Traffic (Encrypted)
1. Visit: `https://google.com`
2. Filter: `tls`
3. Result: You'll see encrypted data (not readable)

### See All Web Traffic
1. Visit any website
2. Filter: `tcp.port == 80 or tcp.port == 443`
3. Result: Both HTTP and HTTPS traffic

## 🔬 **What Each Filter Shows**

| Filter | What It Shows | Example Sites |
|--------|---------------|---------------|
| `http` | Unencrypted web traffic | httpbin.org, neverssl.com |
| `tls` | Encrypted web traffic | google.com, facebook.com |
| `tcp.port == 80` | HTTP port traffic | httpbin.org |
| `tcp.port == 443` | HTTPS port traffic | google.com |
| `dns` | Domain name lookups | All websites |

## 💡 **Pro Tips**

1. **Start with httpbin.org** - it's designed for testing
2. **Use the Protocol column** - tells you what type of traffic
3. **Right-click on packets** - lots of useful options
4. **Don't worry about encryption** - focus on understanding the flow
5. **Try different filters** - experiment with what you see

## 🚀 **Quick Success Test**

1. Open Wireshark
2. Select your network interface
3. Start capture
4. Visit `http://httpbin.org/get`
5. Filter: `http`
6. Click on a packet
7. Expand "Hypertext Transfer Protocol" in the middle pane
8. You should see "GET /get HTTP/1.1"

**If this works, you've successfully captured and analyzed HTTP traffic!**
