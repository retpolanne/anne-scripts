#!/bin/bash

ARCH=`uname -m`

DEBARCH=`[ "$ARCH" == "x86_64" ] && echo amd64 || echo arm64`

QEMUARCH=`[ "$ARCH" == "x86_64" ] && echo x86_64 || echo aarch64`

echo Running on $DEBARCH - $QEMUARCH

ls debian-12-genericcloud-$DEBARCH.qcow2 || wget https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-$DEBARCH.qcow2

qemu-system-$QEMUARCH \
	-net nic \
	-net user \
	-M accel=hvf \
	-m 2G \
	-cpu host \
	-serial stdio \
	-display none \
	-hda debian-12-genericcloud-$DEBARCH.qcow2 \
	-smbios type=1,serial=ds='nocloud;s=http://10.0.2.2:8000/'
