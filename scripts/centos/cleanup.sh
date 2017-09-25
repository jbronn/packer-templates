#!/bin/bash -ex

GUEST_LANG="${GUEST_LANG:-en_US.UTF-8}"

echo '--> Removing locale (internationalisation) files for unused languages.'
sudo find /usr/share/i18n/locales \
  -type f \
  -regextype posix-extended \
  \( ! -regex ".*\/(en_US|${GUEST_LANG%%.*})(@.+)?$" \
    -a -regex '.*\/[a-z][a-z]([a-z])?_[A-Z][A-Z](@.+)?$' \) \
  -delete

echo '--> Cleaning virtual-guest.'

echo '---> Purging temporary directories.'
sudo rm -rf /{root,tmp,var/cache/{ldconfig,yum}}/*

echo '---> Rebuilding RPM DB.'
sudo rpm --rebuilddb

echo '---> Removing SSH host keys.'
sudo rm -f /etc/ssh/ssh_host_*

echo '---> Generalising hostname.'
sudo sed -i \
  -e 's~^HOSTNAME=.*$~HOSTNAME=localhost.localdomain~g' \
  /etc/sysconfig/network

echo '---> Removing udev rules.'
sudo rm -rf /etc/udev/rules.d/70-*

echo '---> Generalising network device configuration.'
sudo sed -i \
  -e 's~^DHCP_HOSTNAME=.*$~DHCP_HOSTNAME="localhost.localdomain"~' \
  -e '/^HWADDR=/d' \
  -e '/^UUID=/d' \
  /etc/sysconfig/network-scripts/ifcfg-eth*

echo '---> Removing machine-id.'
sudo bash -c ":> /etc/machine-id"
