#!/bin/bash

# Get a list of current workspaces
last=$(hyprctl workspaces -j | jq '.[].id' | sort -n | tail -n1)

# If there are no workspaces (just in case), default to 1
next=$(( (last > 0 ? last : 0) + 1 ))

# Switch to the next workspace
hyprctl dispatch workspace "$next"

