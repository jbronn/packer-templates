#!/bin/bash -e

# Set default action to build a CentOS 7 Vagrant base box.
BUILDER="${BUILDER:-virtualbox-iso}"
OS="${OS:-centos7}"
POST_PROCESSOR="${POST_PROCESSOR:-vagrant}"
VM_NAME="${BUILD_NAME:-${OS}-minimal}"

# Because Packer uses an array for its builders, we have to use an expression to combine
# the first builders together (we only use one: virtualbox-iso).  This way we can not
# have to define all the redundant information and only focus on the commands and scripts
# that truly differ between platforms.  The rest of the JSON information is recursively
# merged together from the post-processor file.
jq -M -s \
   '{builders: [(.[0].builders[0] * .[1].builders[0])], variables: (.[0].variables * .[1].variables)} * .[2]' \
   builder/virtualbox-iso.json \
   os/$OS.json \
   post-processor/$POST_PROCESSOR.json | \
   packer build -var vm_name=$VM_NAME "$@" -
