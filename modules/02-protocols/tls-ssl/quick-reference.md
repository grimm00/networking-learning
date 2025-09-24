# TLS/SSL Quick Reference

Quick reference guide for TLS/SSL protocols, certificates, and OpenSSL commands.

## 🔐 TLS Protocol Versions

| Version | Status | Security | Performance | Notes |
|---------|--------|----------|-------------|-------|
| SSL 2.0 | ❌ Deprecated | Vulnerable | - | Disabled by default |
| SSL 3.0 | ❌ Deprecated | Vulnerable | - | POODLE vulnerability |
| TLS 1.0 | ⚠️ Legacy | Weak | Good | Legacy support only |
| TLS 1.1 | ⚠️ Legacy | Weak | Good | Legacy support only |
| TLS 1.2 | ✅ Recommended | Strong | Good | Widely supported |
| TLS 1.3 | ✅ Modern | Strongest | Best | Latest standard |

## 📜 Certificate Types

### By Validation Level
- **DV (Domain Validated)**: Basic domain ownership verification
- **OV (Organization Validated)**: Organization identity verification  
- **EV (Extended Validated)**: Highest validation level with green address bar

### By Scope
- **Single Domain**: `example.com`
- **Wildcard**: `*.example.com` (covers subdomains)
- **Multi-Domain (SAN)**: Multiple domains in one certificate
- **Self-Signed**: For testing/internal use only

### By Authority
- **CA-Signed**: Signed by trusted Certificate Authority
- **Self-Signed**: Signed by own private key
- **Internal CA**: Signed by internal/private CA

## 🔧 OpenSSL Commands

### Certificate Generation
```bash
# Generate private key
openssl genrsa -out private.key 2048

# Generate CSR
openssl req -new -key private.key -out request.csr

# Generate self-signed certificate
openssl req -x509 -newkey rsa:2048 -keyout private.key -out cert.crt -days 365 -nodes

# Sign certificate with CA
openssl x509 -req -in request.csr -CA ca.crt -CAkey ca.key -out signed.crt -days 365
```

### Certificate Analysis
```bash
# View certificate details
openssl x509 -in cert.crt -text -noout

# Check validity dates
openssl x509 -in cert.crt -noout -dates

# View subject and issuer
openssl x509 -in cert.crt -noout -subject -issuer

# Verify certificate chain
openssl verify -CAfile ca.crt cert.crt

# Extract public key
openssl x509 -in cert.crt -pubkey -noout
```

### TLS Connection Testing
```bash
# Basic TLS connection test
openssl s_client -connect example.com:443

# Test with certificate verification
openssl s_client -connect example.com:443 -CAfile ca.crt

# Show certificate chain
openssl s_client -connect example.com:443 -showcerts

# Test specific TLS version
openssl s_client -connect example.com:443 -tls1_2

# Test with SNI (Server Name Indication)
openssl s_client -connect example.com:443 -servername example.com
```

## 🛡️ Cipher Suites

### Recommended Cipher Suites (TLS 1.2)
```
ECDHE-RSA-AES256-GCM-SHA384
ECDHE-RSA-AES128-GCM-SHA256
ECDHE-RSA-AES256-SHA384
ECDHE-RSA-AES128-SHA256
```

### Recommended Cipher Suites (TLS 1.3)
```
TLS_AES_256_GCM_SHA384
TLS_CHACHA20_POLY1305_SHA256
TLS_AES_128_GCM_SHA256
```

### Weak Cipher Suites (Avoid)
```
RC4-* (RC4 encryption)
DES-* (DES encryption)
MD5-* (MD5 hash)
EXPORT-* (Export-grade)
NULL-* (No encryption)
ANON-* (Anonymous)
```

## 🔍 Security Headers

### HTTP Strict Transport Security (HSTS)
```http
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
```

### Content Security Policy (CSP)
```http
Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline'
```

### Other Security Headers
```http
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
X-XSS-Protection: 1; mode=block
Referrer-Policy: strict-origin-when-cross-origin
```

## 🧪 Testing Tools

### Command Line Tools
```bash
# SSL Labs (online)
curl -s "https://api.ssllabs.com/api/v3/analyze?host=example.com"

# testssl.sh (comprehensive testing)
testssl.sh example.com

# nmap (cipher enumeration)
nmap --script ssl-enum-ciphers -p 443 example.com

# OpenSSL (connection testing)
openssl s_client -connect example.com:443
```

### Online Testing
- **SSL Labs**: https://www.ssllabs.com/ssltest/
- **SSL Shopper**: https://www.sslshopper.com/ssl-checker.html
- **Qualys SSL Test**: https://www.ssllabs.com/ssltest/

## ⚠️ Common Issues

### Certificate Problems
| Issue | Symptoms | Solution |
|-------|----------|----------|
| Expired Certificate | Browser warning, connection fails | Renew certificate |
| Wrong Domain | Certificate error, connection fails | Update certificate with correct domain |
| Self-Signed | Browser warning, "Not secure" | Use CA-signed certificate |
| Chain Incomplete | Certificate error | Include intermediate certificates |
| Weak Key | Security warning | Regenerate with stronger key (2048+ bits) |

### Configuration Problems
| Issue | Symptoms | Solution |
|-------|----------|----------|
| Weak Ciphers | Security warning | Disable weak cipher suites |
| Old TLS Version | Connection fails | Enable TLS 1.2+ |
| Missing HSTS | No security header | Add HSTS header |
| Mixed Content | Browser warning | Use HTTPS for all resources |

## 📊 Certificate Fields

### Subject Fields
- **C**: Country (e.g., US, GB)
- **ST**: State/Province
- **L**: Locality/City
- **O**: Organization
- **OU**: Organizational Unit
- **CN**: Common Name (domain)

### Key Usage Extensions
- **Digital Signature**: Signing data
- **Key Encipherment**: Encrypting keys
- **Data Encipherment**: Encrypting data
- **Key Agreement**: Key exchange
- **Certificate Sign**: Signing certificates (CA only)

### Extended Key Usage
- **Server Authentication**: TLS server certificates
- **Client Authentication**: TLS client certificates
- **Code Signing**: Software signing
- **Email Protection**: S/MIME certificates

## 🔄 Certificate Lifecycle

### 1. Planning
- Determine certificate requirements
- Choose validation level
- Select certificate authority

### 2. Generation
- Generate private key
- Create certificate signing request
- Submit to CA

### 3. Validation
- CA validates domain/organization
- Certificate issued
- Download certificate

### 4. Installation
- Install certificate on server
- Configure web server
- Test configuration

### 5. Monitoring
- Monitor expiration dates
- Set up renewal alerts
- Regular security testing

### 6. Renewal
- Generate new private key (optional)
- Create new CSR
- Renew with CA
- Install renewed certificate

## 📚 Best Practices

### Certificate Management
- Use strong private keys (2048+ bits)
- Implement certificate monitoring
- Set up automatic renewal
- Use certificate transparency logs
- Implement proper key rotation

### TLS Configuration
- Disable SSL 2.0/3.0 and TLS 1.0/1.1
- Use strong cipher suites only
- Implement HSTS
- Enable OCSP stapling
- Use perfect forward secrecy

### Security Monitoring
- Regular security testing
- Monitor certificate expiration
- Check for weak configurations
- Implement security headers
- Use certificate pinning (carefully)

---

**Quick Commands:**
- `tls-analyzer.py` - Comprehensive TLS analysis
- `cert-manager.py` - Certificate management
- `tls-troubleshoot.sh` - TLS diagnostics
- `tls-lab.sh` - Interactive learning lab
