#!/bin/bash
# superuser-info.sh
# MIT License © 2024 Nekorobi
version=1.0.0
LANG=C  script=$(readlink -e "$BASH_SOURCE")
# sudoers: ALL=ALL, ALL=(ALL)ALL, ALL=(ALL:ALL)ALL
reALL='^\s*%?\S+\s+ALL\s*=\s*(\(\s*ALL(\s*:\s*ALL)?\s*\))?\s*ALL(\s*|\s+#.*)$'

if [[ $1 =~ ^(-V|--version)$ ]]; then echo superuser-info.sh v$version; exit; fi

sudoExists() { type sudo >/dev/null 2>&1; }
canSudo() {
  sudoExists || return 1
  # NOPASSWD: status 0, ''
  # privileged: status 1, 'password is required'
  # unprivileged: status 1, 'may not run sudo'
  local result; result=$(LANG=C sudo --validate -kn 2>&1)
  [[ $? = 0 || ($? = 1 && $result =~ 'password is required') ]] || return 2
  sudo --list -u root "$@" >/dev/null 2>&1 || return 3
}
adminRun() { # --debug
  if [[ $(id -u) = 0 ]]; then
    "$@"
  elif canSudo "$@"; then
    sudo --login -u root "$@"
  else
    su --login -c '"$@"' root -- arg0 "$@" # arg0 is treated as filename
  fi
}
# Rerun this script as a superuser
if [[ $(id -u) != 0 ]]; then adminRun "$script" "$@"; exit $?; fi

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
  local p=$(passwd --status root | awk '{print $2}') # L|NP|P
  if [[ $p = P ]]; then echo set; elif [[ $p = L ]]; then echo locked; else echo unset; fi
}

infoLinux; infoSudo; infoRoot
