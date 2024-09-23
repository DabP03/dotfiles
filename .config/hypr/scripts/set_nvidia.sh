#!/usr/bin/env bash

if lspci -nnk | egrep -i --color 'vga|3d|2d' -A3 | grep 'in use' | grep -c 'nvidia'; then
    hyprctl keyword env LIBVA_DRIVER_NAME,nvidia
    hyprctl keyword env GBM_BACKEND,nvidia-drm
    hyprctl keyword env __GLX_VENDOR_LIBRARY_NAME,nvidia
fi
