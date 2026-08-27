#!/usr/bin/env bash
# Run an idle action only when the machine is on battery.
#
# Used by hypridle-laptop.conf so that dimming, locking, blanking and
# suspending never happen while plugged in.
#
#   idle-guard.sh loginctl lock-session
#
# Exits 0 without running the command when on mains power, so hypridle sees a
# successful no-op.
set -uo pipefail

# True if any mains supply reports online. Iterates by 'type' rather than
# guessing a name — the device is AC on some machines, ADP0/ACAD/AC0 on others.
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

if on_ac_power; then
    exit 0
fi

[[ $# -gt 0 ]] || exit 0
exec "$@"
