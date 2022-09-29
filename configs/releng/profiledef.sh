#!/usr/bin/env bash
# shellcheck disable=SC2034
VER=${ID:-1}

iso_name="archlinux"
iso_label="ARCH_$(date +%Y%m)"
iso_publisher="ArchLinux <https://archlinux.org>"
iso_application="ArchLinux Live/Rescue CD"
iso_version="$(date +%Y.%m.%d).$VER"
install_dir="arch"
buildmodes=('iso')
bootmodes=('uefi-loong64.grub.esp'
           'uefi-loong64.grub.eltorito')
arch="loong64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
)
