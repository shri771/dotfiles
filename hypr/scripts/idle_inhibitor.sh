#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Idle Inhibitor Timer Script for Sway/Hyprland
# Uses wofi/rofi for menu selection and hyprctl/swaymsg for idle inhibition.
# Notifications follow SwayNC style with action buttons.

# 📂 Paths for SwayNC notifications
iDIR="$HOME/.config/swaync/icons"
iDoR="$HOME/.config/swaync/images"
sDIR="$HOME/.config/hypr/scripts"

# Detect whether using Hyprland or Sway
if command -v hyprctl &> /dev/null; then
    WM="hyprland"
    INHIBIT_ON="hyprctl dispatch dpms off"   # Turn off screen (Hyprland equivalent)
    INHIBIT_OFF="hyprctl dispatch dpms on"   # Turn screen back on
elif command -v swaymsg &> /dev/null; then
    WM="sway"
    INHIBIT_ON="swaymsg 'seat * idle_inhibit on'"
    INHIBIT_OFF="swaymsg 'seat * idle_inhibit off'"
else
    notify-send -u critical -i "${iDoR}/error.png" "Error" "Neither Sway nor Hyprland detected!"
    exit 1
fi

# Kill any existing menu instances to prevent duplicates
if pidof wofi > /dev/null; then
    pkill wofi
elif pidof rofi > /dev/null; then
    pkill rofi
fi

# 📌 Menu options
options="10 min\n15 min\n30 min\nCustom\nCancel"

# Show menu using wofi or rofi
if command -v wofi &> /dev/null; then
    choice=$(echo -e "$options" | wofi --dmenu --width=250 --height=200 --lines=5 --prompt "Idle Inhibitor Time")
elif command -v rofi &> /dev/null; then
    choice=$(echo -e "$options" | rofi -i -dmenu -p "Idle Inhibitor Time" -config ~/.config/rofi/config-clipboard.rasi)
else
    notify-send -u low -i "${iDoR}/error.png" "Error" "Neither wofi nor rofi found. Please install one."
    exit 1
fi

# Exit if "Cancel" was selected or nothing was entered
if [[ -z "$choice" || "$choice" == "Cancel" ]]; then
    exit 0
fi

# Handle custom time input
if [[ "$choice" == "Custom" ]]; then
    if command -v wofi &> /dev/null; then
        custom_time=$(wofi --dmenu --width=200 --height=100 --prompt "Enter minutes" | tr -d '[:alpha:]')
    elif command -v rofi &> /dev/null; then
        custom_time=$(rofi -dmenu -p "Enter minutes" -config ~/.config/rofi/config-clipboard.rasi | tr -d '[:alpha:]')
    fi

    # Validate custom input
    if [[ -z "$custom_time" || "$custom_time" -le 0 ]]; then
        notify-send -u low -i "${iDoR}/error.png" "Invalid Input" "Please enter a valid number."
        exit 1
    fi
    minutes=$custom_time
else
    minutes=$(echo "$choice" | awk '{print $1}')  # Extract number from selection
fi

# ✅ Activate idle inhibitor
eval "$INHIBIT_ON"

# 📢 Send notification with action buttons
notify_cmd_base="notify-send -t 5000 -A action1=Disable -A action2=Keep -h string:x-canonical-private-synchronous:idle-inhibitor"
notify_cmd_idle="${notify_cmd_base} -i ${iDIR}/lock.png"
notify_cmd_error="notify-send -u low -i ${iDoR}/error.png"

resp=$(timeout 5 ${notify_cmd_idle} "Idle Inhibitor Activated" "Will stay active for $minutes minutes.")

# 🎛 Handle notification action buttons
case "$resp" in
    action1)
        eval "$INHIBIT_OFF"
        notify-send -u low -i "${iDIR}/unlock.png" "Idle Inhibitor" "Disabled early."
        exit 0
        ;;
    action2)
        # Keep it enabled
        ;;
esac

# ⏳ Set a timer to disable idle inhibitor after the selected duration
(
    sleep $((minutes * 60))
    eval "$INHIBIT_OFF"
    notify-send -u low -i "${iDIR}/unlock.png" "Idle Inhibitor" "Automatically disabled after $minutes minutes."
) &

exit 0
