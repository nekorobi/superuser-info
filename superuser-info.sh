#!/bin/bash
# superuser-info.sh
# MIT License © 2024 Nekorobi
version=1.0.0
LANG=C  script=$(readlink -e "$BASH_SOURCE")
unset args reALL; declare -a args
args=("$@")
# sudoers: ALL=ALL, ALL=(ALL)ALL, ALL=(ALL:ALL)ALL
reALL='^\s*%?\S+\s+ALL\s*=\s*(\(\s*ALL(\s*:\s*ALL)?\s*\))?\s*ALL(\s*|\s+#.*)$'

suThisScript() { su --login -c '"$@"' root -- arg1 "$script" "${args[@]}"; } # arg1 is treated as filename
sudoThisScript() { sudo --login -u root "$script" "${args[@]}"; }
sudoExists() { type sudo >/dev/null 2>&1; }
canSudo() {
  # NOPASSWD: status 0, ''
  # privileged: status 1, 'password is required'
  # unprivileged: status 1, 'may not run sudo'
  local result; result=$(sudo --validate -kn 2>&1)
  [[ $? = 0 || ($? = 1 && $result =~ 'password is required') ]]
}
canSudoScript() { sudo --list -u root "$script" "${args[@]}" >/dev/null 2>&1; }

infoLinux() {
  echo Linux: $(sed '/^ID=/ ! d; s/^ID=//; s/"//g' /etc/os-release) \
    $(sed '/^VERSION_ID=/ ! d; s/^VERSION_ID=//; s/"//g' /etc/os-release)
}
infoSudo() {
  if sudoExists; then
    echo sudo: installed
    echo sudoers-ALL: $(grep -E "$reALL" /etc/sudoers | awk '{print $1}')
  else
    echo sudo: not installed
  fi
}
infoRoot() {
  echo -n 'root-passwd: '
  local p=$(passwd --status root | awk '{print $2}')
  if [[ $p = P ]]; then echo set; elif [[ $p = L ]]; then echo locked; else echo unset; fi
}

if [[ $1 =~ ^(-V|--version)$ ]]; then echo superuser-info.sh v$version; exit; fi
# Rerun this script as a superuser
if [[ $(id -u) != 0 ]]; then
  if sudoExists && canSudo && canSudoScript; then sudoThisScript; else suThisScript; fi
  exit $?
fi

infoLinux
infoSudo
infoRoot
