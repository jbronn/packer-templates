#!/bin/bash -e

SSHD_CONFIG="${SSHD_CONFIG:-/etc/ssh/sshd_config}"

echo '--> Configuring SSHD.'
sed -i \
  -e 's~^PasswordAuthentication yes~PasswordAuthentication no~g' \
  -e 's~^#PermitRootLogin yes~PermitRootLogin no~g' \
  -e 's~^#UseDNS yes~UseDNS no~g' \
  $SSHD_CONFIG
