#!/bin/bash

# Read capslock state from kernel LED (works with any keyboard)
LED_PATH="/sys/class/leds/input52::capslock/brightness"

if [[ ! -r "$LED_PATH" ]]; then
    LED_PATH=$(ls /sys/class/leds/*::capslock/brightness 2>/dev/null | head -1)
fi

if [[ -z "$LED_PATH" ]]; then
    echo '{"text": "󰪛", "class": "unknown"}'
    exit 0
fi

state=$(cat "$LED_PATH")
if [[ "$state" == "1" ]]; then
    echo '{"text": "󰪛", "class": "active", "tooltip": "Caps Lock ON"}'
else
    echo '{"text": "󰪛", "class": "inactive", "tooltip": "Caps Lock OFF"}'
fi
