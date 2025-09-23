# HTTP Server Quick Reference

## 🚀 Quick Commands

### Nginx Commands
```bash
# Test configuration
nginx -t

# Reload configuration
nginx -s reload

# Stop server
nginx -s stop

# Start server
nginx

# Check status
systemctl status nginx

# View logs
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

### Apache Commands
```bash
# Test configuration
apache2ctl configtest

# Reload configuration
systemctl reload apache2

# Stop server
systemctl stop apache2

# Start server
systemctl start apache2

# Check status
systemctl status apache2

# View logs
tail -f /var/log/apache2/access.log
tail -f /var/log/apache2/error.log
```

## 🔧 Configuration Files

### Nginx Configuration Locations
- **Main config**: `/etc/nginx/nginx.conf`
- **Site configs**: `/etc/nginx/sites-available/`
- **Enabled sites**: `/etc/nginx/sites-enabled/`
- **Modules**: `/etc/nginx/modules/`

### Apache Configuration Locations
- **Main config**: `/etc/apache2/apache2.conf`
- **Site configs**: `/etc/apache2/sites-available/`
- **Enabled sites**: `/etc/apache2/sites-enabled/`
- **Modules**: `/etc/apache2/mods-available/`

## 🌐 Common Ports

| Service | Port | Protocol |
|---------|------|----------|
| HTTP | 80 | TCP |
| HTTPS | 443 | TCP |
| Nginx Status | 80/nginx_status | HTTP |
| Apache Status | 80/server-status | HTTP |

## 🔒 SSL/TLS Quick Setup

### Generate Self-Signed Certificate
```bash
# Generate private key
openssl genrsa -out example.com.key 2048

# Generate certificate
openssl req -new -x509 -key example.com.key -out example.com.crt -days 365 \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=example.com"
```

### Let's Encrypt Certificate
```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d example.com -d www.example.com

# Auto-renewal
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

## 📊 Performance Testing

### Basic HTTP Test
```bash
# Test response
curl -I http://example.com

# Test with timing
curl -w "@curl-format.txt" -o /dev/null -s http://example.com
```

### Load Testing
```bash
# Simple load test
for i in {1..10}; do curl -s http://example.com > /dev/null & done

# Using ab (Apache Bench)
ab -n 1000 -c 10 http://example.com/

# Using wrk
wrk -t12 -c400 -d30s http://example.com/
```

## 🔍 Troubleshooting

### Common Issues

#### 502 Bad Gateway
```bash
# Check upstream servers
curl -I http://backend-server:8080

# Check proxy configuration
nginx -t

# Check error logs
tail -f /var/log/nginx/error.log
```

#### SSL Certificate Issues
```bash
# Test SSL certificate
openssl s_client -connect example.com:443 -servername example.com

# Check certificate validity
openssl x509 -in /etc/ssl/certs/example.com.crt -text -noout

# Verify certificate chain
curl -I https://example.com
```

#### Performance Issues
```bash
# Check worker processes
ps aux | grep nginx

# Monitor connections
ss -tuln | grep :80

# Check system resources
top
htop
```

### Diagnostic Commands
```bash
# Check listening ports
ss -tuln | grep :80
netstat -tuln | grep :80

# Check process status
ps aux | grep nginx
ps aux | grep apache

# Check system resources
free -h
df -h
iostat 1
```

## 🛡️ Security Headers

### Essential Security Headers
```nginx
# Nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header X-Content-Type-Options "nosniff" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
add_header Content-Security-Policy "default-src 'self'" always;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
```

```apache
# Apache
Header always set X-Frame-Options "SAMEORIGIN"
Header always set X-XSS-Protection "1; mode=block"
Header always set X-Content-Type-Options "nosniff"
Header always set Referrer-Policy "no-referrer-when-downgrade"
Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
```

## ⚡ Performance Optimization

### Nginx Optimizations
```nginx
# Worker processes
worker_processes auto;
worker_cpu_affinity auto;

# Events
events {
    worker_connections 4096;
    use epoll;
    multi_accept on;
}

# Buffer sizes
client_body_buffer_size 128k;
client_max_body_size 10m;
client_header_buffer_size 1k;
large_client_header_buffers 4 4k;

# Gzip compression
gzip on;
gzip_vary on;
gzip_min_length 1024;
gzip_comp_level 6;
gzip_types text/plain text/css application/json application/javascript;
```

### Apache Optimizations
```apache
# MPM configuration
<IfModule mpm_event_module>
    StartServers 3
    MinSpareThreads 75
    MaxSpareThreads 250
    ThreadsPerChild 25
    MaxRequestWorkers 400
</IfModule>

# Compression
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/plain text/html text/xml text/css application/javascript
</IfModule>
```

## 🔄 Load Balancing

### Nginx Load Balancing
```nginx
upstream backend {
    least_conn;
    server 192.168.1.10:8080 weight=3;
    server 192.168.1.11:8080 weight=2;
    server 192.168.1.12:8080 weight=1;
    keepalive 32;
}

server {
    listen 80;
    server_name api.example.com;
    
    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Apache Load Balancing
```apache
<VirtualHost *:80>
    ServerName api.example.com
    
    ProxyPreserveHost On
    ProxyRequests Off
    
    ProxyPass / balancer://mycluster/
    ProxyPassReverse / balancer://mycluster/
    
    <Proxy balancer://mycluster>
        BalancerMember http://192.168.1.10:8080 loadfactor=3
        BalancerMember http://192.168.1.11:8080 loadfactor=2
        BalancerMember http://192.168.1.12:8080 loadfactor=1
    </Proxy>
</VirtualHost>
```

## 📈 Monitoring

### Log Analysis
```bash
# Top IP addresses
awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -nr | head -10

# Most requested pages
awk '{print $7}' /var/log/nginx/access.log | sort | uniq -c | sort -nr | head -10

# Error analysis
grep " 50[0-9] " /var/log/nginx/access.log | tail -20

# Real-time monitoring
tail -f /var/log/nginx/access.log | grep -E "(GET|POST|PUT|DELETE)"
```

### Performance Monitoring
```bash
# Check Nginx status
curl http://localhost/nginx_status

# Monitor connections
ss -tuln | grep :80

# Check worker processes
ps aux | grep nginx
```

## 🧪 Testing Tools

### HTTP Testing
```bash
# Basic HTTP test
curl -I http://example.com

# HTTP with headers
curl -H "User-Agent: TestBot" http://example.com

# POST request
curl -X POST -d "key=value" http://example.com/api

# HTTPS test
curl -k https://example.com
```

### Performance Testing
```bash
# Apache Bench
ab -n 1000 -c 10 http://example.com/

# wrk
wrk -t12 -c400 -d30s http://example.com/

# Siege
siege -c 10 -t 30s http://example.com/
```

## 🔧 Docker Commands

### HTTP Server Containers
```bash
# Start basic Nginx (port 8081)
docker-compose up -d nginx-basic

# Start with SSL (port 8083)
docker-compose --profile ssl up -d

# Start load balancer
docker-compose --profile loadbalancer up -d

# View logs
docker-compose logs -f nginx-basic

# Stop all
docker-compose down
```

### Container Management
```bash
# List running containers
docker ps

# Check container logs
docker logs nginx-basic

# Execute commands in container
docker exec -it nginx-basic /bin/sh

# Check container resources
docker stats nginx-basic
```

## 📚 Useful Resources

- [Nginx Documentation](https://nginx.org/en/docs/)
- [Apache Documentation](https://httpd.apache.org/docs/)
- [SSL Labs](https://www.ssllabs.com/ssltest/)
- [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org/)
- [OWASP Security Headers](https://owasp.org/www-project-secure-headers/)
