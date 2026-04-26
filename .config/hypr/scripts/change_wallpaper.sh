#!/usr/bin/env bash

if [ $# -eq 1 ]; then
    time="$1"
else
    time=1800
fi

while true; do
    waypaper --random 
    sleep "$time"
done

