# HTTP/HTTPS Protocol Analysis

Learn about web protocols through hands-on analysis and testing.

## What You'll Learn

- HTTP request/response cycle
- HTTP methods and status codes
- HTTPS encryption and certificates
- Headers and cookies
- Performance optimization

## Exercises

### Exercise 1: Basic HTTP Analysis

```bash
# Start the web server
docker-compose up -d web-server

# Test basic HTTP request
curl -v http://localhost:8080

# Analyze HTTP headers
curl -I http://localhost:8080

# Test different HTTP methods
curl -X GET http://localhost:8080
curl -X POST http://localhost:8080
curl -X PUT http://localhost:8080
curl -X DELETE http://localhost:8080
```

### Exercise 2: HTTPS Analysis

```bash
# Test HTTPS connection
curl -v https://localhost:8443

# Check SSL certificate
openssl s_client -connect localhost:8443 -servername localhost

# Test SSL/TLS versions
curl --tlsv1.2 -v https://localhost:8443
curl --tlsv1.3 -v https://localhost:8443
```

### Exercise 3: Headers and Cookies

```bash
# Send custom headers
curl -H "User-Agent: Learning-Tool" -H "Accept: application/json" http://localhost:8080

# Test cookie handling
curl -c cookies.txt http://localhost:8080
curl -b cookies.txt http://localhost:8080

# Analyze response headers
curl -D headers.txt http://localhost:8080
cat headers.txt
```

## HTTP Protocol Deep Dive

### Request Structure
```
GET /path HTTP/1.1
Host: example.com
User-Agent: Mozilla/5.0
Accept: text/html
Connection: keep-alive

[Request Body]
```

### Response Structure
```
HTTP/1.1 200 OK
Content-Type: text/html
Content-Length: 1234
Server: nginx/1.18.0

[Response Body]
```

### Common HTTP Methods
- **GET**: Retrieve data
- **POST**: Submit data
- **PUT**: Update data
- **DELETE**: Remove data
- **HEAD**: Get headers only
- **OPTIONS**: Get allowed methods

### Status Code Categories
- **1xx**: Informational
- **2xx**: Success
- **3xx**: Redirection
- **4xx**: Client Error
- **5xx**: Server Error

## HTTPS Security

### SSL/TLS Handshake
1. Client sends supported cipher suites
2. Server selects cipher suite and sends certificate
3. Client verifies certificate
4. Client generates session key
5. Both sides switch to encrypted communication

### Certificate Analysis
```bash
# Get certificate details
openssl x509 -in certificate.crt -text -noout

# Check certificate chain
openssl s_client -connect example.com:443 -showcerts

# Verify certificate
openssl verify certificate.crt
```

## Performance Analysis

### HTTP/2 Features
- Multiplexing
- Server push
- Header compression
- Binary protocol

### Testing Performance
```bash
# Test with HTTP/2
curl --http2 -v https://localhost:8443

# Measure response time
curl -w "@curl-format.txt" -o /dev/null -s http://localhost:8080

# Test concurrent requests
ab -n 100 -c 10 http://localhost:8080/
```

## Practical Examples

### Example 1: API Testing
```bash
# Test REST API endpoints
curl -X GET http://localhost:8080/api/users
curl -X POST -H "Content-Type: application/json" -d '{"name":"John"}' http://localhost:8080/api/users
curl -X PUT -H "Content-Type: application/json" -d '{"name":"Jane"}' http://localhost:8080/api/users/1
curl -X DELETE http://localhost:8080/api/users/1
```

### Example 2: Web Scraping
```bash
# Get page content
curl -s http://localhost:8080 | grep -i "title"

# Follow redirects
curl -L http://localhost:8080/redirect

# Save content
curl -o page.html http://localhost:8080
```

## Troubleshooting

### Common Issues
1. **Connection refused**: Check if server is running
2. **SSL errors**: Verify certificate configuration
3. **Timeout**: Check network connectivity
4. **403 Forbidden**: Check authentication and permissions

### Debugging Commands
```bash
# Verbose output
curl -v http://localhost:8080

# Show headers only
curl -I http://localhost:8080

# Test with different user agent
curl -H "User-Agent: Test" http://localhost:8080

# Check DNS resolution
nslookup localhost
```

## Lab Exercises

Run the included scripts for hands-on practice:

```bash
./http-analysis.sh        # Basic HTTP analysis
./https-analysis.sh       # HTTPS and SSL analysis
./performance-test.sh     # Performance testing
./security-test.sh        # Security testing
```

## Tools and Resources

### Command Line Tools
- `curl`: HTTP client
- `wget`: File downloader
- `openssl`: SSL/TLS tools
- `ab`: Apache Bench (load testing)

### Browser Tools
- Developer Tools (F12)
- Network tab
- Security tab
- Performance tab

### Online Tools
- SSL Labs SSL Test
- HTTP/2 Test
- WebPageTest
- GTmetrix
