# Ansible Role: SSL/TLS

## Description

Manages SSL/TLS certificates and encryption configuration for NGINX. Implements industry best practices for certificate management, cipher suite selection, and TLS protocol configuration.

## Purpose

- Generate self-signed certificates (dev/test)
- Deploy production certificates
- Configure strong cipher suites
- Enable TLS 1.2/1.3 only
- Configure OCSP stapling
- Generate DH parameters
- Implement HSTS

## Requirements

- RHEL/CentOS/Rocky 8.x or 9.x
- OpenSSL 1.1.1 or 3.0+
- NGINX installed
- Root or sudo access

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ssl_enabled` | `true` | Enable SSL/TLS |
| `ssl_protocols` | `TLSv1.2 TLSv1.3` | Allowed TLS protocols |
| `ssl_certificate_path` | `/etc/nginx/ssl/server.crt` | Certificate path |
| `ssl_certificate_key_path` | `/etc/nginx/ssl/server.key` | Private key path |
| `ssl_dhparam_bits` | `2048` | DH parameter size |
| `ssl_stapling` | `true` | Enable OCSP stapling |

## Security Features

### TLS Configuration
- TLS 1.2 and 1.3 only (TLS 1.0/1.1 disabled)
- Strong cipher suites (ECDHE, AES-GCM, ChaCha20)
- Perfect Forward Secrecy (PFS)
- OCSP stapling for certificate validation

### HSTS Implementation
- Strict-Transport-Security header
- includeSubDomains directive
- Preload support

## Dependencies

- nginx role (for web server configuration)

## Example Playbook

hosts: webservers
roles:

role: ssl_tls
vars:
ssl_dhparam_bits: 4096
ssl_stapling: true

text

## Tags

- `ssl_tls` - Run all SSL/TLS tasks
- `ssl_generate` - Certificate generation only
- `ssl_configure` - Configuration only
- `ssl_harden` - Hardening only

## Certificate Management

### Self-Signed (Dev/Test)
ansible-playbook playbooks/ssl_tls.yml --tags ssl_generate

text

### Production Certificates
Place certificates in:
- `/etc/nginx/ssl/server.crt`
- `/etc/nginx/ssl/server.key`

## Testing

Test SSL configuration:
openssl s_client -connect localhost:443 -tls1_2

text

Test cipher suites:
nmap --script ssl-enum-ciphers -p 443 hostname

text

## Security Notes

⚠️ **Important:**
- Use 4096-bit DH parameters for production
- Rotate certificates before expiration
- Monitor certificate expiry
- Use trusted CA certificates in production
- Never commit private keys to version control

## References

- Mozilla SSL Configuration: https://ssl-config.mozilla.org/
- OWASP TLS Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Transport_Layer_Protection_Cheat_Sheet.html

## Author

DevOps Automation Team

## License

Proprietary

################################################################################
# END OF FILE: roles/ssl_tls/README.md
################################################################################