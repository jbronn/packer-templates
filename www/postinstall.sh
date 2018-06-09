#!/bin/sh -e

export APT_LISTBUGS_FRONTEND=none
export APT_LISTCHANGES_FRONTEND=none
export DEBIAN_FRONTEND=noninteractive
export KERNEL_PACKAGE="${1:-linux-generic}"

# No need for deb-src (2x http hits on `apt-get update`).
sed -i /^deb-src/d /etc/apt/sources.list

# Enable root login temporarily.
sed -i \
    -e 's~^\#\?PermitRootLogin \(prohibit\|without\)-password~PermitRootLogin yes~g' \
    /etc/ssh/sshd_config

apt-get -y update
apt-get -y -o DPkg::Options="--force-confold" upgrade
apt-get -y install $KERNEL_PACKAGE
