#!/bin/bash -e

SSH_USER="${SSH_USER:-vagrant}"
SSH_USER_AUTHORIZED_KEYS="${SSH_USER_AUTHORIZED_KEYS:-}"
SSH_USER_PASSWORD="${SSH_USER_PASSWORD:-vagrant}"
SSH_USER_SHELL="${SSH_USER_SHELL:-/bin/bash}"
SSH_USER_HOME="/home/${SSH_USER}"

echo '--> Adding SSH user.'
useradd \
  -m \
  -d ${SSH_USER_HOME} \
  -s ${SSH_USER_SHELL} \
  ${SSH_USER}

echo '---> Setting password.'
echo "${SSH_USER}:${SSH_USER_PASSWORD}" | chpasswd

echo '---> Populating authorized_keys.'
mkdir -pm 0700 ${SSH_USER_HOME}/.ssh
echo "${SSH_USER_AUTHORIZED_KEYS}" > ${SSH_USER_HOME}/.ssh/authorized_keys
chown -R ${SSH_USER}:${SSH_USER} ${SSH_USER_HOME}/.ssh
chmod 0600 ${SSH_USER_HOME}/.ssh/authorized_keys

echo '---> Restoring SELinux context'
restorecon -R ${SSH_USER_HOME}/.ssh

echo '--> Configuring sudoer access.'
echo "${SSH_USER} ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/${SSH_USER}
chmod 0440 /etc/sudoers.d/${SSH_USER}
