#!/bin/bash
set -eu
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
    -e 's/^\#\?\(PubkeyAuthentication \(yes\|no\)\)/PubkeyAuthentication yes/g' \
    -e '/^HostKey \/etc\/ssh\/ssh_host_dsa_key/d' \
    -e '/^\#\?\(UseDNS \(yes\|no\)\)/d' \
    $SSHD_CONFIG

# `UseDNS` config needs to be added as not available in default config on Ubuntu.
printf "\nUseDNS no\n" >> $SSHD_CONFIG

if [ -f /etc/os-release ]; then
    source /etc/os-release
    if [ "$NAME" = "Ubuntu" ]; then
        # Upstart script on Ubuntu 14.04 to automatically generate SSH keys.
        if [ "$VERSION_CODENAME" = "trusty" ]; then
            cat > /etc/init/ssh-keygen.conf <<EOF
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
        # Systemd unit on Ubuntu 18.04 to automatically generate SSH keys.
        if [ "$VERSION_CODENAME" = "bionic" ]; then
            cat > /lib/systemd/system/ssh-keygen.service <<EOF
[Unit]
Description=OpenSSH Server Key Generation
ConditionFileNotEmpty=|!/etc/ssh/ssh_host_rsa_key
ConditionFileNotEmpty=|!/etc/ssh/ssh_host_ecdsa_key
ConditionFileNotEmpty=|!/etc/ssh/ssh_host_ed25519_key
Before=ssh.service
PartOf=ssh.service ssh.socket

[Service]
Type=oneshot
ExecStart=/usr/bin/ssh-keygen -A
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
            # Enable ssh-keygen service.
            systemctl daemon-reload
            systemctl enable ssh-keygen
        fi
    fi
fi
