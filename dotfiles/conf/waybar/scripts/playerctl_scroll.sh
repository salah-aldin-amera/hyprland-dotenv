#!/bin/bash
# Scrolling marquee for playerctl - outputs shifted text each frame
MAX_LEN=25
SCROLL_DELAY=0.20   # seconds per character step
PAUSE=1.5           # seconds to hold at the start before scrolling
CHECK_EVERY=8       # check for track change every N frames (avoids per-frame subprocess cost)

while true; do
    STATUS=$(playerctl status 2>/dev/null)

    if [ "$STATUS" != "Playing" ] && [ "$STATUS" != "Paused" ]; then
        echo ""
        sleep 2
        continue
    fi

    TITLE=$(playerctl metadata title 2>/dev/null)
    ARTIST=$(playerctl metadata artist 2>/dev/null)

    if [ -n "$ARTIST" ] && [ "$ARTIST" != "$TITLE" ]; then
        TEXT="$TITLE - $ARTIST"
    else
        TEXT="$TITLE"
    fi

    if [ -z "$TEXT" ]; then
        echo ""
        sleep 2
        continue
    fi

    LEN=${#TEXT}

    if [ $LEN -le $MAX_LEN ]; then
        printf "%-${MAX_LEN}s\n" "$TEXT"
        sleep 2
        continue
    fi

    # Pad with a short separator so the loop wraps cleanly
    PAD="   -   "
    LOOPED="$TEXT$PAD"
    LLEN=${#LOOPED}

    track_changed=0
    for ((i = 0; i < LLEN; i++)); do
        END=$((i + MAX_LEN))
        if [ $END -le $LLEN ]; then
            FRAME="${LOOPED:$i:$MAX_LEN}"
        else
            WRAP=$((END - LLEN))
            FRAME="${LOOPED:$i}${LOOPED:0:$WRAP}"
        fi
        printf "%-${MAX_LEN}s\n" "$FRAME"

        if [ $i -eq 0 ]; then
            sleep "$PAUSE"
        else
            sleep "$SCROLL_DELAY"
        fi

        # Only spawn playerctl every CHECK_EVERY frames
        if (( i % CHECK_EVERY == 0 )); then
            NEW_TITLE=$(playerctl metadata title 2>/dev/null)
            if [ "$NEW_TITLE" != "$TITLE" ]; then
                track_changed=1
                break
            fi
        fi
    done
done
