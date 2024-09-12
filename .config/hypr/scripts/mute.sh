#!/usr/bin/bash
echo $( pamixer --get-mute )

if [ $(pamixer --get-mute) = true ]; then
    pamixer -u
else
    pamixer -m
fi
