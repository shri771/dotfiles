#!/usr/bin/env bash
# ~/.local/bin/focus-urgent.sh

# CONFIG: rate‑limit params
MAX_EVENTS=5
WINDOW=60  # seconds

# sliding window of recent event timestamps
declare -a ts=()

# figure out your instance’s socket path
SIG=${HYPRLAND_INSTANCE_SIGNATURE:-$(hyprctl getoption instance 2>/dev/null | awk '{print $2}')}
SOCK="/tmp/hypr/$SIG/.socket2.sock"

# connect to the continuous socket2 stream
socat -U "UNIX-CONNECT:$SOCK" - \
  | while IFS= read -r line; do
      # only act on “urgent” events
      if [[ "$line" != *urgent* ]]; then
        continue
      fi

      now=$(date +%s)
      ts+=("$now")

      # prune old timestamps
      cutoff=$((now - WINDOW))
      filtered=()
      for t in "${ts[@]}"; do
        (( t >= cutoff )) && filtered+=("$t")
      done
      ts=("${filtered[@]}")

      # rate‑limit check
      if (( ${#ts[@]} <= MAX_EVENTS )); then
        hyprctl dispatch focusurgentorlast
      else
        >&2 echo "[focus-urgent] 🔥 rate limit hit (${#ts[@]} in ${WINDOW}s); skipping"
      fi
    done
