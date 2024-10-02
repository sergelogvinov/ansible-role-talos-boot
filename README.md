# Ansible role talos-boot

If your server does not have DHCP, PXE, or IPMI in your network, it can be challenging to automate the deployment of Talos operating systems.
In such cases, you may want to consider using an Ansible role to simplify the process.
This role downloads the Talos kernel and launch the OS by command `kexec -l <kernel-image> --initrd=<initrd-image> --append=<kernel-command-line-args>`.
It also sets the networks configuration in kernel parameters, witch helps you to boot OS with static IP.

Unfortunately, not all servers support booting a kernel through kexec.
Some servers may have hardware or firmware limitations that prevent the use of kexec, or the operating system may not have the necessary drivers or support for kexec.
In such cases, you can set the boot menu to boot the Talos kernel on the next boot and then reboot the server.

## Install

```shell
ansible-galaxy role install git+https://github.com/sergelogvinov/ansible-role-talos-boot.git,main
```

Or galaxy storage

```shell
ansible-galaxy role install sergelogvinov.talos-boot
```

## Options

Useful variables

1. ```talos_version: 1.7.7``` - version on distributive
2. ```talos_grub: true``` - add boot menu to the grub (boot menu)
3. ```talos_kexec: true``` - dowwnload and run talos
4. ```talos_interface: eth0``` - network interface

## Launch Talos

```yaml
# talos.yml

- hosts: all
  vars:
    talos_grub: true
    talos_kexec: true

    # Stream logs
    #
    # talos_cmdline_addon: "talos.logging.kernel=udp://1.2.3.4:5044"

    # IPv6 network
    #
    # talos_cmdline_net: "ip=[{{ ansible_default_ipv6['address'] }}]::[{{ ansible_default_ipv6['gateway'] }}]:{{ ansible_default_ipv6['prefix'] }}::{{ talos_interface }}:off:[2001:4860:4860::8888]:[2606:4700::1111]:[2606:4700:f1::1]"
  roles:
    - ansible-role-talos-boot
```

```yaml
# talos.ini

[all]
talos   ansible_host=1.2.3.4 ansible_ssh_user=debian # ansible_port=112233
```

Deploy Talos to the server

```shell
ansible-playbook -Dv -i talos.ini talos.yml
```
