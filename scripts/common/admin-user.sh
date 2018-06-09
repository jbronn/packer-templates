#!/bin/sh
set -eu

ADMIN_SUDO="${ADMIN_SUDO:-yes}"
ADMIN_USER="${ADMIN_USER:-vagrant}"
ADMIN_USER_AUTHORIZED_KEYS="${ADMIN_USER_AUTHORIZED_KEYS:-}"
ADMIN_USER_PASSWORD="${ADMIN_USER_PASSWORD:-vagrant}"
ADMIN_USER_SHELL="${ADMIN_USER_SHELL:-/bin/bash}"
ADMIN_USER_HOME="/home/$ADMIN_USER"


KERNEL="$(uname -s)"
if [ "$KERNEL" = "Linux" ]; then
    echo '--> Adding admin user.'
    useradd -m -d "$ADMIN_USER_HOME" -s "$ADMIN_USER_SHELL" $ADMIN_USER
    echo '---> Setting password.'
    echo "${ADMIN_USER}:${ADMIN_USER_PASSWORD}" | chpasswd
fi

if [ "$KERNEL" = "OpenBSD" ]; then
    echo '--> Adding admin user.'
    useradd -m -d "$ADMIN_USER_HOME" -s "$ADMIN_USER_SHELL" -p "$(encrypt $ADMIN_USER_PASSWORD)" $ADMIN_USER

    echo '---> Configuring admin user doas access.'
    echo "permit nopass keepenv $ADMIN_USER" > /etc/doas.conf
    chmod 0640 /etc/doas.conf
fi

echo '---> Populating authorized_keys.'
mkdir -pm 0700 "$ADMIN_USER_HOME/.ssh"
echo "$ADMIN_USER_AUTHORIZED_KEYS" > "$ADMIN_USER_HOME/.ssh/authorized_keys"
chown -R $ADMIN_USER:$ADMIN_USER "$ADMIN_USER_HOME/.ssh"
chmod 0600 "$ADMIN_USER_HOME/.ssh/authorized_keys"

if [ -x /usr/sbin/restorecon ]; then
    echo '---> Restoring SELinux context.'
    restorecon -R $ADMIN_USER_HOME/.ssh
fi

if [ "$ADMIN_SUDO" = "yes" ]; then
    if [ "$KERNEL" = "OpenBSD" ]; then
        echo '---> Installing sudo'
        pkg_add sudo--
        echo '---> Configuring admin user sudo access.'
        echo "$ADMIN_USER ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
    else
        echo '---> Configuring admin user sudo access.'
        echo "$ADMIN_USER ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/$ADMIN_USER
        chmod 0440 /etc/sudoers.d/$ADMIN_USER
    fi
fi
