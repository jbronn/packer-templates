#!/bin/bash -ex

echo '--> Updating yum packages'

# Update all packages to latest version and then clean up.
yum update -q -y

# Install deltarpm so that future installs can use less network I/O.
yum install -q -y deltarpm
