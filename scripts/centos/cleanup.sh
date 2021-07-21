#!/bin/bash
set -euo pipefail

GUEST_LANG="${GUEST_LANG:-en_US.UTF-8}"

echo '--> Cleaning virtual-guest.'

echo '---> Cleaning yum.'
yum clean all

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

echo '---> Purging temporary directories.'
rm -rf /{root,tmp,var/cache/{ldconfig,yum}}/*

echo '---> Removing SSH host keys.'
rm -f /etc/ssh/ssh_host_*

echo '---> Removing machine-id.'
  :> /etc/machine-id

echo '---> Stopping logging services.'
#systemctl stop auditd.service
systemctl stop rsyslog.service

echo '---> Truncate log files.'
find /var/log -type f -exec truncate -s 0 {} \;
