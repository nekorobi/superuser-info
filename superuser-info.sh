#!/bin/bash
# superuser-info.sh
# MIT License © 2024 Nekorobi
version=v1.0.1
script=$(readlink -e "$BASH_SOURCE")
unset debug args reALL
args=("$@")
# sudoers: ALL=ALL, ALL=(ALL)ALL, ALL=(ALL:ALL)ALL
reALL='^\s*%?\S+\s+ALL\s*=\s*(\(\s*ALL(\s*:\s*ALL)?\s*\))?\s*ALL(\s*|\s+#.*)$'

while [[ $# -gt 0 ]]; do
  case "$1" in
  --debug)        debug=on; shift 1;;
  -V|--version)   echo superuser-info.sh $version; exit 0;;
  # invalid
  -*) error "$1: unknown option";;
  # Operand
  *) error "$1: unknown argument";;
  esac
done

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
rootRun() {
  if [[ $(id -u) = 0 ]]; then
    "$@"
  elif canSudo "$@"; then
    [[ $debug ]] && echo sudo --login -u root "$@" 1>&2
    sudo --login -u root "$@"
  else
    [[ $debug ]] && echo su --login -c '"$@"' root -- arg0 "$@" 1>&2
    su --login -c '"$@"' root -- arg0 "$@" # arg0 is treated as filename
  fi
}
# Rerun this script as a superuser
if [[ $(id -u) != 0 && ! $debug ]]; then rootRun "$script" "$@"; exit $?; fi

infoLinux() {
  echo Linux: $(sed '/^ID=/ ! d; s/^ID=//; s/"//g' /etc/os-release) \
    $(sed '/^VERSION_ID=/ ! d; s/^VERSION_ID=//; s/"//g' /etc/os-release)
}
infoSudo() {
  if sudoExists; then
    echo sudo: installed
    echo sudoers-ALL: $(rootRun grep -E "$reALL" /etc/sudoers | awk '{print $1}')
  else
    echo sudo: not installed
  fi
}
infoRoot() {
  echo -n 'root-passwd: '
  local p=$(rootRun passwd --status root | awk '{print $2}') # L|NP|P
  if [[ $p = P ]]; then echo set; elif [[ $p = L ]]; then echo locked; else echo unset; fi
}

infoLinux; infoSudo; infoRoot
