#!/usr/bin/env bash

# Exit if not in an X11 session
if [ "$XDG_SESSION_TYPE" != "x11" ]; then
    exit 0
fi


# ─── STEP 1: specify your wallpaper path ─────────────────────────────────────
# replace this with wherever your current wallpaper lives
WALLPAPER="$HOME/Pictures/wallpapers/sddm.png"

# ─── STEP 2 (optional): blur the wallpaper ──────────────────────────────────
# if you want a subtle blur, uncomment the 'convert' line; otherwise skip it
# this outputs a temp file /tmp/wall_blur.png
# mkdir -p /tmp && convert "$WALLPAPER" -filter Gaussian -blur 0x8 /tmp/wall_blur.png
# and then set BACK="$TMP_BLUR"
# TMP_BLUR="/tmp/wall_blur.png"

# if you don’t want blur, just lock with the raw wallpaper:
BACK="$WALLPAPER"

# ─── STEP 3: call i3lock-color with your custom style ────────────────────────
i3lock \
  --image="$BACK" \
  --ringcolor=ffffff00 \
  --ringvercolor=bbff0044 \
  --insidevercolor=00000000 \
  --insidecolor=00000000 \
  --ringw=5 \
  --indpos="x+0:x+0" \
  --separatorcolor=00000000 \
  --timecolor=ffffffff \
  --datecolor=ffffffff \
  --timestr="%I:%M %p" \
  --datestr="%A, %B %d" \
  --veriftext="verifying..." \
  --wrongtext="nah, try again" \
  --clock \
  --indicator \
  --keyhlcolor=ff0000ff \
  --bshlcolor=ff0000ff \
  --fadein 0.2 \
