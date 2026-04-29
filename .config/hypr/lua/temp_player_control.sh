#!/usr/bin/env bash

if ! command -v playerctl &> /dev/null; then
    echo "Error: playerctl is not installed."
    exit 1
fi

player_command=""

case "$#" in
    0)
        player_command="play-pause"
        ;;
    1)
        case "$1" in
            "play-pause")
                player_command="play-pause"
                ;;
            "next")
                player_command="next"
                ;;
            "previous")
                player_command="previous"
                ;;
            "stop")
                player_command="stop"
                ;;
            *)
                echo "Error: Unknown command '$1'. Use: play-pause, next, previous, stop" >&2
                exit 1
                ;;
        esac
        ;;
    2)
        if [[ "$1" = "volume" ]]; then
            if [[ "$2" =~ ^([0-9]*\.?[0-9]+%?|[0-9]+%)(\+|-)?$ ]]; then
                player_command="volume $2"
            else
                echo "Error: Invalid volume value '$2'. Examples: 0.5, +0.1, -10%, 80%" >&2
                exit 1
            fi
        else
            echo "Error: Unknown subcommand '$1'. Only 'volume' takes 3 arguments." >&2
            exit 1
        fi
        ;;
    *)
        echo "Usage: $(basename "$0") [command]" >&2
        echo "Commands:" >&2
        echo "   (no args)      → toggle play/pause" >&2
        echo "   play-pause     → toggle play/pause" >&2
        echo "   next           → next track" >&2
        echo "   previous       → previous track" >&2
        echo "   stop           → stop playback" >&2
        echo "   volume <val>   → set or adjust volume (e.g. 0.8, +0.1, -5%)" >&2
        exit 1
        ;;
esac

ignored_players="$(playerctl -l 2>/dev/null | grep -v -i -E 'spotify|tidal' | paste -sd ',' -)"

bash -c "playerctl --ignore-player=\"$ignored_players\" $player_command"
