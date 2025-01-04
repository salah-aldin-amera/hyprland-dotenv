mkdir ~/Downloads
mkdir -p ~/.config/wofi

cd ~/Downloads

git clone https://github.com/joao-vitor-sr/wofi-themes-collection
cd wofi-themes-collection

cp themes/* ~/.config/wofi/
