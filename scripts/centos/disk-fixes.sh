#!/bin/bash -e

# For "plain" disks (those for AWS), we want to remove the swap partition
# and rewrite /etc/fstab.
if [ "${DISK_TYPE}" = "plain" ]; then
    echo '--> Disabling swap.'
    swapoff -a

    echo '--> Removing swap from /etc/fstab.'
    # Use `lsblk` to get the UUIDs and filesystems for the partitions used
    # in the 'plain' partition type (/boot on sda1, / on sda2, swap on sda3).
    BOOT_FS="$(lsblk -o FSTYPE -n /dev/sda1)"
    BOOT_UUID="$(lsblk -o UUID -n /dev/sda1)"
    ROOT_FS="$(lsblk -o FSTYPE -n /dev/sda2)"
    ROOT_UUID="$(lsblk -o UUID -n /dev/sda2)"
    cat > /etc/fstab <<-EOF
UUID=${BOOT_UUID}	/boot	${BOOT_FS}	defaults	0 0
UUID=${ROOT_UUID}	/	${ROOT_FS}	defaults	0 1
EOF

    echo '--> Deleting the swap partition.'
    parted /dev/sda rm 3
fi
