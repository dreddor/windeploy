# Import the certificate that signed all these scripts
Function ImportSelfSigningCert {
    Write-Host "PSScriptRoot: $PSScriptRoot"
    $cert = Import-Certificate -Filepath "$PSScriptRoot\dreddor_code_signing.cert" `
      -CertStoreLocation cert:\LocalMachine\Root
    Import-Certificate -FilePath "$PSScriptRoot\dreddor_code_signing.cert" `
      -Cert Cert:\CurrentUser\TrustedPublisher
}

Function SetupProfile {

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

Function SetupWinRMForAnsible {
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
          -ArgumentList install,--root `
          -NoNewWindow -Wait
    }
}

Function SetupWSL {
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

Function InstallAnsible {
    bash -c "apt-get update && sudo apt-get install python-pip git libffi-dev libssl-dev -y"
    bash -c "pip install ansible pywinrm"
}

Function InstallChocolatey {
    Write-Host "Installing Chocolatey..."
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

Function Main {
    ImportSelfSigningCert
    SetupProfile
    InstallChocolatey
    SetupWinRMForAnsible
    SetupWSL
    InstallAnsible
}

Main

# SIG # Begin signature block
# MIIFrAYJKoZIhvcNAQcCoIIFnTCCBZkCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUw48MPXTexapgR0Ny1kLL+6HF
# fn6gggMyMIIDLjCCAhagAwIBAgIQdDJnWpUt9L9J1E+xJuLlkzANBgkqhkiG9w0B
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
# 9w0BCQQxFgQUC+IEezU5ZhGv1Ex+y3a9fWo0AqMwDQYJKoZIhvcNAQEBBQAEggEA
# RiXNF/5bfW+SfNypzGYBVoCOYMnf7/pUCursNZTZgMjsQRHhplY7qrzqdBurps8c
# YM7w/YA/gUUXEJNYlFns3msMHueBxdqXrYExTOCnQCNzd0mBq5ZuzaS95iJGDYR8
# KSFUJE8tBiEckdvRq3sm8cGQNngCxTd94cJLx1FVKMk4ER4ucAwTJfou5K25eUdl
# LbfpNTSBlcE5xk0mcLe5Cc0HQVSXqU7CwlDMmOf0iw0h/1d+YHjGFD4yQkeTwNyH
# 4agAOu4G3wx+VJpFJu6U5RwK56vLstAoSRJoqWtjGMICgNUCni7t2+ZmH5FBb0vi
# gtWZj3nhyPgA50inQJeTAA==
# SIG # End signature block
