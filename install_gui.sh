#!/bin/bash

set -e

readonly BASE_URL="https://raw.githubusercontent.com/kiwixz/dotfiles/master/"

if [[ $EUID -eq 0 ]]; then
    echo "You must not run this script as root." >&2
    exit 1
fi


cd "/tmp"
curl -L -O "${BASE_URL}install.sh"
bash "install.sh"

yay -Sy "visual-studio-code-bin"
cd
mkdir -p ".config/Code/User/"
curl -L -o ".config/Code/User/settings.json" "${BASE_URL}vscode_settings.json"
