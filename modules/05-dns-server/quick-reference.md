# CoreDNS Quick Reference

## 🚀 Quick Start

### Start Basic DNS Server
```bash
# Using Docker Compose
cd 05-dns-server
docker-compose up -d coredns

# Test DNS resolution
dig @localhost example.com
```

### Start Advanced DNS Server
```bash
# Start with advanced configuration
docker-compose --profile advanced up -d coredns-advanced

# Test on port 5353
dig @localhost -p 5353 example.com
```

## 📝 Corefile Syntax

### Basic Structure
```corefile
zone:port {
    plugin1
    plugin2 {
        option value
    }
    plugin3
}
```

### Common Plugins

#### **file** - Zone File Support
```corefile
example.com:53 {
    file /etc/coredns/zones/example.com.db
    log
    errors
}
```

#### **forward** - Forward Queries
```corefile
.:53 {
    forward . 8.8.8.8 8.8.4.4 {
        health_check 5s
        except example.com
    }
    cache
    log
    errors
}
```

#### **cache** - Response Caching
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

#### **log** - Query Logging
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

#### **prometheus** - Metrics
```corefile
.:53 {
    forward . 8.8.8.8 8.8.4.4
    prometheus :9153
    log
    errors
}
```

#### **health** - Health Checks
```corefile
.:53 {
    forward . 8.8.8.8 8.8.4.4
    health :8080
    log
    errors
}
```

## 🔧 Configuration Examples

### Basic Forwarding Server
```corefile
.:53 {
    forward . 8.8.8.8 8.8.4.4
    cache
    log
    errors
}
```

### Multi-Zone Setup
```corefile
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
    forward . 8.8.8.8 8.8.4.4 {
        except example.com internal.local
    }
    cache
    log
    errors
}
```

### Secure Configuration
```corefile
.:53 {
    forward . tls://8.8.8.8 tls://8.8.4.4 {
        tls_servername dns.google
        health_check 5s
    }
    cache
    rate_limit {
        window 1m
        max_requests 100
    }
    acl {
        allow 10.0.0.0/8
        allow 192.168.0.0/16
        block 0.0.0.0/0
    }
    prometheus :9153
    health :8080
    log
    errors
}
```

## 📋 Zone File Format

### Basic Zone File
```dns
; Zone file for example.com
$TTL 3600
$ORIGIN example.com.

@       IN      SOA     ns1.example.com. admin.example.com. (
                        2024010101 3600 1800 604800 86400
                        )

; Name servers
@       IN      NS      ns1.example.com.
@       IN      NS      ns2.example.com.

; A records
@       IN      A       192.168.1.100
www     IN      A       192.168.1.100
mail    IN      A       192.168.1.103

; CNAME records
web     IN      CNAME   www.example.com.

; MX records
@       IN      MX      10 mail.example.com.

; TXT records
@       IN      TXT     "v=spf1 mx ~all"
```

## 🛠️ Management Commands

### Test Configuration
```bash
# Test Corefile syntax
coredns -conf Corefile -test

# Validate zone file
named-checkzone example.com example.com.db
```

### Start Server
```bash
# Start with specific config
coredns -conf Corefile

# Start with specific port
coredns -conf Corefile -dns.port 5353
```

### Test DNS Resolution
```bash
# Test with dig
dig @localhost example.com
dig @localhost example.com MX

# Test with nslookup
nslookup example.com localhost

# Test specific record types
dig @localhost example.com A
dig @localhost example.com AAAA
dig @localhost example.com MX
dig @localhost example.com NS
dig @localhost example.com TXT
```

### Check Server Status
```bash
# Check if server is running
dig @localhost google.com +short

# Check health endpoint
curl http://localhost:8080/health

# Check metrics
curl http://localhost:9153/metrics
```

## 🔍 Troubleshooting

### Common Issues

#### Configuration Syntax Errors
```bash
# Test configuration
coredns -conf Corefile -test

# Check for errors
coredns -conf Corefile -validate
```

#### Zone File Issues
```bash
# Validate zone file
named-checkzone example.com example.com.db

# Check zone syntax
dig @localhost example.com SOA
```

#### Forwarding Problems
```bash
# Test upstream servers
dig @8.8.8.8 example.com

# Check forwarding
dig @localhost example.com
```

#### Performance Issues
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

# Check port binding
netstat -tulpn | grep :53
ss -tulpn | grep :53

# Test DNS resolution
dig @localhost example.com
nslookup example.com localhost
```

## 📊 Monitoring

### Health Checks
```bash
# Check health endpoint
curl http://localhost:8080/health

# Check metrics endpoint
curl http://localhost:9153/metrics
```

### Query Logging
```bash
# View query logs
tail -f /var/log/coredns/query.log

# Monitor real-time queries
coredns -conf Corefile -log
```

### Performance Metrics
```bash
# Check response times
dig @localhost example.com +stats

# Monitor cache performance
curl http://localhost:9153/metrics | grep coredns_cache
```

## 🎯 Common Use Cases

### 1. Basic Forwarding DNS
```corefile
.:53 {
    forward . 8.8.8.8 8.8.4.4
    cache
    log
    errors
}
```

### 2. Local Zone + Forwarding
```corefile
internal.local:53 {
    file /etc/coredns/zones/internal.local.db
    log
    errors
}

.:53 {
    forward . 8.8.8.8 8.8.4.4 {
        except internal.local
    }
    cache
    log
    errors
}
```

### 3. High Performance DNS
```corefile
.:53 {
    forward . 8.8.8.8 8.8.4.4 1.1.1.1 1.0.0.1 {
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
    log
    errors
}
```

### 4. Secure DNS
```corefile
.:53 {
    forward . tls://8.8.8.8 tls://8.8.4.4 {
        tls_servername dns.google
    }
    cache
    acl {
        allow 10.0.0.0/8
        allow 192.168.0.0/16
        block 0.0.0.0/0
    }
    log
    errors
}
```

## 📚 Useful Resources

- [CoreDNS Documentation](https://coredns.io/manual/)
- [CoreDNS Plugins](https://coredns.io/plugins/)
- [DNS RFC Standards](https://tools.ietf.org/html/rfc1035)
- [CoreDNS GitHub](https://github.com/coredns/coredns)
