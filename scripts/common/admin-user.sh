#!/bin/sh
set -eu

ADMIN_SUDO="${ADMIN_SUDO:-yes}"
ADMIN_USER="${ADMIN_USER:-vagrant}"
ADMIN_GROUP="${ADMIN_GROUP:-$ADMIN_USER}"
ADMIN_GROUPS="${ADMIN_GROUPS:-}"
ADMIN_USER_AUTHORIZED_KEYS="${ADMIN_USER_AUTHORIZED_KEYS:-}"
ADMIN_USER_PASSWORD="${ADMIN_USER_PASSWORD:-vagrant}"
ADMIN_USER_SHELL="${ADMIN_USER_SHELL:-/bin/bash}"
ADMIN_USER_HOME="${ADMIN_USER_HOME:-/home/$ADMIN_USER}"
KERNEL="$(uname -s)"

echo '--> Adding admin user.'

if [ "$KERNEL" = "Linux" ]; then
    useradd -m -d "$ADMIN_USER_HOME" -s "$ADMIN_USER_SHELL" "$ADMIN_USER"
    echo '---> Setting password.'
    echo "${ADMIN_USER}:${ADMIN_USER_PASSWORD}" | chpasswd

    LSB_DIST="$(. /etc/os-release && echo "$ID")"
    if [ "$LSB_DIST" = 'centos' ] || [ "$LSB_DIST" = 'fedora' ] || [ "$LSB_DIST" = 'rhel' ]; then
        ADMIN_GROUPS="${ADMIN_GROUPS:-adm,systemd-journal,wheel}"
    elif [ "$LSB_DIST" = 'debian' ] || [ "$LSB_DIST" = 'ubuntu' ]; then
        ADMIN_GROUPS="${ADMIN_GROUPS:-adm}"
    fi
    if [ -n "$ADMIN_GROUPS" ]; then
        echo '---> Setting groups.'
        usermod -a -G "$ADMIN_GROUPS" "$ADMIN_USER"
    fi
fi

if [ "$KERNEL" = "OpenBSD" ]; then
    useradd -m -d "$ADMIN_USER_HOME" -s "$ADMIN_USER_SHELL" -p "$(encrypt "$ADMIN_USER_PASSWORD")" "$ADMIN_USER"
    echo '---> Configuring admin user doas access.'
    echo "permit nopass keepenv $ADMIN_USER" > /etc/doas.conf
    chmod 0640 /etc/doas.conf
fi

if [ "$KERNEL" = "SunOS" ]; then
    ADMIN_DIRNAME="$(dirname "$ADMIN_USER_HOME")"
    mkdir -p "$ADMIN_DIRNAME"
    useradd -m -g "$ADMIN_GROUP" -b "$ADMIN_DIRNAME" -s "$ADMIN_USER_SHELL" "$ADMIN_USER"
    # TODO: Can't actually set password interactively.
    passwd -N "$ADMIN_USER"
fi

echo '---> Populating authorized_keys.'
mkdir -pm 0700 "$ADMIN_USER_HOME/.ssh"
echo "$ADMIN_USER_AUTHORIZED_KEYS" > "$ADMIN_USER_HOME/.ssh/authorized_keys"
chown -R "$ADMIN_USER:$ADMIN_GROUP" "$ADMIN_USER_HOME/.ssh"
chmod 0600 "$ADMIN_USER_HOME/.ssh/authorized_keys"

if [ -x /usr/sbin/restorecon ]; then
    echo '---> Restoring SELinux context.'
    restorecon -R "$ADMIN_USER_HOME/.ssh"
fi

if [ "$ADMIN_SUDO" = "yes" ]; then
    if [ "$KERNEL" = "OpenBSD" ]; then
        echo '---> Installing sudo'
        pkg_add sudo--
        echo '---> Configuring admin user sudo access.'
        echo "$ADMIN_USER ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
    else
        echo '---> Configuring admin user sudo access.'
        echo "$ADMIN_USER ALL=(ALL:ALL) NOPASSWD: ALL" > "/etc/sudoers.d/$ADMIN_USER"
        chmod 0440 "/etc/sudoers.d/$ADMIN_USER"
    fi
fi
