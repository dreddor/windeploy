# Packer script to create Windows Vagrant Box

1. Download Windows 10 Iso, and place it in ./iso
1. Run packer command to build iso
1. Add vagrant box generated by packer


Building on Windows with Hyper-V:

```powershell
packer build -except=virtualbox-iso -var 'iso=iso\Win10_1903_V1_English_x64.iso' -var 'iso_md5=8ba0e81b276d9052e8538deb0cf6c7d0' .\win10_builder.json
packer build -except=virtualbox-ovf .\ansible_builder.json
vagrant box add .\boxes\win10.box --name win10
```

Building on Linux with Virtualbox:

```bash
packer build -except=hyperv-iso -var 'iso=iso/Win10_1903_V1_English_x64.iso' -var 'iso_md5=8ba0e81b276d9052e8538deb0cf6c7d0' win10_builder.json
packer build -except=hyperv-vmcx ansible_builder.json
vagrant box add ./boxes/win10.box --name win10
```
