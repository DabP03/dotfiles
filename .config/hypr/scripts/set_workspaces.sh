#!/usr/bin/env bash

if hyprctl monitors | grep -q "eDP-1"; then
    MAIN_MONITOR="eDP-1"
elif hyprctl monitors | grep -q "DP-1"; then
    MAIN_MONITOR="DP-1"
fi

if hyprctl monitors | grep -q "HDMI-A-2"; then
    SECONDARY_MONITOR="HDMI-A-2"
elif hyprctl monitors | grep -q "HDMI-A-1"; then
    SECONDARY_MONITOR="HDMI-A-1"
else
    SECONDARY_MONITOR=false
fi

hyprctl keyword workspace 1,$MAIN_MONITOR
hyprctl keyword workspace 2,$MAIN_MONITOR
hyprctl keyword workspace 3,$MAIN_MONITOR
hyprctl keyword workspace 4,$MAIN_MONITOR
hyprctl keyword workspace 5,$MAIN_MONITOR
hyprctl keyword workspace 6,$MAIN_MONITOR
hyprctl keyword workspace 7,$MAIN_MONITOR
hyprctl keyword workspace 8,$MAIN_MONITOR
hyprctl keyword workspace 9,$MAIN_MONITOR
hyprctl keyword workspace 10,$MAIN_MONITOR

if [[ $SECONDARY_MONITOR -ne false ]]; then
    hyprctl keyword workspace 11,$SECONDARY_MONITOR
    hyprctl keyword workspace 12,$SECONDARY_MONITOR
    hyprctl keyword workspace 13,$SECONDARY_MONITOR
    hyprctl keyword workspace 14,$SECONDARY_MONITOR
    hyprctl keyword workspace 15,$SECONDARY_MONITOR
    hyprctl keyword workspace 16,$SECONDARY_MONITOR
    hyprctl keyword workspace 17,$SECONDARY_MONITOR
    hyprctl keyword workspace 18,$SECONDARY_MONITOR
    hyprctl keyword workspace 19,$SECONDARY_MONITOR
    hyprctl keyword workspace 20,$SECONDARY_MONITOR
fi
