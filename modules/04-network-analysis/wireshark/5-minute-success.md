# Wireshark 5-Minute Success Guide

## 🎯 **Goal**: See your web traffic in 5 minutes

This guide will get you capturing real packets immediately, no confusion.

## ⚡ **Quick Start (5 Minutes)**

### 1. Open Wireshark (1 minute)
- Launch Wireshark (the GUI, not command line)
- You'll see a list of network interfaces
- **Look for the one with green bars** (that's your active interface)

### 2. Start Capturing (30 seconds)
- Click on your active interface (the one with green bars)
- Click the **blue shark fin** 🦈 to start capturing
- You should see packets appearing in real-time

### 3. Generate Traffic (2 minutes)
- Open a web browser
- Visit: `http://httpbin.org/get` (note: **http**, not https)
- Watch packets appear in Wireshark

### 4. Filter the Traffic (1 minute)
- In the filter bar at the top, type: `http`
- Press Enter
- You should see HTTP packets from httpbin.org

### 5. Analyze a Packet (30 seconds)
- Click on any HTTP packet
- In the middle pane, expand "Hypertext Transfer Protocol"
- You'll see "GET /get HTTP/1.1" - that's your web request!

## ✅ **Success! You Just Captured Web Traffic**

## 🔍 **Why This Works**

- **httpbin.org uses HTTP** (unencrypted) - you can see the content
- **Most other sites use HTTPS** (encrypted) - you can't see the content
- **HTTP shows as "HTTP"** in the Protocol column
- **HTTPS shows as "TLS"** in the Protocol column

## 🚨 **Common Mistakes**

1. **Visiting HTTPS sites** - Use httpbin.org instead
2. **Wrong interface** - Look for the one with traffic
3. **Wrong filter** - Use `http` (lowercase), not `HTTP`
4. **Not generating traffic** - You need to browse while capturing

## 🎓 **What You Learned**

- How to start packet capture
- How to identify the right interface
- The difference between HTTP and HTTPS
- How to use display filters
- How to analyze packet contents

## 🔄 **Next Steps**

Once this works, try:
- Filter `tls` to see HTTPS traffic (encrypted)
- Filter `dns` to see domain name lookups
- Right-click a packet → Follow → TCP Stream
- Visit different websites and see the traffic

## 💡 **Pro Tips**

1. **Start with httpbin.org** - it's designed for testing
2. **Look at the Protocol column** - tells you what type of traffic
3. **Right-click everything** - lots of useful options
4. **Don't worry about the bytes pane** - focus on the middle pane
5. **Practice with different sites** - see what traffic looks like

---

**This should work in 5 minutes and give you immediate, visible results!**
