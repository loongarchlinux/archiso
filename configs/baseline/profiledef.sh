#!/usr/bin/env bash
# shellcheck disable=SC2034

ID=${ID:-1}

iso_name="loongarchlinux-baseline"
iso_label="ARCH_$(date +%Y%m)"
iso_publisher="Arch Linux <https://archlinux.org>"
iso_application="Arch Linux baseline"
iso_version="$(date +%Y.%m.%d).$ID"
install_dir="arch"
buildmodes=('iso')
bootmodes=('uefi-la64.systemd-boot.esp' 'uefi-la64.systemd-boot.eltorito')
arch="loongarch64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
)
