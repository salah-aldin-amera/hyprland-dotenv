#!/bin/bash

# Get highest current workspace id (ignore special workspaces, which have negative ids)
last=$(hyprctl workspaces -j | jq '[.[].id | select(. > 0)] | max // 0')

# Next workspace number
next=$((last + 1))

# Move current window to next workspace, then follow it.
# Hyprland 0.55+ with a lua config takes lua dispatcher expressions; older hyprlang
# sessions only understand the legacy syntax. Try lua first, fall back to legacy.
hyprctl dispatch "hl.dsp.window.move({ workspace = $next })" 2>/dev/null | grep -q '^ok' \
  || hyprctl dispatch movetoworkspace "$next"

hyprctl dispatch "hl.dsp.focus({ workspace = $next })" 2>/dev/null | grep -q '^ok' \
  || hyprctl dispatch workspace "$next"
