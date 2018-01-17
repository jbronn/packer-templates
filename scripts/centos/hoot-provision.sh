#!/bin/bash -e

sudo yum -q -y install git
cd ../home/vagrant
git clone https://github.com/ngageoint/hootenanny -b develop hoot
sudo chown -R vagrant:vagrant hoot
cd hoot
pwd
su vagrant -c "./VagrantProvisionCentOS7.sh"
