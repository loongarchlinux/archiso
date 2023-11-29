#!/usr/bin/env bash
#
# Copyright (C) 2020 David Runge <dvzrv@archlinux.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# A simple script to run an archiso image using qemu. The image can be booted
# using BIOS or UEFI.
#
# Requirements:
# - qemu
# - edk2-ovmf (when UEFI booting)


set -eu

print_help() {
    local usagetext
    IFS='' read -r -d '' usagetext <<EOF || true
Usage:
    run_archiso [options]

Options:
    -a              set accessibility support using brltty
    -b              set boot type to 'BIOS' (default)
    -d              set image type to hard disk instead of optical disc
    -h              print help
    -i [image]      image to boot into
    -s              use Secure Boot (only relevant when using UEFI)
    -u              set boot type to 'UEFI'
    -v              use VNC display (instead of default SDL)
    -c [image]      attach an additional optical disc image (e.g. for cloud-init)

Example:
    Run an image using UEFI:
    $ run_archiso -u -i archiso-2020.05.23-x86_64.iso
EOF
    printf '%s' "${usagetext}"
}

cleanup_working_dir() {
    if [[ -d "${working_dir}" ]]; then
        rm -rf -- "${working_dir}"
    fi
}

copy_ovmf_vars() {
    if [[ ! -f '/usr/share/edk2/loongarch64/QEMU_VARS.fd' ]]; then
        printf 'ERROR: %s\n' "OVMF_VARS.fd not found. Install edk2-ovmf."
        exit 1
    fi
    cp -av -- '/usr/share/edk2/loongarch64/QEMU_VARS.fd' "${working_dir}/OVMF_VARS.fd"
}

check_image() {
    if [[ -z "$image" ]]; then
        printf 'ERROR: %s\n' "Image name can not be empty."
        exit 1
    fi
    if [[ ! -f "$image" ]]; then
        printf 'ERROR: %s\n' "Image file (${image}) does not exist."
        exit 1
    fi
}

run_image() {
    if [[ "$boot_type" == 'uefi' ]]; then
        copy_ovmf_vars
        if [[ "${secure_boot}" == 'on' ]]; then
            printf '%s\n' 'Using Secure Boot'
            local ovmf_code='/usr/share/edk2-ovmf/x64/OVMF_CODE.secboot.fd'
        else
            local ovmf_code='/usr/share/edk2/loongarch64/QEMU_CODE.fd'
        fi
        qemu_options+=(
            '-blockdev' "node-name=libvirt-pflash0-storage,driver=file,filename=${working_dir}/OVMF_VARS.fd,auto-read-only=false,discard=unmap"
            '-blockdev' "node-name=libvirt-pflash0-format,driver=raw,read-only=false,file=libvirt-pflash0-storage"
            '-bios' "${ovmf_code}"
        )
    fi

    if [[ "${accessibility}" == 'on' ]]; then
        qemu_options+=(
            '-chardev' 'braille,id=brltty'
            '-device' 'usb-braille,id=usbbrl,chardev=brltty'
        )
    fi

    if [[ -n "${oddimage}" ]]; then
        qemu_options+=(
            '-device' 'scsi-cd,bus=scsi0.0,drive=cdrom1'
            '-drive' "id=cdrom1,if=none,format=raw,media=cdrom,read-only=on,file=${oddimage}"
        )
    fi

    qemu-system-loongarch64 \
        -boot order=d,menu=on,reboot-timeout=5000 \
        -m "size=3072,slots=0,maxmem=$((3072*1024*1024))" \
        -k en-us \
        -accel kvm \
        -cpu la464-loongarch-cpu \
        -name archiso,process=archiso_0 \
        -device virtio-scsi-pci,id=scsi0 \
        -device "scsi-${mediatype%rom},bus=scsi0.0,drive=${mediatype}0" \
        -drive "id=${mediatype}0,if=none,format=raw,media=${mediatype/hd/disk},read-only=on,file=${image}" \
        -display "${display}" \
        -device virtio-gpu-pci \
        -audiodev pa,id=snd0 \
        -device ich9-intel-hda \
        -device hda-output,audiodev=snd0 \
        -device nec-usb-xhci,id=xhci,addr=0x1b \
        -device usb-tablet,id=tablet,bus=xhci.0,port=1 \
        -device usb-kbd,id=keyboard,bus=xhci.0,port=2 \
        -device virtio-net-pci,romfile=,netdev=net0 -netdev user,id=net0,hostfwd=tcp::60022-:22 \
        -machine virt,pflash=libvirt-pflash0-format  \
        "${qemu_options[@]}" \
        -serial stdio \
        -spice port=5920,disable-ticketing=on \
        -no-reboot
}

image=''
oddimage=''
accessibility=''
boot_type='bios'
mediatype='cdrom'
secure_boot='off'
display='gtk'
qemu_options=()
working_dir="$(mktemp -dt run_archiso.XXXXXXXXXX)"
trap cleanup_working_dir EXIT

if (( ${#@} > 0 )); then
    while getopts 'abc:dhi:suv' flag; do
        case "$flag" in
            a)
                accessibility='on'
                ;;
            b)
                boot_type='bios'
                ;;
            c)
                oddimage="$OPTARG"
                ;;
            d)
                mediatype='hd'
                ;;
            h)
                print_help
                exit 0
                ;;
            i)
                image="$OPTARG"
                ;;
            u)
                boot_type='uefi'
                ;;
            s)
                secure_boot='on'
                ;;
            v)
                display='none'
                qemu_options+=(-vnc 'vnc=0.0.0.0:0,vnc=[::]:0')
                ;;
            *)
                printf '%s\n' "Error: Wrong option. Try 'run_archiso -h'."
                exit 1
                ;;
        esac
    done
else
    print_help
    exit 1
fi

check_image
run_image
