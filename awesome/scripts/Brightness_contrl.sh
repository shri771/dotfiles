#!/bin/bash
# Brightness control for screen using brightnessctl + naughty notify

iDIR="$HOME/.config/swaync/icons"  # You can keep or change this path for icons

# Get screen brightness
get_brightness() {
    brightnessctl -d intel_backlight -m | cut -d, -f4
}

# Get icons
get_icon() {
    current=$(get_brightness | sed 's/%//')
    if   [ "$current" -le "20" ]; then
        icon="$iDIR/brightness-20.png"
    elif [ "$current" -le "40" ]; then
        icon="$iDIR/brightness-40.png"
    elif [ "$current" -le "60" ]; then
        icon="$iDIR/brightness-60.png"
    elif [ "$current" -le "80" ]; then
        icon="$iDIR/brightness-80.png"
    else
        icon="$iDIR/brightness-100.png"
    fi
}

# Show notification with naughty via dbus
# Show notification with naughty via dbus
notify_user() {
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
    dbus-send --session --dest=org.awesomewm.awful / \
        org.awesomewm.awful.Remote.Eval \
        string:"
        naughty.notify({
            title = 'Screen',
            text = 'Brightness: $current%',
            icon = '$icon',
            urgency = 'low'
        })"
}

# Change brightness
change_brightness() {
    brightnessctl -d intel_backlight set "$1" && get_icon && notify_user
}

# Execute based on argument
case "$1" in
    "--get")
        get_brightness
        ;;
    "--inc")
        change_brightness "+10%"
        ;;
    "--dec")
        change_brightness "10%-"
        ;;
    *)
        get_brightness
        ;;
esac
