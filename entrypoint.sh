#!/bin/bash

set -x

git clone "https://aur.archlinux.org/$1.git"
cd "$1"
makepkg -sf --noconfirm
echo $2
