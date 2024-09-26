#!/usr/bin/env bash

CONFIG="$HOME/.config/wofi/config/config"
STYLE="$HOME/.config/wofi/src/frappe/style.scss"

if [[ ! $(pidof wofi) ]]; then
    wofi --conf "${CONFIG}" --style "${STYLE}"
else
    pkill wofi
fi
