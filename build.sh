#!/bin/bash -e

# Set default action to build a CentOS base box.
BUILDER="${BUILDER:-virtualbox-iso}"
OS="${OS:-centos}"
PROVISIONER="${PROVISIONER:-default}"
POST_PROCESSOR="${POST_PROCESSOR:-vagrant}"

# Determining the OS release to use.
case "${OS}" in
    centos)
        DEFAULT_RELEASE="7.5"
        ;;
    omnios)
        DEFAULT_RELEASE="r151022s"
        ;;
    openbsd)
        DEFAULT_RELEASE="6.3"
        ;;
    ubuntu)
        DEFAULT_RELEASE="bionic"
        ;;
    *)
        echo "Don't know how to build ${OS} yet, exiting."
        exit 1;
        ;;
esac
OS_RELEASE="${OS_RELEASE:-${DEFAULT_RELEASE}}"

# Because Packer uses an array for its builders, we have to use an expression
# to combine the first builders together (we only use one: virtualbox-iso).
# This way we don't  have to define all the redundant information and only
# focus on the commands and scripts that truly differ between platforms.
# The rest of the JSON information is recursively merged together from the
# post-processor file.
jq -M -s \
   '{builders: [(.[0].builders[0] * .[1].builders[0])], provisioners: (.[1].provisioners + .[3].provisioners), variables: (.[0].variables * .[1].variables)} * .[2] * .[4]' \
   builder/$BUILDER.json \
   os/$OS.json \
   os/$OS/$OS_RELEASE.json \
   provisioner/$PROVISIONER.json \
   post-processor/$POST_PROCESSOR.json | \
   packer build "$@" -
