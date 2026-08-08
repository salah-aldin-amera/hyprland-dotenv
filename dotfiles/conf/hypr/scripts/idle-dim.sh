#!/usr/bin/env bash
# Dim / undim the backlight for hypridle, safely.
#
#   idle-dim.sh dim     # remember current brightness, drop to DIM_PERCENT
#   idle-dim.sh restore # put it back, if we dimmed it
#
# Deliberately does NOT use `brightnessctl -s` / `-r`. That pair failed badly:
# `brightnessctl -s set 10` sets raw value 10, which on a 96000-max panel is
# 0% — a black screen — and if the restore never runs (session restart, resume
# while on AC, hypridle reload) there is no way back short of sshing in. This
# writes the previous value to a runtime file instead, so restore is
# idempotent, and never dims below a level you can still see.
set -uo pipefail

DIM_PERCENT=${DIM_PERCENT:-10}
STATE="${XDG_RUNTIME_DIR:-/tmp}/hypr-idle-brightness"

# POWER_SUPPLY_PATH is overridable so the battery path can be tested without
# physically unplugging the machine.
POWER_SUPPLY_PATH=${POWER_SUPPLY_PATH:-/sys/class/power_supply}

on_ac_power() {
    local ps
    for ps in "$POWER_SUPPLY_PATH"/*; do
        [[ -r $ps/type   ]] || continue
        [[ $(< "$ps/type") == Mains ]] || continue
        [[ -r $ps/online ]] || continue
        [[ $(< "$ps/online") == 1 ]] && return 0
    done
    return 1
}

case ${1:-} in
    dim)
        # Never dim on mains power.
        on_ac_power && exit 0

        # Already dimmed: do not overwrite the saved value with the dim value.
        [[ -f $STATE ]] && exit 0

        current=$(brightnessctl get 2>/dev/null) || exit 0
        [[ -n $current ]] || exit 0

        printf '%s\n' "$current" > "$STATE"
        brightnessctl set "${DIM_PERCENT}%" >/dev/null 2>&1 || true
        ;;

    restore)
        # Unconditional: if we dimmed, we restore — regardless of whether the
        # machine has since been plugged in.
        [[ -f $STATE ]] || exit 0

        saved=$(< "$STATE")
        rm -f "$STATE"
        [[ -n $saved ]] || exit 0

        brightnessctl set "$saved" >/dev/null 2>&1 || true
        ;;

    *)
        printf 'usage: %s dim|restore\n' "${0##*/}" >&2
        exit 2
        ;;
esac
