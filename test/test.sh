#!/bin/bash
cd ${0%/*}
[[ $(id -u) = 0 || $debug ]] || exit 1
[[ $(../superuser-info.sh | md5sum | sed -r 's/\s+.*$//') = \
  $(md5sum ../example/ubuntu-24.04.txt | sed -r 's/\s+.*$//') ]] || exit 2
echo success: test.sh
