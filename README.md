## Generate a self-signed root certificate

```powershell
$cert = New-SelfSignedCertificate -Subject "Dreddor Self-Signed Code Certificate" -Type CodeSigningCert -CertStoreLocation cert:\LocalMachine\My
Move-Item -Path $cert.PSPath -Destination "Cert:\LocalMachine\Root\"
$cert | Export-Certificate -FilePath .\dreddor_root_cert.cert

```

## Import self-signed cert from this repo

```powershell
Import-Certificate -Filepath ".\dreddor_root_cert.cert" -CertStoreLocation cert:\LocalMachine\Root

```

## Sign a script
```powershell
$cert | Export-Certificate -FilePath .\dreddor_root_cert.cert
```

The certificate is signed with a cmdlet from this package:

```powershell
PS C:\Users\dreddor\deployments\windeploy> Get-Command -Module PKI

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Cmdlet          Add-CertificateEnrollmentPolicyServer              1.0.0.0    PKI
Cmdlet          Export-Certificate                                 1.0.0.0    PKI
Cmdlet          Export-PfxCertificate                              1.0.0.0    PKI
Cmdlet          Get-Certificate                                    1.0.0.0    PKI
Cmdlet          Get-CertificateAutoEnrollmentPolicy                1.0.0.0    PKI
Cmdlet          Get-CertificateEnrollmentPolicyServer              1.0.0.0    PKI
Cmdlet          Get-CertificateNotificationTask                    1.0.0.0    PKI
Cmdlet          Get-PfxData                                        1.0.0.0    PKI
Cmdlet          Import-Certificate                                 1.0.0.0    PKI
Cmdlet          Import-PfxCertificate                              1.0.0.0    PKI
Cmdlet          New-CertificateNotificationTask                    1.0.0.0    PKI
Cmdlet          New-SelfSignedCertificate                          1.0.0.0    PKI
Cmdlet          Remove-CertificateEnrollmentPolicyServer           1.0.0.0    PKI
Cmdlet          Remove-CertificateNotificationTask                 1.0.0.0    PKI
Cmdlet          Set-CertificateAutoEnrollmentPolicy                1.0.0.0    PKI
Cmdlet          Switch-Certificate                                 1.0.0.0    PKI
Cmdlet          Test-Certificate                                   1.0.0.0    PKI
```

List certificates:

```powershell
PS C:\Users\dreddor\deployments\windeploy> dir cert:\CurrentUser\CA
```

List Registry Entries:

```
PS C:\Users\dreddor\deployments\windeploy> Get-ChildItem hklm:\


    Hive: HKEY_LOCAL_MACHINE


    Name                           Property
    ----                           --------
    BCD00000000
    HARDWARE
    SAM
    Get-ChildItem : Requested registry access is not allowed.
    At line:1 char:1
    + Get-ChildItem hklm:\
    + ~~~~~~~~~~~~~~~~~~~~
        + CategoryInfo          : PermissionDenied: (HKEY_LOCAL_MACHINE\SECURITY:String) [Get-ChildItem], SecurityException
            + FullyQualifiedErrorId : System.Security.SecurityException,Microsoft.PowerShell.Commands.GetChildItemCommand

            SOFTWARE
            SYSTEM
```

More Providers:

https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_providers?view=powershell-6
