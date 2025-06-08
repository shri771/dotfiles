#!/usr/bin/env bash

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
  --ringcolor=ffffff00 \      # transparent ring
  --ringvercolor=bbff0044 \   # subtle verification color
  --insidevercolor=00000000 \ # fully transparent inside
  --insidecolor=00000000 \    # fully transparent inside
  --ringw=5 \                 # ring width
  --indpos="x+0:x+0" \        # dead‑center indicator
  --separatorcolor=00000000 \ # no separator
  --timecolor=ffffffff \      # time text color (white)
  --datecolor=ffffffff \      # date text color (white)
  --timestr="%I:%M %p" \      # e.g., 07:32 PM
  --datestr="%A, %B %d" \     # e.g., Thursday, June 05
  --veriftext="verifying..." \
  --wrongtext="nah, try again" \
  --clock \
  --indicator \
  --keyhlcolor=ff0000ff \     # key highlight (semi‑red)
  --bshlcolor=ff0000ff \      # backspace highlight (semi‑red)
  --fadein 0.2                # subtle fade‑in
