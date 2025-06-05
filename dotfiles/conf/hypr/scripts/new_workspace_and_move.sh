#!/bin/bash

# Get highest current workspace number
last=$(hyprctl workspaces -j | jq '.[].id' | sort -n | tail -n1)

# Fallback if no workspaces exist
if [[ -z "$last" ]]; then
  last=0
fi

# Next workspace number
next=$((last + 1))

# Move current window to next workspace
hyprctl dispatch movetoworkspace "$next"

# Switch to that workspace
hyprctl dispatch workspace "$next"

