#!/bin/bash -ex
SSHD_CONFIG="${SSHD_CONFIG:-/etc/ssh/sshd_config}"

# Configure SSH to:
#  1. Only allow public key authentication, no passwords are allowed.
#  2. Disable root login.
#  3. Disable rDNS lookups of clients.
#  4. Disable use of DSA host keys.
echo '--> Configuring SSHD.'
sed -i \
    -e 's/^\#\?\(PasswordAuthentication \(yes\|no\)\)/PasswordAuthentication no/g' \
    -e 's/^\#\?\(PermitRootLogin \(yes\|no\)\)/PermitRootLogin no/g' \
    -e '/^HostKey \/etc\/ssh\/ssh_host_dsa_key/d' \
    -e '/^\#\?\(UseDNS \(yes\|no\)\)/d'

# `UseDNS` config needs to be added as not available in default config on Ubuntu.
echo "\nUseDNS no" >> $SSHD_CONFIG

# Upstart script on Ubuntu 14.04 to automatically generate SSH keys.
if [ "$(lsb_release -s -c)" = "trusty" ]; then
    cat > /etc/init/ssh-keygen.conf <<-EOF
description "OpenSSH HostKey Generation"

start on starting ssh

task

script
  if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
  fi
  if [ ! -f /etc/ssh/ssh_host_ecdsa_key ]; then
    ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa
  fi
  if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
    ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -N '' -t ed25519
  fi
end script
EOF
fi
