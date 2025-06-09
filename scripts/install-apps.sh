# Update System Packages
sudo pacman -Syu

# Create and Navigate to Downloads folder
mkdir ~/Downloads
cd ~/Downloads

# Install ZSH & OMZ
sudo pacman -S --noconfirm zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

cd ~/Downloads
# Install Yay package manager
sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

# Install Utils
sudo pacman -S --noconfirm linux-headers
sudo pacman -S --noconfirm git
sudo pacman -S --noconfirm tree
sudo pacman -S --noconfirm vi vim neovim
sudo pacman -S --noconfirm kdeconnect
sudo pacman -S --noconfirm keepassxc
sudo pacman -S --noconfirm vlc
sudo pacman -S --noconfirm ffmpeg
sudo pacman -S --noconfirm pavucontrol
sudo pacman -S --noconfirm alsa-utils
sudo pacman -S --noconfirm flatpak
sudo pacman -S --noconfirm gnome-keyring
sudo pacman -S --noconfirm seahorse
sudo pacman -S --noconfirm android-tools
sudo pacman -S --noconfirm v4l2loopback-dkms v4l2loopback-utils
sudo pacman -S --noconfirm scrcpy
sudo pacman -S --noconfirm jq
sudo pacman -S --noconfirm bluez bluez-utils blueman
sudo pacman -S --noconfirm usbutils
sudo pacman -S --noconfirm lsof lshw
sudo pacman -S --noconfirm xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-kde
sudo pacman -S --noconfirm archlinux-xdg-menu
sudo pacman -S --noconfirm libreoffice
sudo pacman -S --noconfirm awesome alacritty

# Install KDE Apps
sudo pacman -S --noconfirm dolphin
sudo pacman -S --noconfirm gwenview
sudo pacman -S --noconfirm kate

# Install Gnome Apps
sudo pacman -S --noconfirm nautilus
sudo pacman -S --noconfirm gnome-calculator

# Install nwg Utils
sudo pacman -S --noconfirm nwg-look
sudo pacman -S --noconfirm nwg-dock-hyprland

# Install Fonts & Icons
sudo pacman -S --noconfirm noto-fonts
sudo pacman -S --noconfirm ttf-dejavu ttf-liberation
sudo pacman -S --noconfirm ttf-font-awesome
sudo pacman -S --noconfirm papirus-icon-theme
sudo pacman -S --noconfirm noto-fonts-emoji
yay -S --noconfirm numix-icon-theme-git
yay -S --noconfirm yaru-icon-theme

# Install Official-Repos Browsers
sudo pacman -S --noconfirm firefox
sudo pacman -S --noconfirm firefox-developer-edition
sudo pacman -S --noconfirm chromiumy

# Install AUR Browsers
yay -S --noconfirm google-chrome
yay -S --noconfirm brave-bin
yay -S --noconfirm zen-browser-bin
yay -S --noconfirm microsoft-edge-stable-bin

# Install Messaging Apps
sudo pacman -S --noconfirm telegram-desktop
sudo pacman -S --noconfirm discord


# Install Development Apps
sudo pacman -S --noconfirm npm
sudo pacman -S --noconfirm code
sudo pacman -S --noconfirm postgresql
yay -S --noconfirm pgadmin4-desktop
yay -S --noconfirm mongodb-bin
yay -S --noconfirm mongodb-compass
yay -S --noconfirm apidog-bin
yay -S --noconfirm jetbrains-toolbox
sudo npm install --global yarn

# Install Creativity Apps
sudo pacman -S --noconfirm blender
sudo pacman -S --noconfirm inkscape
sudo pacman -S --noconfirm gimp
sudo pacman -S --noconfirm kdenlive


# Install Trading Apps
yay -S --noconfirm cointop
yay -S --noconfirm tradingview


# Install Flatpak Apps
flatpak install flathub com.obsproject.Studio
flatpak install com.obsproject.Studio.Plugin.BackgroundRemoval

# Install Hyprland Utils
sudo pacman -S --noconfirm waybar
sudo pacman -S --noconfirm hyprpaper
sudo pacman -S --noconfirm hyprpicker
sudo pacman -S --noconfirm hyprlock
sudo pacman -S --noconfirm rofi

# Install Entertainment Apps
sudo pacman -S --noconfirm spotify-launcher

# Install rkvm for keyboard and mouse sharing between linux devices
yay -S rkvm

# Install nvim plugins
yay -S --noconfirm neovim-tree-lua-git
yay -S --noconfirm neovim-telescope

# Install keyboard sounds app
yay -S --noconfirm mechvibes



# Enable bluetooth service
sudo systemctl enable bluetooth.service
sudo systemctl start bluetooth.service

# Enable postgresql
sudo -u postgres initdb --locale=C.UTF-8 --encoding=UTF8 -D /var/lib/postgres/data
sudo systemctl enable postgresql.service
sudo systemctl start postgresql.service

