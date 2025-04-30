#!/bin/bash

# Must be run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root using: sudo $0"
  exit 1
fi

LOG_FILE="security_hardening_$(date +%F_%T).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "[+] Starting Security Hardening - $(date)"

# 1. Disable root SSH login
echo "[*] Disabling SSH root login..."
SSHD_CONFIG="/etc/ssh/sshd_config"
if [ -f "$SSHD_CONFIG" ]; then
  sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' $SSHD_CONFIG
  sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' $SSHD_CONFIG
  systemctl restart ssh || systemctl restart sshd
  echo "[+] Root SSH login disabled."
else
  echo "[!] SSH config not found!"
fi

# 2. Fix world-writable files
echo "[*] Fixing world-writable files..."
find / -xdev -type f -perm -0002 -exec chmod o-w {} \; 2>/dev/null
echo "[+] World-writable files fixed."

# 3. Check and fix .ssh permissions
echo "[*] Checking .ssh directory permissions..."
for dir in $(find /home -type d -name ".ssh"); do
  chmod 700 "$dir"
  chown $(basename $(dirname "$dir")):$USER "$dir"
done
echo "[+] .ssh permissions checked."

# 4. Disable IPv6
echo "[*] Disabling IPv6..."
cat <<EOF >> /etc/sysctl.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
EOF
sysctl -p

# 5. Enable unattended updates
echo "[*] Installing unattended-upgrades..."
apt-get update && apt-get install -y unattended-upgrades
dpkg-reconfigure -f noninteractive unattended-upgrades

# 6. Set up firewall
echo "[*] Setting up UFW firewall..."
apt-get install -y ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow http
ufw --force enable

# 7. List suspicious SUID/SGID files
echo "[*] Listing SUID/SGID files..."
find / -xdev \( -perm -4000 -o -perm -2000 \) -type f 2>/dev/null

# 8. Check running services
echo "[*] Checking running services..."
ss -tulnp

# 9. Disable IP forwarding
echo "[*] Disabling IP forwarding..."
sysctl -w net.ipv4.ip_forward=0
sysctl -w net.ipv6.conf.all.forwarding=0

# 10. Lock system accounts
echo "[*] Locking system accounts..."
for user in $(awk -F: '($3 < 1000) {print $1}' /etc/passwd); do
  usermod -L $user
done
echo "[+] System accounts locked."

# 11. Install and run rkhunter (Rootkit check)
echo "[*] Installing rkhunter..."
apt-get install -y rkhunter
rkhunter --update
rkhunter --check --sk

# 12. Check for updates
echo "[*] Checking for updates..."
apt-get update && apt-get upgrade -y

echo "[+] Security Hardening Complete."
echo "Log saved to: $LOG_FILE"

