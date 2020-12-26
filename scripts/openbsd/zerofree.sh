#!/bin/sh
set -eu
echo '--> Zero out free space on disks.'

DD_BLOCKSIZE="${DD_BLOCKSIZE:-1M}"
DD_STATUS="${DD_STATUS:-none}"
MOUNTPOINTS="$(mount | awk '{ if ( $5 == "ffs" ) { print $3 } }')"

for mountpoint in ${MOUNTPOINTS}; do
    echo "---> Zero out ${mountpoint}."
    dd if=/dev/zero of="${mountpoint}/ffs.zero" bs=${DD_BLOCKSIZE} status=${DD_STATUS} || true
    rm -f "${mountpoint}/ffs.zero"
done
