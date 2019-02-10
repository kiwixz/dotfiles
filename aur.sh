#!/bin/bash

set -e

if [[ $# -eq 0 ]]; then
    echo "Usage: $0 package" >2
    exit 1
fi

cd "/tmp"
curl -LO "https://aur.archlinux.org/cgit/aur.git/snapshot/$1.tar.gz"
tar -xf "$1.tar.gz"
cd "$1"
makepkg -sirc
