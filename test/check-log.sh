#!/bin/bash

# this is a helper script to work around issue with grep exit codes
# in `set -e` environments like GitHub Actions CI

cat "$1" | grep "$2" ; test $? -eq 1
