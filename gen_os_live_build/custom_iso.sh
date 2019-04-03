#!/bin/bash
#
# I'm following this guide:
# https://www.hiroom2.com/2016/06/10/ubuntu-16-04-create-customized-livedvd
#

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

# Create rootfs
echo "Create rootfs"
mkdir live-build
cd live-build/
livebuilddir=/usr/share/livecd-rootfs/live-build
if [ -d $livebuilddir ]; then
	echo "Copying example files"
	cp -a $livebuilddir/auto .
	cp -a $livebuilddir/ubuntu-core .
else
	echo "Directory doesn't exists $livebuilddir"
	echo "Check live-build installation"
	exit -1
fi

# Generate ubuntu xenial config
echo "Generate ubuntu config"
export PROJECT="ubuntu-core"
env | grep ubuntu

if [ $# -eq 1 ]; then
	http_proxy=$1
	PROJECT="ubuntu-core" lb config --apt-http-proxy "$http_proxy" --apt-ftp-proxy "$http_proxy"
else
	PROJECT="ubuntu-core" lb config
fi

sed -i 's/precise/xenial/g' config/bootstrap

echo "Execute lb build"
mkdir chroot
sudo PROJECT="ubuntu-core" lb build

if [ $? -eq 0 ]; then
    echo ">> Adding config files"

    sudo cp /etc/apt/sources.list chroot/etc/apt/
    echo "ubuntu-live" | sudo tee chroot/etc/hostname
    echo "127.0.0.1 ubuntu-live" | sudo tee chroot/etc/hosts

    sudo mkdir -p chroot/boot/grub/
    sudo cp ../grub.cfg chroot/boot/grub/
    sudo cp ../config_rootfs.sh chroot/
    sudo systemd-nspawn -D chroot --machine blabla ./config_rootfs.sh
    retcode=$?
    if [ $retcode -eq 0 ]; then
        echo ">> generate iso"
        mkdir -p iso/live
        sudo cp -a chroot/boot/ iso/
        sudo mksquashfs chroot iso/live/filesystem.squashfs
        sudo grub-mkrescue -o ubuntu-live.iso iso
    else
        echo "systemd-nspawn failed..."
    fi
else
    echo "Error with lb build command"
fi
