#!/usr/bin/env bash
# mount.sh — interactive mount/unmount of removable devices for Yazi.
# Replicates ranger's `ranger_udisk_menu` plugin using udisks2 + fzf.
set -euo pipefail

# Columns: NAME SIZE FSTYPE LABEL MOUNTPOINT TYPE
choice=$(
	lsblk -rno NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT,TYPE |
		awk '$6 == "part" || $6 == "rom"' |
		fzf --prompt="mount/umount > " --height=40% --reverse
) || exit 0

[ -z "${choice:-}" ] && exit 0

name=$(printf '%s\n' "$choice" | awk '{print $1}')
mountpoint=$(printf '%s\n' "$choice" | awk '{print $5}')
dev="/dev/${name}"

if [ -n "$mountpoint" ]; then
	echo "Unmounting $dev ($mountpoint) ..."
	udisksctl unmount -b "$dev"
else
	echo "Mounting $dev ..."
	udisksctl mount -b "$dev"
fi

read -rp "Press <Enter> to return to Yazi..." _
