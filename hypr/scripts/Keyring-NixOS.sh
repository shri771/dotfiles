#!/bin/bash
# GNOME Keyring startup for NixOS/Hyprland

# Find gnome-keyring-daemon in the Nix store
keyring_daemon=$(find /nix/store -name 'gnome-keyring-daemon' -type f -executable 2>/dev/null | head -n 1)

if [ -n "$keyring_daemon" ]; then
    # Kill any existing instances
    pkill -f gnome-keyring-daemon 2>/dev/null
    sleep 0.5

    # Start daemon and export environment variables
    eval $("$keyring_daemon" --start --components=secrets,ssh,pkcs11)

    # Update systemd and dbus environments
    systemctl --user import-environment GNOME_KEYRING_CONTROL SSH_AUTH_SOCK
    dbus-update-activation-environment --systemd GNOME_KEYRING_CONTROL SSH_AUTH_SOCK WAYLAND_DISPLAY XDG_CURRENT_DESKTOP 2>/dev/null

    echo "GNOME Keyring started: $GNOME_KEYRING_CONTROL"
else
    echo "ERROR: GNOME Keyring daemon not found"
fi
