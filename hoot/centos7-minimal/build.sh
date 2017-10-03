#!/bin/bash -ex

BUILD_TYPE="${BUILD_TYPE:-vagrant}"

# Use `jq` to merge the base centos7 template with the proper variables
# and post-processors.
jq -M -s '.[0] * .[1]' \
   os/centos7.json \
   hoot/centos7-minimal/$BUILD_TYPE.json | \
   packer build "$@" -
