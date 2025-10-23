# Ansible Role: NGINX

## Description

Installs, configures, and hardens NGINX web server with security best practices. Implements NGINX-specific hardening controls including security headers, rate limiting, and access controls.

## Purpose

- Install NGINX from official repositories
- Configure secure NGINX settings
- Implement security headers (HSTS, CSP, X-Frame-Options, etc.)
- Hide version information
- Configure rate limiting
- Set up virtual hosts
- Enable monitoring endpoints

## Requirements

- RHEL/CentOS/Rocky 8.x or 9.x
- Internet connectivity for package installation
- Root or sudo access
- Minimum 1GB RAM, 5GB free disk space

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `nginx_version` | `1.20` | NGINX version to install |
| `nginx_user` | `nginx` | NGINX process user |
| `nginx_worker_processes` | `auto` | Number of worker processes |
| `nginx_worker_connections` | `1024` | Max connections per worker |
| `nginx_hide_version` | `true` | Hide NGINX version |
| `ssl_enabled` | `true` | Enable SSL/TLS |
| `rate_limiting_enabled` | `false` | Enable rate limiting |

## Security Features

### Headers Implemented
- X-Frame-Options: DENY/SAMEORIGIN
- X-Content-Type-Options: nosniff
- X-XSS-Protection: 1; mode=block
- Referrer-Policy: strict-origin-when-cross-origin
- Content-Security-Policy: Configurable
- Strict-Transport-Security: HSTS with preload

### Hardening Controls
- Version information hiding
- Secure default cipher suites
- Request rate limiting
- Client body size limits
- Timeout configurations
- Access logging

## Dependencies

None (standalone role)

## Example Playbook

hosts: webservers
roles:

role: nginx
vars:
nginx_worker_connections: 2048
nginx_hide_version: true
rate_limiting_enabled: true

text

## Tags

- `nginx` - Run all NGINX tasks
- `nginx_install` - Installation only
- `nginx_configure` - Configuration only
- `nginx_harden` - Hardening only

## Directory Structure

/etc/nginx/
├── nginx.conf # Main configuration
├── conf.d/ # Additional configs
│ ├── security.conf # Security headers
│ └── vhost.conf # Virtual hosts
├── ssl/ # SSL certificates
└── sites-available/ # Available sites

text

## Testing

Test NGINX configuration:
nginx -t

text

Reload NGINX:
systemctl reload nginx

text

## Security Notes

⚠️ **Important:**
- Always test configuration changes before applying
- Use SSL/TLS in production
- Implement rate limiting for public-facing servers
- Review security headers for your use case
- Monitor access and error logs

## References

- NGINX Security: https://nginx.org/en/docs/http/ngx_http_core_module.html
- OWASP Headers: https://owasp.org/www-project-secure-headers/

## Author

DevOps Automation Team

## License

Proprietary

################################################################################
# END OF FILE: roles/nginx/README.md
################################################################################