#!/bin/bash

# Get the active monitor's info in JSON format
active_monitor_json=$(hyprctl monitors -j | jq '.[] | select(.focused == true)')

# Check if there's an active special workspace on this monitor
special_workspace_name=$(echo "$active_monitor_json" | jq -r '.specialWorkspace.name // empty')

# If a special workspace is found and it's active, toggle it
if [[ -n "$special_workspace_name" && "$special_workspace_name" == special:* ]]; then
    workspace_to_toggle=$(echo "$special_workspace_name" | sed 's/^special://')
    hyprctl dispatch togglespecialworkspace "$workspace_to_toggle"
fi