DISTRO ?= "ubuntu"

all:
	@ echo "Check all options"

ubuntu:
	@ cd live_img_ubuntu && make

centos:
	@ echo "Not supported yet"
