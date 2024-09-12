#!/bin/bash

count=0

dbus-monitor --session "interface='org.kde.StatusNotifierWatcher'" |
while read -r signal; do
    if  echo $signal | grep -q "StatusNotifierItemRegistered"; then
      count=$(($count + 1))
    elif echo $signal | grep -q "StatusNotifierItemUnregistered"; then
      count=$(($count - 1))
    fi

    echo $count
done
