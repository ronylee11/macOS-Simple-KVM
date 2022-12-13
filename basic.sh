#!/bin/bash

OSK="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
SCRIPT=$(readlink -f "$0")
VMDIR=$(dirname "$SCRIPT")
OVMF=$VMDIR/firmware
#export QEMU_AUDIO_DRV=pa
#QEMU_AUDIO_DRV=pa

args=(
    -nodefaults \
    -enable-kvm \
    -m 4G \
    -machine q35,accel=kvm \
    -smp 4 \
    -cpu Penryn,vendor=GenuineIntel,kvm=on,+sse3,+sse4.2,+aes,+xsave,+avx,+xsaveopt,+xsavec,+xgetbv1,+avx2,+bmi2,+smep,+bmi1,+fma,+movbe,+invtsc \
    -device isa-applesmc,osk="$OSK" \
    -smbios type=2 \
    -object rng-random,id=rng0,filename=/dev/urandom -device virtio-rng-pci,rng=rng0 \
    -serial mon:stdio \
    -drive if=pflash,format=raw,readonly=on,file="$OVMF/OVMF_CODE.fd" \
    -drive if=pflash,format=raw,file="$OVMF/OVMF_VARS-1024x768.fd" \
    -device virtio-vga-gl \
    -display gtk,gl=on \
    #-display spice-app \
    -audiodev pa,id=pa,server="/run/user/$(id -u)/pulse/native" \
    -device ich9-intel-hda -device hda-output,audiodev=pa \
    -usb -device usb-kbd -device usb-mouse \
    -netdev user,id=net0 \
    -device vmxnet3,netdev=net0,id=net0 \
    -device ich9-ahci,id=sata \
    -drive id=ESP,if=none,format=qcow2,file="$VMDIR"/ESP.qcow2 \
    -device ide-hd,bus=sata.2,drive=ESP \
    -drive id=SystemDisk,if=none,file="$VMDIR"/MyDisk.qcow2 \
    -device ide-hd,bus=sata.3,drive=SystemDisk \
    -drive id=InstallMedia,format=raw,if=none,file="$VMDIR"/BaseSystem.img \
    -device ide-hd,bus=sata.4,drive=InstallMedia \
    -device usb-host,vendorid=0x05ac,productid=0x12ab,guest-reset=false,id=ipad \
    -device usb-host,vendorid=0x05ac,productid=0x12a8,guest-reset=false,id=iphone \
)

qemu-system-x86_64 "${args[@]}"
