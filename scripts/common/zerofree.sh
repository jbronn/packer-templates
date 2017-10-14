#!/bin/bash -e
echo '--> Zero out free space on disks.'

DD_BLOCKSIZE="${DD_BLOCKSIZE:-1M}"
DD_STATUS="${DD_STATUS:-none}"
SWAP_UUID="$(blkid -l -o value -s UUID -t TYPE=swap || true)"

if [ -z "${SWAP_UUID}" ]; then
    echo '---> Skipping, no swap device.'
else
    echo '---> Zero out swap.'
    SWAP_DEVICE=/dev/disk/by-uuid/$SWAP_UUID

    swapoff -a
    dd if=/dev/zero of=$SWAP_DEVICE bs=$DD_BLOCKSIZE status=$DD_STATUS || true
    mkswap -f $SWAP_DEVICE
fi

if lsblk -n -o MOUNTPOINT | grep -q '^/boot$'; then
    echo '---> Zero out /boot.'
    dd if=/dev/zero of=/boot/boot.zero bs=$DD_BLOCKSIZE status=$DD_STATUS || true
    rm -f /boot/boot.zero
fi

echo '---> Zero out /.'
dd if=/dev/zero of=/root.zero bs=$DD_BLOCKSIZE status=$DD_STATUS || true
rm -f /root.zero
