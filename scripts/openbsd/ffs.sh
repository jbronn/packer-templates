#!/bin/sh
set -eu

echo '--> Optimize FFS filesystems'

# Add softdep,noatime to all FFS mounts, except /.
sed -i -e 's/ ffs rw,/ ffs rw,softdep,noatime,/g' /etc/fstab

# Add softdep,noatime to / FFS mount.
sed -i -e 's/ ffs rw / ffs rw,softdep,noatime /g' /etc/fstab
