# Zsh config — Oh My Zsh.
#
# Tracked in hyprland-dotenv; install.sh links this to ~/.zshrc.
# Machine-specific additions belong in ~/.zshrc.local (not tracked), which is
# sourced at the end of this file.

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="fino-time"

plugins=(git)

source "$ZSH/oh-my-zsh.sh"

# --- environment -------------------------------------------------------------

export TERM=xterm-256color

export HYPRSHOT_DIR="$HOME/Pictures/screenshots"

export POSTING_EDITOR=nvim
export POSTING_PAGER=less

# --- PATH --------------------------------------------------------------------

# Only prepend directories that actually exist. Every entry below is optional
# per machine — the laptop has no flutter or android SDK, and a stale PATH
# entry makes command lookup slower and `which` output misleading.
_prepend_path() {
    [[ -d $1 ]] && PATH="$1:$PATH"
}

_prepend_path "$HOME/.local/bin"
_prepend_path "$HOME/.cargo/bin"
_prepend_path "$HOME/.opencode/bin"
_prepend_path "$HOME/flutter/bin"

# --- node (nvm) --------------------------------------------------------------

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # loads completion

# --- android -----------------------------------------------------------------

if [[ -d /opt/android-sdk ]]; then
    export ANDROID_HOME=/opt/android-sdk
    export ANDROID_SDK_ROOT=/opt/android-sdk
    _prepend_path "$ANDROID_HOME/cmdline-tools/latest/bin"
    _prepend_path "$ANDROID_HOME/platform-tools"
    _prepend_path "$ANDROID_HOME/emulator"
fi

unset -f _prepend_path
export PATH

# --- per-machine overrides ---------------------------------------------------

# Anything host-specific: work tokens, one-off aliases, local paths.
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
