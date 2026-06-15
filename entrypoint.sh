#!/bin/bash

set -x

echo print prameters ...
echo "$@"

git clone "https://aur.archlinux.org/$1.git"
cd "$1"
makepkg -sf --noconfirm --skipchecksums

if [ "$?" != 0 ]; then
  exit $?
fi

if [ "$3" != "" ]; then
  eval "$3"
fi

if [ "$2" = "true" ]; then
  echo building repo db ...
  repo-add repo.db.tar.zst *.tar.zst
  rm *.db *.files
  mv repo.db.tar.zst repo.db
  mv repo.files.tar.zst repo.files
  chmod o+rw repo.db repo.files
fi 

chmod o+rw *.tar.zst
