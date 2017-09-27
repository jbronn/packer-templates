#!/bin/bash -e

# Bail if we don't really want to install the guest extensions.
if [ "${VBOXGUEST}" = "disabled" ]; then
    exit 0
fi

# Install the prerequisites necessary to build the guest extensions.
yum install -q -y bzip2 dkms gcc kernel-devel make perl

# Mount the VirtualBox guest extensions ISO.
mkdir -p /media/cdrom
mount -t iso9660 -o ro -o loop "$HOME/VBoxGuestAdditions.iso" /media/cdrom

# Install the VirtualBox guest extensions.
#  (because X isn't available ignore exit code)
sh /media/cdrom/VBoxLinuxAdditions.run || true
umount /media/cdrom
rm -f $HOME/VBoxGuestAdditions.iso
rmdir /media/cdrom
