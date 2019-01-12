# Import the certificate that signed all these scripts
Function ImportSelfSigningCert() {
    Write-Host "PSScriptRoot: $PSScriptRoot"
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUBoZeOZiq7/Bx4T3zi52TwRvP
# 3qagggMyMIIDLjCCAhagAwIBAgIQUe8ypRuUealJXJm8+dJzJzANBgkqhkiG9w0B
# AQsFADAvMS0wKwYDVQQDDCREcmVkZG9yIFNlbGYtU2lnbmVkIENvZGUgQ2VydGlm
# aWNhdGUwHhcNMTkwMTEyMDAzNzE4WhcNMjAwMTEyMDA1NzE4WjAvMS0wKwYDVQQD
# DCREcmVkZG9yIFNlbGYtU2lnbmVkIENvZGUgQ2VydGlmaWNhdGUwggEiMA0GCSqG
# SIb3DQEBAQUAA4IBDwAwggEKAoIBAQDVEnm5noUHsMfzjYui1VTMWGBEtqH4h1C8
# /x6adxhhbfh2dBGgb/e3ivNzChLyWc7xOxhEquGMa1GP7rm+nS9fLa6vCN+n/gUe
# nCRDQLl2j3ajgTzdknEYt2K9DXS9/uaf6DSp+7uhrHzHqTDMBlRYkYpAbg/giw9f
# 2e06JsERdIlWfHsp2BXsM7ZNwX83P2c0RPn5Qi3nEC5jEjf7gqeMe/nT4nXwotHc
# ibJxRt5Q5Rhg0JdNRHBYXyMLPO3ptQnuPcu2fSXHNsmwVgOqBALLJswXC2tmk2GE
# LyQn1gq/BQq7NSAi0QcS7kmpmSC6gl6CgTlPHcnqoxBGglSrpQ+ZAgMBAAGjRjBE
# MA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQU
# 9MC4JkXMl+niSEfkBFdi/qkTtaEwDQYJKoZIhvcNAQELBQADggEBAIO2Vx2RI3Pg
# nHTRlXapltJ/CnetoxD/m3tHom0zHBAJobm1Z+NdSzkmK+vkLK/1PlrCApj8a/BA
# DLXQYNh4YvzZB3ToDEOVbBeCw/8KY5nL36vDD31vm+TE8XawqfprHUQunR6Q0HMM
# ZFUioBOEKnyWLnbNR3gclkYytgY5xiLrrhxHej0ZxG1AD8BE5B1D1aX786pCwNvd
# W5MeprY0lsTKdfuxnTed3MnFLW6SknpfLJVQWG+1/7uxLT54RVgrJuQyYJ8KIPsH
# z7CuWUzA7jTg4T1jYB5nu0sqEPAu8YnJhfl3j+1w7S8yTJHuCS07cGmtx1MW9ZQG
# nGCQiXl9/8ExggHkMIIB4AIBATBDMC8xLTArBgNVBAMMJERyZWRkb3IgU2VsZi1T
# aWduZWQgQ29kZSBDZXJ0aWZpY2F0ZQIQUe8ypRuUealJXJm8+dJzJzAJBgUrDgMC
# GgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYK
# KwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG
# 9w0BCQQxFgQUDI1SbTilefxIlqWee1eJvYfvImswDQYJKoZIhvcNAQEBBQAEggEA
# ZdVlfFu3RvGGWi7X9jMNbTH1vBvC16RR8AiNDFZ57OoclZvr9iNhz40Z4A5rTNEE
# TXGGeewAUroCbiOlb6JDzvhisHFQUvqjD/pxxniq6KTysNWVMczERvcrgiNSacFJ
# tTwqDrL40+KpSBosnefq5JfkNyp8P0rYNRtVgzyPzvGtG2qapZq/dVOpYPlBjg5U
# c0W/l7WBM+p69RUDv9JZp/q8DlUjdf04T8fm0/5Zv37CiQXGRsuxxO86uoJ1mB7X
# mT2RKZ5jb8RBvoWY1aGW9QGfZu2YigZvngyMzkbFn1yvOPXB9XaHoBREkQK7+H+v
# +CGfMoewUmjEO23tKAOVSg==
# SIG # End signature block
