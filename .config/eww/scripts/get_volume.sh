#!/usr/bin/bash


current_vol=$(pamixer --get-volume)

if [ $(pamixer --get-mute) = true ]; then
    icon=" "
elif [[ $current_vol -gt 50 ]]; then
    icon=" "
elif [[ $current_vol -gt 0 ]]; then
    icon=" "
else
    $icon=" "
fi

[ "$1" = "icon" ] && echo $icon && exit
[ "$1" = "percent" ] && echo $current_vol && exit
exit

