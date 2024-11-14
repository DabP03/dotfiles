#!/usr/bin/env bash

directory=~/.wallpapers

if [ $# -eq 1 ]; then
    time="$1"
else
    time=1800
fi

while true; do
    if [ -d "$directory" ]; then
        random_background="$directory/$(ls $directory | shuf -n 1)"

        swww img "$random_background" --transition-type wipe --transition-angle 45
        cp "$random_background" ~/.config/background
    fi
    sleep "$time"
done

