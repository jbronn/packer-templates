#!/bin/bash -ex

GUEST_LANG="${GUEST_LANG:-en_US.UTF-8}"

echo '--> Cleaning unused locale files'

echo '---> Removing locale (internationalisation) files for unused languages.'
find /usr/share/i18n/locales \
  -type f \
  -regextype posix-extended \
  \( ! -regex ".*\/(en_US|${GUEST_LANG%%.*})(@.+)?$" \
    -a -regex '.*\/[a-z][a-z]([a-z])?_[A-Z][A-Z](@.+)?$' \) \
  -delete

echo '---> Removing locale (translation) files for unused languages.'
find /usr/share/locale \
  -mindepth 1 \
  -maxdepth 1 \
  -type d \
  -regextype posix-extended \
  ! -regex ".*\/(en|en_US|${GUEST_LANG%%_*}|${GUEST_LANG%%.*})(@.+)?$" \
  -exec find -- {} -type f -name "*.mo" -delete \;

echo '--> Cleaning virtual-guest.'

echo '---> Purging temporary directories.'
rm -rf /{root,tmp,var/cache/{ldconfig,yum}}/*

echo '---> Rebuilding RPM DB.'
rpm --rebuilddb

echo '---> Removing SSH host keys.'
rm -f /etc/ssh/ssh_host_*

echo '---> Removing machine-id.'
  :> /etc/machine-id
