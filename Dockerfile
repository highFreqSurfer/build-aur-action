FROM archlinux:latest

RUN pacman -Syu base-devel git sudo --noconfirm --overwrite '*' \
    && useradd -m -s /bin/bash builder \
    && echo 'builder ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/builder \
    && chmod 440 /etc/sudoers.d/builder

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
