#!/bin/bash

set -x

git clone "https://aur.archlinux.org/$1.git"
cd "$1"
makepkg -sf --noconfirm

if [ $2 -eq "true" ]; then
  echo building repo db ...
  repo-add repo.db.tar.zst *.tar.zst
fi 
