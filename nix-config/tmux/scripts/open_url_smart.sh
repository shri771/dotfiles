#!/bin/bash

URL="$1"

# Prepend https:// if no protocol is specified
if [[ "$URL" != http://* && "$URL" != https://* ]]; then
    URL="https://$URL"
fi

# Ensure DISPLAY and XAUTHORITY are correctly propagated for graphical applications
# These should be set by the tmux client-attached hook, but explicit export here
# ensures they are available in the sub-shell where vivaldi runs.
export DISPLAY=$(tmux show-env -g DISPLAY | cut -d= -f2)
export XAUTHORITY=$(tmux show-env -g XAUTHORITY | cut -d= -f2)

vivaldi --new-tab "$URL" & disown