#!/bin/bash

set -euo pipefail

get_playing_players() {
    local output playing_players=()
    output=$(playerctl -l 2>/dev/null) || return 1

    echo "$output" > /tmp/playerctl_players.log  # log all players seen

    while IFS= read -r player; do
        status=$(playerctl --player="$player" status 2>/dev/null) || continue
        [[ "$status" == "Playing" ]] && playing_players+=("$player")
    done <<< "$output"

    [[ ${#playing_players[@]} -gt 0 ]] && printf "%s\n" "${playing_players[@]}" || return 1
}

pause_other_players() {
    local primary_player="$1"
    local all_players paused=0

    all_players=$(playerctl -l 2>/dev/null) || return 1

    while IFS= read -r player; do
        [[ "$player" == "$primary_player" ]] && continue

        local status
        status=$(playerctl --player="$player" status 2>/dev/null) || continue
        [[ "$status" != "Playing" ]] && continue

        playerctl --player="$player" pause
        paused=1
    done <<< "$all_players"

    return 0
}

monitor_music_players() {
    local last_player=""

    while true; do
        local current_players
        if ! IFS=$'\n' read -d '' -r -a current_players < <(get_playing_players && printf '\0'); then
            sleep 0.5
            continue
        fi

        local primary_player="${current_players[0]}"

        if [[ -n "$primary_player" && "$primary_player" != "$last_player" ]]; then
            pause_other_players "$primary_player"
            last_player="$primary_player"
        fi

        sleep 0.5
    done
}

main() {
    if ! command -v playerctl &>/dev/null; then
        echo "playerctl is not installed." >&2
        exit 1
    fi

    monitor_music_players
}

main
