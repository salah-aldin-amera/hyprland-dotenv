#!/usr/bin/env bash
# Shared helpers for install.sh. Sourced, not executed.

# --- output ------------------------------------------------------------------

if [[ -t 1 ]]; then
    C_RESET=$'\033[0m'; C_BOLD=$'\033[1m'; C_DIM=$'\033[2m'
    C_RED=$'\033[31m'; C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'; C_BLUE=$'\033[34m'
else
    C_RESET=; C_BOLD=; C_DIM=; C_RED=; C_GREEN=; C_YELLOW=; C_BLUE=
fi

step() { printf '%s==>%s %s%s%s\n' "$C_BLUE" "$C_RESET" "$C_BOLD" "$*" "$C_RESET"; }
info() { printf '  %s->%s %s\n' "$C_DIM" "$C_RESET" "$*"; }
ok()   { printf '  %s✓%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
warn() { printf '  %s!%s %s\n' "$C_YELLOW" "$C_RESET" "$*" >&2; }
die()  { printf '%serror:%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; exit 1; }

# Run a command, or just print it when DRY_RUN=1.
run() {
    if [[ ${DRY_RUN:-0} == 1 ]]; then
        printf '  %s[dry-run]%s %s\n' "$C_DIM" "$C_RESET" "$*"
        return 0
    fi
    "$@"
}

confirm() {
    local prompt=$1 reply
    [[ ${ASSUME_YES:-0} == 1 ]] && return 0
    read -rp "  ${prompt} [y/N] " reply
    [[ $reply == [yY]* ]]
}

# --- preflight ---------------------------------------------------------------

require_arch() {
    command -v pacman >/dev/null 2>&1 \
        || die "this installer targets Arch Linux (no pacman found)"
}

require_not_root() {
    [[ $EUID -ne 0 ]] \
        || die "run as your normal user, not root — it calls sudo where needed"
}

# Ask for sudo once up front so the run is not interrupted halfway.
prime_sudo() {
    [[ ${DRY_RUN:-0} == 1 ]] && return 0
    step "Requesting sudo (needed for package installs and /etc files)"
    sudo -v || die "sudo failed"
}

# --- AUR helper --------------------------------------------------------------

AUR_HELPER=""

detect_aur_helper() {
    local h
    for h in yay paru; do
        if command -v "$h" >/dev/null 2>&1; then
            AUR_HELPER=$h
            return 0
        fi
    done
    return 1
}

# Build yay from source. Needs git + base-devel, which core.list installs.
bootstrap_aur_helper() {
    if detect_aur_helper; then
        ok "AUR helper: $AUR_HELPER"
        return 0
    fi

    step "No AUR helper found — building yay"
    run sudo pacman -S --needed --noconfirm git base-devel || die "failed to install build deps"

    local tmp
    tmp=$(mktemp -d)
    run git clone --depth 1 https://aur.archlinux.org/yay.git "$tmp/yay" || die "failed to clone yay"
    ( cd "$tmp/yay" && run makepkg -si --noconfirm ) || die "failed to build yay"
    rm -rf "$tmp"

    detect_aur_helper || die "yay still not on PATH after build"
    ok "AUR helper: $AUR_HELPER"
}

# --- packages ---------------------------------------------------------------

# Read a package list, stripping comments/blanks. Emits one name per line,
# 'aur:' prefixes intact.
read_pkg_list() {
    local file=$1
    [[ -f $file ]] || die "package list not found: $file"
    sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' "$file"
}

# Install every package from the given lists. Repo packages go in one pacman
# transaction (fast, resolves conflicts together); AUR packages go one at a
# time so a single failure does not sink the batch.
install_pkg_lists() {
    local -a repo_pkgs=() aur_pkgs=()
    local file line

    for file in "$@"; do
        while IFS= read -r line; do
            [[ -z $line ]] && continue
            if [[ $line == aur:* ]]; then
                aur_pkgs+=("${line#aur:}")
            else
                repo_pkgs+=("$line")
            fi
        done < <(read_pkg_list "$file")
    done

    if ((${#repo_pkgs[@]})); then
        step "Installing ${#repo_pkgs[@]} repo packages"
        run sudo pacman -S --needed --noconfirm "${repo_pkgs[@]}" \
            || warn "some repo packages failed — see output above"
    fi

    if ((${#aur_pkgs[@]})); then
        bootstrap_aur_helper
        step "Installing ${#aur_pkgs[@]} AUR packages"
        local p
        for p in "${aur_pkgs[@]}"; do
            info "$p"
            run "$AUR_HELPER" -S --needed --noconfirm "$p" \
                || warn "AUR package failed, continuing: $p"
        done
    fi
}

# --- linking ----------------------------------------------------------------

# Back up an existing path once, into a timestamped directory, then remove it.
# Never clobbers silently: the old file is always recoverable.
backup_path() {
    local target=$1
    [[ -e $target || -L $target ]] || return 0

    # A symlink already pointing into this repo is ours — replace, don't back up.
    if [[ -L $target ]]; then
        local dest
        dest=$(readlink -f "$target" 2>/dev/null || true)
        if [[ $dest == "$REPO_ROOT"/* ]]; then
            run rm -f "$target"
            return 0
        fi
    fi

    run mkdir -p "$BACKUP_DIR"
    info "backing up $target -> $BACKUP_DIR/"
    run cp -a "$target" "$BACKUP_DIR/" || die "backup failed for $target"
    run rm -rf "$target"
}

# link_file <source-in-repo> <destination>
link_file() {
    local src=$1 dst=$2
    [[ -e $src ]] || die "link source missing: $src"

    if [[ -L $dst ]] && [[ $(readlink -f "$dst" 2>/dev/null) == "$(readlink -f "$src")" ]]; then
        ok "already linked: ${dst/#$HOME/~}"
        return 0
    fi

    backup_path "$dst"
    run mkdir -p "$(dirname "$dst")"
    run ln -sfn "$src" "$dst"
    ok "linked ${dst/#$HOME/~}"
}

# Copy rather than link, for files that must survive the repo being unmounted
# or that tools rewrite in place.
copy_file() {
    local src=$1 dst=$2 mode=${3:-644}
    [[ -e $src ]] || die "copy source missing: $src"
    backup_path "$dst"
    run mkdir -p "$(dirname "$dst")"
    run install -Dm"$mode" "$src" "$dst"
    ok "copied ${dst/#$HOME/~}"
}

# Root-owned file under /etc.
copy_system_file() {
    local src=$1 dst=$2 mode=${3:-644}
    [[ -e $src ]] || die "copy source missing: $src"
    info "installing $dst"
    if run sudo install -Dm"$mode" "$src" "$dst"; then
        ok "installed $dst"
    else
        warn "could not install $dst (needs sudo)"
        return 1
    fi
}

# --- services ---------------------------------------------------------------

enable_system_service() {
    local svc=$1
    if ! systemctl list-unit-files "$svc" >/dev/null 2>&1; then
        warn "no such system service, skipping: $svc"
        return 0
    fi
    run sudo systemctl enable --now "$svc" && ok "enabled $svc" \
        || warn "could not enable $svc"
}

enable_user_service() {
    local svc=$1
    run systemctl --user enable --now "$svc" && ok "enabled (user) $svc" \
        || warn "could not enable user service $svc"
}
