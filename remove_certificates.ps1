Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Function RemoveCodeSigningCertificates {
    $CertificatePath = "$PSScriptRoot\ansible\certificates\CodeSigningCert.pfx"
    $CodeSigningCert = Get-PfxCertificate -FilePath $CertificatePath
    $CodeSigningCertThumbprint = $CodeSigningCert.Thumbprint.ToString()

    if (Test-Path Cert:\LocalMachine\Root\$CodeSigningCertThumbprint) {
        Write-Host "Removing Code Signing Certificate from 'Root' certificate store..."
        Remove-Item Cert:\LocalMachine\Root\$CodeSigningCertThumbprint
    } Else {
        Write-Host "Code Signing Certificate is not installed in the 'Root' certificate store. Skipping."
    }

    if (Test-Path Cert:\LocalMachine\My\$CodeSigningCertThumbprint) {
        Write-Host "Removing Code Signing Certificate from 'My' certificate store..."
        Remove-Item Cert:\LocalMachine\My\$CodeSigningCertThumbprint
    } Else {
        Write-Host "Code Signing Certificate is not installed in the 'My' certificate store. Skipping."
    }

    if (Test-Path Cert:\LocalMachine\CA\$CodeSigningCertThumbprint) {
        Write-Host "Removing Code Signing Certificate from 'CA' certificate store..."
        Remove-Item Cert:\LocalMachine\CA\$CodeSigningCertThumbprint
    } Else {
        Write-Host "Code Signing Certificate is not installed in the 'CA' certificate store. Skipping."
    }

    if (Test-Path Cert:\LocalMachine\TrustedPeople\$CodeSigningCertThumbprint) {
        Write-Host "Removing Code Signing Certificate from the 'TrustedPeople' certificate store..."
        Remove-Item Cert:\LocalMachine\TrustedPeople\$CodeSigningCertThumbprint
    } Else {
        Write-Host "Code Signing Certificate is not installed in the 'Trusted People' certificate store. Skipping."
    }
}

Function RemoveWinRMCertificates {
    $CertificatePath = "$PSScriptRoot\ansible\certificates\WinRMCert.pfx"
    $PrivateWinRMCert = Get-PfxCertificate -FilePath $CertificatePath
    $PrivateThumbprint = $PrivateWinRMCert.Thumbprint.ToString()

    # Try to find Private Key in WSMan
    $WSManClientCert = Get-ChildItem  WSMan:\localhost\ClientCertificate\  |
        Where-Object {
            $_ | Get-ChildItem |
                Where-Object {($_).Name  -eq "Issuer" -and  $_.Value -eq $PrivateThumbprint }
        } 

    # Remove Public Key from WSMan
    if ($WSManClientCert -and (Test-Path $WSManClientCert.PSPath) )  {
        Write-Host "Removing WinRM Client Certificate from WSMan"
        Remove-Item -Recurse $WSManClientCert.PSPath
    } Else {
        Write-Host "WinRM Client Certificate does not exist in WSMan. Skipping"
    }

    if (Test-Path Cert:\LocalMachine\Root\$PrivateThumbprint) {
        Write-Host "Removing WinRM Certificate from 'Root' certificate store..."
        Remove-Item Cert:\LocalMachine\Root\$PrivateThumbprint
    } Else {
        Write-Host "WinRM Private Certificate is not installed in the 'Root' certificate store. Skipping."
    }

    if (Test-Path Cert:\LocalMachine\My\$PrivateThumbprint) {
        Write-Host "Removing WinRM Certificate from 'My' certificate store..."
        Remove-Item Cert:\LocalMachine\My\$PrivateThumbprint
    } Else {
        Write-Host "WinRM Private Certificate is not installed in the 'My' certificate store. Skipping."
    }

    if (Test-Path Cert:\LocalMachine\CA\$PrivateThumbprint) {
        Write-Host "Removing WinRM Certificate from 'CA' certificate store..."
        Remove-Item Cert:\LocalMachine\CA\$PrivateThumbprint
    } Else {
        Write-Host "WinRM Private Certificate is not installed in the 'CA' certificate store. Skipping."
    }

    # Import Public Key
    $CertificatePath = "$PSScriptRoot\ansible\certificates\WinRMCert.pem"
    $PublicWinRMCert = Get-PfxCertificate -FilePath $CertificatePath
    $PublicThumbprint = $PublicWinRMCert.Thumbprint.ToString()
    #
    # Remove Public Key from Certificate Store
    if (Test-Path Cert:\LocalMachine\TrustedPeople\$PublicThumbprint) {
        Write-Host "Removing WinRM Public Certificate from the 'TrustedPeople' certificate store..."
        Remove-Item Cert:\LocalMachine\TrustedPeople\$PublicThumbprint
    } Else {
        Write-Host "WinRM Public Certificate is not installed in the 'Trusted People' certificate store. Skipping."
    }
}


Function Main {
    RemoveCodeSigningCertificates
    RemoveWinRMCertificates
}

Main
