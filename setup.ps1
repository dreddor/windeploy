# Import the certificate that signed all these scripts
Function ImportSelfSigningCert() {
    $cert = Import-Certificate -Filepath "$PSScriptRoot\dreddor_root_cert.cert" `
      -CertStoreLocation cert:\LocalMachine\Root
}

Function SetupProfile() {

    $write_profile = $TRUE

    If(Test-Path $HOME\Documents\WindowsPowerShell\Microsoft.Powershell_profile.ps1) {
        If(Test-Path $HOME\Documents\WindowsPowerShell\Microsoft.Powershell_profile.ps1.old) {
            Write-Host "Old powershell profile already exists. Skipping"
            $write_profile = $FALSE
        } Else {
            Write-Host "Found existing powershell profile- Moving aside."
            mv $HOME\Documents\WindowsPowerShell\Microsoft.Powershell_profile.ps1 `
               $HOME\Documents\WindowsPowerShell\Microsoft.Powershell_profile.ps1.old
        }
    }

    # Link the powershell profile to this powershell profile
    If($write_profile) {
        New-Item -Path $HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 `
          -ItemType SymbolicLink `
          -Value $PSScriptRoot\Microsoft.PowerShell_profile.ps1
    }
}

Function SetupWinRMForAnsible() {
    $url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
    $file = "$env:temp\ConfigureRemotingForAnsible.ps1"

    (New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)

    powershell.exe -ExecutionPolicy ByPass -File $file
}

Function SetupWSL() {
    return
}

Function Main() {
    ImportSelfSigningCert
    SetupProfile
    SetupWinRMForAnsible
}

Main

# SIG # Begin signature block
# MIIFrAYJKoZIhvcNAQcCoIIFnTCCBZkCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUOl6/dk7n/VRYHy1KglewR93G
# hZugggMyMIIDLjCCAhagAwIBAgIQFlDAr68W6LtJ2eMhRB8hRTANBgkqhkiG9w0B
# AQsFADAvMS0wKwYDVQQDDCREcmVkZG9yIFNlbGYtU2lnbmVkIENvZGUgQ2VydGlm
# aWNhdGUwHhcNMTkwMTExMTkzNDA1WhcNMjAwMTExMTk1NDA1WjAvMS0wKwYDVQQD
# DCREcmVkZG9yIFNlbGYtU2lnbmVkIENvZGUgQ2VydGlmaWNhdGUwggEiMA0GCSqG
# SIb3DQEBAQUAA4IBDwAwggEKAoIBAQDOvwJjvJ0PwRfLb0jchyXbaSyT30lxrN/6
# bTBd2n7z91veRSsMEEUBzRrHGDA0a1NGvOgxXTmNgwafjrTcSS542TEHxsx+Hwkc
# 8AoxxiFIQdIHrx7dJ7jK2MEmdk3uAveKtFscUkKtN8qdJ6qZ+HBms3rvEpdT2m9X
# lEm8jnT4ZEMIceI8XOHHrtNI8Zi3ZIzSbMUk9L9W1vrW6o93AUgM5sfnuUhoXOG+
# 0nWWVTrKir0yqEDT+zXtLECogYkeNvb+qTlch3aGmWo85La49YMD71eEcFUys+iY
# UMX+OaMhaX4Ourl+jaSIA43EV94scQec4HX/aGyBOUU6LkJvgPGtAgMBAAGjRjBE
# MA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQU
# YwRnfNhhtAP8ssyJileg7ox0GLIwDQYJKoZIhvcNAQELBQADggEBALehL2ZQZl16
# 5E4dvj5zZryJHdBSVnzGK87Cqm8SDrJbABNi2PEEcaVbn2GmLqB/meNzj9dXSDER
# IrAqpzg/DcavE80uMtRctJ1mfvcUYqen2pfyJ6vzlRWqzSeoeZ6NNbPYxws+UOvj
# 0WV1DsrORPPlbn9bi2CKCTzZF+39C3gL0SS+QCrf6DZHccZmrs3I9CALnCAnprLY
# JcbvW7vut2CCmlpq6J0rqyT4kcGg72YfWN9jDHo0wUODAB8xip6u2yWnf16ky9ca
# gLOUys3dy8D4Mo3SX96TDvnF+zeoHMr+QYyjrNTeu4ys/h9GA7CCOARKlUgEd0R0
# RgmXQbexQVMxggHkMIIB4AIBATBDMC8xLTArBgNVBAMMJERyZWRkb3IgU2VsZi1T
# aWduZWQgQ29kZSBDZXJ0aWZpY2F0ZQIQFlDAr68W6LtJ2eMhRB8hRTAJBgUrDgMC
# GgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYK
# KwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG
# 9w0BCQQxFgQUXkBaYRkiZwvQ23V91JSuAUgFzLMwDQYJKoZIhvcNAQEBBQAEggEA
# XtMoAffbUFOskTdktXHozBBv6u4qHrk+L56/+AHZYR0sYXkZU0KsiDaZ7Bkarcz9
# aJBTHE5rJPbONCJp9jrIK1ZQ100iwsNlp/OUIaI3vHAznsEAB6E3t/i6IwAgeIq6
# 8Ahb9fxQkquSW86xCkpv4WmWEV5sa3DMhsIU3mYz6dHQjgccEQNvHqOTWSOBcvkF
# eayqDvwNeSQHmp7c44+GMh55Sh3Rm8Ww0nNbUGL4/UJjSV4CkmCLDNewp1mXjPa6
# IPSCXmuaSiad66Z2Z5d+YqbFnjakqGHBY/J/7oaM0xJL3N38PkBSFP0U/hzu9ktl
# gSwV0sHM3/ytUiCpz2paeQ==
# SIG # End signature block
