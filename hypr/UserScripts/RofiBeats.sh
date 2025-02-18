#!/bin/bash

# Directory local music base folder
BASE_DIR="$HOME/Downloads/Music"

# Directory for icons
ICON_DIR="$HOME/.config/swaync/icons"

# Online Stations. Edit as required
declare -A ONLINE_MUSIC=(
  ["Feel Good Song 💓"]="https://music.youtube.com/watch?v=0wNmT99M1Iw&list=PLOlHDApPp3YtOYIj_1S_NSBLavu9JsoNY"
  ["Cheerful Songs 🍻📻🎶"]="https://music.youtube.com/watch?v=1qz_5uzzo1s&list=PLOlHDApPp3YvM3Ov9rnFCrT5jha8DWVGu"
  ["Recap Songs 📻🎶"]="https://music.youtube.com/playlist?list=LRSRQ8GXxh9usDGmDwlEldwe_vlkFindDamD7&si=FttFEIxH9yFPgd4T"
)

# Function for displaying notifications
notification() {
  notify-send -u normal -i "$ICON_DIR/music.png" " Now Playing:" " $@"
}

# Function to select a folder
select_music_folder() {
  local folder_choice
  folder_choice=$(find "$BASE_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | \
    rofi -dmenu -i -config ~/.config/rofi/config-rofi-Beats.rasi -p "Select Music Folder" \
    -kb-move-up "Control+p" -kb-move-down "Control+n")

  [[ -z "$folder_choice" ]] && return 1
  echo "$BASE_DIR/$folder_choice"
}

# Function for playing local music (shuffle play selected folder)
play_local_music() {
  local selected_folder
  selected_folder=$(select_music_folder) || exit 1

  notification "Shuffle Play from: $(basename "$selected_folder")"

  mpv --shuffle --loop-playlist --vid=no "$selected_folder"
}

# Function for playing online music
play_online_music() {
  local choice
  choice=$(printf "%s\n" "${!ONLINE_MUSIC[@]}" | rofi -i -dmenu -config ~/.config/rofi/config-rofi-Beats.rasi -p "Online Music" \
    -kb-move-up "Control+p" -kb-move-down "Control+n")

  [[ -z "$choice" ]] && exit 1

  local link="${ONLINE_MUSIC[$choice]}"
  notification "$choice"
  mpv --shuffle "$link"
}

# Stop music if mpv is running, otherwise show menu
pkill mpv && notify-send -u low -i "$ICON_DIR/music.png" "Music stopped" || {
  if pidof rofi >/dev/null; then
    pkill rofi
  fi

  user_choice=$(printf "Play from Music Folder\nPlay from Online Stations" | \
    rofi -dmenu -config ~/.config/rofi/config-rofi-Beats-menu.rasi -p "Select Music Source" \
    -kb-move-up "Control+p" -kb-move-down "Control+n")

  case "$user_choice" in
    "Play from Music Folder")
      play_local_music
      ;;
    "Play from Online Stations")
      play_online_music
      ;;
    *)
      echo "Invalid choice"
      ;;
  esac
}
