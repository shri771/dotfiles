#!/usr/bin/env bash

### —— CONFIG —— ###
# Path to the user’s Xauthority and display
XAUTHORITY="/home/sh/.Xauthority"
DISPLAY=":0"
# Ensure ACPI’s root shell can find everything
export DISPLAY XAUTHORITY PATH=/usr/local/bin:/usr/bin:/bin
# Figure out the GUI user from that Xauthority file
USER="$(stat -c '%U' "$XAUTHORITY")"
### ———————— ###

sleep 0.5

# allow root to talk to your X session
xhost +SI:localuser:root >/dev/null 2>&1

# run the lockscreen as your user (inherits DISPLAY & XAUTHORITY)
sudo -u "$USER" betterlockscreen -l

# revoke that temporary root access
xhost -SI:localuser:root >/dev/null 2>&1

# finally, suspend
systemctl suspend
