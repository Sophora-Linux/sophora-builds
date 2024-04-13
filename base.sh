#!/bin/bash

#This script not aims to be executable as is, it's just the commands used to build the base-stage4 archive for Sophora.


nano -w etc/portage/make.conf

#Don't using -march=something, as we build generic optimized stages.

#Adding configuration to make.conf file.

USE=""
MAKEOPTS="-j8" #Default Sophora build server conf. Change this value.
LINGUAS="fr" #Default Sophora value
L10N="fr" #Default Sophora value
VIDEO_CARDS="fbdev vesa intel i915 nvidia nouveau radeon amdgpu radeonsi virtualbox vmware qxl" #Default Sophora value
INPUT_DEVICES="libinput synaptics keyboard mouse joystick wacom" #Default Sophora value


#We don't change yet the gentoo repo server, default rotation is fine.

mkdir -p etc/portage/repos.conf
cp usr/share/portage/config/repos.conf etc/portage/repos.conf/gentoo.conf

cp -L /etc/resolv.conf etc/

mount -t proc /proc proc
mount --rbind /dev dev
mount --rbind /sys sys

chroot . /bin/bash

env-update && source /etc/profile

export PS1="[chroot] $PS1"

emerge-webrsync


#Adding cpuid detect package, but not used here.
emerge -av app-portage/cpuid2cpuflags

#Adding march detect package, but not used too here.
emerge -av app-misc/resolve-march-native

#Updating the stage :
emerge -avuDN @world

#Set locale to FR, Sophora default value.

nano -w /etc/locale.gen
fr_FR.UTF-8 UTF-8
locale-gen
eselect locale set fr_FR.utf8

#Same to keymaps : 

nano -w /etc/conf.d/keymaps
keymap="fr"
env-update && source /etc/profile && export PS1="[chroot] $PS1"

#Changing timezone too :

echo "Europe/Paris" > /etc/timezone
emerge --config sys-libs/timezone-data

#Kernel install (binary) :
mkdir /etc/portage/package.license
echo "sys-kernel/linux-firmware linux-fw-redistributable no-source-code" >> /etc/portage/package.license/linux-firmware

emerge -a linux-firmware
emerge -av sys-kernel/gentoo-kernel-bin

#Networking :

emerge -a --noreplace net-misc/netifrc
emerge -a dhcpcd
emerge -a net-wireless/wpa_supplicant

# Bootloader (grub) :

nano -w /etc/portage/make.conf
GRUB_PLATFORMS="pc efi-64" 
emerge -a grub

# Installing basic complementary packages :

emerge -a app-admin/rsyslog app-admin/logrotate sys-process/cronie net-misc/chrony app-portage/gentoolkit app-portage/portage-utils  app-portage/eix app-shells/bash-completion app-shells/gentoo-bashcomp sys-process/htop eselect-repository dev-vcs/git

# Building cache of eix :

eix-sync 

# Cleaning cache of downloaded packages and history :


rm -rf /var/cache/distfiles/*
history -c

# Exiting chroot

exit 
umount -Rl base

# Creating archive of what we've done :

tar -cvzf sophora-stage-base-0-0-1.tar.gz .