# Disable WinRM while sysprep runs
powershell.exe -Command 'Disable-NetFirewallRule -DisplayName \"Windows Remote Management (HTTP-In)\"'

C:\Windows\System32\Sysprep\sysprep.exe /generalize /shutdown /oobe /unattend:C:\temp\unattend.xml
