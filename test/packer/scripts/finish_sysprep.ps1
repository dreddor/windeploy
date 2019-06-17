# After sysprep is complete, we can re-enable WinRM
Enable-NetFirewallRule -DisplayName "Windows Remote Management (HTTP-In)"
