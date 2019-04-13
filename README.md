# Deploy WSL for Ansible workstation setup

This is a powershell script and supporting infrastructure to run workstation
setup with WSL and Ansible. This was done as an exercise to learn both
Ansible and Powershell.

WARNING: Use at your own risk. This could very well overwrite something
important, as I haven't really thought about what it would look like for
somebody else to use this.

## Run Deploy
```powershell
powershell.exe -ExecutionPolicy ByPass -File .\setup.ps1
```
