# Foreman iPXE

Adds in PXE loaders for chainloaded iPXE (`undionly.kpxe`, `ipxe.efi`)

This is useful for when you want to selectively chainload specific hosts into iPXE without affecting all other machines with the same OS.


## Installation

Follow the Foreman manual for [advanced installation from gems](https://theforeman.org/plugins/#2.3AdvancedInstallationfromGems)


## Usage

### Global

This plugin adds global iPXE templates for hosts, if your DHCP is set up to always boot iPXE on all hosts - or hosts have iPXE embedded as their boot software.

You'll need to create a global default template for iPXE to support this feature, an example given below;

```erb
<%#
kind: iPXE
model: ProvisioningTemplate
name: iPXE Global Default
snippet: false
-%>
#!ipxe

set menu-default local
set menu-timeout 5000

:start
menu iPXE global boot menu
item --key l local     Continue local boot
item shell             Drop into iPXE shell
item reboot            Reboot system
item
item --key d discovery Foreman Discovery
choose --timeout ${menu-timeout} --default ${menu-default} selected || goto cancel
set menu-timeout 0
goto ${selected}

:cancel
echo Menu canceled, dropping to shell

:shell
echo Use the command 'exit' to return to menu
shell
set menu-timeout 0
goto start

:failed
echo Boot failed, dropping to shell
goto shell

:reboot
reboot

:local
exit

:discovery
dhcp
kernel ${next-server}/boot/fdi-image/vmlinuz0 rootflags=loop root=live:/fdi.iso rootfstype=auto ro rd.live.image acpi=force rd.luks=0 rd.md=0 rd.dm=0 rd.lvm=0 rd.bootif=0 rd.neednet=0 nomodeset proxy.url=<%= foreman_server_url %> proxy.type=foreman BOOTIF=01-${net0/mac}
initrd ${next-server}/boot/fdi-image/initrd0.img
boot || goto failed
goto start
```

### Chainloading

#### Without DHCP setup

To use the chainloading, you need to generate the iPXE executables first.

```sh
git clone git://git.ipxe.org/ipxe.git
cd ipxe/src

cat <<EOF > default.ipxe
#!ipxe

dhcp
chain https://foreman.example.com/unattended/iPXE
EOF

make bin/undionly.kpxe EMBED=default.ipxe
make bin-x86_64-efi/ipxe.efi EMBED=default.ipxe
```

The generated executables should then be uploaded to the root of your TFTP server (or depending on your root path DHCP option).

#### With DHCP setup

Install the officially available iPXE executables (`undionly.kpxe`, `ipxe.efi`) into your TFTP server, then follow the [iPXE guide for "breaking the loop"](http://ipxe.org/howto/chainloading#breaking_the_loop_with_the_dhcp_server).

You want to add a rule that passes the bootfile "https://foreman.example.com/unattended/iPXE" to any client reporting in as user class "iPXE".


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ananace/foreman_ipxe


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

