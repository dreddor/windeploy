Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Function GetNeededCredentials {
    $Username = "$env:UserName"
    try {
        $Thumbprint = (Get-ChildItem -Path cert:\LocalMachine\root | Where-Object { $_.Subject -eq "CN=$Username WinRM Cert" }).Thumbprint
    } catch {
        $Thumbprint = [String]::Empty
    }

    if (-Not (ClientCert-Installed -Thumbprint $Thumbprint)) {
        $Password = Read-Host "Enter Password" -AsSecureString
        $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password

        if (-Not (Test-LocalAuth -Credential $Credential).PasswordValid) {
            Throw "Invalid Credentials"
        }
    } else {
        $Credential = $null
    }

    return $Credential
}

Function Test-LocalAuth {
	param($Credential)
	Add-Type -AssemblyName System.DirectoryServices.AccountManagement
	$Obj = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('machine', $env:COMPUTERNAME)
	$Result = $Obj.ValidateCredentials($Credential.GetNetworkCredential().Username, `
                                       $Credential.GetNetworkCredential().Password)
	$Obj | Add-Member NoteProperty "Machine" $env:COMPUTERNAME
	$Obj | Add-Member NoteProperty "User" $Username
	$Obj | Add-Member NoteProperty "PasswordValid" $Result
	return $Obj | Select-Object Machine, User, PasswordValid
}

Function ClientCert-Installed {
    param($Thumbprint)
    $HasClientCert = (ls WSMan:\localhost\ClientCertificate\ | Get-ChildItem | Where-Object { $_.Name -eq "Issuer" }) `
                        | Where-Object { $_.Value -eq $Thumbprint }
    if ($HasClientCert) {
        return $true
    }
    return $false
}

# Import the certificate that signed all these scripts
Function ImportSelfSigningCert {
    $CertPath = "$PSScriptRoot\ansible\certificates\dreddor_code_signing.cert"
    $CertFile = Get-PfxCertificate -FilePath $CertPath
    $Thumbprint = $CertFile.Thumbprint.ToString()
    if(Get-ChildItem Cert:\LocalMachine\Root\$thumbprint -ErrorAction SilentlyContinue) {
        Write-Host "Code Signing Certificate already imported. Skipping"
    } Else {
        $cert = ''
        Write-Host "Importing Code Signing Certificate..."
        $cert = Import-Certificate -Filepath $CertPath `
          -CertStoreLocation cert:\LocalMachine\Root
        if (-Not $cert) {
            Throw "Could not import certificate to Cert:\LocalMachine\Root"
        }

        $cert = ''
        $cert = Import-Certificate -FilePath  $CertPath `
          -Cert Cert:\LocalMachine\TrustedPublisher
        if (-Not $cert) {
            Throw "Could not import certificate to Cert:\LocalMachine\TrustedPublisher"
        }
    }
}

Function GenerateWinRMCertificate {
    Write-Host "Generating WinRM Certificate..."
    # set the name of the local user that will have the key mapped
    $Username = "$env:UserName"
    $Output_Path = "$PSScriptRoot\ansible\certificates"
    if(Test-Path $Output_Path\WinRMCert.pfx) {
        Write-Host "WinRM Certificate already generated. Skipping"
    } Else {
        # instead of generating a file, the cert will be added to the personal
        # LocalComputer folder in the certificate store
        $cert = New-SelfSignedCertificate -Type Custom `
            -Subject "CN=$Username WinRM Cert" `
            -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2","2.5.29.17={text}upn=$Username@localhost") `
            -KeyUsage DigitalSignature,KeyEncipherment `
            -KeyAlgorithm RSA `
            -KeyLength 2048

        # export the public key
        $pem_output = @()
        $pem_output += "-----BEGIN CERTIFICATE-----"
        $pem_output += [System.Convert]::ToBase64String($cert.RawData) -replace ".{64}", "$&`n"
        $pem_output += "-----END CERTIFICATE-----"
        [System.IO.File]::WriteAllLines("$Output_Path\WinRMCert.pem", $pem_output)

        # export the private key in a PFX file
        [System.IO.File]::WriteAllBytes("$Output_Path\WinRMCert.pfx", $cert.Export("Pfx"))
    }
}

Function ImportWinRMCertificate {
    $CertificatePath = "$PSScriptRoot\ansible\certificates\WinRMCert.pfx"
    $PrivateWinRMCert = Get-PfxCertificate -FilePath $CertificatePath
    $PrivateThumbprint = $PrivateWinRMCert.Thumbprint.ToString()

    # Import Private Key
    if (Test-Path Cert:\LocalMachine\Root\$PrivateThumbprint) {
        Write-Host "WinRM Private Certificate already imported. Skipping."
    } Else {
        $cert = ''
        Write-Host "Importing WinRM Private Certificate into the registry..."
        $cert = Import-PfxCertificate -Filepath $CertificatePath `
          -CertStoreLocation cert:\LocalMachine\Root
        if (-Not $cert) {
            Throw "Could not import private certificate to Cert:\LocalMachine\Root"
        }
    }

    # Import Public Key
    $CertificatePath = "$PSScriptRoot\ansible\certificates\WinRMCert.pem"
    $PublicWinRMCert = Get-PfxCertificate -FilePath $CertificatePath
    $PublicThumbprint = $PublicWinRMCert.Thumbprint.ToString()

    if (Test-Path Cert:\LocalMachine\TrustedPeople\$PublicThumbprint) {
        Write-Host "WinRM Public Certificate already imported. Skipping."
    } Else {
        $cert = ''
        Write-Host "Importing WinRM Public Certificate into the registry..."
        $cert = Import-Certificate -Filepath $CertificatePath `
          -CertStoreLocation cert:\LocalMachine\TrustedPeople
        if (-Not $cert) {
            Throw "Could not import public certificate to Cert:\LocalMachine\TrustedPeople"
        }
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

Function EnableWinRMAccess {
    Param($Credential)

    if ($Credential) {
        $Username = $Credential.GetNetworkCredential().Username
        $Thumbprint = (Get-ChildItem -Path cert:\LocalMachine\root `
                        | Where-Object { $_.Subject -eq "CN=$Username WinRM Cert" }).Thumbprint

        New-Item -Path WSMan:\localhost\ClientCertificate `
            -Subject "$Username@localhost" `
            -URI * `
            -Issuer $Thumbprint `
            -Credential $Credential `
            -Force
    }

    Set-Item -Path WSMan:\localhost\Service\Auth\Certificate -Value $true
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
    RunAnsible

}

Function EnableHyperV {
    if (Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V | where State -eq "Disabled") {
        Write-Host "Enabling Hyper-V"
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
    } Else {
        Write-Host "HyperV is already enabled. Skipping"
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

    # Set an exclusion path for windows defender on this on WSL
    Add-MpPreference -ExclusionPath $HOME\WSL

    # Download the WSL ubuntu image if it does not already exist
    InstallDistro -distname "ubuntu1804" -disturl "https://aka.ms/wsl-ubuntu-1804"
}

Function InstallAnsible($distname) {
    if ($distname -eq "ubuntu1804") {
        bash -c "apt-get update && sudo apt-get install python-pip git libffi-dev libssl-dev -y"
        if ($LASTEXITCODE -ne 0) {
            Throw "Could not install ansible dependencies"
        }
        bash -c "pip install ansible pywinrm"
        if ($LASTEXITCODE -ne 0) {
            Throw "Could not install ansible"
        }
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
    if ($LASTEXITCODE -ne 0) {
        Throw "Failed to set up WSL user"
    }
    # Work around windows bug:
    #   https://stackoverflow.com/questions/4742992/cannot-access-network-drive-in-powershell-running-as-administrator
    #   https://support.microsoft.com/en-us/help/937624/programs-may-be-unable-to-access-some-network-locations-after-you-turn
    if (-Not (Test-Path Z:\) ) {
        net use Z: \\10.10.0.150\PRIVATE /persistent:no
    }
    bash -c "ansible-playbook /mnt/c/Users/dreddor/deployments/windeploy/ansible/environment_wsl.yaml"
    if ($LASTEXITCODE -ne 0) {
        Throw "Failed to set up WSL environment"
    }
}

Function RunAnsible {
    bash -c "make -C /home/dreddor/deployments/envsetup/ windows_host"
    if ($LASTEXITCODE -ne 0) {
        Throw "Failed Windows Ansible Install"
    }
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
    $Credential = GetNeededCredentials
    ImportSelfSigningCert
    DisableRealtimeProtection
    SetupProfile
    InstallChocolatey
    GenerateWinRMCertificate
    ImportWinRMCertificate
    SetupWinRMForAnsible
    EnableWinRMAccess -Credential $Credential
    EnableHyperV
    SetupWSL
    EnableRealTimeProtection
}

Main
