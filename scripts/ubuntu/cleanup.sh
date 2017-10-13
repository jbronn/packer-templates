#!/bin/bash
set -ex

echo '--> Cleaning virtual-guest.'

# Clean out any cached interfaces.
rm -f /etc/udev/rules.d/70-persistent-net.rules

echo '---> Cleaning apt.'
# Remove any Linux kernel packages that we aren't using to boot.
dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | xargs apt-get -y purge

# Clean out apt cache, lists, and autoremove any packages.
rm -f /var/lib/apt/lists/lock
rm -f /var/lib/apt/lists/*_*
rm -f /var/lib/apt/lists/partial/*
apt-get -y autoremove
apt-get -y clean

echo '---> Purging temporary directories.'
find /{root,tmp,var/cache} -type f -delete

echo '---> Removing SSH host keys.'
rm -f /etc/ssh/ssh_host_*

echo '---> Stopping logging services.'
if [ "$(lsb_release -c -s)" = "trusty" ]; then
    stop rsyslog
else
    systemctl stop rsyslog.service
fi

echo '---> Truncate log files.'
find /var/log -name \*.gz -o -name \*.dat -delete
find /var/log -type f -exec truncate -s 0 {} \;

