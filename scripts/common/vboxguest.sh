#!/bin/bash -e

# Bail if we don't really want to install the guest extensions.
if [ "${VBOXGUEST}" = "disable" ]; then
    exit 0
fi

# Install the prerequisites necessary to build the guest extensions.
if [ -x /usr/bin/yum ]; then
    yum install -q -y bzip2 dkms gcc kernel-devel make perl
else
    export APT_LISTBUGS_FRONTEND=none
    export APT_LISTCHANGES_FRONTEND=none
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get -y install build-essential dkms secure-delete
fi

# Mount the VirtualBox guest extensions ISO.
mkdir -p /media/cdrom
mount -t iso9660 -o ro -o loop "$HOME/VBoxGuestAdditions.iso" /media/cdrom

# Install the VirtualBox guest extensions.
#  (because X isn't available ignore exit code)
sh /media/cdrom/VBoxLinuxAdditions.run || true
umount /media/cdrom
rm -f $HOME/VBoxGuestAdditions.iso
rmdir /media/cdrom
