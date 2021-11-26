# ansible-collection-talos

## talos-boot

Useful variables

1. ```talos_version: 0.13.3``` - version on distributive
2. ```talos_grub: true``` - add boot menu to the grub
3. ```talos_kexec: true``` - dowwnload and run talos

## Install Talos

```yaml
# talos.yml

- hosts: all
  roles:
    - talos-boot

```

```shell
ansible-playbook -Dv -i inventories/talos.ini talos.yml
```
