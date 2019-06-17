Start-Transcript -Path "C:\ProvisionLog.txt" -append

$retry=$true
While ($retry -eq $true)
{
    Start-Sleep -Seconds 1
    Get-NetConnectionProfile | foreach {
        Try
        {
            Set-NetConnectionProfile -InterfaceIndex $_.InterfaceIndex -NetworkCategory Private
        }
        Catch
        {
            Write-Host "Could not set network to Private..."
        }
    }

    $retry=$false
    Get-NetConnectionProfile | foreach {
        if ($_.NetworkCategory -ne "Private") {
            $retry=$true
        }
    }

}

Write-Host "Network sucessfully configured to Private"

Enable-PSRemoting -SkipNetworkProfileCheck -Force
Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value $true
Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value $true
Set-Item -Path WSMan:\localhost\MaxTimeoutms -Value 2000000
# Set as per suggestion here:
# https://github.com/mwrock/packer-templates/issues/27#issuecomment-221421119
Set-Item -Path WSMan:\localhost\Shell\MaxMemoryPerShellMB -Value 2048
Stop-Service -Name WinRm

Set-Service -Name "winrm" -StartupType Automatic

Enable-NetFirewallRule -DisplayName "Windows Remote Management (HTTP-In)"

Start-Service -Name WinRm

Stop-Transcript
