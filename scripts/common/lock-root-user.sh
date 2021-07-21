#!/bin/bash
set -euo pipefail

# Preventing access to the root acount.
echo '--> Locking root account.'
usermod -L root
