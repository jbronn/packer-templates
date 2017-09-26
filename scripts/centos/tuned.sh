#!/bin/bash -e

echo '--> Setting tuned profile to virtual-guest'
tuned-adm profile virtual-guest
