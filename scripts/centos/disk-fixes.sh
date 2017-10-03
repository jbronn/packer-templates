#!/bin/bash -ex

# I've encountered issues with anaconda writing the wrong UUIDs to the system
# fstab when the `autopart --type=`plain` kickstart command.  This causes a
# very long boot delay as the system scrambles to find the correct partitions.
# Moreover, anaconda uses the wrong value (0) for the sixth field (`fs_passno`).
# This script rewrites `/etc/fstab` to contain the correct UUIDs and sets the
# `fs_passno` to 1 for the root filesystem.
if [ "${DISK_TYPE}" = "plain" ]; then
    # Use `lsblk` to get the UUIDs and filesystems for the partitions used
    # in the 'plain' partition type (/boot on sda1, swap on sda2, / on sda3).
    BOOT_FS="$(lsblk -o FSTYPE -n /dev/sda1)"
    BOOT_UUID="$(lsblk -o UUID -n /dev/sda1)"
    SWAP_UUID="$(lsblk -o UUID -n /dev/sda2)"
    ROOT_FS="$(lsblk -o FSTYPE -n /dev/sda3)"
    ROOT_UUID="$(lsblk -o UUID -n /dev/sda3)"

    cat > /etc/fstab <<-EOF
UUID=${BOOT_UUID}	/boot	${BOOT_FS}	defaults	0 0
UUID=${SWAP_UUID}	swap	swap	defaults	0 0
UUID=${ROOT_UUID}	/	${ROOT_FS}	defaults	0 1
EOF
fi
