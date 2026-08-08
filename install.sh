#!/usr/bin/env bash
#
# hyprland-dotenv installer.
#
# Brings a fresh Arch box to a working Hyprland desktop: installs packages,
# links configs, generates the per-machine local.lua, enables services.
#
# Safe to re-run. Existing files are backed up to ~/.dotfiles-backup/<stamp>/
# before anything is replaced.
#
#   ./install.sh                        # interactive: asks pc or laptop
#   ./install.sh --machine laptop       # non-interactive machine choice
#   ./install.sh --profile dev          # core + dev packages
#   ./install.sh --dry-run              # print actions, change nothing
#   ./install.sh --configs-only         # skip packages, just link configs
#
set -uo pipefail

REPO_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
readonly REPO_ROOT
# shellcheck source=lib/common.sh
source "$REPO_ROOT/lib/common.sh"

BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
readonly BACKUP_DIR

DOTS="$REPO_ROOT/dotfiles"
CONF="$DOTS/conf"

# --- options ----------------------------------------------------------------

MACHINE=""
PROFILE="core"
DRY_RUN=0
ASSUME_YES=0
CONFIGS_ONLY=0
PACKAGES_ONLY=0

usage() {
    sed -n '3,20p' "$0" | sed 's/^# \{0,1\}//'
    cat <<'EOF'

Options:
  -m, --machine pc|laptop   Machine class. Prompted for if omitted.
  -p, --profile PROFILE     core (default) | dev | full
                              core = usable desktop
                              dev  = core + development tooling
                              full = core + dev + browsers, creative, media
      --configs-only        Link configs and generate local.lua only.
      --packages-only       Install packages only, touch no configs.
  -n, --dry-run             Print what would happen; change nothing.
  -y, --yes                 Do not prompt for confirmation.
  -h, --help                This message.
EOF
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--machine)  MACHINE=${2:-}; shift 2 ;;
        -p|--profile)  PROFILE=${2:-}; shift 2 ;;
        --configs-only)  CONFIGS_ONLY=1; shift ;;
        --packages-only) PACKAGES_ONLY=1; shift ;;
        -n|--dry-run)  DRY_RUN=1; shift ;;
        -y|--yes)      ASSUME_YES=1; shift ;;
        -h|--help)     usage; exit 0 ;;
        *) die "unknown option: $1 (try --help)" ;;
    esac
done

case $PROFILE in
    core|dev|full) ;;
    *) die "invalid profile: $PROFILE (want core, dev, or full)" ;;
esac

# --- machine selection ------------------------------------------------------

# The one genuinely per-box decision, and it changes input config, power
# behaviour, waybar layout, and which package list runs.
prompt_machine() {
    local reply
    printf '\n%sWhich kind of machine is this?%s\n' "$C_BOLD" "$C_RESET"
    printf '  %s1)%s pc      — desktop: multi-monitor, no battery, ydotool mouse keys,\n' "$C_BOLD" "$C_RESET"
    printf '                 UPS widgets, rkvm server\n'
    printf '  %s2)%s laptop  — touchpad + gestures, backlight keys, lid switch,\n' "$C_BOLD" "$C_RESET"
    printf '                 battery widget, suspend on idle\n\n'
    while :; do
        read -rp "  Choice [1/2]: " reply
        case $reply in
            1|pc)     MACHINE=pc;     return 0 ;;
            2|laptop) MACHINE=laptop; return 0 ;;
            *) warn "answer 1 or 2" ;;
        esac
    done
}

if [[ -z $MACHINE ]]; then
    if [[ $ASSUME_YES == 1 ]]; then
        die "--yes given without --machine; pass --machine pc|laptop"
    fi
    prompt_machine
fi

case $MACHINE in
    pc|laptop) ;;
    *) die "invalid machine: $MACHINE (want pc or laptop)" ;;
esac

# --- preflight --------------------------------------------------------------

require_arch
require_not_root

HOSTNAME_SHORT=$(uname -n)

step "hyprland-dotenv"
info "repo:     $REPO_ROOT"
info "machine:  $MACHINE"
info "host:     $HOSTNAME_SHORT"
info "profile:  $PROFILE"
[[ $DRY_RUN == 1 ]] && warn "dry run — nothing will be changed"

if [[ -f "$CONF/hypr/hosts/$HOSTNAME_SHORT.lua" ]]; then
    info "host config: dotfiles/conf/hypr/hosts/$HOSTNAME_SHORT.lua"
else
    warn "no host config for '$HOSTNAME_SHORT' — monitors will auto-detect."
    warn "add dotfiles/conf/hypr/hosts/$HOSTNAME_SHORT.lua to pin the layout."
fi

confirm "Proceed?" || { info "aborted"; exit 0; }

[[ $DRY_RUN == 1 || $CONFIGS_ONLY == 1 ]] || prime_sudo

# --- packages ---------------------------------------------------------------

install_packages() {
    local -a lists=("$REPO_ROOT/packages/core.list")

    case $PROFILE in
        dev)  lists+=("$REPO_ROOT/packages/dev.list") ;;
        full) lists+=("$REPO_ROOT/packages/dev.list" "$REPO_ROOT/packages/full.list") ;;
    esac

    lists+=("$REPO_ROOT/packages/$MACHINE.list")

    step "Syncing package databases"
    run sudo pacman -Syu --noconfirm || warn "system update reported errors"

    install_pkg_lists "${lists[@]}"
}

# --- configs ----------------------------------------------------------------

# local.lua tells hyprland.lua which machine/ and hosts/ file to load. It is
# generated, not tracked, because it is the one file that differs per box.
generate_local_lua() {
    local target="$HOME/.config/hypr/local.lua"
    local host_arg="nil"

    if [[ -f "$CONF/hypr/hosts/$HOSTNAME_SHORT.lua" ]]; then
        host_arg="\"$HOSTNAME_SHORT\""
    fi

    step "Generating local.lua"
    if [[ $DRY_RUN == 1 ]]; then
        info "[dry-run] would write $target (machine=$MACHINE host=$host_arg)"
        return 0
    fi

    mkdir -p "$(dirname "$target")"
    cat > "$target" <<EOF
-- Generated by install.sh on $(date -Iseconds). Not tracked in git.
-- Re-run ./install.sh to regenerate, or edit by hand.
return {
    machine = "$MACHINE",
    host    = $host_arg,
}
EOF
    ok "wrote ${target/#$HOME/~} (machine=$MACHINE host=$host_arg)"
}

link_hypr() {
    step "Linking Hyprland config"

    local dst="$HOME/.config/hypr"
    mkdir -p "$dst"

    link_file "$CONF/hypr/hyprland.lua"      "$dst/hyprland.lua"
    link_file "$CONF/hypr/modules"           "$dst/modules"
    link_file "$CONF/hypr/machine"           "$dst/machine"
    link_file "$CONF/hypr/hosts"             "$dst/hosts"
    link_file "$CONF/hypr/scripts"           "$dst/scripts"

    link_file "$CONF/hypr/hyprlock.conf"     "$dst/hyprlock.conf"
    link_file "$CONF/hypr/hyprpaper.conf"    "$dst/hyprpaper.conf"
    link_file "$CONF/hypr/hyprlauncher.conf" "$dst/hyprlauncher.conf"
    link_file "$CONF/hypr/hyprtoolkit.conf"  "$dst/hyprtoolkit.conf"

    # hypridle differs by machine class: the laptop profile suspends.
    if [[ $MACHINE == laptop ]]; then
        link_file "$CONF/hypr/hypridle-laptop.conf" "$dst/hypridle.conf"
    else
        link_file "$CONF/hypr/hypridle.conf"        "$dst/hypridle.conf"
    fi
}

link_waybar() {
    step "Linking waybar"
    local dst="$HOME/.config/waybar"
    mkdir -p "$dst"

    link_file "$CONF/waybar/modules.jsonc" "$dst/modules.jsonc"
    link_file "$CONF/waybar/style.css"     "$dst/style.css"
    link_file "$CONF/waybar/scripts"       "$dst/scripts"
    link_file "$CONF/waybar/config-$MACHINE.jsonc" "$dst/config.jsonc"
}

# Oh My Zsh, then .zshrc. Order matters: the OMZ installer writes its own
# ~/.zshrc, so --keep-zshrc stops it clobbering ours, and the link happens
# after in any case. Runs unattended: no prompts, no shell switch mid-script.
setup_zsh() {
    step "Setting up zsh"

    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        ok "oh-my-zsh already installed"
    else
        info "installing oh-my-zsh (unattended)"
        if [[ $DRY_RUN == 1 ]]; then
            info "[dry-run] would install oh-my-zsh"
        else
            RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
                "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
                "" --unattended --keep-zshrc \
                || warn "oh-my-zsh install failed; ~/.zshrc will still be linked"
        fi
    fi

    # ZSH_THEME=fino-time ships with oh-my-zsh, so there is nothing to fetch.
    link_file "$DOTS/home/.zshrc" "$HOME/.zshrc"

    # Make zsh the login shell, if it is not already. Skipped under
    # --configs-only, which is deliberately sudo-free.
    if [[ $CONFIGS_ONLY == 1 ]]; then
        info "skipping login-shell change (--configs-only avoids sudo)"
        return 0
    fi

    local current
    current=$(getent passwd "$USER" | cut -d: -f7)
    if [[ $current != *zsh ]]; then
        info "changing login shell: $current -> /usr/bin/zsh"
        run sudo chsh -s /usr/bin/zsh "$USER" \
            && ok "login shell is now zsh (takes effect next login)" \
            || warn "could not change login shell"
    else
        ok "login shell already zsh"
    fi
}

# rofi and wofi, with the tracked themes. The themes live in this repo rather
# than being cloned from the upstream collections at install time, so a rebuild
# is offline and reproducible and cannot clobber salah-theme.rasi.
link_launchers() {
    step "Linking launchers (rofi + wofi themes)"

    link_file "$CONF/rofi"  "$HOME/.config/rofi"
    link_file "$CONF/wofi"  "$HOME/.config/wofi"

    # rofi looks for user themes here, and config.rasi @theme points into it.
    link_file "$DOTS/.local/share/rofi/themes" "$HOME/.local/share/rofi/themes"
}

# Dark theme, everywhere. Qt goes through QT_QPA_PLATFORMTHEME=kde plus
# kdeglobals (BreezeDark); GTK needs both the settings.ini files and the
# gsettings keys, because different consumers read different sources: GTK reads
# the files, while xdg-desktop-portal, libadwaita and GNOME apps read dconf.
# On salahaldin-pc this only ever lived in dconf, so a fresh machine came up
# light with nothing in the repo to explain it.
setup_theme() {
    step "Applying dark theme"

    link_file "$CONF/gtk-3.0/settings.ini" "$HOME/.config/gtk-3.0/settings.ini"
    link_file "$CONF/gtk-4.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"

    if ! command -v gsettings >/dev/null 2>&1; then
        warn "gsettings not found — GTK4/portal apps may stay light"
        return 0
    fi

    local schema=org.gnome.desktop.interface
    run gsettings set "$schema" color-scheme 'prefer-dark'
    run gsettings set "$schema" gtk-theme 'Adwaita-dark'
    run gsettings set "$schema" icon-theme 'Adwaita'
    ok "gsettings: prefer-dark, Adwaita-dark, Adwaita icons"
}

link_apps() {
    step "Linking application configs"

    link_file "$CONF/kitty"   "$HOME/.config/kitty"
    link_file "$CONF/nvim"    "$HOME/.config/nvim"

    # Qt/KDE theme bridge so Dolphin and friends follow the dark theme.
    copy_file "$CONF/kdeglobals" "$HOME/.config/kdeglobals"

    if [[ -d "$CONF/nwg-dock-hyprland" ]]; then
        link_file "$CONF/nwg-dock-hyprland" "$HOME/.config/nwg-dock-hyprland"
    fi
}

install_wallpapers() {
    step "Installing wallpapers"
    local dst="$HOME/Pictures/wallpapers"
    run mkdir -p "$dst"
    local f
    for f in "$REPO_ROOT"/images/wallpapers/*; do
        [[ -e $f ]] || continue
        run cp -n "$f" "$dst/" || true
    done
    ok "wallpapers in ${dst/#$HOME/~}"
}

# keyd remaps a specific mouse by USB id; only meaningful on the desktop.
# Needs sudo, so it is skipped under --configs-only, which is sudo-free.
install_system_configs() {
    [[ $MACHINE == pc ]] || return 0

    if [[ $CONFIGS_ONLY == 1 ]]; then
        info "skipping /etc/keyd/mouse.conf (--configs-only avoids sudo)"
        return 0
    fi

    [[ -f "$DOTS/etc/keyd/mouse.conf" ]] || return 0

    step "Installing system configs"
    copy_system_file "$DOTS/etc/keyd/mouse.conf" "/etc/keyd/mouse.conf"
}

# --- services ---------------------------------------------------------------

setup_services() {
    step "Enabling services"

    if [[ $MACHINE == pc ]]; then
        # keyd owns the mouse remap; ydotoold backs the keyboard mouse binds.
        enable_system_service keyd.service
        enable_system_service ydotoold.service
    else
        enable_system_service power-profiles-daemon.service
        enable_system_service NetworkManager.service
    fi

    # ydotool needs the invoking user in the input group to reach uinput.
    if [[ $MACHINE == pc ]] && ! id -nG "$USER" | grep -qw input; then
        info "adding $USER to the input group (for ydotool); re-login to apply"
        run sudo usermod -aG input "$USER"
    fi

    # brightnessctl works inside a logind seat session without this, but not
    # from a plain ssh login — which is exactly when you need it to unstick a
    # screen that got dimmed and never restored.
    if [[ $MACHINE == laptop ]] && ! id -nG "$USER" | grep -qw video; then
        info "adding $USER to the video group (for brightnessctl); re-login to apply"
        run sudo usermod -aG video "$USER"
    fi
}

# --- run --------------------------------------------------------------------

if [[ $CONFIGS_ONLY == 0 ]]; then
    install_packages
fi

if [[ $PACKAGES_ONLY == 0 ]]; then
    generate_local_lua
    link_hypr
    link_waybar
    link_launchers
    link_apps
    setup_theme
    setup_zsh
    install_wallpapers
    install_system_configs
fi

if [[ $CONFIGS_ONLY == 0 ]]; then
    setup_services
fi

step "Done"
if [[ -d $BACKUP_DIR ]]; then
    info "replaced files backed up to ${BACKUP_DIR/#$HOME/~}"
fi
cat <<EOF

  Next:
    - Log out and start Hyprland, or reload:  hyprctl reload
    - Launchers:     SUPER + H hyprlauncher  (. emoji  = math  ' fonts)
                     SUPER + R rofi   SUPER + W wofi
    - Clipboard:     SUPER + SHIFT + V
    - Screenshot:    SUPER + P / PRINT / SUPER + SHIFT + P
    - Lock:          SUPER + L

  Machine class is recorded in ~/.config/hypr/local.lua ($MACHINE).
  Re-run with --machine to change it.
EOF
