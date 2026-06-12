#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Scripts for refreshing ags, waybar, rofi, swaync, wallust

SCRIPTSDIR=$HOME/.config/hypr/scripts
UserScripts=$HOME/.config/hypr/UserScripts

# Define file_exists function
file_exists() {
    if [ -e "$1" ]; then
        return 0 # File exists
    else
        return 1 # File does not exist
    fi
}

# Kill already running processes
_ps=(waybar rofi)
for _prs in "${_ps[@]}"; do
    if pidof "${_prs}" >/dev/null; then
        pkill "${_prs}"
    fi
done

killall -SIGUSR2 waybar 2>/dev/null # added since wallust sometimes not applying

# # quit ags
# ags -q
#
# # relaunch ags
# ags &

# Kill waybar yet again # added since wallust sometimes not applying
_ps2=(waybar)
for _prs2 in "${_ps2[@]}"; do
    if pidof "${_prs2}" >/dev/null; then
        killall "${_prs2}"
    fi
done

# Restart systemd-managed swaync
sleep 0.5
systemctl --user restart swaync.service >/dev/null 2>&1 || true

# Restart UWSM-managed waybar
sleep 1
uwsm app -- waybar >/dev/null 2>&1 &

# Relaunching rainbow borders if the script exists
sleep 1
if file_exists "${UserScripts}/RainbowBorders.sh"; then
    ${UserScripts}/RainbowBorders.sh &
fi

exit 0
