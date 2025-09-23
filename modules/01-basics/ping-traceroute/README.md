# Ping and Traceroute Exercises

Learn the fundamentals of network connectivity testing with ping and traceroute.

## What You'll Learn

- How to test network connectivity
- Understanding network latency and packet loss
- Tracing network paths and identifying bottlenecks
- Interpreting ping and traceroute output

## Exercises

### Exercise 1: Basic Ping Testing

```bash
# Test connectivity to different targets
ping -c 4 8.8.8.8                    # Google DNS
ping -c 4 1.1.1.1                    # Cloudflare DNS
ping -c 4 google.com                 # Domain name resolution

# Test with different packet sizes
ping -c 4 -s 32 8.8.8.8             # Small packets
ping -c 4 -s 1024 8.8.8.8           # Large packets
ping -c 4 -s 1500 8.8.8.8           # Maximum size packets
```

### Exercise 2: Traceroute Analysis

```bash
# Trace route to different destinations
traceroute 8.8.8.8
traceroute google.com
traceroute github.com

# Use different methods
traceroute -T 8.8.8.8                # TCP traceroute
traceroute -U 8.8.8.8                # UDP traceroute
traceroute -I 8.8.8.8                # ICMP traceroute
```

### Exercise 3: Continuous Monitoring

```bash
# Monitor connectivity over time
ping -i 1 8.8.8.8                    # Ping every second
ping -i 0.1 8.8.8.8                  # Ping every 100ms

# Save results to file
ping -c 100 8.8.8.8 > ping_results.txt
```

## Understanding the Output

### Ping Output Explained
```
PING 8.8.8.8 (8.8.8.8): 56 data bytes
64 bytes from 8.8.8.8: icmp_seq=0 ttl=64 time=12.345 ms
64 bytes from 8.8.8.8: icmp_seq=1 ttl=64 time=11.234 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=64 time=10.123 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=64 time=9.012 ms

--- 8.8.8.8 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss
round-trip min/avg/max/stddev = 9.012/10.678/12.345/1.234 ms
```

- **icmp_seq**: Sequence number of the packet
- **ttl**: Time To Live (decremented at each hop)
- **time**: Round-trip time in milliseconds
- **packet loss**: Percentage of packets lost
- **min/avg/max/stddev**: Statistical summary

### Traceroute Output Explained
```
traceroute to 8.8.8.8 (8.8.8.8), 64 hops max, 52 byte packets
 1  192.168.1.1 (192.168.1.1)  1.234 ms  0.987 ms  0.765 ms
 2  10.0.0.1 (10.0.0.1)  5.432 ms  4.321 ms  3.210 ms
 3  * * *
 4  72.14.239.1 (72.14.239.1)  15.678 ms  14.567 ms  13.456 ms
```

- **Hop number**: Number of router hops from source
- **IP address**: Router's IP address
- **Hostname**: Reverse DNS lookup (if available)
- **Three times**: Three separate measurements
- **\* \* \***: No response (firewall or timeout)

## Troubleshooting Common Issues

### High Latency
- Check if you're on WiFi vs Ethernet
- Test different times of day
- Try different DNS servers

### Packet Loss
- Check your local network connection
- Test with different packet sizes
- Try different destinations

### Timeouts
- Check if destination is reachable
- Verify firewall settings
- Try different traceroute methods

## Advanced Exercises

### Exercise 4: Network Path Analysis
```bash
# Compare different paths
traceroute 8.8.8.8 > path1.txt
traceroute 1.1.1.1 > path2.txt
diff path1.txt path2.txt
```

### Exercise 5: Bandwidth Testing
```bash
# Test with different packet sizes
for size in 32 64 128 256 512 1024 1500; do
  echo "Testing with $size byte packets:"
  ping -c 10 -s $size 8.8.8.8
  echo "---"
done
```

## Tools and Scripts

Run the included scripts for automated testing:

```bash
./ping-test.sh          # Comprehensive ping testing
./traceroute-test.sh    # Multiple destination tracing
./network-analysis.py   # Python-based analysis
```
