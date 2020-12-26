#!/bin/sh
set -eu

# Bail if guest extensions ISO wasn't uploaded.
if [ "${VBOXGUEST}" != "upload" ]; then
    exit 0
fi

KERNEL="$(uname -s)"

if [ "${KERNEL}" = "Linux" ]; then
    . /etc/os-release

    # Install the prerequisites necessary to build the guest extensions.
    if [ "${ID}" = "ubuntu" -o "${ID}" = "debian" ]; then
        apt-get -q -y install build-essential dkms
    fi

    if [ "${ID}" = "centos" -o "${ID}" = "rhel" ]; then
        yum install -q -y bzip2 dkms gcc kernel-devel make perl
    fi

    # Mount the VirtualBox guest extensions ISO.
    mkdir -p /media/cdrom
    mount -t iso9660 -o ro -o loop ${HOME}/VBoxGuestAdditions.iso /media/cdrom

    # Install the VirtualBox guest extensions; ignore exit code
    # because no guarantee X is available.
    sh /media/cdrom/VBoxLinuxAdditions.run || true
    umount /media/cdrom
    rmdir /media/cdrom
fi

if [ "${KERNEL}" = "SunOS" ]; then
    # Prevent Solaris package from asking questions interactively.
    cat > /tmp/vboxguest.admin <<EOF
mail=
instance=unique
partial=quit
runlevel=nocheck
idepend=quit
rdepend=quit
space=quit
setuid=nocheck
conflict=nocheck
action=nocheck
basedir=default
EOF
    VBOXGUESTDEV="$(lofiadm -a ${HOME}/VBoxGuestAdditions.iso)"
    mkdir -p /mnt/vboxguest
    mount -o ro -F hsfs ${VBOXGUESTDEV} /mnt/vboxguest
    pkgadd -a /tmp/vboxguest.admin -G -d /mnt/vboxguest/VBoxSolarisAdditions.pkg all
    umount /mnt/vboxguest
    rmdir /mnt/vboxguest
    rm -f /tmp/vboxguest.admin
    lofiadm -d ${VBOXGUESTDEV}
fi

# Remove ISO file.
rm -f ${HOME}/VBoxGuestAdditions.iso
