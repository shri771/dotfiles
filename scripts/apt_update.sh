#!/bin/bash

# Script to update and upgrade the system using apt
# Ensure this script is run with sudo privileges

echo "Updating package lists..."
sudo apt update

echo "Upgrading installed packages..."
sudo apt -y upgrade

echo "Cleaning up unused packages and cache..."
sudo apt -y autoremove
sudo apt -y clean

echo "APT System Update Completed Successfully!"
