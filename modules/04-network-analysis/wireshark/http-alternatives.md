# Alternative HTTP Sites for Wireshark Testing

## 🚨 **httpbin.org is down (503 error)**

Here are some reliable alternatives that use HTTP (not HTTPS) for testing:

## 🌐 **Working HTTP Sites**

### 1. **http://neverssl.com**
- **Purpose**: Deliberately uses HTTP (not HTTPS)
- **Why it works**: Designed for testing and captive portals
- **What you'll see**: Clear HTTP traffic in Wireshark

### 2. **http://httpforever.com**
- **Purpose**: Simple HTTP test site
- **Why it works**: Always uses HTTP
- **What you'll see**: Basic HTTP requests and responses

### 3. **http://example.com**
- **Purpose**: Basic example site
- **Why it works**: Simple HTTP site
- **What you'll see**: Standard HTTP traffic

### 4. **http://httpstat.us/200**
- **Purpose**: HTTP status code testing
- **Why it works**: Returns specific HTTP status codes
- **What you'll see**: HTTP responses with status codes

## 🎯 **Quick Test Steps**

1. **Open Wireshark**
2. **Select en0** (your WiFi interface)
3. **Start capturing**
4. **Visit**: `http://neverssl.com`
5. **Filter**: `http`
6. **You should see HTTP packets!**

## 🔍 **What to Look For**

- **Protocol column**: Should show "HTTP"
- **Info column**: Should show "GET / HTTP/1.1"
- **When you click a packet**: Expand "Hypertext Transfer Protocol" in the middle pane

## 💡 **Pro Tips**

- **neverssl.com** is the most reliable alternative
- **Always use http://** (not https://)
- **Look for "HTTP" in the Protocol column**
- **If you see "TLS", you're on the wrong site**

## 🚨 **If All HTTP Sites Are Down**

You can also test with:
- **Local HTTP server**: `python -m http.server 8000` then visit `http://localhost:8000`
- **Simple ping**: Filter `icmp` and run `ping google.com`
- **DNS queries**: Filter `dns` and visit any website

---

**Try neverssl.com first - it's the most reliable alternative to httpbin.org!**
