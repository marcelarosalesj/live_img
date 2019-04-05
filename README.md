# Operating Systems building demos  

Currently there are two approaches in this project:

* Through Live Build tool
* Downloading from Ubuntu website

## Through Live Build tool  
We can use Live Build tool to get a base for the Ubuntu rootfs. Then use `systemd-nspawn` container to customize it. After having the rootfs complete, we compress it to squashfs using `mksquashfs`
and finally we generate a GRUB image using `grub-mkrescue` tool.

## Downloading from Ubuntu website

Another option is to get the rootfs from an official Ubuntu repository as a tarball. After we uncompress it, we can follow the same approach as before: use `systemd-nspawn`, `mksquashfs` and `grub-mkrescue`.