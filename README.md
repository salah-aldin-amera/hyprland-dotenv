# hyprland-dotenv

Personal dotfiles and setup notes for an Arch Linux + Hyprland (Wayland) desktop.

## System base

| Layer                | Choice                                                    |
| -------------------- | --------------------------------------------------------- |
| Distribution         | Arch Linux (rolling)                                      |
| Display server       | Wayland                                                   |
| Compositor / WM      | [Hyprland](https://hyprland.org/)                         |
| Shell                | Zsh + Oh My Zsh                                           |
| Package managers     | `pacman`, `yay` (AUR), `flatpak`                          |

The full bootstrap (packages, services, AUR pulls) lives in
[`scripts/install-apps.sh`](scripts/install-apps.sh). Run it on a fresh Arch
install to get the same baseline.

## Repository layout

```
dotfiles/
  conf/                    # mirrors ~/.config/<app>/
    hypr/                  # Hyprland + hyprlock + hypridle + hyprpaper
    kitty/                 # terminal config, sessions, scripts
    nvim/                  # Neovim (LazyVim layout)
    waybar/                # status bar config + scripts
    rofi/                  # rofi launcher + theme
    wofi/                  # wofi launcher + multiple themes
    nwg-dock-hyprland/     # dock styling
    kdeglobals             # KDE color scheme (BreezeDark) for Qt apps
  etc/
    keyd/                  # /etc/keyd/ — system-wide input remap
  .local/share/rofi/       # rofi themes (deployed alongside)
scripts/                   # bootstrap and helper scripts
commands/                  # one-off shell scripts (e.g. audio routing)
docs/                      # external references
```

## The desktop stack

### Compositor — Hyprland

- **Config**: `dotfiles/conf/hypr/hyprland.conf` (main) sources
  `modules/workspaces.conf`, `modules/windows.conf`, and
  `modules/mouse-bindings.conf`.
- **Scripts**: `dotfiles/conf/hypr/scripts/{new_workspace.sh,new_workspace_and_move.sh}`.
- **Programs wired up**:
  - `$terminal = kitty`
  - `$fileManager = dolphin`
  - `$wofi-menu = wofi --show drun`
  - `$rofi-menu = rofi -show drun -show-icons`
- **Monitors**: HDMI-A-1, DP-3, DP-1 (all 1920x1080).
- **Companion daemons**:
  - `hyprlock.conf` — screen locker
  - `hypridle.conf` — idle / DPMS / auto-lock
  - `hyprpaper.conf` — wallpaper

#### Qt theming under Hyprland

There is no Plasma session running, so Qt/KDE apps (Dolphin, Kate, Gwenview,
Ark) need an explicit platform-theme bridge. The repo ships:

```
# dotfiles/conf/hypr/hyprland.conf
env = QT_QPA_PLATFORMTHEME,kde
```

…and `dotfiles/conf/kdeglobals` with `[General] ColorScheme=BreezeDark` plus
the `[Colors:*]` / `[WM]` blocks merged from
`/usr/share/color-schemes/BreezeDark.colors`.

Required packages: `kde-cli-tools`, `breeze`, `plasma-workspace`. After
deploying the dotfiles, log out and back into Hyprland for `env =` to take
effect on newly spawned apps.

### Status bar — Waybar

- **Config**: `dotfiles/conf/waybar/config.jsonc`
- **Style**: `dotfiles/conf/waybar/style.css`
- **Custom scripts** (`dotfiles/conf/waybar/scripts/`):
  - `capslock.sh` — caps-lock indicator
  - `playerctl_scroll.sh` — scrollable now-playing module
  - `ups_battery.sh` — UPS battery percentage (NUT)
  - `ups_load.sh` — UPS load percentage (NUT)

### Terminal — kitty

- **Config**: `dotfiles/conf/kitty/kitty.conf`
- **Sessions** (`dotfiles/conf/kitty/sessions/`):
  - `sg-microservices.kitty-session`
  - `sg-dashboard.kitty-session`
- **Helpers** (`dotfiles/conf/kitty/scripts/`):
  - `tab_switcher.sh` — fzf overlay for tab switching
- **Bindings**:
  - `Ctrl+Shift+S` — save current window/tabs as a session
  - `Ctrl+Shift+R` — load a session from `~/.config/kitty/sessions/`
  - `Ctrl+Shift+F` — fzf tab switcher overlay
- Remote control enabled (`listen_on unix:/tmp/kitty-{kitty_pid}`) so session
  scripts can query window/tab state. Clipboard access from remote SSH via
  OSC52 is allowed (writes auto-allowed, reads gated).

### Editor — Neovim (LazyVim)

- **Layout**: `dotfiles/conf/nvim/`
  - `init.lua`, `lazyvim.json`, `.neoconf.json`
  - `lua/config/{options,keymaps,autocmds,lazy}.lua`
  - `lua/plugins/{colorscheme,colorizer,neo-tree,snacks,example}.lua`
- `lazy-lock.json` is **not** tracked (regenerated on first run by lazy.nvim).

### Launchers — rofi & wofi

- **rofi** — `dotfiles/conf/rofi/config.rasi` + themes under
  `dotfiles/.local/share/rofi/themes/` (also `scripts/install-rofi-themes.sh`)
- **wofi** — `dotfiles/conf/wofi/style.css` plus alt themes
  (`nord.css`, `gruvbox.css`, `solarized.css`, `everforest.css`)

### Dock — nwg-dock-hyprland

- **Style**: `dotfiles/conf/nwg-dock-hyprland/style.css`

### File manager — Dolphin (KDE)

Dolphin is the primary file manager (`$fileManager` in Hyprland). It picks up
the BreezeDark palette via the Qt theming bridge described above. Nautilus is
also installed for GTK contexts.

### Input — keyd

- **Config**: `dotfiles/etc/keyd/mouse.conf` → install to `/etc/keyd/`.
- Currently swaps mouse buttons 1/2 to scroll (a vertical-mouse remap):

  ```
  [ids]
  30fa:1701

  [main]
  mouse2 = scrollup
  mouse1 = scrolldown
  scrollup = noop
  scrolldown = noop
  ```

- Enable with `sudo systemctl enable --now keyd`.

### KVM over network — rkvm

`rkvm` shares one keyboard/mouse across machines on the LAN.

- Server runs on the host with the physical keyboard/mouse:
  - `/etc/rkvm/server.toml` — **not committed** (root-owned config).
  - `/etc/rkvm/certificate.pem`, `/etc/rkvm/key.pem` — **secrets, never
    commit**. Generate with `rkvm-certificate-gen` (see install script) and
    copy the public certificate to clients out-of-band.
  - Service: `sudo systemctl enable --now rkvm-server`.

The bootstrap steps and the certificate-copy hint are in
`scripts/install-apps.sh`.

## Other things installed by the bootstrap

The full list is in `scripts/install-apps.sh`. Highlights:

- **Browsers**: Firefox, Firefox Developer Edition, Chromium, Brave, Zen,
  Microsoft Edge (AUR), Google Chrome (AUR)
- **KDE apps**: Dolphin, Gwenview, Kate, Ark
- **GNOME apps**: Nautilus, gnome-calculator
- **Media**: VLC, ffmpeg, kdenlive, scrcpy, yt-dlp, pavucontrol, alsa-utils
- **Messaging**: Telegram Desktop, Discord
- **Dev**: VS Code (`code`), npm, yarn, PostgreSQL, MongoDB, pgAdmin4,
  MongoDB Compass, Apidog, JetBrains Toolbox
- **Creative**: Blender, Inkscape, GIMP
- **Fonts/icons**: noto-fonts, noto-fonts-emoji, font-awesome,
  papirus-icon-theme, numix-icon-theme-git, yaru-icon-theme
- **Services enabled**: `bluetooth.service`, `postgresql.service`,
  `rkvm-server`

## Helper commands

`commands/` holds standalone shell scripts:

- `audio-mic-mono-to-stereo.sh` — duplicate a mono mic to stereo via PipeWire.

`scripts/` also includes:

- `install-apps.sh` — full system bootstrap (described above).
- `install-rofi-themes.sh`, `install-wofi-themes.sh` — drop-in themes.
- `downloader/` — small media-download helpers.

## Deploying these dotfiles

There is no installer wrapper — this is a manual / copy-by-hand setup. The
intended workflow is:

```sh
# 1. clone the repo
git clone git@github.com:salah-aldin-amera/hyprland-dotenv.git
cd hyprland-dotenv

# 2. install packages
bash scripts/install-apps.sh

# 3. drop configs into place
cp -r dotfiles/conf/*           ~/.config/
cp     dotfiles/conf/kdeglobals ~/.config/kdeglobals
sudo cp -r dotfiles/etc/keyd/   /etc/

# 4. log out of Hyprland and back in (so env = takes effect)
```

For rkvm, copy `server.toml` to `/etc/rkvm/` manually and generate the
cert/key — they are intentionally not in this repo.

## References

External docs and upstream projects are listed in
[`docs/references.md`](docs/references.md).
