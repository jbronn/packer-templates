#!/bin/sh
set -eu

KERNEL="$(uname -s)"

echo '--> Installing rsync'

if [ "$KERNEL" = "OpenBSD" ]; then
    pkg_add rsync--
fi

if [ "$KERNEL" = "SunOS" ]; then
    pkg install rsync
fi
