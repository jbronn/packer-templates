#!/bin/bash -e

if [ "${CLOUD_INIT}" != "yes" ]; then
    exit 0
fi

if [ -x /usr/bin/yum ]; then
    yum -q -y install cloud-init cloud-utils-growpart
else
    export APT_LISTBUGS_FRONTEND=none
    export APT_LISTCHANGES_FRONTEND=none
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get -y install cloud-init
fi
