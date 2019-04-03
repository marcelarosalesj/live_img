#!/bin/bash

set -x

install_package() {
	pkg=$1
	dpkg -s $pkg &> /dev/null
	retcode=${PIPESTATUS[0]}
	if [ $retcode -eq 0 ]; then
		echo "$pkg already installed"
	else
		echo "Installing $pkg..."
		#sudo apt-get install -y $pkg $> /dev/null
		#retcode=${PIPESTATUS[0]}
		sudo apt-get install -y $pkg
		retcode=$?
		if [ $retcode -eq 1 ]; then
			echo "Errors intalling $pkg"
		fi
	fi
}

# Install dependencies
sudo apt-get clean
sudo apt-get update -y
sudo apt-get upgrade -y
install_package livecd-rootfs
install_package systemd-container
install_package xorriso

if [ ! -e ubuntu-base-16.04.6-base-amd64.tar.gz ]; then
    echo "ubuntu-base tarball already exists"
    wget http://cdimage.ubuntu.com/ubuntu-base/releases/16.04/release/ubuntu-base-16.04.6-base-amd64.tar.gz
fi

if [ -d chroot ]; then
    echo "deleting previous iso generation..."
    sudo rm -rf chroot
fi

mkdir chroot
tar -xvzf ubuntu-base-16.04.6-base-amd64.tar.gz -C chroot

echo ">> Adding config files"
echo "ubuntu-live" | sudo tee chroot/etc/hostname
echo "127.0.0.1 ubuntu-live" | sudo tee chroot/etc/hosts
if [ ! -d chroot/boot/grub ]; then
    echo "chroot/boot/grub dir doesn't exist, let's create it"
    mkdir -p chroot/boot/grub
fi
cp grub.cfg chroot/boot/grub/
cp config_rootfs.sh chroot/

# Allow empty password for root user
cp chroot/etc/shadow chroot/etc/shadow_backup
sed '/^root:/ s|\*||' -i chroot/etc/shadow
cp chroot/etc/securetty chroot/etc/securetty_backup

# Add special deb file to rootfb
mkdir -p chroot/stxdebs
cp fm-common-dev_0.0-1_amd64.deb chroot/stxdebs
cp fm-mgr_0.0-1_amd64.deb chroot/stxdebs

# Configure rootfs with config_rootfs.sh script
sudo systemd-nspawn -D chroot --machine genubuntu ./config_rootfs.sh
retcode=$?
if [ $retcode -eq 0 ]; then
    echo "continue with iso generation..."
    echo ">> generate iso"
    mkdir -p iso/live
    sudo cp -a chroot/boot/ iso/
    sudo mksquashfs chroot iso/live/filesystem.squashfs
    sudo grub-mkrescue -o ubuntu-live.iso iso
else
    echo "error with systemd-nspawn..."
    exit -1
fi
