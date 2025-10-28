#!/bin/bash

# Start the GNOME Keyring daemon and export its environment variables
eval $(gnome-keyring-daemon --start)
export SSH_AUTH_SOCK
export GPG_AGENT_INFO
export PKCS11_MODULES

# Launch Hyprland
exec Hyprland
