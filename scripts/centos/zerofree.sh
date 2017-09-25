#!/bin/bash -ex

SWAP_DEVICE=$(
  sudo readlink -f /dev/disk/by-uuid/$(
    sudo blkid -l -o value -s UUID -t TYPE=swap
  )
)

echo '--> Zero out and reset swap.'
if [[ ${SWAP_DEVICE} == /dev/disk/by-uuid ]]; then
  echo '---> Skipping (No swap device).'
else
  sudo swapoff -a
  sudo dd if=/dev/zero of=${SWAP_DEVICE} bs=1M || true
  sudo mkswap -f ${SWAP_DEVICE}
fi

echo '--> Zero out any remaining free disk space.'
sudo dd if=/dev/zero of=/boot/boot.zero bs=1M || true
sudo dd if=/dev/zero of=/root.zero bs=1M || true
sudo rm -f /boot/boot.zero
sudo rm -f /root.zero
