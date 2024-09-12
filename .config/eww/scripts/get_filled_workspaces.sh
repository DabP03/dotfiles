#!/usr/bin/bash

input_data=$(hyprctl workspaces)

# Extract workspace IDs using grep and awk
workspace_ids=$(echo "$input_data" | grep -oP 'workspace ID \K\d+')

# Convert to JSON array format
json_array=$(echo "$workspace_ids" | awk '{printf "%s", (NR==1 ? "" : " ") $0}' | sed 's/^/ /; s/$/ /')

echo "$json_array"
