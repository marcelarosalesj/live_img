#!/bin/bash

set -x

OS="ubuntu-base-16.04.6-base-amd64.tar.gz"
URL="http://cdimage.ubuntu.com/ubuntu-base/releases/16.04/release/$OS"
CHROOT="chroot"

install_package() {
	pkg=$1
	dpkg -s $pkg &> /dev/null
	retcode=${PIPESTATUS[0]}
	if [ $retcode -eq 0 ]; then
		echo "$pkg already installed"
	else
		echo "Installing $pkg..."
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

# Download OS tarball if it does not exist
[ ! -e $OS ] && wget $URL

# Uncompress tarball in new CHROOT directory
[ -d $CHROOT ] && sudo rm -rf $CHROOT
mkdir $CHROOT
tar -xvzf $OS -C $CHROOT

# Add some configuration
echo "ubuntu-live" | sudo tee $CHROOT/etc/hostname
echo "127.0.0.1 ubuntu-live" | sudo tee $CHROOT/etc/hosts
[ ! -d "$CHROOT/boot/grub" ] && mkdir -p "$CHROOT/boot/grub"
cp grub.cfg $CHROOT/boot/grub/
cp config_rootfs.sh $CHROOT/

# Allow empty password for root user
cp $CHROOT/etc/shadow $CHROOT/etc/shadow_backup
sed '/^root:/ s|\*||' -i $CHROOT/etc/shadow
cp $CHROOT/etc/securetty $CHROOT/etc/securetty_backup

# Add StarlingX deb files to rootfs
cp -r stxdebs $CHROOT/
cp -r stxdebs $CHROOT/usr/local

# Configure rootfs with config_rootfs.sh script
sudo systemd-nspawn -D $CHROOT --machine genubuntu ./config_rootfs.sh
retcode=$?
if [ $retcode -eq 0 ]; then
    mkdir -p iso/live
    sudo cp -a $CHROOT/boot/ iso/
    sudo mksquashfs $CHROOT iso/live/filesystem.squashfs
    sudo grub-mkrescue -o ubuntu-live.iso iso
else
    echo "Error with systemd-nspawn"
    exit -1
fi
