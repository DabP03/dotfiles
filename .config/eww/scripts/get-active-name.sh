#!/usr/bin/bash 
echo "$(hyprctl activewindow -j | jq -r ".initialTitle")"
