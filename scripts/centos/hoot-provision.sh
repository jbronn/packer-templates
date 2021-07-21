#!/bin/bash
set -euo pipefail
HOOT_BRANCH="${HOOT_BRANCH:-master}"
HOOT_REPO="${HOOT_REPO:-https://github.com/ngageoint/hootenanny}"
yum -q -y install git
su -l vagrant -c "git clone -b ${HOOT_BRANCH} ${HOOT_REPO} hoot"
su -l vagrant -c "./hoot/VagrantProvisionCentOS7.sh"
