# Deployment Guide

## Overview

This guide covers the deployment and setup procedures for the Networking Learning Project across different environments and platforms.

## Prerequisites

### System Requirements
- **RAM**: Minimum 4GB, Recommended 8GB+
- **Storage**: Minimum 10GB free space
- **CPU**: Multi-core processor recommended
- **Network**: Internet connection for initial setup

### Software Requirements
- **Docker**: Version 20.10+
- **Docker Compose**: Version 2.0+
- **Git**: Version 2.0+
- **Python**: Version 3.8+ (for local development)

### Platform Support
- **Linux**: Ubuntu 20.04+, CentOS 8+, RHEL 8+
- **macOS**: macOS 10.15+ (Catalina or later)
- **Windows**: Windows 10+ with WSL2 or Docker Desktop

## Installation Methods

### Method 1: Quick Start (Recommended)

#### Step 1: Clone Repository
```bash
git clone https://github.com/grimm00/networking.git
cd networking
```

#### Step 2: Build and Start
```bash
# Build containers
docker-compose build

# Start all services
docker-compose up -d

# Verify containers are running
docker-compose ps
```

#### Step 3: Access Learning Environment
```bash
# Enter the learning container
./container-practice.sh
```

### Method 2: Manual Setup

#### Step 1: Install Docker
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install docker.io docker-compose

# CentOS/RHEL
sudo yum install docker docker-compose

# macOS (using Homebrew)
brew install docker docker-compose

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker
```

#### Step 2: Clone and Configure
```bash
# Clone repository
git clone https://github.com/grimm00/networking.git
cd networking

# Make scripts executable
chmod +x *.sh
chmod +x scripts/*.py
chmod +x scripts/*.sh
```

#### Step 3: Build Containers
```bash
# Build all containers
docker-compose build

# Build specific container
docker-compose build net-practice
```

#### Step 4: Start Services
```bash
# Start all services
docker-compose up -d

# Start specific service
docker-compose up -d net-practice

# View logs
docker-compose logs -f net-practice
```

## Environment Configuration

### Docker Compose Configuration

#### Basic Configuration
```yaml
# docker-compose.yml
version: '3.8'

services:
  net-practice:
    build: .
    container_name: net-practice
    volumes:
      - ./01-basics/basic-commands:/basic-commands
      - ./tools:/tools
      - ./scripts:/scripts
    networks:
      - learning-network
    command: tail -f /dev/null

networks:
  learning-network:
    driver: bridge
```

#### Advanced Configuration
```yaml
# docker-compose.override.yml
version: '3.8'

services:
  net-practice:
    environment:
      - PYTHONPATH=/scripts
      - LOG_LEVEL=INFO
    volumes:
      - ./data:/data
      - ./logs:/var/log
    ports:
      - "8080:8080"
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "python3", "/scripts/health-check.py"]
      interval: 30s
      timeout: 10s
      retries: 3
```

### Environment Variables

#### Required Variables
```bash
# .env file
COMPOSE_PROJECT_NAME=networking-learning
DOCKER_NETWORK_NAME=learning-network
CONTAINER_PREFIX=net-
```

#### Optional Variables
```bash
# Development settings
DEBUG=true
LOG_LEVEL=DEBUG
PYTHON_PATH=/scripts

# Performance settings
MEMORY_LIMIT=2g
CPU_LIMIT=2
```

## Platform-Specific Deployment

### Linux Deployment

#### Ubuntu/Debian
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Clone and setup
git clone https://github.com/grimm00/networking.git
cd networking
docker-compose up -d
```

#### CentOS/RHEL
```bash
# Install Docker
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Setup project
git clone https://github.com/grimm00/networking.git
cd networking
docker-compose up -d
```

### macOS Deployment

#### Using Homebrew
```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Docker
brew install --cask docker

# Start Docker Desktop
open /Applications/Docker.app

# Clone and setup
git clone https://github.com/grimm00/networking.git
cd networking
docker-compose up -d
```

#### Using Docker Desktop
```bash
# Download Docker Desktop from https://www.docker.com/products/docker-desktop
# Install and start Docker Desktop

# Clone repository
git clone https://github.com/grimm00/networking.git
cd networking

# Build and start
docker-compose up -d
```

### Windows Deployment

#### Using WSL2
```bash
# Install WSL2
wsl --install

# Install Docker in WSL2
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Clone repository
git clone https://github.com/grimm00/networking.git
cd networking

# Setup
docker-compose up -d
```

#### Using Docker Desktop
```bash
# Download Docker Desktop from https://www.docker.com/products/docker-desktop
# Install Docker Desktop

# Open PowerShell or Command Prompt
git clone https://github.com/grimm00/networking.git
cd networking
docker-compose up -d
```

## Cloud Deployment

### AWS Deployment

#### Using EC2
```bash
# Launch EC2 instance (Ubuntu 22.04)
# Connect via SSH

# Install Docker
sudo apt update
sudo apt install docker.io docker-compose

# Clone repository
git clone https://github.com/grimm00/networking.git
cd networking

# Configure security groups
# Allow ports 22 (SSH), 80 (HTTP), 443 (HTTPS)

# Start services
docker-compose up -d
```

#### Using ECS
```yaml
# ecs-task-definition.json
{
  "family": "networking-learning",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "1024",
  "memory": "2048",
  "containerDefinitions": [
    {
      "name": "net-practice",
      "image": "ubuntu:22.04",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8080,
          "protocol": "tcp"
        }
      ]
    }
  ]
}
```

### Azure Deployment

#### Using Azure Container Instances
```bash
# Create resource group
az group create --name networking-rg --location eastus

# Deploy container
az container create \
  --resource-group networking-rg \
  --name networking-learning \
  --image ubuntu:22.04 \
  --cpu 2 \
  --memory 4 \
  --ports 80 443
```

#### Using Azure Container Apps
```yaml
# azure-container-app.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: networking-learning
spec:
  replicas: 1
  selector:
    matchLabels:
      app: networking-learning
  template:
    metadata:
      labels:
        app: networking-learning
    spec:
      containers:
      - name: net-practice
        image: ubuntu:22.04
        ports:
        - containerPort: 8080
```

### Google Cloud Deployment

#### Using Cloud Run
```bash
# Build and push image
gcloud builds submit --tag gcr.io/PROJECT-ID/networking-learning

# Deploy to Cloud Run
gcloud run deploy networking-learning \
  --image gcr.io/PROJECT-ID/networking-learning \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

#### Using GKE
```yaml
# gke-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: networking-learning
spec:
  replicas: 1
  selector:
    matchLabels:
      app: networking-learning
  template:
    metadata:
      labels:
        app: networking-learning
    spec:
      containers:
      - name: net-practice
        image: ubuntu:22.04
        ports:
        - containerPort: 8080
```

## Production Deployment

### Production Considerations

#### Security
- **Network Security**: Use firewalls and security groups
- **Access Control**: Implement proper authentication
- **Secrets Management**: Use secret management services
- **SSL/TLS**: Enable HTTPS for all communications
- **Updates**: Regular security updates

#### Performance
- **Resource Allocation**: Proper CPU and memory allocation
- **Load Balancing**: Distribute load across multiple instances
- **Caching**: Implement caching strategies
- **Monitoring**: Comprehensive monitoring and alerting
- **Scaling**: Auto-scaling based on demand

#### Reliability
- **High Availability**: Multiple availability zones
- **Backup**: Regular backups and disaster recovery
- **Health Checks**: Automated health monitoring
- **Rolling Updates**: Zero-downtime deployments
- **Rollback**: Quick rollback capabilities

### Production Configuration

#### Docker Compose Production
```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  net-practice:
    image: networking-learning:latest
    container_name: net-practice-prod
    restart: unless-stopped
    environment:
      - ENVIRONMENT=production
      - LOG_LEVEL=INFO
    volumes:
      - ./data:/data
      - ./logs:/var/log
    networks:
      - production-network
    healthcheck:
      test: ["CMD", "python3", "/scripts/health-check.py"]
      interval: 30s
      timeout: 10s
      retries: 3
    deploy:
      resources:
        limits:
          memory: 2g
          cpus: '2'
        reservations:
          memory: 1g
          cpus: '1'

  nginx:
    image: nginx:alpine
    container_name: nginx-proxy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - net-practice

networks:
  production-network:
    driver: bridge
```

#### Nginx Configuration
```nginx
# nginx.conf
events {
    worker_connections 1024;
}

http {
    upstream networking-learning {
        server net-practice:8080;
    }

    server {
        listen 80;
        server_name your-domain.com;
        return 301 https://$server_name$request_uri;
    }

    server {
        listen 443 ssl;
        server_name your-domain.com;

        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;

        location / {
            proxy_pass http://networking-learning;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

## Monitoring and Logging

### Monitoring Setup

#### Prometheus Configuration
```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'networking-learning'
    static_configs:
      - targets: ['net-practice:9090']
```

#### Grafana Dashboard
```json
{
  "dashboard": {
    "title": "Networking Learning Project",
    "panels": [
      {
        "title": "Container CPU Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(container_cpu_usage_seconds_total[5m])"
          }
        ]
      }
    ]
  }
}
```

### Logging Configuration

#### Log Aggregation
```yaml
# docker-compose.logging.yml
version: '3.8'

services:
  elasticsearch:
    image: elasticsearch:7.14.0
    environment:
      - discovery.type=single-node
    ports:
      - "9200:9200"

  kibana:
    image: kibana:7.14.0
    ports:
      - "5601:5601"
    depends_on:
      - elasticsearch

  logstash:
    image: logstash:7.14.0
    volumes:
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf
    depends_on:
      - elasticsearch
```

## Troubleshooting Deployment

### Common Issues

#### Docker Issues
```bash
# Check Docker status
sudo systemctl status docker

# Restart Docker
sudo systemctl restart docker

# Check Docker logs
sudo journalctl -u docker

# Clean up Docker
docker system prune -a
```

#### Container Issues
```bash
# Check container status
docker-compose ps

# View container logs
docker-compose logs net-practice

# Restart container
docker-compose restart net-practice

# Rebuild container
docker-compose build --no-cache net-practice
```

#### Network Issues
```bash
# Check network connectivity
docker network ls
docker network inspect learning-network

# Test connectivity
docker exec net-practice ping 8.8.8.8

# Check DNS resolution
docker exec net-practice nslookup google.com
```

#### Permission Issues
```bash
# Fix script permissions
chmod +x *.sh
chmod +x scripts/*.py
chmod +x scripts/*.sh

# Fix Docker permissions
sudo usermod -aG docker $USER
newgrp docker
```

### Debugging Commands

#### System Information
```bash
# Check system resources
free -h
df -h
top

# Check Docker resources
docker system df
docker stats

# Check container resources
docker exec net-practice free -h
docker exec net-practice df -h
```

#### Network Debugging
```bash
# Check network interfaces
docker exec net-practice ip link show
docker exec net-practice ip addr show

# Check routing
docker exec net-practice ip route show

# Check connectivity
docker exec net-practice ping -c 3 8.8.8.8
docker exec net-practice traceroute 8.8.8.8
```

## Maintenance and Updates

### Update Procedures

#### Application Updates
```bash
# Pull latest changes
git pull origin main

# Rebuild containers
docker-compose build --no-cache

# Restart services
docker-compose down
docker-compose up -d
```

#### System Updates
```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Update Docker
sudo apt install docker.io docker-compose

# Restart services
sudo systemctl restart docker
docker-compose up -d
```

#### Backup Procedures
```bash
# Backup data
tar -czf networking-backup-$(date +%Y%m%d).tar.gz data/ logs/

# Backup configuration
cp docker-compose.yml docker-compose.yml.backup
cp .env .env.backup
```

---

*This deployment guide provides comprehensive instructions for deploying the Networking Learning Project across various environments and platforms.*
