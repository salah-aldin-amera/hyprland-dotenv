#!/bin/bash

# Get LOADPCT from apcaccess
load=$(apcaccess status | awk -F': +' '/LOADPCT/ {print int($2)}')

# Output for Waybar
echo "$load%"        # Text displayed
echo "$load"         # Optional tooltip or numeric value

