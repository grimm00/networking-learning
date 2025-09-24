#!/usr/bin/env python3
"""
Certificate Manager Tool
Generate, validate, and manage SSL/TLS certificates
"""

import subprocess
import os
import json
import argparse
from datetime import datetime, timedelta
from typing import Dict, List, Any, Optional
import tempfile


class CertificateManager:
    def __init__(self, output_dir: str = "certs"):
        self.output_dir = output_dir
        os.makedirs(output_dir, exist_ok=True)

    def generate_private_key(self, key_size: int = 2048, key_file: str = None) -> str:
        """Generate RSA private key"""
        if key_file is None:
            key_file = os.path.join(self.output_dir, "private.key")
        
        print(f"🔑 Generating {key_size}-bit RSA private key...")
        
        cmd = ['openssl', 'genrsa', '-out', key_file, str(key_size)]
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            print(f"  ✅ Private key generated: {key_file}")
            return key_file
        else:
            print(f"  ❌ Failed to generate private key: {result.stderr}")
            raise Exception(f"OpenSSL error: {result.stderr}")

    def generate_csr(self, key_file: str, csr_file: str = None, 
                    subject: Dict[str, str] = None, san_list: List[str] = None) -> str:
        """Generate Certificate Signing Request"""
        if csr_file is None:
            csr_file = os.path.join(self.output_dir, "request.csr")
        
        print(f"📝 Generating Certificate Signing Request...")
        
        # Create config file for CSR
        config_content = self._create_csr_config(subject, san_list)
        
        with tempfile.NamedTemporaryFile(mode='w', suffix='.conf', delete=False) as config_file:
            config_file.write(config_content)
            config_path = config_file.name
        
        try:
            cmd = ['openssl', 'req', '-new', '-key', key_file, '-out', csr_file, 
                   '-config', config_path]
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode == 0:
                print(f"  ✅ CSR generated: {csr_file}")
                return csr_file
            else:
                print(f"  ❌ Failed to generate CSR: {result.stderr}")
                raise Exception(f"OpenSSL error: {result.stderr}")
        finally:
            os.unlink(config_path)

    def _create_csr_config(self, subject: Dict[str, str], san_list: List[str]) -> str:
        """Create OpenSSL config file for CSR"""
        config = "[req]\n"
        config += "distinguished_name = req_distinguished_name\n"
        config += "req_extensions = v3_req\n"
        config += "prompt = no\n\n"
        
        config += "[req_distinguished_name]\n"
        if subject:
            for key, value in subject.items():
                config += f"{key} = {value}\n"
        else:
            config += "C = US\n"
            config += "ST = State\n"
            config += "L = City\n"
            config += "O = Organization\n"
            config += "OU = Organizational Unit\n"
            config += "CN = example.com\n"
        
        if san_list:
            config += "\n[v3_req]\n"
            config += "keyUsage = keyEncipherment, dataEncipherment\n"
            config += "extendedKeyUsage = serverAuth\n"
            config += "subjectAltName = @alt_names\n\n"
            config += "[alt_names]\n"
            for i, san in enumerate(san_list, 1):
                config += f"DNS.{i} = {san}\n"
        
        return config

    def generate_self_signed_cert(self, key_file: str, cert_file: str = None,
                                 subject: Dict[str, str] = None, days: int = 365) -> str:
        """Generate self-signed certificate"""
        if cert_file is None:
            cert_file = os.path.join(self.output_dir, "certificate.crt")
        
        print(f"📜 Generating self-signed certificate (valid for {days} days)...")
        
        # Create subject string
        if subject:
            subject_str = "/".join([f"{k}={v}" for k, v in subject.items()])
        else:
            subject_str = "/C=US/ST=State/L=City/O=Organization/OU=Unit/CN=example.com"
        
        cmd = ['openssl', 'req', '-x509', '-newkey', 'rsa:2048', '-keyout', key_file,
               '-out', cert_file, '-days', str(days), '-nodes', '-subj', subject_str]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            print(f"  ✅ Self-signed certificate generated: {cert_file}")
            return cert_file
        else:
            print(f"  ❌ Failed to generate certificate: {result.stderr}")
            raise Exception(f"OpenSSL error: {result.stderr}")

    def sign_certificate(self, ca_key: str, ca_cert: str, csr_file: str, 
                        cert_file: str = None, days: int = 365) -> str:
        """Sign certificate with CA"""
        if cert_file is None:
            cert_file = os.path.join(self.output_dir, "signed.crt")
        
        print(f"✍️  Signing certificate with CA (valid for {days} days)...")
        
        cmd = ['openssl', 'x509', '-req', '-in', csr_file, '-CA', ca_cert,
               '-CAkey', ca_key, '-out', cert_file, '-days', str(days), '-CAcreateserial']
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            print(f"  ✅ Certificate signed: {cert_file}")
            return cert_file
        else:
            print(f"  ❌ Failed to sign certificate: {result.stderr}")
            raise Exception(f"OpenSSL error: {result.stderr}")

    def analyze_certificate(self, cert_file: str) -> Dict[str, Any]:
        """Analyze certificate details"""
        print(f"🔍 Analyzing certificate: {cert_file}")
        
        # Get certificate text
        cmd = ['openssl', 'x509', '-in', cert_file, '-text', '-noout']
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode != 0:
            print(f"  ❌ Failed to analyze certificate: {result.stderr}")
            return {'error': result.stderr}
        
        cert_text = result.stdout
        
        # Parse certificate information
        cert_info = {
            'file': cert_file,
            'subject': self._extract_field(cert_text, 'Subject:'),
            'issuer': self._extract_field(cert_text, 'Issuer:'),
            'validity': self._extract_validity(cert_text),
            'serial_number': self._extract_field(cert_text, 'Serial Number:'),
            'signature_algorithm': self._extract_field(cert_text, 'Signature Algorithm:'),
            'public_key': self._extract_public_key_info(cert_text),
            'extensions': self._extract_extensions(cert_text)
        }
        
        print(f"  ✅ Certificate analyzed successfully")
        return cert_info

    def _extract_field(self, text: str, field_name: str) -> str:
        """Extract field value from certificate text"""
        lines = text.split('\n')
        for line in lines:
            if field_name in line:
                return line.split(field_name, 1)[1].strip()
        return 'Not found'

    def _extract_validity(self, text: str) -> Dict[str, Any]:
        """Extract validity information"""
        validity = {}
        
        not_before = self._extract_field(text, 'Not Before:')
        not_after = self._extract_field(text, 'Not After:')
        
        validity['not_before'] = not_before
        validity['not_after'] = not_after
        
        if not_before != 'Not found' and not_after != 'Not found':
            try:
                # Parse dates (format: "Dec 31 23:59:59 2024 GMT")
                before_date = datetime.strptime(not_before, '%b %d %H:%M:%S %Y %Z')
                after_date = datetime.strptime(not_after, '%b %d %H:%M:%S %Y %Z')
                now = datetime.now()
                
                validity['is_valid'] = before_date <= now <= after_date
                validity['is_expired'] = now > after_date
                validity['days_until_expiry'] = (after_date - now).days
                validity['total_validity_days'] = (after_date - before_date).days
                
            except Exception as e:
                validity['parse_error'] = str(e)
        
        return validity

    def _extract_public_key_info(self, text: str) -> Dict[str, Any]:
        """Extract public key information"""
        key_info = {}
        
        # Extract key type
        key_type = self._extract_field(text, 'Public Key Algorithm:')
        key_info['algorithm'] = key_type
        
        # Extract key size
        key_size_line = None
        lines = text.split('\n')
        for i, line in enumerate(lines):
            if 'Public-Key:' in line:
                key_size_line = line
                break
        
        if key_size_line:
            key_size_match = key_size_line.split('Public-Key:')[1].strip()
            key_info['size'] = key_size_match
        
        return key_info

    def _extract_extensions(self, text: str) -> Dict[str, Any]:
        """Extract certificate extensions"""
        extensions = {}
        
        # Extract Subject Alternative Names
        san_lines = []
        in_san_section = False
        lines = text.split('\n')
        
        for line in lines:
            if 'Subject Alternative Name:' in line:
                in_san_section = True
                continue
            elif in_san_section:
                if line.strip() and not line.startswith(' '):
                    break
                if 'DNS:' in line or 'IP:' in line:
                    san_lines.append(line.strip())
        
        if san_lines:
            extensions['subject_alternative_names'] = san_lines
        
        # Extract Key Usage
        key_usage = self._extract_field(text, 'Key Usage:')
        if key_usage != 'Not found':
            extensions['key_usage'] = key_usage
        
        # Extract Extended Key Usage
        ext_key_usage = self._extract_field(text, 'Extended Key Usage:')
        if ext_key_usage != 'Not found':
            extensions['extended_key_usage'] = ext_key_usage
        
        return extensions

    def verify_certificate_chain(self, cert_file: str, ca_file: str = None) -> Dict[str, Any]:
        """Verify certificate against CA"""
        print(f"🔍 Verifying certificate chain...")
        
        if ca_file:
            cmd = ['openssl', 'verify', '-CAfile', ca_file, cert_file]
        else:
            cmd = ['openssl', 'verify', cert_file]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        verification_result = {
            'certificate': cert_file,
            'ca_file': ca_file,
            'success': result.returncode == 0,
            'output': result.stdout,
            'error': result.stderr if result.returncode != 0 else None
        }
        
        if result.returncode == 0:
            print(f"  ✅ Certificate verification successful")
        else:
            print(f"  ❌ Certificate verification failed: {result.stderr}")
        
        return verification_result

    def create_ca(self, ca_key_file: str = None, ca_cert_file: str = None,
                  subject: Dict[str, str] = None, days: int = 3650) -> tuple:
        """Create Certificate Authority"""
        if ca_key_file is None:
            ca_key_file = os.path.join(self.output_dir, "ca.key")
        if ca_cert_file is None:
            ca_cert_file = os.path.join(self.output_dir, "ca.crt")
        
        print(f"🏛️  Creating Certificate Authority...")
        
        # Generate CA private key
        self.generate_private_key(4096, ca_key_file)
        
        # Generate CA certificate
        if subject is None:
            subject = {
                'C': 'US',
                'ST': 'State',
                'L': 'City',
                'O': 'Certificate Authority',
                'OU': 'CA Unit',
                'CN': 'Root CA'
            }
        
        subject_str = "/".join([f"{k}={v}" for k, v in subject.items()])
        
        cmd = ['openssl', 'req', '-x509', '-newkey', 'rsa:4096', '-keyout', ca_key_file,
               '-out', ca_cert_file, '-days', str(days), '-nodes', '-subj', subject_str]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            print(f"  ✅ CA created: {ca_cert_file}")
            return ca_key_file, ca_cert_file
        else:
            print(f"  ❌ Failed to create CA: {result.stderr}")
            raise Exception(f"OpenSSL error: {result.stderr}")

    def save_certificate_info(self, cert_info: Dict[str, Any], filename: str = None) -> str:
        """Save certificate information to JSON file"""
        if filename is None:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"cert_info_{timestamp}.json"
        
        if not filename.endswith('.json'):
            filename += '.json'
        
        filepath = os.path.join(self.output_dir, filename)
        
        with open(filepath, 'w') as f:
            json.dump(cert_info, f, indent=2)
        
        print(f"📄 Certificate info saved to: {filepath}")
        return filepath


def main():
    parser = argparse.ArgumentParser(description='Certificate Manager Tool')
    parser.add_argument('action', choices=['create-ca', 'generate-key', 'generate-csr', 
                                          'sign-cert', 'analyze', 'verify'],
                       help='Action to perform')
    parser.add_argument('--key-file', help='Private key file')
    parser.add_argument('--cert-file', help='Certificate file')
    parser.add_argument('--csr-file', help='Certificate Signing Request file')
    parser.add_argument('--ca-key', help='CA private key file')
    parser.add_argument('--ca-cert', help='CA certificate file')
    parser.add_argument('--output-dir', '-d', default='certs', help='Output directory')
    parser.add_argument('--days', type=int, default=365, help='Certificate validity days')
    parser.add_argument('--key-size', type=int, default=2048, help='Key size in bits')
    parser.add_argument('--subject', help='Certificate subject (format: C=US,ST=State,L=City,O=Org,CN=example.com)')
    parser.add_argument('--san', nargs='+', help='Subject Alternative Names')
    
    args = parser.parse_args()
    
    manager = CertificateManager(args.output_dir)
    
    try:
        if args.action == 'create-ca':
            ca_key, ca_cert = manager.create_ca(args.ca_key, args.ca_cert, days=args.days)
            print(f"✅ CA created: {ca_key}, {ca_cert}")
            
        elif args.action == 'generate-key':
            key_file = manager.generate_private_key(args.key_size, args.key_file)
            print(f"✅ Private key generated: {key_file}")
            
        elif args.action == 'generate-csr':
            if not args.key_file:
                print("❌ --key-file is required for CSR generation")
                return
            
            subject = None
            if args.subject:
                subject = dict(item.split('=') for item in args.subject.split(','))
            
            csr_file = manager.generate_csr(args.key_file, args.csr_file, subject, args.san)
            print(f"✅ CSR generated: {csr_file}")
            
        elif args.action == 'sign-cert':
            if not all([args.ca_key, args.ca_cert, args.csr_file]):
                print("❌ --ca-key, --ca-cert, and --csr-file are required for signing")
                return
            
            cert_file = manager.sign_certificate(args.ca_key, args.ca_cert, args.csr_file, 
                                                args.cert_file, args.days)
            print(f"✅ Certificate signed: {cert_file}")
            
        elif args.action == 'analyze':
            if not args.cert_file:
                print("❌ --cert-file is required for analysis")
                return
            
            cert_info = manager.analyze_certificate(args.cert_file)
            manager.save_certificate_info(cert_info)
            
        elif args.action == 'verify':
            if not args.cert_file:
                print("❌ --cert-file is required for verification")
                return
            
            result = manager.verify_certificate_chain(args.cert_file, args.ca_cert)
            print(f"Verification result: {result['success']}")
            
    except Exception as e:
        print(f"❌ Error: {e}")


if __name__ == "__main__":
    main()
