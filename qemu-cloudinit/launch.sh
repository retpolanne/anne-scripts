#!/bin/bash

ARCH=`uname -m`

DEBARCH=`[ "$ARCH" == "x86_64" ] && echo amd64 || echo arm64`

QEMUARCH=`[ "$ARCH" == "x86_64" ] && echo x86_64 || echo aarch64`

MACHINE=`[ "$ARCH" == "arm64" ] && echo virt,accel=hvf || echo accel=hvf`

echo Running on $DEBARCH - $QEMUARCH 

ls bionic-server-cloudimg-$DEBARCH.img || wget https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-$DEBARCH.img

if [ "$ARCH" == "arm64" ]; then
	ls QEMU_EFI.fd || wget https://releases.linaro.org/components/kernel/uefi-linaro/16.02/release/qemu64/QEMU_EFI.fd
	dd if=/dev/zero of=flash0.img bs=1M count=64
	dd if=QEMU_EFI.fd of=flash0.img conv=notrunc
	dd if=/dev/zero of=flash1.img bs=1M count=64
	PFLASH="-pflash flash0.img -pflash flash1.img"
fi

echo qemu-system-$QEMUARCH \
	-M $MACHINE \
	-m 2G \
	-cpu host \
	-serial stdio \
	-display none \
	-device virtio-scsi-pci,id=scsi \
	-hda bionic-server-cloudimg-$DEBARCH.img \
	-device e1000,netdev=net0 \
	-netdev user,id=net0,hostfwd=tcp::2222-:22 \
	-smbios type=1,serial=ds='nocloud-net;s=http://10.0.2.2:8000/' \
	$PFLASH

qemu-system-$QEMUARCH \
	-M $MACHINE \
	-m 2G \
	-cpu host \
	-serial stdio \
	-display none \
	-device virtio-scsi-pci,id=scsi \
	-hda bionic-server-cloudimg-$DEBARCH.img \
	-device e1000,netdev=net0 \
	-netdev user,id=net0,hostfwd=tcp::2222-:22 \
	-smbios type=1,serial=ds='nocloud-net;s=http://10.0.2.2:8000/' \
	$PFLASH
