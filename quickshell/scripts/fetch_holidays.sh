#!/usr/bin/env bash
# scripts/fetch_holidays.sh
# Fetches and parses holiday ICS file, outputs YYYY-MM-DD|Holiday Name per line

URL="$1"
CACHE_FILE="$2"
CACHE_DIR="$(dirname "$CACHE_FILE")"

mkdir -p "$CACHE_DIR"

# Refetch if file doesn't exist or is older than 7 days
if [ ! -f "$CACHE_FILE" ] || [ $(find "$CACHE_FILE" -mtime +7 | wc -l) -gt 0 ]; then
    curl -s -o "$CACHE_FILE" "$URL"
    if [ $? -ne 0 ]; then
        echo "FAILED"
        exit 1
    fi
    echo "FETCHED" >&2
else
    echo "CACHED" >&2
fi

# Parse VEVENT blocks — all years
awk '
    /^BEGIN:VEVENT/ { in_event=1; dtstart=""; summary="" }
    /^END:VEVENT/ {
        if (in_event && dtstart != "" && summary != "") {
            print dtstart "|" summary
        }
        in_event=0
    }
    in_event && /^DTSTART/ {
        split($0, a, ":")
        val = a[2]
        if (index($0, ";") > 0) {
            split($0, b, ":")
            val = b[2]
        }
        gsub(/[^0-9]/, "", val)
        if (length(val) >= 8) {
            y = substr(val,1,4)
            m = substr(val,5,2)
            d = substr(val,7,2)
            dtstart = y "-" m "-" d
        }
    }
    in_event && /^SUMMARY/ {
        split($0, a, ":")
        summary = a[2]
        gsub(/\r/, "", summary)
    }
' "$CACHE_FILE" | sort
