# Import the certificate that signed all these scripts
Function ImportSelfSigningCert() {
    Write-Host "PSScriptRoot: $PSScriptRoot"
    $cert = Import-Certificate -Filepath "$PSScriptRoot\dreddor_code_signing.cert" `
      -CertStoreLocation cert:\LocalMachine\Root
    Import-Certificate -FilePath "$PSScriptRoot\dreddor_code_signing.cert" `
      -Cert Cert:\CurrentUser\TrustedPublisher
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

Function InstallDistro {
    Param ([string] $distname, [string] $disturl)
    if (-NOT (Test-Path $HOME\WSL\archives\$distname.zip) ) {
        Write-Host "Downloading $distname WSL image from $disturl..."
        Invoke-WebRequest -Uri $disturl -Outfile $HOME\WSL\archives\$distname.zip -UseBasicParsing
    }
    if (-NOT (Test-Path $HOME\WSL\$distname) ) {
        Write-Host "Extracting $distname WSL image..."
        Expand-Archive -DestinationPath $HOME\WSL\$distname `
            $HOME\WSL\archives\$distname.zip

        Start-Process -FilePath $HOME\WSL\$distname\$distname.exe `
          -ArgumentList install `
          -NoNewWindow -Wait
    }
}

Function SetupWSL() {
    if (-NOT (Test-Path $HOME\WSL) ) {
        mkdir $HOME\WSL
    }
    if (-NOT (TEST-Path $HOME\WSL\archives)) {
        mkdir $HOME\WSL\archives
    }

    # Enable the WSL Feature - this will prompt for reboot if it is not already enabled
    Write-Host "Enabling WSL. If this is not already enabled, it will prompt for reboot..."
    Write-Host "  Note: If prompted for reboot, re-run setup again after restart"
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
    #
    # Download the WSL ubuntu image if it does not already exist
    InstallDistro -distname "ubuntu1804" -disturl "https://aka.ms/wsl-ubuntu-1804"
}

Function Main() {
    ImportSelfSigningCert
    SetupProfile
    SetupWinRMForAnsible
    SetupWSL
}

Main

# SIG # Begin signature block
# MIIFrAYJKoZIhvcNAQcCoIIFnTCCBZkCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUEnhfHVmS+u41QhjylN2lfd3Y
# rzqgggMyMIIDLjCCAhagAwIBAgIQdDJnWpUt9L9J1E+xJuLlkzANBgkqhkiG9w0B
# AQsFADAvMS0wKwYDVQQDDCREcmVkZG9yIFNlbGYtU2lnbmVkIENvZGUgQ2VydGlm
# aWNhdGUwHhcNMTkwMTEyMjE0MDM4WhcNMjAwMTEyMjIwMDM4WjAvMS0wKwYDVQQD
# DCREcmVkZG9yIFNlbGYtU2lnbmVkIENvZGUgQ2VydGlmaWNhdGUwggEiMA0GCSqG
# SIb3DQEBAQUAA4IBDwAwggEKAoIBAQC/KqVr9b6yQcnTsZE6fFX0cVAikPMHiCe6
# hhmOjhPzr9XU+mGa/na46065i4mTduDH1v9qrG1GzI2NSs7yK8ygmo0GSfADwsgl
# AVK8MXKriO2wLtYBsV9qQMEJrXfB5fJthyEDiGn2+y0AlzYKTSEM/h03NS1WjfTl
# CE+nfprEP1x9IGP9tq/QA9KpSs14LtJ6JZTG9DrZV1OwkLxX9+xvMamiaGCmDzhR
# 8Fd9Pa6SzJMREZ13jcGGehzSYHd2M5pygVU73cA6h3ANBydQRROqTEwGMjuRM5QN
# zLjBXAiJJlqOS9Iq6LgHnVpZpSXAnH3j05f9ekFUbhWBS+JnKb9lAgMBAAGjRjBE
# MA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQU
# jWREIhYt99lRzTZ8gMxgBb+YylEwDQYJKoZIhvcNAQELBQADggEBABjfbDLjkY3c
# Rxl5eoh8j6STEcEw2CqKALfu1YZJNZZSQ2hlCLq5KhoFCgKoEasJOqd7CkFBG8nM
# QoVaj+Un4sfO6zhaqcZZEDTqbktm01sgM+PsQiXkOP2HRfPRYVlmgcrFDwU8gEMP
# HcfZnnaE28rRq4kv2Lhd7UY6pKlmx/Nsq/5LjMaCK2xlSzbdhjmDJbiBPKWuyLAM
# QuVyGdn3HuiLdSLNRBAEk0CWwBjeOqgfRs6/CCoTPTuEDQpzVTDwteBYCXtESS9f
# wsWaNsE7sJRPgH1r1Vw+qiaLRHz1YRnWVWsDe/GBsCsWJFKkQAQU4qiscECjM+Qn
# AsrVKP0ToekxggHkMIIB4AIBATBDMC8xLTArBgNVBAMMJERyZWRkb3IgU2VsZi1T
# aWduZWQgQ29kZSBDZXJ0aWZpY2F0ZQIQdDJnWpUt9L9J1E+xJuLlkzAJBgUrDgMC
# GgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYK
# KwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG
# 9w0BCQQxFgQUGHZXXUlNh0nMhBDPYfgx32CwkggwDQYJKoZIhvcNAQEBBQAEggEA
# hSAyJwhQd9NKfasTU7b7zWtwax6kNeeCzafheW+vT0M3GuF+IagI+flRaISAwJfR
# iNvBCIX3YlHudUUt/KFifNTcS0n+38XPgcIlK7J87bcvISPDnPRKxF6vdWd5AHc5
# 5xHldUp3WVgTaBOXIVRO9P/vOq6PFF5kEgDDdKIctDqBUIJ2nVskyFrpX8ufHEYQ
# XPHmZNGdwfcUCe37y0DPQ2E5bFZ+JhoyRuQRi8j6nhfNCrSLpBwNg6bHt0WMV/My
# UH/Fs2TQanPeZE9YQPpSl/e3p0YELFGR5pEeQKviNXNfKbrhgbIK64hvXCznRFhH
# Njzr2T92F5xjJ6+ufz1gZA==
# SIG # End signature block
