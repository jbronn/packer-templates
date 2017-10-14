#!/bin/bash -e

if [ "${CLOUD_INIT}" != "yes" ]; then
    exit 0
fi

if [ -x /usr/bin/yum ]; then
    yum -q -y install cloud-init cloud-utils-growpart
else
    sudo apt-get -q -y install cloud-init
fi
