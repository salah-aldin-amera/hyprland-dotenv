
sudo pacman -S python-pipx 

pipx install gallery-dl

pipx install yt-dlp

pipx inject gallery-dl yt-dlp

echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc

source ~/.zshrc
