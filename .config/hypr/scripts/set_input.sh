#!/usr/bin/env bash

if hyprctl devices | grep -q "synaptics"; then
    hyprctl keyword input:sensitivity 0
    hyprctl keyword input:accel_profile "adaptive"
else
    hyprctl keyword input:sensitivity -0.4
    hyprctl keyword input:accel_profile "flat"
fi
