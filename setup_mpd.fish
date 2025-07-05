#!/usr/bin/fish

# Stop and disable the system-wide MPD service
sudo systemctl stop mpd.socket; and sudo systemctl disable mpd.socket
sudo systemctl stop mpd.service; and sudo systemctl disable mpd.service

# Create directories for user service
mkdir -p ~/.config/mpd/playlists
mkdir -p ~/.config/systemd/user

# Move the service file
mv /home/sh/dotfiles/mpd.service ~/.config/systemd/user/

# Reload systemd and start the user service
systemctl --user daemon-reload
systemctl --user enable --now mpd.service

echo "MPD setup complete. Check status with: systemctl --user status mpd"
