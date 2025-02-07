#!/bin/bash

# Define the paths to the Day and Night wallpaper folders
DAY_WALLPAPER_DIR="/home/shri/Pictures/wallpaper/Day"
NIGHT_WALLPAPER_DIR="/home/shri/Pictures/wallpaper/Night"

# Get the current hour
HOUR=$(date +%H)

# Check if it's between 7 AM and 6 PM
if [ "$HOUR" -ge 7 ] && [ "$HOUR" -lt 18 ]; then
  # Daytime: Set Day folder and remove Night folder from Variety
  variety --set "$DAY_WALLPAPER_DIR"
  variety --remove "$NIGHT_WALLPAPER_DIR"
  echo "Switched to Day wallpapers."
else
  # Nighttime: Set Night folder and remove Day folder from Variety
  variety --set "$NIGHT_WALLPAPER_DIR"
  variety --remove "$DAY_WALLPAPER_DIR"
  echo "Switched to Night wallpapers."
fi
