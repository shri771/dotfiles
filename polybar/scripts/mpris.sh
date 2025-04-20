#!/bin/sh

# Define icons for known players
get_player_icon() {
    case "$1" in
        chromium) echo "   " ;;
        firefox) echo " " ;;
        kdeconnect) echo "   " ;;
        mpv) echo "  " ;;
        spotify) echo "   " ;;
        vlc) echo " 󰕼  " ;;
        *) echo " 󰗃  " ;;  # default icon
    esac
}

# Define icons for playback status
get_status_icon() {
    case "$1" in
        Playing) echo "" ;;
        Paused) echo "󰐎" ;;
        Stopped) echo "" ;;
        *) echo "" ;;
    esac
}

# Set color variables (adjust as desired)
color_playing="#ba5663"  # green for playing
color_paused="#ba5663"  # orange for paused
color_stopped="#ba5663"  # red for stopped

# Find an active player that is currently playing
active_player=""
for p in $(playerctl -l 2>/dev/null); do
    if [ "$(playerctl --player="$p" status 2>/dev/null)" = "Playing" ]; then
        active_player="$p"
        break
    fi
done

# Fallback: use first available player if none is active
if [ -z "$active_player" ]; then
    active_player=$(playerctl -l 2>/dev/null | head -n 1)
fi

status=$(playerctl --player="$active_player" status 2>/dev/null)

# Output only the colored icon
if [ "$status" = "Playing" ]; then
    icon=$(get_player_icon "$active_player")
    echo "%{F${color_playing}}${icon}%{F-}"
elif [ "$status" = "Paused" ]; then
    icon=$(get_status_icon "$status")
    echo "%{F${color_paused}}${icon}%{F-}"
elif [ "$status" = "Stopped" ]; then
    icon=$(get_status_icon "$status")
    echo "%{F${color_stopped}}${icon}%{F-}"
else
    echo ""
fi
