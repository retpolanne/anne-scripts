#!/bin/bash

ARCH=`uname -m`

DEBARCH=`[ "$ARCH" == "x86_64" ] && echo amd64 || echo arm64`

QEMUARCH=`[ "$ARCH" == "x86_64" ] && echo x86_64 || echo aarch64`

echo Running on $DEBARCH - $QEMUARCH

rm bionic-server-cloudimg-$DEBARCH.img
wget https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-$DEBARCH.img

qemu-system-$QEMUARCH \
	-M accel=hvf \
	-m 2G \
	-cpu host \
	-serial stdio \
	-display none \
	-hda bionic-server-cloudimg-$DEBARCH.img \
	-device e1000,netdev=net0 \
	-netdev user,id=net0,hostfwd=tcp::2222-:22 \
	-smbios type=1,serial=ds='nocloud;s=http://10.0.2.2:8000/'
