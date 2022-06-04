# ansible-role-talos-boot

## Install

```shell
ansible-galaxy role install git+https://github.com/sergelogvinov/ansible-role-talos-boot.git,main
```

## talos-boot

Useful variables

1. ```talos_version: 0.13.3``` - version on distributive
2. ```talos_grub: true``` - add boot menu to the grub
3. ```talos_kexec: true``` - dowwnload and run talos

## Launch Talos

```yaml
# talos.yml

- hosts: all
  vars:
    talos_kexec: true
    talos_cmdline_addon: "talos.logging.kernel=udp://1.2.3.4:5044"
  roles:
    - ansible-role-talos-boot
```

```shell
ansible-playbook -Dv -i talos.ini talos.yml
```
