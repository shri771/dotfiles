#!/bin/bash
# Screenshots scripts with notification actions

# variables
time=$(date "+%d-%b_%H-%M-%S")
dir="$(xdg-user-dir)/Pictures/Screenshots"
file="Screenshot_${time}_${RANDOM}.png"

iDIR="$HOME/.config/swaync/icons"
sDIR="$HOME/.config/hypr/scripts"

# Notification config
notify_cmd="notify-send -t 3000 -i ${iDIR}/picture.png -h string:x-canonical-private-synchronous:shot-notify"
sound_script="$sDIR/Sounds.sh"

# --- Functions ---
copy_to_clipboard() {
    if [[ -e "$1" ]]; then
        wl-copy -t image/png < "$1"
        notify-send -t 2000 -i "$iDIR/clipboard.png" "Copied to Clipboard"
        return 0
    else
        notify-send -u critical -i "$iDIR/error.png" "Error" "File not found!"
        return 1
    fi
}

open_in_swappy() {
    if [[ -e "$1" ]]; then
        swappy -f "$1" & disown
    else
        notify-send -u critical -i "$iDIR/error.png" "Error" "File not found!"
        return 1
    fi
}

delete_file() {
    if [[ -e "$1" ]]; then
        rm "$1" && \
        notify-send -t 1000 -i "$iDIR/trash.png" "🗑️ Deleted" "   Screenshot removed"
    else
        notify-send -u critical -i "$iDIR/error.png" "Error" "File not found!"
        return 1
    fi
}

# Notification with actions
notify_view() {
    local filepath="$1"
    local message="$2"
    
    if [[ -e "$filepath" ]]; then
        # Play success sound
        [[ -f $sound_script ]] && "$sound_script" --screenshot

        action=$($notify_cmd "Screenshot Saved" "$message" \
            --action="EDIT=✏️ Edit" \
            --action="DELETE=🗑️ Delete")

        case "$action" in
            "COPY") copy_to_clipboard "$filepath" ;;
            "EDIT") open_in_swappy "$filepath" ;;
            "DELETE") delete_file "$filepath" ;;
        esac
    else
        notify-send -u critical -i "$iDIR/error.png" "Error" "Screenshot failed!"
        [[ -f $sound_script ]] && "$sound_script" --error
    fi
}

# --- Screenshot Functions ---
shotnow() {
    cd ${dir} && grim - | tee "$file" | wl-copy -t image/png
    sleep 1
    notify_view "${dir}/$file" "Screenshot captured"
}

shotarea() {
    tmpfile=$(mktemp)
    grim -g "$(slurp)" - > "$tmpfile"

    if [[ -s "$tmpfile" ]]; then
        wl-copy -t image/png < "$tmpfile"
        mv "$tmpfile" "$dir/$file"
        notify_view "${dir}/$file" "Area capture saved"
    else
        notify-send -u critical -i "$iDIR/error.png" "Screenshot cancelled"
        [[ -f $sound_script ]] && "$sound_script" --error
    fi
}

shotwin() {
    w_pos=$(hyprctl activewindow | grep 'at:' | cut -d':' -f2 | tr -d ' ' | tail -n1)
    w_size=$(hyprctl activewindow | grep 'size:' | cut -d':' -f2 | tr -d ' ' | tail -n1 | sed s/,/x/g)
    cd ${dir} && grim -g "$w_pos $w_size" - | tee "$file" | wl-copy -t image/png
    notify_view "${dir}/$file" "Window capture saved"
}

shotactive() {
    active_window_class=$(hyprctl -j activewindow | jq -r '(.class)')
    active_window_file="Screenshot_${time}_${active_window_class}.png"
    active_window_path="${dir}/${active_window_file}"

    hyprctl -j activewindow | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | grim -g - "$active_window_path"
    wl-copy -t image/png < "$active_window_path"
    notify_view "$active_window_path" "Active window captured"
}

# --- Main ---
mkdir -p "$dir"

case "$1" in
    "--now") shotnow ;;
    "--win") shotwin ;;
    "--area") shotarea ;;
    "--active") shotactive ;;
    *)
        echo "Available options:"
        echo "--now    : Capture immediately"
        echo "--win    : Capture active window"
        echo "--area   : Capture selected area"
        echo "--active : Capture active window (class-specific)"
        exit 1
        ;;
esac

exit 0
