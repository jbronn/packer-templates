#!/bin/bash
set -euo pipefail

ADMIN_USER="${ADMIN_USER:-vagrant}"
ADMIN_USER_AUTHORIZED_KEYS="${ADMIN_USER_AUTHORIZED_KEYS:-}"
ADMIN_USER_PASSWORD="${ADMIN_USER_PASSWORD:-vagrant}"
ADMIN_USER_SHELL="${ADMIN_USER_SHELL:-/bin/bash}"
ADMIN_USER_HOME="/home/${ADMIN_USER}"

echo '--> Adding admin user.'
useradd -m -d ${ADMIN_USER_HOME} -s ${ADMIN_USER_SHELL} ${ADMIN_USER}

echo '---> Setting password.'
echo "${ADMIN_USER}:${ADMIN_USER_PASSWORD}" | chpasswd

echo '---> Populating authorized_keys.'
mkdir -pm 0700 ${ADMIN_USER_HOME}/.ssh
echo "${ADMIN_USER_AUTHORIZED_KEYS}" > ${ADMIN_USER_HOME}/.ssh/authorized_keys
chown -R ${ADMIN_USER}:${ADMIN_USER} ${ADMIN_USER_HOME}/.ssh
chmod 0600 ${ADMIN_USER_HOME}/.ssh/authorized_keys

if [ -x /usr/sbin/restorecon ]; then
    echo '---> Restoring SELinux context.'
    restorecon -R ${ADMIN_USER_HOME}/.ssh
fi
    
echo '---> Configuring admin user sudo access.'
echo "${ADMIN_USER} ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/${ADMIN_USER}
chmod 0440 /etc/sudoers.d/${ADMIN_USER}
