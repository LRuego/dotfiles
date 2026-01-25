#!/bin/bash

# A script to take a screenshot of a selected window using grim, slurp, and satty.

# Get window geometries, adjust for borders/shadows, and let user select one with slurp.
# -d: display dimensions
# -c: border color (red)
# -b: background color (transparent)
GEOMETRY=$(hyprctl clients -j | jq -r '.[] | select(.workspace.id == '$(hyprctl activeworkspace -j | jq -r '.id')') | "\((.at[0]-2)),\((.at[1]-2)) \((.size[0]+4))x\((.size[1]+4))"' | slurp -d -c "ff0000ff" -b "00000000")

# If no geometry was captured (e.g., user pressed Esc in slurp), exit.
if [ -z "$GEOMETRY" ]; then
    exit 0
fi

# Take the screenshot using the selected geometry, output as PNG, and pipe to satty.
grim -g "$GEOMETRY" -t png - | satty --filename - --fullscreen --output-filename ~/Pictures/Screenshots/$(date '+%Y%m%d-%H:%M:%S').png
