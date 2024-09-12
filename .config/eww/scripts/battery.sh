#!/bin/sh

bat=/sys/class/power_supply/BAT0/
per="$(cat "$bat/capacity")"

icon() {

[ $(cat "$bat/status") = Charging ] && echo "" && exit

if [ "$per" -gt "75" ]; then
	icon=""
elif [ "$per" -gt "50" ]; then
	icon=""
elif [ "$per" -gt "25" ]; then
	icon=""
elif [ "$per" -gt "10" ]; then
	icon=""
elif [ "$per" -gt "0" ]; then
	icon=""
else
        echo  && exit
fi
echo "$icon"
}

percent() {
echo $per
}

[ "$1" = "icon" ] && icon && exit
[ "$1" = "percent" ] && percent && exit
exit
