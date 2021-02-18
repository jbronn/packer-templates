#!/bin/bash
set -euo pipefail
CLOUD_INIT="${CLOUD_INIT:-no}"

if [ "${CLOUD_INIT}" = "no" ]; then
    exit 0
fi

if [ "${CLOUD_INIT}" = "disable" ]; then
    systemctl disable cloud-config
    systemctl disable cloud-final
    systemctl disable cloud-init-local
    exit 0
fi

if [ -x /usr/bin/yum ]; then
    yum -q -y install cloud-init cloud-utils-growpart
else
    sudo apt-get -q -y install cloud-init
fi
