#!/bin/bash

set -x

update_debs(){
    pushd /usr/local/stxdebs
    dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz
    popd
}

apt-get clean -y
apt-get update -y
apt-get upgrade -y

apt-get install -y \
    live-boot \
    live-boot-initramfs-tools \
    grub2-common \
    linux-image-4.4.0-143-generic

apt-get install -y \
	network-manager \
	openssh-server \
	openssh-client \
	byobu \
	emacs \
	less \
	lvm2 \
	e2fsprogs \
	net-tools \
        vim \
        strace \
        iputils-ping

# Create Apt Local Repo for StarlingX packages
apt-get install -y dpkg-dev
sed -i '1s/^/deb [trusted=yes] file:\/usr\/local\/stxdebs .\/\n/' /etc/apt/sources.list
update_debs
apt-get update -y

# Install StarlingX package
pushd /stxdebs
apt install -y ./fm-mgr_0.0-1_amd64.deb --allow-unauthenticated
popd
