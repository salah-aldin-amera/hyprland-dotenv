#!/bin/bash

# Get battery charge from apcaccess
charge=$(apcaccess status | awk -F': +' '/BCHARGE/ {print int($2)}')

# Output for Waybar
echo "$charge%"      # Text displayed
echo "$charge"       # Optional tooltip or numeric value

