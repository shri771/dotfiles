#!/usr/bin/env bash
# YouTube Music → MP3 only
# — folder named after playlist title, square cover-art, clean workspace

set -euo pipefail

# 1) Check for required commands
for cmd in yt-dlp ffmpeg find; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: '$cmd' is not installed." >&2
    exit 1
  fi
done

# 2) Ask for the YouTube Music URL
read -rp "Enter YouTube Music URL: " url
if [[ -z "$url" ]]; then
  echo "No URL provided, aborting." >&2
  exit 1
fi

# 3) Derive folder name from playlist title
playlist_title=$(yt-dlp --no-warnings --skip-download \
  --print "%(playlist_title)s" "$url" 2>/dev/null | head -n1)

# fallback if yt-dlp couldn't detect a playlist title
folder=${playlist_title:-Downloads}

# sanitize: replace any chars except letters, numbers, spaces, hyphens or underscores
folder=${folder//[^[:alnum:]\ \-_]/_}

outdir="$HOME/Downloads/Music/$folder"
mkdir -p "$outdir"

# 4) Download audio + raw thumbnail (no embed yet)
echo "→ Downloading audio + thumbnail into '$folder'…"
yt-dlp \
  -f bestaudio \
  --extract-audio --audio-format mp3 --audio-quality 0 \
  --write-thumbnail --no-embed-thumbnail --add-metadata \
  -o "${outdir}/%(title)s.%(ext)s" \
  "$url"

# 5) Process each MP3: center-crop & embed, then clean up images
echo "→ Processing and embedding cover art…"
shopt -s nullglob
for mp3 in "$outdir"/*.mp3; do
  base="${mp3%.mp3}"
  thumb=""
  for ext in webp jpg jpeg png; do
    [[ -f "${base}.${ext}" ]] && thumb="${base}.${ext}" && break
  done
  if [[ -z "$thumb" ]]; then
    echo "⚠️  No thumbnail for '$(basename "$mp3")', skipping."
    continue
  fi

  echo "   • Embedding cover into $(basename "$mp3")"
  proc="${base}.crop.jpg"

  # a) crop to exactly 800×800 (one frame)
  ffmpeg -y -i "$thumb" \
    -vf "scale=800:800:force_original_aspect_ratio=increase,crop=800:800" \
    -frames:v 1 -update 1 \
    "$proc"

  # b) embed as ID3v2.3 MJPEG cover into temp MP3
  tmp="${base}.tmp.mp3"
  ffmpeg -y \
    -i "$mp3" -i "$proc" \
    -map 0:a -map 1:v \
    -c:a copy -c:v mjpeg \
    -id3v2_version 3 \
    "$tmp"

  mv "$tmp" "$mp3"
done

# 6) Remove any non-MP3 files
find "$outdir" -type f ! -iname '*.mp3' -delete

echo "✅ Done! Your MP3s with square cover art are in: $outdir"
