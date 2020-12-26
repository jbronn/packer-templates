#!/bin/bash
set -euo pipefail

echo -n "Waiting for cloud-init"
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do
    echo -n "."
    sleep 1
done
