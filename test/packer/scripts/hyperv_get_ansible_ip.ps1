$ip = Get-VM | Where-Object -Property Name -eq "win10_base_image_sysprep" |
  Select -ExpandProperty NetworkAdapters |
  Select -ExpandProperty IPAddresses |
  Select-Object -First 1
$HostFile=$PSScriptRoot.Parent.Parent.FullName + "hyperv_host.ini"
$HostContent = "[windows]
$ip"
Out-File -FilePath $HostFile -InputObject $HostContent -Encoding ASCII
