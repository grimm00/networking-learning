# Docker Setup Explained - HTTP Servers Module

This document explains the Docker configuration for the HTTP Servers module in simple terms, perfect for networking learners.

## 🐳 What is Docker?

Docker is a tool that creates **containers** - like lightweight virtual machines that run applications in isolation. Think of it as:
- **Container** = A box that contains everything needed to run an application
- **Image** = A template/blueprint for creating containers
- **Docker Compose** = A tool that manages multiple containers together

## 📁 File Structure

```
06-http-servers/
├── docker-compose.yml          # Main configuration file
├── nginx-configs/              # Nginx server configurations
│   ├── server-basic.conf       # Simple web server setup
│   ├── server-advanced.conf    # Advanced server with security
│   └── server-ssl.conf         # HTTPS server setup
├── html/                       # Website files
│   ├── index.html             # Main webpage
│   ├── test.html              # Test page for learning
│   ├── static/                # CSS and JavaScript files
│   └── api/                   # API endpoints
└── ssl-certs/                 # SSL certificates (for HTTPS)
```

## 🔧 Docker Compose Configuration Explained

### **Basic Structure**
```yaml
services:                    # List of containers to run
  nginx-basic:              # Name of our first container
    image: nginx:alpine     # Use Nginx web server (Alpine Linux = lightweight)
    container_name: nginx-basic  # Give it a friendly name
    ports:                  # Port mapping: host_port:container_port
      - "8090:80"          # Host port 8090 → Container port 80 (HTTP)
      - "8440:443"         # Host port 8440 → Container port 443 (HTTPS)
```

### **What Each Part Does:**

#### **1. Image Selection**
```yaml
image: nginx:alpine
```
- **nginx** = Web server software (like Apache, but different)
- **alpine** = Tiny Linux distribution (only 5MB!)
- **Why Alpine?** Faster startup, less memory usage, more secure

#### **2. Port Mapping**
```yaml
ports:
  - "8090:80"
  - "8440:443"
```
- **8090:80** = "When someone visits localhost:8090, send them to port 80 inside the container"
- **8440:443** = "When someone visits localhost:8440, send them to port 443 inside the container"
- **Why different ports?** Avoid conflicts with other services on your computer

#### **3. Volume Mounting**
```yaml
volumes:
  - ./nginx-configs/server-basic.conf:/etc/nginx/conf.d/default.conf:ro
  - ./html:/usr/share/nginx/html:ro
```
- **Volume** = A way to share files between your computer and the container
- **./nginx-configs/server-basic.conf** = File on your computer
- **:/etc/nginx/conf.d/default.conf** = Where it goes inside the container
- **:ro** = "read-only" (container can't modify your files)

#### **4. Networks**
```yaml
networks:
  - http-network
```
- **Network** = How containers talk to each other
- **http-network** = Our custom network for HTTP servers
- **Why custom network?** Better isolation and control

## 🚀 Different Server Types Explained

### **1. Basic Server (nginx-basic)**
```yaml
nginx-basic:
  image: nginx:alpine
  ports:
    - "8090:80"
  volumes:
    - ./nginx-configs/server-basic.conf:/etc/nginx/conf.d/default.conf:ro
    - ./html:/usr/share/nginx/html:ro
```
**What it does:**
- Runs a simple web server
- Serves files from the `html/` folder
- Uses basic Nginx configuration
- **Access:** http://localhost:8090

### **2. Advanced Server (nginx-advanced)**
```yaml
nginx-advanced:
  image: nginx:alpine
  ports:
    - "8091:80"
  volumes:
    - ./nginx-configs/server-advanced.conf:/etc/nginx/conf.d/default.conf:ro
  profiles:
    - advanced
```
**What it does:**
- Same as basic, but with security headers
- Adds protection against common web attacks
- **Access:** http://localhost:8091
- **Profiles:** Only starts when you specifically ask for it

### **3. SSL Server (nginx-ssl)**
```yaml
nginx-ssl:
  image: nginx:alpine
  ports:
    - "8092:80"
    - "8442:443"
  volumes:
    - ./nginx-configs/server-ssl.conf:/etc/nginx/conf.d/default.conf:ro
    - ./ssl-certs:/etc/ssl/certs:ro
```
**What it does:**
- Runs HTTPS (encrypted) web server
- Uses SSL certificates for security
- **Access:** https://localhost:8442
- **Why SSL?** Encrypts data between browser and server

### **4. Apache Server (apache-basic)**
```yaml
apache-basic:
  image: httpd:alpine
  ports:
    - "8093:80"
```
**What it does:**
- Runs Apache web server (alternative to Nginx)
- **Access:** http://localhost:8093
- **Why Apache?** Different web server to compare with Nginx

## 🔄 How to Use This Setup

### **Start Basic Server**
```bash
cd 06-http-servers
docker-compose up -d nginx-basic
```
**What happens:**
1. Docker downloads nginx:alpine image (if not already downloaded)
2. Creates a container named "nginx-basic"
3. Maps port 8090 on your computer to port 80 in the container
4. Mounts your HTML files and Nginx config
5. Starts the web server

### **Start Advanced Server**
```bash
docker-compose --profile advanced up -d
```
**What happens:**
1. Starts nginx-advanced container
2. Uses advanced configuration with security headers
3. Available on port 8091

### **Start All Servers**
```bash
docker-compose up -d
```
**What happens:**
1. Starts nginx-basic (always starts)
2. Starts other servers based on profiles

## 🧪 Testing Your Setup

### **1. Check if Server is Running**
```bash
curl http://localhost:8090
```
**Expected output:** HTML content from your website

### **2. Check Server Status**
```bash
docker-compose ps
```
**Expected output:** List of running containers

### **3. View Server Logs**
```bash
docker-compose logs nginx-basic
```
**Expected output:** Nginx startup messages and any errors

## 🔍 Common Issues and Solutions

### **Port Already in Use**
```
Error: Bind for 0.0.0.0:8090 failed: port is already allocated
```
**Solution:** Change the port number in docker-compose.yml
```yaml
ports:
  - "8091:80"  # Changed from 8090 to 8091
```

### **Configuration Error**
```
nginx: [emerg] invalid variable name
```
**Solution:** Check your Nginx configuration file for syntax errors

### **Container Won't Start**
```bash
docker-compose logs nginx-basic
```
**Solution:** Check the logs to see what's wrong

## 🎯 Learning Objectives

After understanding this setup, you should be able to:

1. **Explain Docker Concepts**
   - What containers are
   - How port mapping works
   - What volume mounting does

2. **Understand Web Server Configuration**
   - How Nginx serves files
   - What security headers do
   - How SSL/HTTPS works

3. **Troubleshoot Common Issues**
   - Port conflicts
   - Configuration errors
   - Container startup problems

## 🚀 Next Steps

1. **Try Different Configurations**
   - Modify the Nginx config files
   - Add new HTML pages
   - Test different security settings

2. **Experiment with Ports**
   - Change port numbers
   - See how it affects access

3. **Compare Servers**
   - Test both Nginx and Apache
   - Compare basic vs advanced configurations

## 💡 Key Takeaways

- **Docker** makes it easy to run web servers without installing software
- **Port mapping** lets you access containers from your computer
- **Volume mounting** lets you edit files and see changes immediately
- **Profiles** let you start only the services you need
- **Networks** let containers communicate with each other

This setup gives you a safe environment to learn web server management without affecting your main computer! 🎉
