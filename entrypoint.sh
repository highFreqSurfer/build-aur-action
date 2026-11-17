#!/bin/bash
#
# args: $1 = AUR package name
#       $2 = "true" to build a local repo db
#       $3 = commands to run before the build (as root)
#
set -o pipefail
set -x

echo "print parameters ..."
echo "$@"

WORKSPACE="${GITHUB_WORKSPACE:-/github/workspace}"

# 1. run-before-build: runs as root, used for pacman-key / pacman / gpg setup
if [ -n "$3" ]; then
  eval "$3"
  status=$?
  if [ "$status" -ne 0 ]; then
    echo "run-before-build failed with exit code $status"
    exit "$status"
  fi
fi

# 2. hand over the gpg keys imported above, makepkg verifies source signatures
if [ -d "${HOME}/.gnupg" ]; then
  mkdir -p /home/builder/.gnupg
  cp -a "${HOME}/.gnupg/." /home/builder/.gnupg/
  chown -R builder:builder /home/builder/.gnupg
fi

# 3. build as unprivileged user: makepkg refuses to run as root
chown -R builder:builder "$WORKSPACE" /home/builder

export AUR_PKG="$1"
su builder -s /bin/bash -c '
  set -e
  cd "$0"
  git clone "https://aur.archlinux.org/${AUR_PKG}.git"
  cd "${AUR_PKG}"
  makepkg -sf --noconfirm --skipchecksums
' "$WORKSPACE"
ret=$?

# 4. restore permissions so the following workflow steps (runner user) can write
chmod -R a+rwX "$WORKSPACE"

if [ "$ret" -ne 0 ]; then
  echo "makepkg failed with exit code $ret"
  exit "$ret"
fi

cd "$WORKSPACE/$1"

if [ "$2" = "true" ]; then
  echo "building repo db ..."
  repo-add repo.db.tar.zst ./*.tar.zst
  rm -f repo.db repo.files
  mv repo.db.tar.zst repo.db
  mv repo.files.tar.zst repo.files
  chmod o+rw repo.db repo.files
fi

chmod o+rw ./*.tar.zst
