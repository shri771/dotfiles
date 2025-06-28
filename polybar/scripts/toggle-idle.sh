#!/usr/bin/env bash
PIDFILE="$HOME/.idle_inhibitor.pid"

if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" &>/dev/null; then
  kill "$(cat "$PIDFILE")" && rm -f "$PIDFILE"
else
  systemd-inhibit --what=idle --who="$USER" --why="Prevent idle" sleep infinity &
  echo $! > "$PIDFILE"
fi

# fire hook index 0 for module “idle”
polybar-msg hook idle 0 >/dev/null
