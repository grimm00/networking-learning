# DNS Server Configuration with CoreDNS

This module covers DNS server configuration, management, and troubleshooting using CoreDNS - a modern, flexible DNS server.

## 📚 Table of Contents

1. [CoreDNS Overview](#coredns-overview)
2. [Installation and Setup](#installation-and-setup)
3. [Configuration Files](#configuration-files)
4. [Core Plugins](#core-plugins)
5. [Advanced Configuration](#advanced-configuration)
6. [DNS Zones and Records](#dns-zones-and-records)
7. [Security and Access Control](#security-and-access-control)
8. [Monitoring and Logging](#monitoring-and-logging)
9. [Troubleshooting](#troubleshooting)
10. [Practical Labs](#practical-labs)

## 🌐 CoreDNS Overview

CoreDNS is a DNS server written in Go that chains plugins. It's designed to be flexible and performant, making it ideal for modern infrastructure.

### Key Features:
- **Plugin Architecture**: Modular design with chainable plugins
- **High Performance**: Written in Go with excellent concurrency
- **Flexible Configuration**: Simple Corefile syntax
- **Cloud Native**: Perfect for Kubernetes and containerized environments
- **Security**: Built-in support for DNS over TLS (DoT) and DNS over HTTPS (DoH)

### CoreDNS vs Traditional DNS Servers:
| Feature | CoreDNS | BIND | PowerDNS |
|---------|---------|------|----------|
| Configuration | Corefile | named.conf | pdns.conf |
| Performance | High | Medium | High |
| Plugin System | Native | Limited | Limited |
| Container Support | Excellent | Good | Good |
| Learning Curve | Easy | Medium | Medium |

## 🚀 Installation and Setup

### Container Installation
```bash
# Pull CoreDNS image
docker pull coredns/coredns:latest

# Run CoreDNS container
docker run -d --name coredns \
  -p 53:53/udp \
  -p 53:53/tcp \
  -v $(pwd)/Corefile:/etc/coredns/Corefile \
  coredns/coredns:latest
```

### Local Installation (Ubuntu/Debian)
```bash
# Install CoreDNS
sudo apt update
sudo apt install coredns

# Start and enable service
sudo systemctl start coredns
sudo systemctl enable coredns

# Check status
sudo systemctl status coredns
```

### Verification
```bash
# Test CoreDNS is running
dig @localhost example.com

# Check CoreDNS version
coredns -version

# Test configuration
coredns -conf /etc/coredns/Corefile -test
```

## 📝 Configuration Files

### Basic Corefile Structure
```corefile
# Corefile syntax
.:53 {
    # Plugins go here
    forward . 8.8.8.8 8.8.4.4
    cache
    log
    errors
}
```

### Configuration Blocks
```corefile
# Multiple zones
example.com:53 {
    file /etc/coredns/zones/example.com.db
    log
    errors
}

internal.local:53 {
    file /etc/coredns/zones/internal.local.db
    log
    errors
}

.:53 {
    forward . 8.8.8.8 8.8.4.4
    cache
    log
    errors
}
```

## 🔌 Core Plugins

### Essential Plugins

#### 1. **file** - Zone File Support
```corefile
example.com:53 {
    file /etc/coredns/zones/example.com.db
    log
    errors
}
```

#### 2. **forward** - Forward Queries
```corefile
.:53 {
    forward . 8.8.8.8 8.8.4.4 {
        except example.com
    }
    cache
    log
    errors
}
```

#### 3. **cache** - Response Caching
```corefile
.:53 {
    forward . 8.8.8.8 8.8.4.4
    cache {
        success 9984 30
        denial 9984 5
    }
    log
    errors
}
```

#### 4. **log** - Query Logging
```corefile
.:53 {
    forward . 8.8.8.8 8.8.4.4
    log {
        class all
    }
    errors
}
```

#### 5. **errors** - Error Logging
```corefile
.:53 {
    forward . 8.8.8.8 8.8.4.4
    errors {
        consolidate 5m
    }
}
```

### Advanced Plugins

#### 6. **hosts** - Host File Support
```corefile
internal.local:53 {
    hosts /etc/hosts {
        fallthrough
    }
    log
    errors
}
```

#### 7. **auto** - Automatic Zone Management
```corefile
.:53 {
    auto {
        directory /etc/coredns/zones
        reload 1m
    }
    log
    errors
}
```

#### 8. **reload** - Configuration Reloading
```corefile
.:53 {
    forward . 8.8.8.8 8.8.4.4
    reload 2s
    log
    errors
}
```

## 🔧 Advanced Configuration

### Multiple Interfaces
```corefile
# Listen on multiple interfaces
.:53 {
    bind 127.0.0.1 192.168.1.100
    forward . 8.8.8.8 8.8.4.4
    log
    errors
}
```

### TLS Support
```corefile
# DNS over TLS
.:53 {
    forward . tls://8.8.8.8 tls://8.8.4.4 {
        tls_servername dns.google
    }
    log
    errors
}
```

### Health Checks
```corefile
.:53 {
    forward . 8.8.8.8 8.8.4.4 {
        health_check 5s
    }
    log
    errors
}
```

### Rate Limiting
```corefile
.:53 {
    forward . 8.8.8.8 8.8.4.4
    rate_limit {
        window 1m
        max_requests 100
    }
    log
    errors
}
```

## 📋 DNS Zones and Records

### Zone File Format
```dns
; Zone file for example.com
$TTL 3600
$ORIGIN example.com.

@       IN      SOA     ns1.example.com. admin.example.com. (
                        2024010101      ; Serial
                        3600            ; Refresh
                        1800            ; Retry
                        604800          ; Expire
                        86400           ; Minimum TTL
                        )

; Name servers
@       IN      NS      ns1.example.com.
@       IN      NS      ns2.example.com.

; A records
@       IN      A       192.168.1.100
ns1     IN      A       192.168.1.101
ns2     IN      A       192.168.1.102
www     IN      A       192.168.1.100
mail    IN      A       192.168.1.103

; CNAME records
ftp     IN      CNAME   www.example.com.

; MX records
@       IN      MX      10 mail.example.com.

; TXT records
@       IN      TXT     "v=spf1 mx ~all"
```

### CoreDNS Zone Configuration
```corefile
example.com:53 {
    file /etc/coredns/zones/example.com.db {
        reload 1m
    }
    log
    errors
}
```

## 🔒 Security and Access Control

### Access Control Lists
```corefile
.:53 {
    forward . 8.8.8.8 8.8.4.4
    acl {
        block 192.168.1.0/24
        allow 10.0.0.0/8
    }
    log
    errors
}
```

### DNS over HTTPS (DoH)
```corefile
.:53 {
    forward . 8.8.8.8 8.8.4.4
    https://dns.google/dns-query {
        tls_servername dns.google
    }
    log
    errors
}
```

### DNSSEC Support
```corefile
example.com:53 {
    file /etc/coredns/zones/example.com.db
    dnssec {
        key file /etc/coredns/keys/Kexample.com.+013+12345.key
    }
    log
    errors
}
```

## 📊 Monitoring and Logging

### Query Logging
```corefile
.:53 {
    forward . 8.8.8.8 8.8.4.4
    log {
        class all
        format json
    }
    errors
}
```

### Metrics Collection
```corefile
.:53 {
    forward . 8.8.8.8 8.8.4.4
    prometheus :9153
    log
    errors
}
```

### Health Endpoints
```corefile
.:53 {
    forward . 8.8.8.8 8.8.4.4
    health :8080
    log
    errors
}
```

## 🔍 Troubleshooting

### Common Issues

#### 1. **Configuration Syntax Errors**
```bash
# Test configuration
coredns -conf /etc/coredns/Corefile -test

# Check for syntax errors
coredns -conf /etc/coredns/Corefile -validate
```

#### 2. **Zone File Issues**
```bash
# Validate zone file
named-checkzone example.com /etc/coredns/zones/example.com.db

# Check zone syntax
dig @localhost example.com SOA
```

#### 3. **Forwarding Problems**
```bash
# Test upstream servers
dig @8.8.8.8 example.com

# Check forwarding configuration
dig @localhost example.com
```

#### 4. **Performance Issues**
```bash
# Monitor query performance
dig @localhost example.com +stats

# Check cache hit rates
curl http://localhost:9153/metrics | grep coredns_cache
```

### Diagnostic Commands
```bash
# Check CoreDNS status
systemctl status coredns

# View logs
journalctl -u coredns -f

# Test DNS resolution
dig @localhost example.com
nslookup example.com localhost

# Check port binding
netstat -tulpn | grep :53
ss -tulpn | grep :53
```

## 🧪 Practical Labs

### Lab 1: Basic DNS Server Setup
```bash
# 1. Create basic Corefile
cat > Corefile << EOF
.:53 {
    forward . 8.8.8.8 8.8.4.4
    cache
    log
    errors
}
EOF

# 2. Start CoreDNS
coredns -conf Corefile

# 3. Test resolution
dig @localhost google.com
```

### Lab 2: Local Zone Configuration
```bash
# 1. Create zone file
cat > example.com.db << EOF
\$TTL 3600
\$ORIGIN example.com.

@       IN      SOA     ns1.example.com. admin.example.com. (
                        2024010101 3600 1800 604800 86400
                        )

@       IN      NS      ns1.example.com.
@       IN      A       192.168.1.100
www     IN      A       192.168.1.100
mail    IN      A       192.168.1.103
EOF

# 2. Configure CoreDNS
cat > Corefile << EOF
example.com:53 {
    file example.com.db
    log
    errors
}

.:53 {
    forward . 8.8.8.8 8.8.4.4
    cache
    log
    errors
}
EOF

# 3. Test local resolution
dig @localhost www.example.com
```

### Lab 3: Advanced Features
```bash
# 1. Configure with multiple features
cat > Corefile << EOF
.:53 {
    forward . 8.8.8.8 8.8.4.4 {
        health_check 5s
    }
    cache {
        success 9984 30
        denial 9984 5
    }
    rate_limit {
        window 1m
        max_requests 100
    }
    prometheus :9153
    health :8080
    log {
        class all
        format json
    }
    errors
}
EOF

# 2. Test health endpoint
curl http://localhost:8080/health

# 3. Check metrics
curl http://localhost:9153/metrics
```

## 📚 Quick Reference

### Corefile Syntax
```corefile
# Basic structure
zone:port {
    plugin1
    plugin2 {
        option value
    }
    plugin3
}
```

### Common Plugins
- `file` - Zone file support
- `forward` - Forward queries
- `cache` - Response caching
- `log` - Query logging
- `errors` - Error logging
- `hosts` - Host file support
- `auto` - Automatic zones
- `reload` - Config reloading
- `prometheus` - Metrics
- `health` - Health checks

### Useful Commands
```bash
# Test configuration
coredns -conf Corefile -test

# Start with specific config
coredns -conf Corefile

# Check version
coredns -version

# Validate zone
named-checkzone domain.com zone.db

# Test resolution
dig @server domain.com
nslookup domain.com server
```

## 🎯 Learning Objectives

By the end of this module, you should be able to:

1. **Understand CoreDNS Architecture**: Explain how CoreDNS works and its plugin system
2. **Configure Basic DNS Server**: Set up CoreDNS with forwarding and caching
3. **Manage DNS Zones**: Create and manage zone files and records
4. **Implement Security**: Configure access control and DNSSEC
5. **Monitor and Troubleshoot**: Set up logging, metrics, and diagnose issues
6. **Optimize Performance**: Configure caching, rate limiting, and health checks

## 🔗 Additional Resources

- [CoreDNS Documentation](https://coredns.io/manual/)
- [CoreDNS Plugins](https://coredns.io/plugins/)
- [DNS RFC Standards](https://tools.ietf.org/html/rfc1035)
- [CoreDNS GitHub](https://github.com/coredns/coredns)

---

**Next Steps**: Practice with the hands-on labs and explore the advanced configuration options. The DNS server configuration skills you learn here will be valuable for network administration and infrastructure management.
