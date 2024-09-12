#!/usr/bin/bash

prev_brightness=$(brightnessctl g)
max_brightness=$(brightnessctl m)
echo $(jq -n "$prev_brightness / $max_brightness * 100" | jq 'round')

while true; do
    current_brightness=$(brightnessctl g)

    if [ "$current_brightness" -ne "$prev_brightness" ]; then
        echo $(jq -n "$current_brightness / $max_brightness * 100" | jq 'round')
        prev_brightness=$current_brightness
    fi

    sleep 0.25
done

