# Linux Server Security Audit & Hardening Toolkit

![Security Shield](https://img.shields.io/badge/Security-Level_3-orange) 
![Bash Version](https://img.shields.io/badge/Bash-4.2%2B-blue)

## Table of Contents
1. [Overview](#overview)
2. [Features](#features)
3. [Installation](#installation)
4. [Usage](#usage)
5. [Configuration](#configuration)
6. [Security Measures](#security-measures)
7. [Troubleshooting](#troubleshooting)
8. [License](#license)

## Overview
A complete Bash-based solution for automating security audits and hardening of Linux servers. Designed for sysadmins to:
- Identify vulnerabilities
- Implement CIS benchmark recommendations
- Maintain compliance across server fleets

## Features

### Security Audits
| Check Category       | Implemented Checks                          |
|----------------------|--------------------------------------------|
| User/Groups          | UID 0 users, passwordless accounts, sudoers|
| File Permissions     | World-writable files, .ssh dirs, SUID/SGID|
| Services            | Unauthorized services, open ports          |
| Network            | Public/private IPs, IP forwarding          |
| Logs               | Failed SSH attempts, brute force attacks    |

### Hardening Measures
```text
1. SSH Hardening
   - Key-based auth only
   - Root login disabled
   - Strong crypto settings

2. Network Security
   - IPv6 disable (configurable)
   - iptables/UFW rulesets
   - Port knocking support

3. System Protections
   - GRUB password
   - Kernel parameter hardening
   - System account locking

```

## Installation

### Requirements
```bash
# Tested On
- Ubuntu 18.04+
- Debian 10+
- CentOS/RHEL 7+
- Bash 4.2+
- Root privileges
```

### Setup
```bash
wget https://example.com/secure_server.sh -O /usr/local/bin/secure_server
chmod 750 /usr/local/bin/secure_server
mkdir -p /etc/server_security/{config,custom_checks}
```

## Usage
bash ``` chmod u+x secure_server.sh ```

## Run

bash ``` sudo ./secure_server.sh ```

### Options
| Flag          | Description                              |
|---------------|------------------------------------------|
| `-c FILE`     | Custom config file                       |
| `--skip-ipv6` | Skip IPv6 disable                        |
| `--email`     | Send report to admin@example.com         |

## Configuration

### Main Config (/etc/server_security/config/main.conf)
```ini
[ssh]
DISABLE_ROOT_LOGIN=true
REQUIRE_KEY_AUTH=true

[network]
DISABLE_IPV6=false
ALLOWED_PORTS=22,80,443,9090

[updates]
AUTO_SECURITY_UPDATES=true
AUTO_REBOOT=false
```


## Security Measures

### Implemented Hardening
1. **SSH Security**
   ```bash
   # Before: PermitRootLogin yes
   # After:  PermitRootLogin prohibit-password
   ```

2. **IPv6 Control**
   ```bash
   net.ipv6.conf.all.disable_ipv6 = 1
   net.ipv6.conf.default.disable_ipv6 = 1
   ```

3. **Bootloader Protection**
   ```bash
   grub2-mkpasswd-pbkdf2 | tee /etc/grub.d/00_password
   ```

## Troubleshooting

### Common Issues
| Error                          | Solution                                |
|--------------------------------|-----------------------------------------|
| "Requires root privileges"     | Run with `sudo`                         |
| IPv6 disable fails             | Check for NetworkManager conflicts      |
| SSH restart fails              | Check syntax in `/etc/ssh/sshd_config`  |



## License
MIT

---
*This project complies with CIS Benchmark Level 2 hardening standards*
```

