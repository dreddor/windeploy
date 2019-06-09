param(
    [switch] $UseRestricted = $false,
    [string] $EnvsetupRepo = "https://github.com/dreddor/envsetup",
    [string] $GitUser = "Taylor Vesely",
    [string] $GitEmail = "dreddor@dreddor.net"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Function Main {
    if(-Not(Test-Path $env:HOMEPATH\deployments)) {
        mkdir $env:HOMEPATH\deployments
    }

    if(-Not(Test-Path $env:HOMEPATH\deployments\windeploy)) {
        Invoke-WebRequest -Uri "https://github.com/dreddor/windeploy/archive/master.zip" -OutFile C:\windeploy.zip
        Expand-Archive -Path C:\windeploy.zip -DestinationPath C:\
        mv C:\windeploy-master $env:HOMEPATH\deployments\windeploy
    }

    $user = "vagrant"
    $pass = ConvertTo-SecureString -String "vagrant" -AsPlainText -Force
    $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, $pass

    cd $env:HOMEPATH\deployments\windeploy

    .\setup.ps1 `
      -UseRestricted=$UseRestricted `
      -EnvsetupRepo $EnvsetupRepo `
      -GitUser $GitUser `
      -GitEmail $GitEmail `
      -CredentialArg $Credential
}

Main
