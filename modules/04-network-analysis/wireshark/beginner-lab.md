# Wireshark Beginner Lab - "See Your Web Traffic"

## 🎯 **Goal**: Actually capture and see your web browsing traffic

This lab will get you capturing real packets in 5 minutes, guaranteed.

## ⚠️ **Why Your HTTP Filter Isn't Working**

The most common reasons:
1. **Wrong interface** - You're capturing on the wrong network interface
2. **HTTPS instead of HTTP** - Most websites use HTTPS (encrypted), not HTTP
3. **No traffic** - You need to generate traffic while capturing
4. **Wrong filter syntax** - Display filters are case-sensitive

## 🚀 **Step-by-Step Lab**

### Step 1: Start Wireshark (2 minutes)

1. **Open Wireshark** (not tshark - the GUI version)
2. **You'll see a list of network interfaces** - this is the key part!
3. **Look for your active interface**:
   - **WiFi**: Look for `wlan0`, `Wi-Fi`, or `en0` (macOS)
   - **Ethernet**: Look for `eth0` or `Ethernet`
   - **Look for the one with traffic** (green bars or packet counts)

### Step 2: Start Capturing (1 minute)

1. **Click on your active interface** (the one with traffic)
2. **Click the blue shark fin** 🦈 to start capturing
3. **You should see packets appearing** in real-time

### Step 3: Generate Traffic (2 minutes)

**Open a web browser and visit these sites in order:**

1. **First, visit an HTTP site** (not HTTPS):
   ```
   http://httpbin.org/get
   ```
   (This site deliberately uses HTTP, not HTTPS)

2. **Then visit a regular site**:
   ```
   https://google.com
   ```

3. **Watch the packets appear** in Wireshark as you browse

### Step 4: Apply Filters (2 minutes)

**Now let's filter to see specific traffic:**

1. **In the filter bar at the top**, type: `http`
   - Press Enter
   - You should see HTTP packets from httpbin.org

2. **Clear the filter** (click the X) and type: `tls`
   - Press Enter  
   - You should see TLS/HTTPS packets from google.com

3. **Try this filter**: `ip.addr == 8.8.8.8`
   - This shows traffic to/from Google's DNS server

### Step 5: Analyze a Packet (3 minutes)

1. **Click on any HTTP packet** (from httpbin.org)
2. **Look at the three panes**:
   - **Top pane**: List of packets
   - **Middle pane**: Protocol details (expand the sections)
   - **Bottom pane**: Raw bytes (hex view)

3. **Expand the HTTP section** in the middle pane
   - You'll see the actual HTTP request
   - Look for "GET /get HTTP/1.1"

## 🔍 **What You Should See**

### HTTP Traffic (httpbin.org)
- **Protocol column**: Shows "HTTP"
- **Info column**: Shows "GET /get HTTP/1.1"
- **When you click it**: You can see the actual web request

### HTTPS Traffic (google.com)  
- **Protocol column**: Shows "TLS" or "TLSv1.3"
- **Info column**: Shows "Application Data" (encrypted)
- **This is why you can't see the content** - it's encrypted!

## 🚨 **Troubleshooting**

### "I don't see any packets"
- **Check the interface**: Make sure you selected the right one
- **Look for traffic indicators**: Green bars or packet counts
- **Try a different interface**: Some interfaces don't capture properly

### "I see packets but no HTTP"
- **Make sure you visited httpbin.org** (not httpsbin.org)
- **Check the filter**: Type `http` exactly (lowercase)
- **Look in the Protocol column**: Should show "HTTP"

### "The interface list is empty"
- **On Linux**: You might need to run `sudo wireshark`
- **On macOS**: Grant permissions in System Preferences
- **On Windows**: Run as Administrator

## 🎓 **What You Learned**

1. **How to start capturing** packets
2. **How to identify** the right network interface  
3. **The difference** between HTTP (visible) and HTTPS (encrypted)
4. **How to use filters** to focus on specific traffic
5. **How to analyze** packet contents

## 🔄 **Next Steps**

Once this works, try:
- **Filter by IP address**: `ip.addr == 1.2.3.4`
- **Filter by port**: `tcp.port == 80`
- **Follow a stream**: Right-click → Follow → TCP Stream
- **Look at DNS**: Filter `dns` and see name resolution

## 💡 **Pro Tips**

1. **Start without filters** - see all traffic first
2. **Use httpbin.org** - it's designed for testing
3. **Look at the Protocol column** - tells you what type of traffic
4. **Right-click everything** - lots of useful options
5. **Don't worry about the bytes pane** - focus on the middle pane

---

**This lab should take 10 minutes and give you immediate, visible results!**
