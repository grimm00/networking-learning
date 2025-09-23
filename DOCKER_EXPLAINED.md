# Docker Setup Explained - Main Networking Project

This document explains the main Docker configuration for the entire networking learning project in simple terms, perfect for beginners.

## 🎯 What is This Project?

This is a **comprehensive networking learning environment** that uses Docker containers to create a safe space for learning computer networking concepts. Think of it as a virtual lab where you can experiment without breaking your computer.

## 🐳 What is Docker?

**Docker** is a tool that creates **containers** - like lightweight virtual machines that run applications in isolation. 

**Simple analogy:**
- **Container** = A shipping container that holds everything needed for an application
- **Image** = A blueprint/template for creating containers
- **Docker Compose** = A manager that coordinates multiple containers

## 📁 Project Structure

```
networking/
├── docker-compose.yml          # Main configuration file
├── bin/                        # Management scripts
├── scripts/                    # Python and shell tools
├── 01-basics/                  # Basic networking concepts
├── 02-protocols/               # Network protocols
├── 03-docker-networks/         # Container networking
├── 04-network-analysis/        # Network monitoring tools
├── 05-dns-server/              # DNS server module
├── 06-http-servers/            # HTTP server module
└── admin/                      # Project documentation
```

## 🔧 Main Docker Compose Configuration Explained

### **Basic Structure**
```yaml
services:                    # List of all containers to run
  net-practice:             # Main learning container
    image: ubuntu:22.04     # Use Ubuntu Linux
    container_name: net-practice  # Friendly name
    privileged: true        # Give special permissions
    cap_add:               # Add specific capabilities
      - NET_ADMIN          # Network administration
      - NET_RAW           # Raw network access
      - SYS_ADMIN         # System administration
```

### **What Each Part Does:**

#### **1. Main Practice Container (net-practice)**
```yaml
net-practice:
  image: ubuntu:22.04
  container_name: net-practice
  privileged: true
  cap_add:
    - NET_ADMIN
    - NET_RAW
    - SYS_ADMIN
```
**What it does:**
- Creates your main learning environment
- Runs Ubuntu Linux (popular, beginner-friendly)
- **privileged: true** = Gives container special permissions
- **NET_ADMIN** = Allows network configuration
- **NET_RAW** = Allows raw network access (for packet capture)
- **SYS_ADMIN** = Allows system-level operations

#### **2. Port Mapping**
```yaml
ports:
  - "8080:80"              # Web interface
  - "8443:443"            # HTTPS interface
```
**What this means:**
- **8080:80** = "When someone visits localhost:8080, send them to port 80 inside the container"
- **8443:443** = "When someone visits localhost:8443, send them to port 443 inside the container"

#### **3. Volume Mounting**
```yaml
volumes:
  - ./scripts:/scripts:ro
  - ./01-basics:/workspace/01-basics:ro
  - ./02-protocols:/workspace/02-protocols:ro
```
**What this means:**
- **./scripts** = Your scripts folder on your computer
- **:/scripts** = Where it goes inside the container
- **:ro** = "read-only" (container can't modify your files)

#### **4. Networks**
```yaml
networks:
  - frontend
  - backend
```
**What this means:**
- **frontend** = Network for web interfaces
- **backend** = Network for databases and services
- **Why separate networks?** Better security and organization

## 🚀 Different Services Explained

### **1. Web Interface (nginx-frontend)**
```yaml
nginx-frontend:
  image: nginx:alpine
  ports:
    - "80:80"
    - "443:443"
```
**What it does:**
- Provides a web interface for the project
- **Access:** http://localhost:80
- **Purpose:** Easy access to learning materials

### **2. Database (postgres)**
```yaml
postgres:
  image: postgres:15
  ports:
    - "5433:5432"
  environment:
    POSTGRES_DB: networking
    POSTGRES_USER: student
    POSTGRES_PASSWORD: learn123
```
**What it does:**
- Runs PostgreSQL database
- **Access:** localhost:5433
- **Purpose:** Store learning progress and data

### **3. DNS Server (dns-server)**
```yaml
dns-server:
  image: coredns/coredns:latest
  ports:
    - "53:53/udp"
    - "53:53/tcp"
```
**What it does:**
- Runs DNS server for name resolution
- **Access:** localhost:53
- **Purpose:** Learn DNS concepts

### **4. Monitoring (prometheus)**
```yaml
prometheus:
  image: prom/prometheus:latest
  ports:
    - "9090:9090"
```
**What it does:**
- Monitors system performance
- **Access:** http://localhost:9090
- **Purpose:** Learn network monitoring

## 🔄 How to Use This Setup

### **Start Everything**
```bash
docker-compose up -d
```
**What happens:**
1. Downloads all required images
2. Creates all containers
3. Sets up networks
4. Starts all services

### **Start Specific Services**
```bash
docker-compose up -d net-practice postgres
```
**What happens:**
1. Starts only the practice container and database
2. Other services remain stopped

### **Stop Everything**
```bash
docker-compose down
```
**What happens:**
1. Stops all containers
2. Removes containers (but keeps images)
3. Cleans up networks

## 🧪 Testing Your Setup

### **1. Check Container Status**
```bash
docker-compose ps
```
**Expected output:** List of running containers

### **2. Access Practice Container**
```bash
docker exec -it net-practice bash
```
**What happens:**
- Opens a bash shell inside the practice container
- You can run networking commands safely

### **3. Test Web Interface**
```bash
curl http://localhost:80
```
**Expected output:** HTML content from web interface

### **4. Test Database**
```bash
docker exec -it postgres psql -U student -d networking
```
**What happens:**
- Connects to PostgreSQL database
- You can run SQL commands

## 🔍 Common Issues and Solutions

### **Port Already in Use**
```
Error: Bind for 0.0.0.0:80 failed: port is already allocated
```
**Solution:** Something else is using port 80. Change the port:
```yaml
ports:
  - "8080:80"  # Changed from 80 to 8080
```

### **Container Won't Start**
```bash
docker-compose logs net-practice
```
**Solution:** Check the logs to see what's wrong

### **Permission Denied**
```
Error: permission denied
```
**Solution:** Make sure Docker has proper permissions:
```bash
sudo usermod -aG docker $USER
# Then log out and back in
```

### **Out of Disk Space**
```
Error: no space left on device
```
**Solution:** Clean up Docker:
```bash
docker system prune -a
```

## 🎯 Learning Objectives

After understanding this setup, you should be able to:

1. **Explain Docker Concepts**
   - What containers are
   - How port mapping works
   - What volume mounting does
   - How networks work

2. **Understand Service Architecture**
   - How different services work together
   - What each service does
   - How services communicate

3. **Troubleshoot Common Issues**
   - Port conflicts
   - Permission problems
   - Container startup issues

## 🚀 Next Steps

1. **Explore Different Modules**
   - Try the DNS server module
   - Try the HTTP servers module
   - Experiment with network analysis tools

2. **Modify Configurations**
   - Change port numbers
   - Add new services
   - Modify existing services

3. **Learn Container Management**
   - Start/stop individual services
   - View logs and debug issues
   - Clean up resources

## 💡 Key Takeaways

- **Docker** makes it easy to run complex applications
- **Containers** provide isolated environments for learning
- **Port mapping** lets you access services from your computer
- **Volume mounting** lets you edit files and see changes
- **Networks** let containers communicate with each other
- **Profiles** let you start only the services you need

This setup gives you a complete networking lab environment where you can learn safely without affecting your main computer! 🎉

## 🔗 Related Documentation

- [HTTP Servers Docker Setup](06-http-servers/DOCKER_EXPLAINED.md)
- [DNS Server Docker Setup](05-dns-server/DOCKER_EXPLAINED.md)
- [Installation Guide](docs/guides/INSTALLATION.md)
- [Container Requirements](docs/guides/CONTAINER_REQUIREMENTS.md)
