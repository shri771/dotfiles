#!/bin/bash

# A script to configure UFW based on a specific ruleset.
# WARNING: This will reset your firewall and delete all existing rules.

echo "--- Configuring Firewall (UFW) ---"

# Reset UFW to a clean state to avoid rule conflicts
echo "Resetting UFW to default..."
sudo ufw --force reset

# 1. Set default policies
echo "Setting default policies..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw default deny routed

# 2. Add specific rules
# --- SSH Access ---
# Note: 'ufw limit ssh' is generally sufficient. The 'allow 22' rule is
# redundant but included to perfectly match your output.
echo "Adding SSH rules..."
sudo ufw limit ssh
sudo ufw allow 22

# --- Web Server Traffic ---
echo "Adding Web Server rules..."
sudo ufw allow 80   # HTTP
sudo ufw allow 443  # HTTPS

# --- KDE Connect ---
echo "Adding KDE Connect rules..."
sudo ufw allow 1714:1764/udp
sudo ufw allow 1714:1764/tcp

# --- Quick Share ---
echo "Adding Quick Share rules..."
sudo ufw allow 5353/udp
sudo ufw allow 6060/tcp
sudo ufw allow 44446/tcp
sudo ufw allow 45455/tcp

# 3. Enable Logging
echo "Enabling logging..."
sudo ufw logging on

# 4. Enable the firewall
echo "Enabling UFW..."
sudo ufw enable

echo "--- Firewall configuration complete! ---"
sudo ufw status verbose
