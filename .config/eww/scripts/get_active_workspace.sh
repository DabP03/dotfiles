#!/bin/bash
echo "$(hyprctl activeworkspace | grep -oP 'workspace ID \K\d+')"

