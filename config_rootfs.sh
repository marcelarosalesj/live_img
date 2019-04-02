#!/bin/bash

set -x

apt update -y
apt install -y live-boot live-boot-initramfs-tools
apt install -y grub2-common
apt install -y linux-image-4.4.0-143-generic

sudo systemctl enable ssh

apt install -y \
	network-manager \
	openssh-server \
	openssh-client \
	byobu \
	emacs \
	less \
	lvm2 \
	e2fsprogs \
	net-tools

useradd -m -s /bin/bash marce
gpasswd -a marce sudo

poweroff




