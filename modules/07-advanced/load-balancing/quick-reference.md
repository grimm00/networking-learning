# Load Balancing Quick Reference

## Essential Commands

### Nginx Load Balancing
```bash
# Test configuration
nginx -t

# Reload configuration
nginx -s reload

# Check status
systemctl status nginx

# View configuration
nginx -T

# Check processes
ps aux | grep nginx
```

### HAProxy Load Balancing
```bash
# Test configuration
haproxy -c -f /etc/haproxy/haproxy.cfg

# Reload configuration
systemctl reload haproxy

# Check status
systemctl status haproxy

# View statistics
curl http://localhost:8080/stats

# Check processes
ps aux | grep haproxy
```

### Load Balancer Monitoring
```bash
# Check active connections
ss -tuna | grep :80
netstat -tuna | grep :80

# Monitor connection states
ss -tuna | awk '{print $1}' | sort | uniq -c

# Check load balancer logs
tail -f /var/log/nginx/access.log
tail -f /var/log/haproxy.log

# Monitor system resources
top -p $(pgrep nginx)
top -p $(pgrep haproxy)
```

## Load Balancing Algorithms

### Round Robin (Default)
```nginx
upstream backend {
    server 192.168.1.10:80;
    server 192.168.1.11:80;
    server 192.168.1.12:80;
}
```

### Weighted Round Robin
```nginx
upstream backend {
    server 192.168.1.10:80 weight=3;
    server 192.168.1.11:80 weight=2;
    server 192.168.1.12:80 weight=1;
}
```

### Least Connections
```nginx
upstream backend {
    least_conn;
    server 192.168.1.10:80;
    server 192.168.1.11:80;
    server 192.168.1.12:80;
}
```

### IP Hash (Session Persistence)
```nginx
upstream backend {
    ip_hash;
    server 192.168.1.10:80;
    server 192.168.1.11:80;
    server 192.168.1.12:80;
}
```

### Consistent Hash
```nginx
upstream backend {
    hash $request_uri consistent;
    server 192.168.1.10:80;
    server 192.168.1.11:80;
    server 192.168.1.12:80;
}
```

## Health Check Configurations

### Nginx Health Checks
```nginx
upstream backend {
    server 192.168.1.10:80 max_fails=3 fail_timeout=30s;
    server 192.168.1.11:80 max_fails=3 fail_timeout=30s;
    server 192.168.1.12:80 max_fails=3 fail_timeout=30s;
}

server {
    location / {
        proxy_pass http://backend;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_next_upstream_tries 3;
        proxy_next_upstream_timeout 10s;
    }
}
```

### HAProxy Health Checks
```haproxy
backend web_servers
    balance roundrobin
    option httpchk GET /health
    http-check expect status 200
    
    server web1 192.168.1.10:80 check inter 5s rise 2 fall 3
    server web2 192.168.1.11:80 check inter 5s rise 2 fall 3
    server web3 192.168.1.12:80 check inter 5s rise 2 fall 3
```

## Session Persistence

### Cookie-Based Persistence
```nginx
upstream backend {
    server 192.168.1.10:80;
    server 192.168.1.11:80;
    server 192.168.1.12:80;
}

server {
    location / {
        proxy_pass http://backend;
        proxy_cookie_path / /;
        proxy_set_header Cookie $http_cookie;
    }
}
```

### HAProxy Cookie Persistence
```haproxy
backend web_servers
    cookie SERVERID insert indirect nocache
    
    server web1 192.168.1.10:80 cookie web1 check
    server web2 192.168.1.11:80 cookie web2 check
    server web3 192.168.1.12:80 cookie web3 check
```

## SSL/TLS Termination

### Nginx SSL Configuration
```nginx
server {
    listen 443 ssl;
    server_name example.com;
    
    ssl_certificate /etc/ssl/certs/example.com.crt;
    ssl_certificate_key /etc/ssl/private/example.com.key;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256;
    ssl_prefer_server_ciphers off;
    
    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### HAProxy SSL Configuration
```haproxy
frontend web_frontend
    bind *:443 ssl crt /etc/ssl/certs/example.com.pem
    redirect scheme https if !{ ssl_fc }
    default_backend web_servers
```

## Performance Optimization

### Connection Pooling
```nginx
upstream backend {
    server 192.168.1.10:80;
    server 192.168.1.11:80;
    server 192.168.1.12:80;
    keepalive 32;
}

server {
    location / {
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }
}
```

### Buffer Optimization
```nginx
server {
    location / {
        proxy_pass http://backend;
        proxy_buffering on;
        proxy_buffer_size 4k;
        proxy_buffers 8 4k;
        proxy_busy_buffers_size 8k;
    }
}
```

### Timeout Configuration
```nginx
server {
    location / {
        proxy_pass http://backend;
        proxy_connect_timeout 5s;
        proxy_send_timeout 10s;
        proxy_read_timeout 10s;
    }
}
```

## Security Headers

### Basic Security Headers
```nginx
server {
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
}
```

### HSTS Configuration
```nginx
server {
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
}
```

## Monitoring and Statistics

### Nginx Status Module
```nginx
server {
    location /nginx_status {
        stub_status on;
        access_log off;
        allow 127.0.0.1;
        deny all;
    }
}
```

### HAProxy Statistics
```haproxy
listen stats
    bind *:8080
    stats enable
    stats uri /stats
    stats refresh 30s
    stats admin if TRUE
```

## Common Use Cases

### E-commerce Application
```nginx
upstream frontend {
    server 192.168.1.10:80 weight=3;
    server 192.168.1.11:80 weight=2;
    server 192.168.1.12:80 weight=1;
}

upstream api {
    least_conn;
    server 192.168.2.10:8080;
    server 192.168.2.11:8080;
    server 192.168.2.12:8080;
}

server {
    listen 80;
    server_name shop.example.com;
    
    location / {
        proxy_pass http://frontend;
    }
    
    location /api/ {
        proxy_pass http://api;
    }
}
```

### Microservices Architecture
```nginx
upstream user-service {
    server 192.168.1.10:3000;
    server 192.168.1.11:3000;
}

upstream order-service {
    server 192.168.1.20:4000;
    server 192.168.1.21:4000;
}

upstream payment-service {
    server 192.168.1.30:5000;
    server 192.168.1.31:5000;
}

server {
    listen 80;
    server_name api.example.com;
    
    location /users/ {
        proxy_pass http://user-service;
    }
    
    location /orders/ {
        proxy_pass http://order-service;
    }
    
    location /payments/ {
        proxy_pass http://payment-service;
    }
}
```

## Troubleshooting Commands

### Check Load Balancer Status
```bash
# Nginx
systemctl status nginx
nginx -t
ps aux | grep nginx

# HAProxy
systemctl status haproxy
haproxy -c -f /etc/haproxy/haproxy.cfg
ps aux | grep haproxy
```

### Test Backend Servers
```bash
# Test connectivity
nc -zv 192.168.1.10 80
telnet 192.168.1.10 80

# Test HTTP response
curl -I http://192.168.1.10/
curl -I http://192.168.1.11/
curl -I http://192.168.1.12/
```

### Monitor Performance
```bash
# Check connections
ss -tuna | grep :80
netstat -tuna | grep :80

# Monitor processes
top -p $(pgrep nginx)
top -p $(pgrep haproxy)

# Check logs
tail -f /var/log/nginx/access.log
tail -f /var/log/haproxy.log
```

### Performance Testing
```bash
# Apache Bench
ab -n 1000 -c 10 http://localhost/

# Load testing with curl
for i in {1..100}; do
    curl -s http://localhost/ > /dev/null &
done
wait
```

## Docker Compose Examples

### Basic Load Balancer Setup
```yaml
version: '3.8'
services:
  nginx-lb:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - web1
      - web2
      - web3
  
  web1:
    image: nginx:alpine
    volumes:
      - ./web1:/usr/share/nginx/html
  
  web2:
    image: nginx:alpine
    volumes:
      - ./web2:/usr/share/nginx/html
  
  web3:
    image: nginx:alpine
    volumes:
      - ./web3:/usr/share/nginx/html
```

### HAProxy Setup
```yaml
version: '3.8'
services:
  haproxy-lb:
    image: haproxy:latest
    ports:
      - "80:80"
      - "8080:8080"
    volumes:
      - ./haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg
    depends_on:
      - web1
      - web2
      - web3
  
  web1:
    image: nginx:alpine
    volumes:
      - ./web1:/usr/share/nginx/html
  
  web2:
    image: nginx:alpine
    volumes:
      - ./web2:/usr/share/nginx/html
  
  web3:
    image: nginx:alpine
    volumes:
      - ./web3:/usr/share/nginx/html
```

## Best Practices

### Configuration Management
- Use version control for configuration files
- Implement configuration validation before deployment
- Use environment-specific configurations
- Document all configuration changes

### Monitoring and Alerting
- Monitor load balancer health and performance
- Set up alerts for backend server failures
- Track response times and error rates
- Monitor SSL certificate expiration

### Security
- Implement SSL/TLS termination
- Use security headers
- Restrict access to management interfaces
- Regular security updates

### Performance
- Choose appropriate load balancing algorithm
- Implement connection pooling
- Optimize buffer settings
- Monitor and tune timeouts

### High Availability
- Use multiple load balancers
- Implement health checks
- Configure automatic failover
- Test disaster recovery procedures

## Common Issues and Solutions

### Issue: All traffic going to one server
**Solution**: Check load balancing algorithm configuration and server weights

### Issue: Health checks failing
**Solution**: Verify health check endpoints and configuration parameters

### Issue: Session persistence not working
**Solution**: Check IP hash or cookie configuration

### Issue: SSL/TLS errors
**Solution**: Verify certificate configuration and SSL protocols

### Issue: Performance problems
**Solution**: Optimize connection settings and monitor system resources

---

**Quick Tips:**
- Always test configuration before reloading
- Monitor logs for errors and performance issues
- Use health checks for automatic failover
- Implement proper security headers
- Regular performance testing and optimization

