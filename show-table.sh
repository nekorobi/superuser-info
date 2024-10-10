#!/bin/bash
cd ${0%/*}
fields=(Linux sudo sudoers-ALL root-passwd)
for e in ${fields[@]}; do echo -n $e '| '; done | sed -r 's/\s*\|\s*$//'
echo
echo '--|--|--|--'
for file in $(ls example); do
  for e in ${fields[@]}; do
    value=$(sed -r "/^$e:/ ! d; s/^[^:]+: //" example/$file)
    value=$(sed -r 's/^(installed|set)$/✅/' <<<$value)
    value=$(sed -r 's/^(not installed|unset|locked)$/⛔/' <<<$value)
    echo -n $value '| '
  done | sed -r 's/\s*\|\s*$//'
  echo
done
