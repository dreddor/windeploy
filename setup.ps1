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
        if (-NOT (Test-Path $HOME\WSL\$distname) ) {
            Write-Host "Extracting $distname WSL image..."
            Expand-Archive -DestinationPath $HOME\WSL\$distname `
                $HOME\WSL\archives\$distname.zip
        }
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
    InstallDistro -distname "ubuntu-1804" -disturl "https://aka.ms/wsl-ubuntu-1804"
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUm3haANWrHvmHcUtYw5TvbWNM
# aFGgggMyMIIDLjCCAhagAwIBAgIQdDJnWpUt9L9J1E+xJuLlkzANBgkqhkiG9w0B
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
# 9w0BCQQxFgQUXosRrKNGOPLksQESU5ZMi8PrFF4wDQYJKoZIhvcNAQEBBQAEggEA
# Tqtxvpv06jBi5SCIBZWK98sDDC5P03WarrpXm9UEYefi3d7N6cGjKvYHxgNYqeX/
# IsVlLf91lR77ITrk1bXe8W1NAyKcqiDPMWdz7hEUdUQw7WTmz/2dnCJhbXSY2tVQ
# wi3ePDZZqiMh9B/xifPNTvRvXm5rig5CwPyts+JxEJ8QYq5DXN1Z/j4uwSmcjINS
# +ezZzx5uLZo88pVSakva0NDzgcWB34TQtfnOTGEYRw2Y7QCyUztzfZ4Ac9shmGP/
# Ho3Ip8IwurVKGR9BBK15TDkLnwkCFCUNr571PXmEV8XL+IAJ1/k4BI+6CCJBqWyB
# uX/ZL2aC5vI9a/d4O8fePQ==
# SIG # End signature block
