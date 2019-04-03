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

### To avoid dependency hell... ###
echo "marj>> avoiding dependency hell..."
apt-get install -y dpkg-dev
mkdir -p /usr/local/stxdebs
cp -r /stxdebs/*.deb /usr/local/stxdebs/
# Scan local repository and generate Packages.gz
update_debs(){
    pushd /usr/local/stxdebs
    dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz
    popd
}
# Add local repo to sources.list
sed -i '1s/^/deb [trusted=yes] file:\/usr\/local\/stxdebs .\/\n/' /etc/apt/sources.list
update_debs
apt-get update -y


echo "marj>> installing fm-common and fm-mgr"
ls /usr/local/stxdebs
ls /stxdebs
pushd /stxdebs
apt install -y ./fm-mgr_0.0-1_amd64.deb --allow-unauthenticated
popd

useradd -m -s /bin/bash marce
gpasswd -a marce sudo

