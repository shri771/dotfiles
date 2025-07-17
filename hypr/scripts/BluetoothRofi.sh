#!/usr/bin/env bash
# ~/.config/hypr/rofi-bluetooth.sh

# rofi wrapper to drop Fontconfig noise
rofi_menu() {
  echo -e "$1" | rofi -dmenu -p Bluetooth 2>/dev/null
}

# list “MAC Name” for any bluetoothctl command
list_devices() {
  bluetoothctl "$1" 2>/dev/null | \
    grep -E '^Device ([0-9A-F:]{17}) ' | \
    awk '{ print $2 " " substr($0, index($0,$3)) }'
}

# top level
main=$(rofi_menu "Connect\nDisconnect")
[ -z "$main" ] && exit

case "$main" in
  Connect)
    # quick 4 s scan
    bluetoothctl scan on & sleep 4 && bluetoothctl scan off

    paired=$(list_devices paired-devices)
    all_dev=$(list_devices devices)
    unpaired=$(comm -23 \
      <(printf "%s\n" "$all_dev" | sort) \
      <(printf "%s\n" "$paired"  | sort) )

    pick=$(rofi_menu "$paired\n$unpaired")
    [[ -n "$pick" ]] && bluetoothctl connect "${pick%% *}"
    ;;

  Disconnect)
    # build array of currently connected from *all* devices
    connected=()
    while IFS= read -r line; do
      mac=${line%% *}
      # limit info lookup to 0.5 s so it’s snappy
      if timeout 0.1 bluetoothctl info "$mac" 2>/dev/null \
           | grep -q "Connected: yes"; then
        connected+=("$line")
      fi
    done < <(list_devices devices)

    if (( ${#connected[@]} == 0 )); then
      rofi_menu "No devices connected."
      exit
    fi

    pick=$(printf "%s\n" "${connected[@]}" | rofi -dmenu -p Bluetooth 2>/dev/null)
    [[ -n "$pick" ]] && bluetoothctl disconnect "${pick%% *}"
    ;;
esac
