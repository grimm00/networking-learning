# HTTP Server Management

This module covers HTTP server configuration, management, and optimization using Nginx and Apache web servers.

## 📚 Table of Contents

1. [HTTP Server Overview](#http-server-overview)
2. [Nginx Configuration](#nginx-configuration)
3. [Apache Configuration](#apache-configuration)
4. [SSL/TLS Configuration](#ssltls-configuration)
5. [Load Balancing](#load-balancing)
6. [Reverse Proxy Setup](#reverse-proxy-setup)
7. [Performance Optimization](#performance-optimization)
8. [Security Configuration](#security-configuration)
9. [Monitoring and Logging](#monitoring-and-logging)
10. [Troubleshooting](#troubleshooting)
11. [Practical Labs](#practical-labs)

## 🌐 HTTP Server Overview

HTTP servers are the backbone of web applications, handling client requests and serving content efficiently.

### Popular HTTP Servers:
- **Nginx**: High-performance, event-driven web server
- **Apache**: Feature-rich, modular web server
- **Caddy**: Modern web server with automatic HTTPS
- **Lighttpd**: Lightweight, high-performance server

### Key Concepts:
- **Virtual Hosts**: Multiple websites on one server
- **Reverse Proxy**: Forwarding requests to backend servers
- **Load Balancing**: Distributing traffic across multiple servers
- **SSL/TLS**: Encrypted communication
- **Caching**: Improving performance with content caching

## 🚀 Nginx Configuration

### Basic Nginx Setup
```nginx
# /etc/nginx/nginx.conf
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    # Logging
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;
    
    # Basic settings
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
    
    # Include server configurations
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
```

### Virtual Host Configuration
```nginx
# /etc/nginx/sites-available/example.com
server {
    listen 80;
    server_name example.com www.example.com;
    root /var/www/example.com;
    index index.html index.htm index.php;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    
    # Main location
    location / {
        try_files $uri $uri/ =404;
    }
    
    # Static files caching
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # PHP processing
    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }
    
    # Deny access to hidden files
    location ~ /\. {
        deny all;
    }
}
```

### SSL/TLS Configuration
```nginx
# SSL configuration for example.com
server {
    listen 443 ssl http2;
    server_name example.com www.example.com;
    root /var/www/example.com;
    index index.html index.htm index.php;
    
    # SSL certificates
    ssl_certificate /etc/ssl/certs/example.com.crt;
    ssl_certificate_key /etc/ssl/private/example.com.key;
    
    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # HSTS
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    
    location / {
        try_files $uri $uri/ =404;
    }
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name example.com www.example.com;
    return 301 https://$server_name$request_uri;
}
```

## 🔧 Apache Configuration

### Basic Apache Setup
```apache
# /etc/apache2/apache2.conf
ServerRoot "/etc/apache2"
PidFile ${APACHE_PID_FILE}
Timeout 300
KeepAlive On
MaxKeepAliveRequests 100
KeepAliveTimeout 5

User ${APACHE_RUN_USER}
Group ${APACHE_RUN_GROUP}

HostnameLookups Off
ErrorLog ${APACHE_LOG_DIR}/error.log
LogLevel warn

# Modules
LoadModule mpm_event_module modules/mod_mpm_event.so
LoadModule authz_core_module modules/mod_authz_core.so
LoadModule dir_module modules/mod_dir.so
LoadModule mime_module modules/mod_mime.so

# Include configurations
IncludeOptional mods-enabled/*.load
IncludeOptional mods-enabled/*.conf
IncludeOptional conf-enabled/*.conf
IncludeOptional sites-enabled/*.conf
```

### Virtual Host Configuration
```apache
# /etc/apache2/sites-available/example.com.conf
<VirtualHost *:80>
    ServerName example.com
    ServerAlias www.example.com
    DocumentRoot /var/www/example.com
    
    # Directory permissions
    <Directory /var/www/example.com>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    # Security headers
    Header always set X-Frame-Options "SAMEORIGIN"
    Header always set X-XSS-Protection "1; mode=block"
    Header always set X-Content-Type-Options "nosniff"
    Header always set Referrer-Policy "no-referrer-when-downgrade"
    
    # Logging
    ErrorLog ${APACHE_LOG_DIR}/example.com_error.log
    CustomLog ${APACHE_LOG_DIR}/example.com_access.log combined
    
    # PHP processing
    <FilesMatch \.php$>
        SetHandler "proxy:unix:/var/run/php/php8.1-fpm.sock|fcgi://localhost"
    </FilesMatch>
</VirtualHost>
```

### SSL Configuration
```apache
# SSL virtual host
<VirtualHost *:443>
    ServerName example.com
    ServerAlias www.example.com
    DocumentRoot /var/www/example.com
    
    # SSL configuration
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/example.com.crt
    SSLCertificateKeyFile /etc/ssl/private/example.com.key
    
    # SSL protocols and ciphers
    SSLProtocol all -SSLv3 -TLSv1 -TLSv1.1
    SSLCipherSuite ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384
    SSLHonorCipherOrder off
    SSLSessionTickets off
    
    # HSTS
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
    
    # Directory permissions
    <Directory /var/www/example.com>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>

# Redirect HTTP to HTTPS
<VirtualHost *:80>
    ServerName example.com
    ServerAlias www.example.com
    Redirect permanent / https://example.com/
</VirtualHost>
```

## 🔒 SSL/TLS Configuration

### Certificate Generation
```bash
# Generate private key
openssl genrsa -out example.com.key 2048

# Generate certificate signing request
openssl req -new -key example.com.key -out example.com.csr

# Generate self-signed certificate
openssl x509 -req -days 365 -in example.com.csr -signkey example.com.key -out example.com.crt

# Generate certificate with Subject Alternative Names
openssl req -x509 -newkey rsa:4096 -keyout example.com.key -out example.com.crt -days 365 -nodes \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=example.com" \
    -addext "subjectAltName=DNS:example.com,DNS:www.example.com"
```

### Let's Encrypt Integration
```bash
# Install Certbot
sudo apt update
sudo apt install certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d example.com -d www.example.com

# Auto-renewal
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

## ⚖️ Load Balancing

### Nginx Load Balancing
```nginx
# Upstream servers
upstream backend {
    least_conn;
    server 192.168.1.10:8080 weight=3;
    server 192.168.1.11:8080 weight=2;
    server 192.168.1.12:8080 weight=1;
    keepalive 32;
}

# Load balancer configuration
server {
    listen 80;
    server_name api.example.com;
    
    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Health checks
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_connect_timeout 5s;
        proxy_send_timeout 10s;
        proxy_read_timeout 10s;
    }
}
```

### Apache Load Balancing
```apache
# Load balancer configuration
<VirtualHost *:80>
    ServerName api.example.com
    
    # Proxy configuration
    ProxyPreserveHost On
    ProxyRequests Off
    
    # Backend servers
    ProxyPass / balancer://mycluster/
    ProxyPassReverse / balancer://mycluster/
    
    # Load balancer cluster
    <Proxy balancer://mycluster>
        BalancerMember http://192.168.1.10:8080 loadfactor=3
        BalancerMember http://192.168.1.11:8080 loadfactor=2
        BalancerMember http://192.168.1.12:8080 loadfactor=1
    </Proxy>
</VirtualHost>
```

## 🔄 Reverse Proxy Setup

### Nginx Reverse Proxy
```nginx
server {
    listen 80;
    server_name app.example.com;
    
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    # Static files
    location /static/ {
        alias /var/www/app/static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

## 🚀 Performance Optimization

### Nginx Optimization
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

# HTTP optimization
http {
    # Buffer sizes
    client_body_buffer_size 128k;
    client_max_body_size 10m;
    client_header_buffer_size 1k;
    large_client_header_buffers 4 4k;
    
    # Timeouts
    client_body_timeout 12;
    client_header_timeout 12;
    keepalive_timeout 15;
    send_timeout 10;
    
    # File caching
    open_file_cache max=1000 inactive=20s;
    open_file_cache_valid 30s;
    open_file_cache_min_uses 2;
    open_file_cache_errors on;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/atom+xml
        image/svg+xml;
}
```

### Apache Optimization
```apache
# MPM configuration
<IfModule mpm_event_module>
    StartServers 3
    MinSpareThreads 75
    MaxSpareThreads 250
    ThreadsPerChild 25
    MaxRequestWorkers 400
    MaxConnectionsPerChild 0
</IfModule>

# Performance modules
LoadModule deflate_module modules/mod_deflate.so
LoadModule expires_module modules/mod_expires.so
LoadModule headers_module modules/mod_headers.so

# Compression
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/plain
    AddOutputFilterByType DEFLATE text/html
    AddOutputFilterByType DEFLATE text/xml
    AddOutputFilterByType DEFLATE text/css
    AddOutputFilterByType DEFLATE application/xml
    AddOutputFilterByType DEFLATE application/xhtml+xml
    AddOutputFilterByType DEFLATE application/rss+xml
    AddOutputFilterByType DEFLATE application/javascript
    AddOutputFilterByType DEFLATE application/x-javascript
</IfModule>

# Expires headers
<IfModule mod_expires.c>
    ExpiresActive on
    ExpiresByType text/css "access plus 1 year"
    ExpiresByType application/javascript "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType image/jpg "access plus 1 year"
    ExpiresByType image/jpeg "access plus 1 year"
    ExpiresByType image/gif "access plus 1 year"
</IfModule>
```

## 🔐 Security Configuration

### Security Headers
```nginx
# Security headers for all sites
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header X-Content-Type-Options "nosniff" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;
```

### Rate Limiting
```nginx
# Rate limiting
limit_req_zone $binary_remote_addr zone=login:10m rate=1r/s;
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;

server {
    # Login rate limiting
    location /login {
        limit_req zone=login burst=5 nodelay;
        # ... other configuration
    }
    
    # API rate limiting
    location /api/ {
        limit_req zone=api burst=20 nodelay;
        # ... other configuration
    }
}
```

### Access Control
```nginx
# IP whitelist
location /admin {
    allow 192.168.1.0/24;
    allow 10.0.0.0/8;
    deny all;
    # ... other configuration
}

# Basic authentication
location /secure {
    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/.htpasswd;
    # ... other configuration
}
```

## 📊 Monitoring and Logging

### Log Analysis
```bash
# Analyze access logs
tail -f /var/log/nginx/access.log | grep -E "(GET|POST|PUT|DELETE)"

# Top IP addresses
awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -nr | head -10

# Most requested pages
awk '{print $7}' /var/log/nginx/access.log | sort | uniq -c | sort -nr | head -10

# Error analysis
grep " 50[0-9] " /var/log/nginx/access.log | tail -20
```

### Performance Monitoring
```bash
# Check Nginx status
curl http://localhost/nginx_status

# Monitor connections
ss -tuln | grep :80
netstat -tuln | grep :80

# Check worker processes
ps aux | grep nginx
```

## 🔍 Troubleshooting

### Common Issues

#### 1. **502 Bad Gateway**
```bash
# Check upstream servers
curl -I http://backend-server:8080

# Check proxy configuration
nginx -t

# Check error logs
tail -f /var/log/nginx/error.log
```

#### 2. **SSL Certificate Issues**
```bash
# Test SSL certificate
openssl s_client -connect example.com:443 -servername example.com

# Check certificate validity
openssl x509 -in /etc/ssl/certs/example.com.crt -text -noout

# Verify certificate chain
curl -I https://example.com
```

#### 3. **Performance Issues**
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
# Test configuration
nginx -t
apache2ctl configtest

# Reload configuration
nginx -s reload
systemctl reload apache2

# Check status
systemctl status nginx
systemctl status apache2

# View logs
journalctl -u nginx -f
journalctl -u apache2 -f
```

## 🧪 Practical Labs

### Lab 1: Basic Web Server Setup
```bash
# Install Nginx
sudo apt update
sudo apt install nginx

# Create website directory
sudo mkdir -p /var/www/example.com
sudo chown -R $USER:$USER /var/www/example.com

# Create test page
echo "<h1>Welcome to Example.com</h1>" > /var/www/example.com/index.html

# Configure virtual host
sudo nano /etc/nginx/sites-available/example.com

# Enable site
sudo ln -s /etc/nginx/sites-available/example.com /etc/nginx/sites-enabled/

# Test and reload
sudo nginx -t
sudo systemctl reload nginx
```

### Lab 2: SSL Configuration
```bash
# Generate self-signed certificate
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/example.com.key \
    -out /etc/ssl/certs/example.com.crt

# Configure SSL virtual host
sudo nano /etc/nginx/sites-available/example.com-ssl

# Test SSL
curl -k https://example.com
```

### Lab 3: Load Balancing
```bash
# Set up multiple backend servers
# Configure load balancer
# Test load distribution
```

## 📚 Quick Reference

### Nginx Commands
```bash
# Test configuration
nginx -t

# Reload configuration
nginx -s reload

# Stop server
nginx -s stop

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

# Check status
systemctl status apache2

# View logs
tail -f /var/log/apache2/access.log
tail -f /var/log/apache2/error.log
```

### Common Ports
- **HTTP**: 80
- **HTTPS**: 443
- **Nginx Status**: 80/nginx_status
- **Apache Status**: 80/server-status

## 🎯 Learning Objectives

By the end of this module, you should be able to:

1. **Configure Web Servers**: Set up Nginx and Apache with virtual hosts
2. **Implement SSL/TLS**: Configure HTTPS with certificates
3. **Set Up Load Balancing**: Distribute traffic across multiple servers
4. **Configure Reverse Proxies**: Forward requests to backend services
5. **Optimize Performance**: Implement caching and compression
6. **Secure Web Servers**: Configure security headers and access control
7. **Monitor and Troubleshoot**: Analyze logs and diagnose issues

## 🔗 Additional Resources

- [Nginx Documentation](https://nginx.org/en/docs/)
- [Apache Documentation](https://httpd.apache.org/docs/)
- [SSL Labs](https://www.ssllabs.com/ssltest/)
- [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org/)

---

**Next Steps**: Practice with the hands-on labs and explore advanced configurations. HTTP server management skills are essential for web infrastructure and application deployment.
