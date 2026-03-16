#!/usr/bin/env bash

# Create a dedicated directory for incoming files
TAILDROP_DIR="$HOME/Downloads/Taildrop"
mkdir -p "$TAILDROP_DIR"

# Run the tailscale loop
tailscale file get --loop --verbose "$TAILDROP_DIR" | while read -r line; do
# Match the 'wrote filename as /path/to/file' pattern
    if [[ "$line" =~ wrote\ ([^ ]+)\ as\ ([^ ]+) ]]; then
        filename="${BASH_REMATCH[1]}"
        filepath="${BASH_REMATCH[2]}"

        # Case-insensitive image check (jpg, jpeg, png, gif, webp, svg)
        if [[ "$filename" =~ \.([jJ][pP][gG]|[jJ][pP][eE][gG]|[pP][nN][gG]|[gG][iI][fF]|[wW][eE][bB][pP]|[sS][vV][gG])$ ]]; then
            notify-send "Tailscale Drop" "Received $filename" \
                -a "Tailscale" \
                -u normal \
                --hint=string:image-path:"$filepath"
        else
            notify-send "Tailscale Drop" "Received $filename" \
                -a "Tailscale" \
                -u normal
        fi
    fi
done
