#!/usr/bin/env bash

directory=~/.wallpapers

while true; do
    if [ -d "$directory" ]; then
        random_background="$directory/$(ls $directory | shuf -n 1)"

        swww img "$random_background" --transition-type center

        # hyprctl hyprpaper unload all
        # hyprctl hyprpaper preload $random_background
        # hyprctl hyprpaper wallpaper ", $random_background"
    fi
    sleep 1800
done

