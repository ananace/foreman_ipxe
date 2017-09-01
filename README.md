# Foreman iPXE

Adds in PXE loaders for chainloaded iPXE (`undionly.kpxe`, `ipxe.efi`)

This is useful for when you want to selectively chainload specific hosts into iPXE without affecting all other machines with the same OS.


## Installation

Follow the Foreman manual for [advanced installation from gems](https://theforeman.org/plugins/#2.3AdvancedInstallationfromGems)


## Usage

### Without DHCP setup

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

### With DHCP setup

Install the officially available iPXE executables (`undionly.kpxe`, `ipxe.efi`) into your TFTP server, then follow the [iPXE guide for "breaking the loop"](http://ipxe.org/howto/chainloading#breaking_the_loop_with_the_dhcp_server).

You want to add a rule that passes the bootfile "https://foreman.example.com/unattended/iPXE" to any client reporting in as user class "iPXE".


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ace13/foreman_ipxe.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

