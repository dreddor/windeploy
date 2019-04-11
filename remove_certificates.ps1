Set-StrictMode -Version Latest
$ErrorActionProference = "Stop"

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
        Write-Host "Removing WinRM Certificate from the certificate store..." 
		Remove-Item Cert:\LocalMachine\Root\$PrivateThumbprint
    } Else {
        Write-Host "WinRM Private Certificate is not installed in the certificate store. Skipping."
    }

    # Import Public Key
    $CertificatePath = "$PSScriptRoot\ansible\certificates\WinRMCert.pem"
    $PublicWinRMCert = Get-PfxCertificate -FilePath $CertificatePath
    $PublicThumbprint = $PublicWinRMCert.Thumbprint.ToString()
    #
    # Remove Public Key from Certificate Store
    if (Test-Path Cert:\LocalMachine\TrustedPeople\$PublicThumbprint) {
        Write-Host "Removing WinRM Public Certificate from the certificate store..."
        Remove-Item Cert:\LocalMachine\TrustedPeople\$PublicThumbprint
    } Else {
        Write-Host "WinRM Public Certificate is not installed. Skipping."
    }


}

Function Main {
    RemoveWinRMCertificates
}

Main
