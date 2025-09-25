# HTTP Methods Testing Guide

## 🚀 **Quick Start**

### **1. Basic Methods Test (All Methods)**
```bash
# Test all standard HTTP methods
docker exec net-practice python3 /scripts/http-methods-test.py http://nginx-basic:80
```

### **2. Specific Method Testing**
```bash
# Test only POST method
docker exec net-practice python3 /scripts/http-methods-test.py -m POST http://nginx-basic:80

# Test with custom data
docker exec net-practice python3 /scripts/http-methods-test.py -m POST -d '{"key":"value"}' http://nginx-basic:80

# Test with custom headers
docker exec net-practice python3 /scripts/http-methods-test.py -m POST -H "Content-Type:application/json" http://nginx-basic:80
```

## 🔧 **Available Methods**

| Method | Purpose | Typical Use Case |
|--------|---------|------------------|
| **GET** | Retrieve data | Reading web pages, API data |
| **POST** | Create/Submit data | Form submissions, API creation |
| **PUT** | Update/Replace data | Full resource updates |
| **PATCH** | Partial updates | Modifying specific fields |
| **DELETE** | Remove data | Deleting resources |
| **HEAD** | Get headers only | Checking if resource exists |
| **OPTIONS** | Get allowed methods | CORS preflight, API discovery |
| **TRACE** | Echo request | Debugging, diagnostics |

## 📝 **Command Examples**

### **GET with Query Parameters**
```bash
docker exec net-practice python3 /scripts/http-methods-test.py -m GET -p '{"page":1,"limit":10}' http://nginx-basic:80
```

### **POST with JSON Data**
```bash
docker exec net-practice python3 /scripts/http-methods-test.py -m POST -d '{"name":"John","email":"john@example.com"}' -H "Content-Type:application/json" http://nginx-basic:80
```

### **POST with Form Data**
```bash
docker exec net-practice python3 /scripts/http-methods-test.py -m POST -d '{"username":"test","password":"secret"}' http://nginx-basic:80
```

### **PUT with Custom Headers**
```bash
docker exec net-practice python3 /scripts/http-methods-test.py -m PUT -d '{"id":1,"status":"updated"}' -H "Content-Type:application/json" -H "Authorization:Bearer token123" http://nginx-basic:80
```

### **DELETE Request**
```bash
docker exec net-practice python3 /scripts/http-methods-test.py -m DELETE http://nginx-basic:80
```

## 🎯 **Using the Original HTTP Analyzer**

### **Test All Methods at Once**
```bash
docker exec net-practice python3 /scripts/http-analyzer.py -m http://nginx-basic:80
```

### **Test with Redirects**
```bash
docker exec net-practice python3 /scripts/http-analyzer.py -r http://nginx-basic:80
```

### **Performance Testing**
```bash
docker exec net-practice python3 /scripts/http-analyzer.py -p 10 http://nginx-basic:80
```

## 🔍 **Understanding Responses**

### **Status Codes**
- **200 OK**: Request successful
- **201 Created**: Resource created (POST)
- **204 No Content**: Success, no response body (DELETE)
- **400 Bad Request**: Invalid request data
- **401 Unauthorized**: Authentication required
- **403 Forbidden**: Access denied
- **404 Not Found**: Resource doesn't exist
- **405 Method Not Allowed**: Method not supported
- **500 Internal Server Error**: Server error

### **Common Headers**
- **Content-Type**: Response format (text/html, application/json)
- **Content-Length**: Response size in bytes
- **Server**: Web server software
- **Date**: Response timestamp
- **ETag**: Resource version identifier
- **Last-Modified**: Resource modification time

## 🛠️ **Troubleshooting**

### **Method Not Allowed (405)**
- Server doesn't support the method
- Check server configuration
- Try different endpoints

### **Connection Refused**
- Server not running
- Wrong port number
- Network connectivity issues

### **Timeout Errors**
- Increase timeout: `-t 30`
- Check server response time
- Verify network stability

## 📚 **Learning Exercises**

1. **Test a REST API**: Find an API that supports multiple methods
2. **Compare Methods**: Test same endpoint with different methods
3. **Header Analysis**: Compare responses with different headers
4. **Error Handling**: Test with invalid data to see error responses
5. **Performance**: Use `-p` flag to test response times

## 🔗 **Related Tools**

- **http-analyzer.py**: Comprehensive HTTP analysis
- **curl**: Command-line HTTP client
- **Postman**: GUI HTTP client
- **Wireshark**: Packet analysis
