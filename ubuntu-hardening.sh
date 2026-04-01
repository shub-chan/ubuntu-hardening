#!/bin/bash

# Exit on error
set -e

echo "🔒 Starting Ubuntu Hardening..."

# -----------------------------
# 1. Update system
# -----------------------------
echo "📦 Updating system..."
sudo apt update && sudo apt upgrade -y

# -----------------------------
# 2. Install UFW (Firewall)
# -----------------------------
echo "🔥 Installing UFW..."
sudo apt install ufw -y

# Reset UFW rules
sudo ufw --force reset

# Default rules
sudo ufw default deny incoming
sudo ufw default allow outgoing

# -----------------------------
# 3. Allow essential ports (EDIT THESE)
# -----------------------------
# Allow SSH (comment this if you want SSH disabled)
sudo ufw allow 22/tcp

# Example: allow HTTP/HTTPS (uncomment if needed)
# sudo ufw allow 80/tcp
# sudo ufw allow 443/tcp

# -----------------------------
# 4. Enable Firewall
# -----------------------------
echo "🚀 Enabling firewall..."
sudo ufw --force enable

# -----------------------------
# 5. Disable SSH (OPTIONAL)
# -----------------------------
read -p "❓ Do you want to disable SSH? (y/n): " disable_ssh

if [[ "$disable_ssh" == "y" ]]; then
    echo "🛑 Disabling SSH..."
    sudo systemctl stop ssh
    sudo systemctl disable ssh
    sudo ufw delete allow 22/tcp || true
fi

# -----------------------------
# 6. Remove unnecessary services
# -----------------------------
echo "🧹 Removing unnecessary services..."
sudo apt purge -y telnet ftp rsh-server || true

# -----------------------------
# 7. Enable Fail2Ban (protect brute force)
# -----------------------------
echo "🛡 Installing Fail2Ban..."
sudo apt install fail2ban -y
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# -----------------------------
# 8. Disable root login via SSH
# -----------------------------
if [ -f /etc/ssh/sshd_config ]; then
    echo "🚫 Disabling root SSH login..."
    sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
    sudo systemctl restart ssh || true
fi

# -----------------------------
# 9. Check open ports
# -----------------------------
echo "🔍 Open ports:"
sudo ss -tuln

echo "✅ Hardening complete!"