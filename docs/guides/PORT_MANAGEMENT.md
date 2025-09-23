# Port Management Guide

This document outlines the port allocation strategy for the networking learning project to prevent conflicts between different modules.

## 🎯 Port Allocation Strategy

### **Core Services (Main docker-compose.yml)**
- **Port 53**: DNS server (dns-server)
- **Port 80**: Main web interface (nginx-frontend)
- **Port 443**: HTTPS web interface (nginx-frontend)
- **Port 5433**: PostgreSQL database (postgres)
- **Port 8080**: Reserved for main practice container
- **Port 9090**: Prometheus monitoring

### **Module-Specific Port Ranges**

#### **05-dns-server Module**
- **Port 53**: CoreDNS basic (conflicts with main DNS - use profiles)
- **Port 5353**: CoreDNS advanced
- **Port 5354**: CoreDNS secure
- **Port 9080-9082**: Health check endpoints
- **Port 9154-9156**: Prometheus metrics

#### **06-http-servers Module**
- **Port 8081**: Nginx basic (updated to avoid conflicts)
- **Port 8082**: Nginx advanced
- **Port 8083**: Nginx SSL
- **Port 8084**: Apache basic
- **Port 8444-8447**: HTTPS endpoints
- **Port 9001-9003**: Backend applications

#### **04-network-analysis Module**
- **Port 8080**: Reserved for analysis tools
- **Port 8443**: Reserved for secure analysis

## 🔧 Conflict Resolution

### **1. Use Docker Compose Profiles**
Each module should use profiles to avoid conflicts:

```yaml
# Main docker-compose.yml
services:
  nginx-frontend:
    profiles: ["main"]
    ports:
      - "80:80"
      - "443:443"

# 06-http-servers/docker-compose.yml
services:
  nginx-basic:
    profiles: ["http-servers"]
    ports:
      - "8080:80"
```

### **2. Port Range Allocation**
Assign specific port ranges to each module:

- **Main Services**: 1-99, 80, 443, 5433, 8080, 9090
- **DNS Module**: 5353-5359, 9080-9089, 9154-9159
- **HTTP Module**: 8081-8089, 8443-8449, 9001-9009
- **Analysis Module**: 8090-8099, 8450-8459
- **Security Module**: 8100-8109, 8460-8469
- **Advanced Module**: 8110-8119, 8470-8479

### **3. Environment-Based Configuration**
Use environment variables to make ports configurable:

```yaml
services:
  nginx-basic:
    ports:
      - "${HTTP_PORT:-8080}:80"
```

## 📋 Port Allocation Table

| Module | Service | Port | Purpose | Conflicts |
|--------|---------|------|---------|-----------|
| Main | nginx-frontend | 80 | Web interface | HTTP modules |
| Main | nginx-frontend | 443 | HTTPS interface | HTTP modules |
| Main | dns-server | 53 | DNS service | DNS modules |
| Main | postgres | 5433 | Database | None |
| Main | prometheus | 9090 | Monitoring | None |
| DNS | coredns | 53 | DNS server | Main DNS |
| DNS | coredns-advanced | 5353 | Advanced DNS | None |
| DNS | coredns-secure | 5354 | Secure DNS | None |
| HTTP | nginx-basic | 8081 | Basic HTTP | None |
| HTTP | nginx-advanced | 8082 | Advanced HTTP | None |
| HTTP | nginx-ssl | 8083 | SSL HTTP | None |
| HTTP | apache-basic | 8084 | Apache HTTP | None |

## 🛠️ Implementation Solutions

### **Solution 1: Modular Docker Compose Files**
Each module has its own docker-compose.yml with unique ports:

```bash
# Start only main services
docker-compose up -d

# Start DNS module
cd modules/05-dns-server && docker-compose up -d

# Start HTTP module
cd modules/06-http-servers && docker-compose up -d
```

### **Solution 2: Unified Port Management**
Create a centralized port management system:

```bash
# Check port usage
./bin/check-ports.sh

# Start specific modules
./bin/start-module.sh dns
./bin/start-module.sh http
```

### **Solution 3: Profile-Based Management**
Use Docker Compose profiles to manage different configurations:

```bash
# Start main services
docker-compose --profile main up -d

# Start with DNS module
docker-compose --profile main --profile dns up -d

# Start with HTTP module
docker-compose --profile main --profile http up -d
```

## 🔍 Port Conflict Detection

### **Check Port Usage**
```bash
# Check what's using specific ports
lsof -i :8080
lsof -i :53
lsof -i :80

# Check Docker port mappings
docker ps --format "table {{.Names}}\t{{.Ports}}"
```

### **Port Conflict Resolution Script**
```bash
#!/bin/bash
# check-ports.sh

CONFLICTS=()

# Check for conflicts
if lsof -i :8080 >/dev/null 2>&1; then
    CONFLICTS+=("8080")
fi

if lsof -i :53 >/dev/null 2>&1; then
    CONFLICTS+=("53")
fi

if [ ${#CONFLICTS[@]} -gt 0 ]; then
    echo "⚠️ Port conflicts detected: ${CONFLICTS[*]}"
    echo "Consider using different modules or stopping conflicting services"
else
    echo "✅ No port conflicts detected"
fi
```

## 📝 Best Practices

### **1. Always Check Ports Before Starting**
```bash
# Before starting any module
./bin/check-ports.sh
```

### **2. Use Descriptive Port Ranges**
- **8000-8099**: HTTP services
- **8400-8499**: HTTPS services
- **9000-9099**: Backend services
- **9100-9199**: Monitoring services

### **3. Document Port Usage**
Each module should document its port usage in its README.md

### **4. Use Environment Variables**
Make ports configurable through environment variables

### **5. Implement Port Validation**
Add port validation to startup scripts

## 🚀 Recommended Implementation

I recommend implementing **Solution 1** (Modular Docker Compose Files) with the following changes:

1. **Update main docker-compose.yml** to use profiles
2. **Modify module docker-compose.yml files** to use unique port ranges
3. **Create port management scripts** for easy module switching
4. **Add port conflict detection** to prevent issues

This approach provides:
- ✅ Clear separation between modules
- ✅ No port conflicts
- ✅ Easy module management
- ✅ Scalable for future modules

Would you like me to implement this port management solution?
