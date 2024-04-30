#Enable Kerberod Key for AAD Login
$RegistryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters"
$Name = "CloudKerberosTicketRetrievalEnabled"
$Value = '1'

If (-NOT (Test-Path $RegistryPath)) {
    New-Item -Path $RegistryPath -Force | Out-Null
}
New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -PropertyType DWORD -Force

#Load Profile from Cred Key
$RegistryPath = "HKLM:\Software\Policies\Microsoft\AzureADAccount"
$Name = "LoadCredKeyFromProfile"
$Value = '1'

If (-NOT (Test-Path $RegistryPath)) {
    New-Item -Path $RegistryPath -Force | Out-Null
}
New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -PropertyType DWORD -Force

# Configure FSLogix
$VhdLocations = "\\sapresidioprofileprod.file.core.windows.net\fsprofiles"
$RegistryPath = "HKLM:\Software\FSLogix\Profiles"

If (-NOT (Test-Path $RegistryPath)) {
    New-Item -Path $RegistryPath -Force | Out-Null
}
New-ItemProperty -Path $RegistryPath -Name "Enabled" -Value 1 -PropertyType DWORD -Force
New-ItemProperty -Path $RegistryPath -Name "ClearCacheOnLogoff" -Value 1 -PropertyType DWORD -Force
New-ItemProperty -Path $RegistryPath -Name "DeleteLocalProfileWhenVHDShouldApply" -Value 1 -PropertyType DWORD -Force
New-ItemProperty -Path $RegistryPath -Name "PreventLoginWithFailure" -Value 1 -PropertyType DWORD -Force
New-ItemProperty -Path $RegistryPath -Name "PreventLoginWithTempProfile" -Value 1 -PropertyType DWORD -Force
New-ItemProperty -Path $RegistryPath -Name "CleanupInvalidSessions" -Value 1 -PropertyType DWORD -Force
New-ItemProperty -Path $registryPath -Name "FlipFlopProfileDirectoryName" -Value 1 -PropertyType DWord -Force
New-ItemProperty -Path $RegistryPath -Name VHDLocations -Value $VhdLocations -PropertyType STRING -Force