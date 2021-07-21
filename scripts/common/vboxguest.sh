#!/bin/bash
set -euo pipefail

# Bail if guest extensions ISO wasn't uploaded.
if [ "${VBOXGUEST}" != "upload" ]; then
    exit 0
fi

# Install the prerequisites necessary to build the guest extensions.
if [ -x /usr/bin/yum ]; then
    yum install -q -y bzip2 dkms gcc kernel-devel make perl
else
    apt-get -q -y install build-essential dkms
fi

# Mount the VirtualBox guest extensions ISO.
mkdir -p /media/cdrom
mount -t iso9660 -o ro -o loop $HOME/VBoxGuestAdditions.iso /media/cdrom

# Install the VirtualBox guest extensions; ignore exit code
# because no guarantee X is available.
sh /media/cdrom/VBoxLinuxAdditions.run || true
umount /media/cdrom
rm -f $HOME/VBoxGuestAdditions.iso
rmdir /media/cdrom
