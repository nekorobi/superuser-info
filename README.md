# superuser-info

[![Test](https://github.com/nekorobi/superuser-info/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/nekorobi/superuser-info/actions)

- `sudo` or `su` in your Linux?

## superuser-info.sh
### Example output in Ubuntu 24.04
```bash
Linux: ubuntu 24.04
sudo: installed
sudoers-ALL: root %admin %sudo
root-passwd: locked
```

- `Linux`: distribution name and version (`/etc/os-release`)
- `sudo`:  `installed` | `not installed`
- `sudoers-ALL`: Users or groups with `ALL=ALL` or `ALL=(ALL)ALL` privileges (`/etc/sudoers`)
- `root-passwd`: `set` | `unset` | `locked`
  - Is there a password for root? Is the root password locked?

## Install without creating root password?
For example,
- AlmaLinux: Select “Make this user administrator” when creating the initial user

#### Example Linux (server)

Linux | sudo | sudoers-ALL | root-passwd
--|--|--|--
almalinux 9.4 | ✅ | root %wheel | ⛔
arch | ✅ | root | ⛔
debian 12 | ✅ | root %sudo | ⛔
fedora 40 | ✅ | root %wheel | ⛔
opensuse-leap 15.5 | ✅ | ALL root | ✅
ubuntu 24.04 | ✅ | root %admin %sudo | ⛔

- openSUSE (using GUI installation): A root password is created.

## MIT License
- © 2024 Nekorobi
