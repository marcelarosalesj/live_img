#!/bin/bash

set -x

apt-get clean -y
apt-get update -y
apt-get upgrade -y

apt-get install -y live-boot live-boot-initramfs-tools
apt-get install -y grub2-common
apt-get install -y grub
apt-get install -y linux-image-4.4.0-143-generic

apt-get install -y \
	network-manager \
	openssh-server \
	openssh-client \
	byobu \
	emacs \
	less \
	lvm2 \
	e2fsprogs \
	net-tools

echo "marj>> installing fm-common and fm-mgr"
ls /stxdebs
pushd /stxdebs
apt install -y ./fm-common-dev_0.0-1_amd64.deb
apt install -y ./fm-mgr_0.0-1_amd64.deb
popd

useradd -m -s /bin/bash marce
gpasswd -a marce sudo

