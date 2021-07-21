#!/bin/bash
set -euo pipefail

echo '--> Setting tuned profile to virtual-guest'
tuned-adm profile virtual-guest
