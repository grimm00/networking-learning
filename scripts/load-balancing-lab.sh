#!/bin/bash
# Load Balancing Lab Exercises
# Comprehensive hands-on exercises for learning load balancing concepts

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Lab configuration
LAB_DIR="/tmp/load-balancing-lab"
NGINX_CONF_DIR="$LAB_DIR/nginx"
HAPROXY_CONF_DIR="$LAB_DIR/haproxy"
WEB_SERVERS_DIR="$LAB_DIR/web-servers"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

# Function to check if running in container
check_container() {
    if [ -f /.dockerenv ] || [ -n "${DOCKER_CONTAINER:-}" ]; then
        return 0
    else
        return 1
    fi
}

# Function to setup lab environment
setup_lab_environment() {
    print_header "Setting Up Load Balancing Lab Environment"
    
    # Create lab directories
    mkdir -p "$LAB_DIR"/{nginx,haproxy,web-servers,logs}
    mkdir -p "$NGINX_CONF_DIR"
    mkdir -p "$HAPROXY_CONF_DIR"
    mkdir -p "$WEB_SERVERS_DIR"
    
    print_status "Lab directories created"
    
    # Check if Docker is available
    if command -v docker >/dev/null 2>&1; then
        print_status "Docker is available"
        USE_DOCKER=true
    else
        print_warning "Docker not available, using local setup"
        USE_DOCKER=false
    fi
    
    # Check if Nginx is available
    if command -v nginx >/dev/null 2>&1; then
        print_status "Nginx is available"
        NGINX_AVAILABLE=true
    else
        print_warning "Nginx not available"
        NGINX_AVAILABLE=false
    fi
    
    # Check if HAProxy is available
    if command -v haproxy >/dev/null 2>&1; then
        print_status "HAProxy is available"
        HAPROXY_AVAILABLE=true
    else
        print_warning "HAProxy not available"
        HAPROXY_AVAILABLE=false
    fi
}

# Exercise 1: Basic Round Robin Load Balancing
exercise_1_round_robin() {
    print_header "Exercise 1: Basic Round Robin Load Balancing"
    
    print_status "Creating web servers for load balancing..."
    
    if [ "$USE_DOCKER" = true ]; then
        # Create web server containers
        docker run -d --name web-server-1 \
            --network bridge \
            -p 8081:80 \
            -v "$WEB_SERVERS_DIR/web1:/usr/share/nginx/html" \
            nginx:alpine
        
        docker run -d --name web-server-2 \
            --network bridge \
            -p 8082:80 \
            -v "$WEB_SERVERS_DIR/web2:/usr/share/nginx/html" \
            nginx:alpine
        
        docker run -d --name web-server-3 \
            --network bridge \
            -p 8083:80 \
            -v "$WEB_SERVERS_DIR/web3:/usr/share/nginx/html" \
            nginx:alpine
        
        # Create unique content for each server
        echo "<h1>Web Server 1</h1><p>Server ID: web-server-1</p><p>Port: 8081</p>" > "$WEB_SERVERS_DIR/web1/index.html"
        echo "<h1>Web Server 2</h1><p>Server ID: web-server-2</p><p>Port: 8082</p>" > "$WEB_SERVERS_DIR/web2/index.html"
        echo "<h1>Web Server 3</h1><p>Server ID: web-server-3</p><p>Port: 8083</p>" > "$WEB_SERVERS_DIR/web3/index.html"
        
        print_status "Web servers created and running"
        
        # Create Nginx load balancer configuration
        cat > "$NGINX_CONF_DIR/round-robin.conf" << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream backend {
        server web-server-1:80;
        server web-server-2:80;
        server web-server-3:80;
    }
    
    server {
        listen 80;
        server_name localhost;
        
        location / {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
}
EOF
        
        # Start Nginx load balancer
        docker run -d --name nginx-lb \
            --network bridge \
            -p 80:80 \
            -v "$NGINX_CONF_DIR/round-robin.conf:/etc/nginx/nginx.conf" \
            nginx:alpine
        
        print_status "Nginx load balancer started"
        
        # Test load balancing
        print_status "Testing round robin load balancing..."
        for i in {1..6}; do
            echo "Request $i:"
            curl -s http://localhost/ | grep -o "Server ID: [^<]*"
            sleep 1
        done
        
    else
        print_warning "Docker not available for this exercise"
        print_status "Please install Docker to run this exercise"
    fi
}

# Exercise 2: Weighted Load Balancing
exercise_2_weighted() {
    print_header "Exercise 2: Weighted Load Balancing"
    
    if [ "$USE_DOCKER" = true ]; then
        # Create weighted Nginx configuration
        cat > "$NGINX_CONF_DIR/weighted.conf" << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream backend {
        server web-server-1:80 weight=3;
        server web-server-2:80 weight=2;
        server web-server-3:80 weight=1;
    }
    
    server {
        listen 80;
        server_name localhost;
        
        location / {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
}
EOF
        
        # Update Nginx configuration
        docker cp "$NGINX_CONF_DIR/weighted.conf" nginx-lb:/etc/nginx/nginx.conf
        docker exec nginx-lb nginx -s reload
        
        print_status "Weighted load balancing configured"
        print_status "Server weights: web-server-1 (3), web-server-2 (2), web-server-3 (1)"
        
        # Test weighted load balancing
        print_status "Testing weighted load balancing..."
        echo "Counting requests per server over 12 requests:"
        
        declare -A server_count
        server_count["web-server-1"]=0
        server_count["web-server-2"]=0
        server_count["web-server-3"]=0
        
        for i in {1..12}; do
            response=$(curl -s http://localhost/)
            server_id=$(echo "$response" | grep -o "Server ID: [^<]*" | cut -d' ' -f3)
            server_count["$server_id"]=$((server_count["$server_id"] + 1))
        done
        
        echo "Results:"
        echo "  web-server-1: ${server_count[web-server-1]} requests"
        echo "  web-server-2: ${server_count[web-server-2]} requests"
        echo "  web-server-3: ${server_count[web-server-3]} requests"
        
    else
        print_warning "Docker not available for this exercise"
    fi
}

# Exercise 3: Health Checks and Failover
exercise_3_health_checks() {
    print_header "Exercise 3: Health Checks and Failover"
    
    if [ "$USE_DOCKER" = true ]; then
        # Create health check endpoints
        echo "<h1>Health Check OK</h1>" > "$WEB_SERVERS_DIR/web1/health.html"
        echo "<h1>Health Check OK</h1>" > "$WEB_SERVERS_DIR/web2/health.html"
        echo "<h1>Health Check OK</h1>" > "$WEB_SERVERS_DIR/web3/health.html"
        
        # Create Nginx configuration with health checks
        cat > "$NGINX_CONF_DIR/health-checks.conf" << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream backend {
        server web-server-1:80 max_fails=2 fail_timeout=10s;
        server web-server-2:80 max_fails=2 fail_timeout=10s;
        server web-server-3:80 max_fails=2 fail_timeout=10s;
    }
    
    server {
        listen 80;
        server_name localhost;
        
        location / {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            
            # Health check configuration
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
            proxy_next_upstream_tries 3;
            proxy_next_upstream_timeout 10s;
        }
        
        location /health {
            access_log off;
            return 200 "Load balancer healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
EOF
        
        # Update Nginx configuration
        docker cp "$NGINX_CONF_DIR/health-checks.conf" nginx-lb:/etc/nginx/nginx.conf
        docker exec nginx-lb nginx -s reload
        
        print_status "Health checks configured"
        print_status "Testing health check endpoint..."
        curl -s http://localhost/health
        
        print_status "Testing failover by stopping a server..."
        docker stop web-server-2
        
        print_status "Testing requests after server failure..."
        for i in {1..5}; do
            echo "Request $i:"
            curl -s http://localhost/ | grep -o "Server ID: [^<]*"
            sleep 1
        done
        
        print_status "Restarting failed server..."
        docker start web-server-2
        sleep 5
        
        print_status "Testing requests after server recovery..."
        for i in {1..3}; do
            echo "Request $i:"
            curl -s http://localhost/ | grep -o "Server ID: [^<]*"
            sleep 1
        done
        
    else
        print_warning "Docker not available for this exercise"
    fi
}

# Exercise 4: Session Persistence
exercise_4_session_persistence() {
    print_header "Exercise 4: Session Persistence"
    
    if [ "$USE_DOCKER" = true ]; then
        # Create session persistence configuration
        cat > "$NGINX_CONF_DIR/session-persistence.conf" << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream backend {
        ip_hash;
        server web-server-1:80;
        server web-server-2:80;
        server web-server-3:80;
    }
    
    server {
        listen 80;
        server_name localhost;
        
        location / {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
}
EOF
        
        # Update Nginx configuration
        docker cp "$NGINX_CONF_DIR/session-persistence.conf" nginx-lb:/etc/nginx/nginx.conf
        docker exec nginx-lb nginx -s reload
        
        print_status "Session persistence (IP hash) configured"
        print_status "Testing session persistence..."
        
        # Test from different IPs (simulated)
        print_status "Testing from simulated IP 192.168.1.100..."
        for i in {1..3}; do
            echo "Request $i:"
            curl -s -H "X-Forwarded-For: 192.168.1.100" http://localhost/ | grep -o "Server ID: [^<]*"
            sleep 1
        done
        
        print_status "Testing from simulated IP 192.168.1.200..."
        for i in {1..3}; do
            echo "Request $i:"
            curl -s -H "X-Forwarded-For: 192.168.1.200" http://localhost/ | grep -o "Server ID: [^<]*"
            sleep 1
        done
        
    else
        print_warning "Docker not available for this exercise"
    fi
}

# Exercise 5: HAProxy Load Balancing
exercise_5_haproxy() {
    print_header "Exercise 5: HAProxy Load Balancing"
    
    if [ "$USE_DOCKER" = true ]; then
        # Create HAProxy configuration
        cat > "$HAPROXY_CONF_DIR/haproxy.cfg" << 'EOF'
global
    daemon
    maxconn 4096
    log stdout local0

defaults
    mode http
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms
    option httplog

# Statistics page
listen stats
    bind *:8080
    stats enable
    stats uri /stats
    stats refresh 30s

# Frontend
frontend web_frontend
    bind *:80
    default_backend web_servers

# Backend
backend web_servers
    balance roundrobin
    option httpchk GET /health.html
    http-check expect status 200
    
    server web1 web-server-1:80 check weight 3
    server web2 web-server-2:80 check weight 2
    server web3 web-server-3:80 check weight 1
EOF
        
        # Start HAProxy
        docker run -d --name haproxy-lb \
            --network bridge \
            -p 8080:80 \
            -p 8081:8080 \
            -v "$HAPROXY_CONF_DIR/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg" \
            haproxy:latest
        
        print_status "HAProxy load balancer started"
        print_status "HAProxy statistics available at: http://localhost:8081/stats"
        
        # Test HAProxy load balancing
        print_status "Testing HAProxy load balancing..."
        for i in {1..6}; do
            echo "Request $i:"
            curl -s http://localhost:8080/ | grep -o "Server ID: [^<]*"
            sleep 1
        done
        
        # Show HAProxy statistics
        print_status "HAProxy Statistics:"
        curl -s http://localhost:8081/stats | grep -A 20 "web_servers"
        
    else
        print_warning "Docker not available for this exercise"
    fi
}

# Exercise 6: Performance Testing
exercise_6_performance() {
    print_header "Exercise 6: Performance Testing"
    
    if [ "$USE_DOCKER" = true ]; then
        print_status "Running performance tests..."
        
        # Test Nginx load balancer performance
        print_status "Testing Nginx load balancer performance..."
        if command -v ab >/dev/null 2>&1; then
            ab -n 100 -c 10 http://localhost/ > "$LAB_DIR/logs/nginx-performance.log" 2>&1
            echo "Nginx performance test completed. Results saved to $LAB_DIR/logs/nginx-performance.log"
        else
            print_warning "Apache Bench (ab) not available for performance testing"
        fi
        
        # Test HAProxy load balancer performance
        if docker ps | grep -q haproxy-lb; then
            print_status "Testing HAProxy load balancer performance..."
            if command -v ab >/dev/null 2>&1; then
                ab -n 100 -c 10 http://localhost:8080/ > "$LAB_DIR/logs/haproxy-performance.log" 2>&1
                echo "HAProxy performance test completed. Results saved to $LAB_DIR/logs/haproxy-performance.log"
            fi
        fi
        
        # Monitor connection counts
        print_status "Monitoring connection counts..."
        echo "Active connections on port 80:"
        ss -tuna | grep :80 | wc -l
        
        if docker ps | grep -q haproxy-lb; then
            echo "Active connections on port 8080:"
            ss -tuna | grep :8080 | wc -l
        fi
        
    else
        print_warning "Docker not available for this exercise"
    fi
}

# Exercise 7: Load Balancer Analysis
exercise_7_analysis() {
    print_header "Exercise 7: Load Balancer Analysis"
    
    print_status "Running load balancer analysis..."
    
    # Use the load balancer analyzer if available
    if [ -f "/usr/local/bin/load-balancer-analyzer.py" ] || [ -f "./load-balancer-analyzer.py" ]; then
        if [ -f "./load-balancer-analyzer.py" ]; then
            python3 ./load-balancer-analyzer.py --all
        else
            python3 /usr/local/bin/load-balancer-analyzer.py --all
        fi
    else
        print_warning "Load balancer analyzer not available"
        print_status "Manual analysis:"
        
        # Check Nginx status
        if docker ps | grep -q nginx-lb; then
            print_status "Nginx load balancer status:"
            docker exec nginx-lb nginx -t
        fi
        
        # Check HAProxy status
        if docker ps | grep -q haproxy-lb; then
            print_status "HAProxy load balancer status:"
            docker exec haproxy-lb haproxy -c -f /usr/local/etc/haproxy/haproxy.cfg
        fi
        
        # Check web server status
        print_status "Web server status:"
        docker ps | grep web-server
    fi
}

# Cleanup function
cleanup_lab() {
    print_header "Cleaning Up Lab Environment"
    
    if [ "$USE_DOCKER" = true ]; then
        print_status "Stopping and removing containers..."
        
        # Stop and remove containers
        docker stop nginx-lb haproxy-lb web-server-1 web-server-2 web-server-3 2>/dev/null || true
        docker rm nginx-lb haproxy-lb web-server-1 web-server-2 web-server-3 2>/dev/null || true
        
        print_status "Containers removed"
    fi
    
    # Remove lab directory
    if [ -d "$LAB_DIR" ]; then
        rm -rf "$LAB_DIR"
        print_status "Lab directory removed"
    fi
    
    print_status "Cleanup complete"
}

# Main menu
show_menu() {
    echo
    print_header "Load Balancing Lab Menu"
    echo "1. Setup Lab Environment"
    echo "2. Exercise 1: Basic Round Robin Load Balancing"
    echo "3. Exercise 2: Weighted Load Balancing"
    echo "4. Exercise 3: Health Checks and Failover"
    echo "5. Exercise 4: Session Persistence"
    echo "6. Exercise 5: HAProxy Load Balancing"
    echo "7. Exercise 6: Performance Testing"
    echo "8. Exercise 7: Load Balancer Analysis"
    echo "9. Run All Exercises"
    echo "10. Cleanup Lab Environment"
    echo "0. Exit"
    echo
}

# Main function
main() {
    print_header "Load Balancing Lab Exercises"
    print_status "Welcome to the Load Balancing Lab!"
    print_status "This lab will teach you load balancing concepts through hands-on exercises."
    
    # Check if running in container
    if check_container; then
        print_status "Running in container environment"
    else
        print_warning "Not running in container - some exercises may not work properly"
    fi
    
    while true; do
        show_menu
        read -p "Select an option (0-10): " choice
        
        case $choice in
            1)
                setup_lab_environment
                ;;
            2)
                exercise_1_round_robin
                ;;
            3)
                exercise_2_weighted
                ;;
            4)
                exercise_3_health_checks
                ;;
            5)
                exercise_4_session_persistence
                ;;
            6)
                exercise_5_haproxy
                ;;
            7)
                exercise_6_performance
                ;;
            8)
                exercise_7_analysis
                ;;
            9)
                setup_lab_environment
                exercise_1_round_robin
                exercise_2_weighted
                exercise_3_health_checks
                exercise_4_session_persistence
                exercise_5_haproxy
                exercise_6_performance
                exercise_7_analysis
                ;;
            10)
                cleanup_lab
                ;;
            0)
                print_status "Exiting Load Balancing Lab"
                exit 0
                ;;
            *)
                print_error "Invalid option. Please select 0-10."
                ;;
        esac
        
        echo
        read -p "Press Enter to continue..."
    done
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

