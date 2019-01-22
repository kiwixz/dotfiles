#!/bin/bash

set -e

readonly BASE_URL="https://raw.githubusercontent.com/kiwixz/dotfiles/master/"

if [[ $EUID -eq 0 ]]; then
    echo "You must not run this script as root." >&2
    exit 1
fi


sudo pacman --noconfirm -Sy zsh zsh-syntax-highlighting
chsh -s "$(which zsh)"

cd "/etc/"
sudo sed -Ei 's|^#(Color)$|\1|g' "pacman.conf"
sudo sed -Ei 's|^#(TotalDownload)$|\1|g' "pacman.conf"

cd "/usr/local/bin/"
sudo curl -LO "${BASE_URL}aur"
sudo chmod +x "aur"
aur "yay"

cd
curl -LO "${BASE_URL}.gitconfig"
curl -LO "${BASE_URL}.zshrc"
