#!/bin/bash -e

SWAP_DEVICE=$(
  readlink -f /dev/disk/by-uuid/$(
    blkid -l -o value -s UUID -t TYPE=swap
  )
)

echo '--> Zero out disks.'

if [[ ${SWAP_DEVICE} == /dev/disk/by-uuid ]]; then
  echo '---> Skipping (No swap device).'
else
  echo '---> Zero out swap.'
  swapoff -a
  dd if=/dev/zero of=${SWAP_DEVICE} bs=1M || true
  mkswap -f ${SWAP_DEVICE}
fi

echo '---> Zero out /boot and /.'
dd if=/dev/zero of=/boot/boot.zero bs=1M || true
dd if=/dev/zero of=/root.zero bs=1M || true
rm -f /boot/boot.zero
rm -f /root.zero
