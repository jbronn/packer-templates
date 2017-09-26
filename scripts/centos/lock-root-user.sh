#!/bin/bash -e

# Preventing access to the root acount.
echo '--> Locking root account.'
usermod -L root
