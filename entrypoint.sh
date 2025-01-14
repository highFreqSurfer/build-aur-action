#!/bin/bash

set -x

git clone "https://aur.archlinux.org/$1.git"
cd "$1"
makepkg -sf --noconfirm

if [ $2 = "true" ]; then
  echo building repo db ...
  repo-add repo.db.tar.zst *.tar.zst
  rm *.db *.files
  mv repo.db.tar.zst repo.db
  mv repo.files.tar.zst repo.files
  chmod o+rw repo.db repo.files
fi 

chmod o+rw *.tar.zst
