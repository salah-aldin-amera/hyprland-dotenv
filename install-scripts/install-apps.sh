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
sudo pacman -S --noconfirm git
sudo pacman -S --noconfirm tree
sudo pacman -S --noconfirm neovim
sudo pacman -S --noconfirm kdeconnect
sudo pacman -S --noconfirm input-leap
sudo pacman -S --noconfirm keepassxc
sudo pacman -S --noconfirm vlc
sudo pacman -S --noconfirm ffmpeg
sudo pacman -S --noconfirm pavucontrol
sudo pacman -S --noconfirm alsa-utils
sudo pacman -S --noconfirm flatpak
sudo pacman -S --noconfirm gnome-keyring
sudo pacman -S --noconfirm seahorse

# Install File Managers
sudo pacman -S --noconfirm nautilus
sudo pacman -S --noconfirm dolphin


# Install Fonts & Arabic-Fonts
sudo pacman -S --noconfirm noto-fonts
sudo pacman -S --noconfirm ttf-dejavu ttf-liberation

# Install Official-Repos Browsers
sudo pacman -S --noconfirm firefox
sudo pacman -S --noconfirm firefox-developer-edition
sudo pacman -S --noconfirm chromium

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


# Hyprland Utils
sudo pacman -S --noconfirm waybar
sudo pacman -S --noconfirm hyprpaper
sudo pacman -S --noconfirm hyprpicker
sudo pacman -S --noconfirm hyprlock


# Install Entertainment Apps
sudo pacman -S --noconfirm spotify-launcher
