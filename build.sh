#!/bin/bash -e

# Set default action to build a CentOS base box.
BUILDER="${BUILDER:-virtualbox-iso}"
OS="${OS:-centos}"
POST_PROCESSOR="${POST_PROCESSOR:-vagrant}"
VM_NAME="${VM_NAME:-${OS}-minimal}"

# Determining the OS release to use.
case "${OS}" in
    centos)
        DEFAULT_RELEASE="7.4"
        ;;
    ubuntu)
        DEFAULT_RELEASE="trusty"
        ;;
    *)
        echo "Don't know how to build ${OS} yet, exiting."
        exit 1;
        ;;
esac
OS_RELEASE="${OS_RELEASE:-${DEFAULT_RELEASE}}"

# Because Packer uses an array for its builders, we have to use an expression to combine
# the first builders together (we only use one: virtualbox-iso).  This way we can not
# have to define all the redundant information and only focus on the commands and scripts
# that truly differ between platforms.  The rest of the JSON information is recursively
# merged together from the post-processor file.
jq -M -s \
   '{builders: [(.[0].builders[0] * .[1].builders[0])], provisioners: (.[1].provisioners), variables: (.[0].variables * .[1].variables)} * .[2] * .[3]' \
   builder/$BUILDER.json \
   os/$OS.json \
   os/$OS_RELEASE.json \
   post-processor/$POST_PROCESSOR.json | \
   packer build -var vm_name=$VM_NAME "$@" -
