# Import the certificate that signed all these scripts
Function ImportSelfSigningCert {
    $CertFile = Get-PfxCertificate -FilePath $PSScriptRoot\dreddor_code_signing.cert
    $Thumbprint = $CertFile.Thumbprint.ToString()
    if(Get-ChildItem Cert:\LocalMachine\Root\$thumbprint -ErrorAction SilentlyContinue) {
        Write-Host "Code Signing Certificate already imported. Skipping"
    } Else {
        Write-Host "Importing Code Signing Certificate..."
        $cert = Import-Certificate -Filepath "$PSScriptRoot\dreddor_code_signing.cert" `
          -CertStoreLocation cert:\LocalMachine\Root
        Import-Certificate -FilePath "$PSScriptRoot\dreddor_code_signing.cert" `
          -Cert Cert:\CurrentUser\TrustedPublisher
    }
}

Function DisableRealTimeProtection {
    Set-MpPreference -DisableRealtimeMonitoring $true
}

Function EnableRealTimeProtection {
    Set-MpPreference -DisableRealtimeMonitoring $false
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

    $ExecPath =  "$HOME\WSL\$distname\$distname.exe"

    if (-NOT (Test-Path $HOME\WSL\archives\$distname.zip) ) {
        Write-Host "Downloading $distname WSL image from $disturl..."
        Invoke-WebRequest -Uri $disturl -Outfile $HOME\WSL\archives\$distname.zip -UseBasicParsing
    }
    if (-NOT (Test-Path $HOME\WSL\$distname) ) {
        Write-Host "Extracting $distname WSL image..."
        Expand-Archive -DestinationPath $HOME\WSL\$distname `
            $HOME\WSL\archives\$distname.zip

        Start-Process -FilePath $ExecPath `
          -ArgumentList install,--root `
          -NoNewWindow -Wait

        SetTaskbarPin $ExecPath

        InstallAnsible($distname)
    }
    # Initialize users and groups for ansible
    RunWSLAnsibleInitPlaybook

    # The dreddor user should have been created in the previous step, so set
    # the default user to 'dreddor'
    Start-Process -FilePath $ExecPath `
      -ArgumentList config,--default-user,dreddor `
      -NoNewWindow -Wait

    # Configure the Windows environment now
    #   - Install Windows Applications
    #   - Set up Windows Firewall Rules
    #   - Set up Z:\ to point to the deadpool PRIVATE share
    #   - Set the default browser
    #RunAnsibleWindows

    # Finally, set up the Linux environment to match what I expect everywhere
    # in my lab and home environments
    RunAnsibleLinux

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

Function InstallAnsible($distname) {
    if ($distname -eq "ubuntu1804") {
        bash -c "apt-get update && sudo apt-get install python-pip git libffi-dev libssl-dev -y"
        bash -c "pip install ansible pywinrm"
    }
}

Function InstallChocolatey {
    if (Get-Command choco.exe -ErrorAction SilentlyContinue) {
        Write-Host "Chocolatey already installed. Skipping."
    } Else {
        Write-Host "Installing Chocolatey..."
        iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }
}

Function RunWSLAnsibleInitPlaybook {
    bash -c "ansible-playbook /mnt/c/Users/dreddor/deployments/windeploy/ansible/user_wsl.yaml"
    # Work around windows bug:
    #   https://stackoverflow.com/questions/4742992/cannot-access-network-drive-in-powershell-running-as-administrator
    #   https://support.microsoft.com/en-us/help/937624/programs-may-be-unable-to-access-some-network-locations-after-you-turn
    net use Z: \\10.10.0.150\PRIVATE /persistent:no
    bash -c "ansible-playbook /mnt/c/Users/dreddor/deployments/windeploy/ansible/environment_wsl.yaml"
}

Function RunAnsibleLinux {
    bash -c "ssh-keyscan -H dreddor.net >> ~/.ssh/known_hosts"
    bash -c "[ -d /home/dreddor/deployments/envsetup ] || git clone dreddor@dreddor.net:build/envsetup /home/dreddor/deployments/envsetup"
    bash -c "ansible-playbook /home/dreddor/deployments/envsetup/ansible/common/*.yaml"
    #bash -c "ansible-playbook /home/dreddor/deployments/envsetup/ansible/linux/*.yaml"
}

# This makes use of a function in shell32.dll by doing some magic
# to read the location of the function out of the registry, and then
# executing it with InvokeVerb()
#
# Found here:
#   https://stackoverflow.com/questions/31720595/pin-program-to-taskbar-using-ps-in-windows-10
Function SetTaskbarPin {
    param (
        [parameter(Mandatory=$True, HelpMessage="Target item to pin")]
        [ValidateNotNullOrEmpty()]
        [string] $Target
    )
    if (!(Test-Path $Target)) {
        Write-Warning "$Target does not exist"
        break
    }

    $KeyPath1  = "HKCU:\SOFTWARE\Classes"
    $KeyPath2  = "*"
    $KeyPath3  = "shell"
    $KeyPath4  = "{:}"
    $ValueName = "ExplorerCommandHandler"
    $ValueData =
        (Get-ItemProperty `
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\" + `
                "CommandStore\shell\Windows.taskbarpin")
        ).ExplorerCommandHandler

    $Key2 = (Get-Item $KeyPath1).OpenSubKey($KeyPath2, $true)
    $Key3 = $Key2.CreateSubKey($KeyPath3, $true)
    $Key4 = $Key3.CreateSubKey($KeyPath4, $true)
    $Key4.SetValue($ValueName, $ValueData)

    $Shell = New-Object -ComObject "Shell.Application"
    $Folder = $Shell.Namespace((Get-Item $Target).DirectoryName)
    $Item = $Folder.ParseName((Get-Item $Target).Name)
    $Item.InvokeVerb("{:}")

    $Key3.DeleteSubKey($KeyPath4)
    if ($Key3.SubKeyCount -eq 0 -and $Key3.ValueCount -eq 0) {
        $Key2.DeleteSubKey($KeyPath3)
    }
}

Function Main {
    ImportSelfSigningCert
    DisableRealtimeProtection
    SetupProfile
    InstallChocolatey
    SetupWinRMForAnsible
    SetupWSL
    EnableRealTimeProtection
}

Main

# SIG # Begin signature block
# MIIFrAYJKoZIhvcNAQcCoIIFnTCCBZkCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUsUeYisOTj4e/h9CP2tx7Z4BV
# HlWgggMyMIIDLjCCAhagAwIBAgIQdDJnWpUt9L9J1E+xJuLlkzANBgkqhkiG9w0B
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
# 9w0BCQQxFgQUq4ZhiNOHvBNHFhnjhKgA36t8sUQwDQYJKoZIhvcNAQEBBQAEggEA
# imxEX+f/3bqrkEUuCEqQltP780Zc2CJF3Y5vxCmvLtk0qBsSHOE1D+R6OXGa06ti
# DpCNkQnDkU4ghWxchKEsSSYrojS/wjKQk+7xhM6y/BJeaP2ls1v1LNCJbiewCKfc
# DhFK3XY6WyrQcWuBr+ixQDJNTdumHCWrprPtAReJ4ppft+SjefueaRRaYBaQ2RrN
# /NsJahFNqfyCJRy2zz1mZ/hDnP/oWrwvqLUpMmxIJrQ4QfzZwosYvsw2hgiExiCz
# k0lQPruhaKXH1XIa3j9b8IfU+uoMqjmHHc9ubtAUdG4hqcm37BMwBtwQj7Dnx4gB
# Yumk2pSv71/UWl2Luo9cTg==
# SIG # End signature block
