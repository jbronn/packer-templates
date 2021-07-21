#!/bin/bash -e

echo '--> Updating yum packages'

# Update all packages to latest version and then clean up.
yum update -q -y

# Install deltarpm so that future installs can use less network I/O and
# yum-utils because even that's available in the base containers.
yum install -q -y deltarpm yum-utils
