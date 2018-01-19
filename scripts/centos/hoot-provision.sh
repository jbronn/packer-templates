#!/bin/bash
set -euo pipefail

yum -q -y install git
su -l vagrant -c "git clone -b develop https://github.com/ngageoint/hootenanny hoot"
su -l vagrant -c "./hoot/VagrantProvisionCentOS7.sh"
