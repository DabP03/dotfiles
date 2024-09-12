#!/bin/bash

# Get the type of active connection (wifi or ethernet)
CONNECTION_TYPE=$(nmcli -t -f TYPE,STATE dev)

if echo $CONNECTION_TYPE | grep -q "ethernet:connected"; then
    # For Ethernet connection
    DEVICE=$(nmcli -t -f DEVICE,TYPE,STATE dev | grep 'ethernet:connected' | cut -d':' -f1)
    CONNECTION_NAME=$(nmcli -t -f NAME,DEVICE con show --active | grep "$DEVICE" | cut -d':' -f1)

    if [[ $1 = "name" ]]; then
        echo "  $DEVICE"
    elif [[ $1 = "signal" ]]; then
        echo $CONNECTION_NAME
    fi
elif echo $CONNECTION_TYPE | grep -q "wifi:connected"; then
    # For Wi-Fi connection
    SSID=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2)
    SIGNAL=$(nmcli -t -f active,ssid,signal dev wifi | grep "^yes:$SSID" | cut -d':' -f3)

    if [[ $1 = "name" ]]; then
        echo "  $SSID"
    elif [[ $1 = "signal" ]]; then
        echo "$SIGNAL%"
    fi
else
    if [[ $1 = "name" ]]; then
        echo "none"
    elif [[ $1 = "signal" ]]; then
        echo "none"
    fi
    exit 1
fi
