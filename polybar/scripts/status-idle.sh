#!/usr/bin/env bash
PIDFILE="$HOME/.idle_inhibitor.pid"

if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" &>/dev/null; then
  echo "%{F#FF5555}⚡"
else
  echo "%{F#50FA7B}⚡"
fi
