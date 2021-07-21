#!/bin/bash
set -euo pipefail

echo '--> Performing post-install network configuration and cleanup.'

echo '---> Replacing network configuration name to device.'
sed -i \
  -e 's~^NAME="eth\([0-9][0-9]*\)"$~DEVICE="eth\1"~' \
  /etc/sysconfig/network-scripts/ifcfg-eth*

echo '---> Generalising hostname.'
sed -i \
  -e 's~^HOSTNAME=.*$~HOSTNAME=localhost.localdomain~g' \
  /etc/sysconfig/network

echo '---> Removing udev rules.'
rm -rf /etc/udev/rules.d/70-*

echo '---> Generalising network device configuration.'
sed -i \
  -e 's~^DHCP_HOSTNAME=.*$~DHCP_HOSTNAME="localhost.localdomain"~' \
  -e '/^HWADDR=/d' \
  -e '/^UUID=/d' \
  /etc/sysconfig/network-scripts/ifcfg-eth*
