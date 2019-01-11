# Import the certificate that signed all these scripts
$cert = Import-Certificate -Filepath "$PSScriptRoot\dreddor_root_cert.cert" `
  -CertStoreLocation cert:\LocalMachine\Root

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


# SIG # Begin signature block
# MIIFrAYJKoZIhvcNAQcCoIIFnTCCBZkCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUdo8lXwA+7PEB7YjzOiwSmxXo
# OaigggMyMIIDLjCCAhagAwIBAgIQFlDAr68W6LtJ2eMhRB8hRTANBgkqhkiG9w0B
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
# 9w0BCQQxFgQUEICynXmydC1DOqlkw0ES6EFm790wDQYJKoZIhvcNAQEBBQAEggEA
# wHhHEy2CjkWkXkmrsew8mXVSQle1V13aUei25+7MNXEQzeiGAYBTNi+C7pGwVMT1
# 857fVSg6vEStEtTqvUzH/+gL7+uGpLJnI25HbyAE+JLP7iV4IoHULHc+gzUGh9tP
# arzEnx21yT/EGi9JnwPiLyS4Vr3r7nmGlv9Gzu8Q8J7+zM8cskAxhony4UKv7SGV
# nFJ14T2m3nlbm6WQ+n4qrpKYHCobe3nopKmfb3qXdCvkv0rN1JBRf3apJMO/ylKy
# 0wawidOtx7E+p1br7BYMWCVwEz3l95jEuvxoiOI6tlninN46Q0qhb7QnM41ArvkK
# rqQXHK3+OPFm/mGdTB10Fw==
# SIG # End signature block
