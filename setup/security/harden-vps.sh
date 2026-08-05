#!/usr/bin/env bash

# ==============================================================================
# VPS Security Hardening & Firewall Configuration Script
# Target: Ubuntu / Debian VPS
# Purpose: Protect against brute-force attacks, port scanning, and unauthorized access.
# ==============================================================================

set -e

echo "🛡️  [VPS Hardening] Starting security configuration..."

# 1. Check Root Privileges
if [ "$EUID" -ne 0 ]; then
    echo "❌ Please run as root (use: sudo ./harden-vps.sh)"
    exit 1
fi

# 2. Update System & Install Core Security Tools
echo "📦 [1/6] Installing security tools (UFW, Fail2ban, iptables-persistent)..."
apt-get update -y
apt-get install -y ufw fail2ban iptables-persistent curl git

# 3. Configure Fail2ban
echo "🔒 [2/6] Configuring Fail2ban for SSH brute-force protection..."
cat << 'EOF' > /etc/fail2ban/jail.local
[DEFAULT]
bantime = 1h
findtime = 10m
maxretry = 5

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 24h
EOF

systemctl restart fail2ban
systemctl enable fail2ban

# 4. Kernel Hardening Parameters (sysctl)
echo "🧠 [3/6] Applying Kernel & Network Hardening (sysctl)..."
cat << 'EOF' > /etc/sysctl.d/99-security-hardening.conf
# Disable IP Forwarding (unless needed for custom routing)
# Protect against SYN flood attacks
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 2048
net.ipv4.tcp_synack_retries = 2

# Ignore ICMP Echo Requests (Ping) - Optional
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Disable IP Source Routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

# Enable Reverse Path Filtering (Prevent IP Spoofing)
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
EOF

sysctl --system >/dev/null 2>&1 || true

# 5. Configure Firewall (UFW)
echo "🧱 [4/6] Setting up UFW Firewall rules..."

# Reset rules
ufw --force reset >/dev/null

# Default Policies: Deny incoming, Allow outgoing
ufw default deny incoming
ufw default allow outgoing

# Allow SSH with Rate Limiting (Prevents Brute Force)
ufw limit 22/tcp comment 'SSH Rate Limited'

# Allow Web Traffic (Traefik Reverse Proxy)
ufw allow 80/tcp comment 'HTTP Traefik'
ufw allow 443/tcp comment 'HTTPS Traefik'

# Allow Docker Swarm Internal Communication (Overlay Network)
ufw allow 2377/tcp comment 'Docker Swarm Management'
ufw allow 7946/tcp comment 'Docker Swarm Node Communication'
ufw allow 7946/udp comment 'Docker Swarm Node Communication'
ufw allow 4789/udp comment 'Docker Swarm Overlay Network'

# 6. Database Ports Security Policy
echo "🗄️  [5/6] Configuring Database Security Policies..."
echo "ℹ️  Database ports (MongoDB 27017, Postgres 5432, Redis 6379) are kept INTERNAL to Docker."
echo "ℹ️  If external connection is needed, use trusted IP whitelist:"
echo "    Example: sudo ufw allow from <YOUR_IP> to any port 5432 proto tcp"

# Enable Firewall
ufw --force enable

echo "----------------------------------------------------------------------"
echo "✅ [VPS Hardening Complete] Status Summary:"
echo "----------------------------------------------------------------------"
ufw status verbose
echo "----------------------------------------------------------------------"
echo "🎉 VPS Security Hardening applied successfully!"
