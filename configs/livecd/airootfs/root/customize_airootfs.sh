#!/usr/bin/env bash

## Script to perform several important tasks before `mkarchcraftiso` create filesystem image.

set -e -u

## -------------------------------------------------------------- ##

if [ -L /etc/resolv.conf ]; then
	unlink /etc/resolv.conf
fi

#sed -i -e 's/^#zh_CN.UTF-8/zh_CN.UTF-8/' -e 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
cat >> /etc/locale.gen << __EOF__
zh_CN.UTF-8 UTF-8
en_US.UTF-8 UTF-8
__EOF__

/usr/bin/locale-gen

## Fix Initrd Generation in Installed System
cat > "/etc/mkinitcpio.d/linux.preset" <<- _EOF_
	# mkinitcpio preset file for the 'linux' package

	ALL_kver="/boot/vmlinuz-linux"
	ALL_config="/etc/mkinitcpio.conf"

	PRESETS=('default' 'fallback')

	#default_config="/etc/mkinitcpio.conf"
	default_image="/boot/initramfs-linux.img"
	#default_options=""

	#fallback_config="/etc/mkinitcpio.conf"
	fallback_image="/boot/initramfs-linux-fallback.img"
	fallback_options="-S autodetect"
_EOF_

## -------------------------------------------------------------- ##

## Enable Parallel Downloads
sed -i -e 's|#ParallelDownloads.*|ParallelDownloads = 5|g' /etc/pacman.conf
sed -i -e '/#\[core-testing\]/Q' /etc/pacman.conf

### Append archcraft repository to pacman.conf
cat >> "/etc/pacman.conf" <<- EOL
	#[core-testing]
	#Include = /etc/pacman.d/mirrorlist

	[core]
	Include = /etc/pacman.d/mirrorlist

	#[extra-testing]
	#Include = /etc/pacman.d/mirrorlist

	[extra]
	Include = /etc/pacman.d/mirrorlist

	#[laur-testing]
	#Include = /etc/pacman.d/mirrorlist

	[laur]
	Include = /etc/pacman.d/mirrorlist

	# An example of a custom package repository.  See the pacman manpage for
	# tips on creating your own repositories.
	#[custom]
	#SigLevel = Optional TrustAll
	#Server = file:///home/custompkgs
EOL

cat >> /etc/environment << EOF
XMODIFIERS=@im=fcitx
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
SDL_IM_MODULE=fcitx
EOF
