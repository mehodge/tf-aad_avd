locals {
  registration_token = azurerm_virtual_desktop_host_pool_registration_info.registrationkey.token
}

#NICs
resource "azurerm_network_interface" "avd" {
  count               = var.NumberOfSessionHosts
  name                = "nic-${var.vm_prefix}-${format("%02d", count.index + 1)}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = data.azurerm_subnet.snet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "avd" {
  count                 = var.NumberOfSessionHosts
  name                  = lower("avd-presidio-${format("%02d", count.index + 1)}")
  computer_name = lower("presidio-${format("%02d", count.index + 1)}")
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  availability_set_id = azurerm_availability_set.as.id
  network_interface_ids = [element(azurerm_network_interface.avd.*.id, count.index)]
  size                  = var.vm_size
  license_type          = "Windows_Client"
  admin_username        = "localadmin"
  admin_password        = azurerm_key_vault_secret.key_vault_secret.value

  additional_capabilities {
  }

  identity {
    type = "SystemAssigned"
  }
  
  os_disk {
    name                 = "osdisk-${var.vm_prefix}-${format("%02d", count.index + 1)}"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-22h2-avd"
    version   = "latest"
  }

  tags = var.tags
}

# Add AVD Agent to SH
resource "azurerm_virtual_machine_extension" "avd_aad_join" {
  count                      = var.NumberOfSessionHosts
  name                       = "AddAvdToAad"
  virtual_machine_id         = element(azurerm_windows_virtual_machine.avd.*.id, count.index)
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  
  settings = <<SETTINGS
  {
    "mdmId" : "0000000a-0000-0000-c000-000000000000"
  }
  SETTINGS

  depends_on = [ azurerm_windows_virtual_machine.avd ]
}

# Add to Azure AD
resource "azurerm_virtual_machine_extension" "aad_dsc" {
  count                      = var.NumberOfSessionHosts
  name                       = "AddToAVD"
  virtual_machine_id         = element(azurerm_windows_virtual_machine.avd.*.id, count.index)
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
            {
                "modulesUrl": "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_09-08-2022.zip",
                "configurationFunction": "Configuration.ps1\\AddSessionHost",            
                "properties": {
                    "hostPoolName": "${azurerm_virtual_desktop_host_pool.hp.name}",
                    "aadJoin": true,
                    "UseAgentDownloadEndpoint": true,
                    "aadJoinPreview": false,
                    "mdmId": "0000000a-0000-0000-c000-000000000000",
                    "sessionHostConfigurationLastUpdateTime": ""
                }
            }
            SETTINGS

            protected_settings = <<PROTECTED_SETTINGS
  {
    "properties": {
      "registrationInfoToken": "${local.registration_token}"
    }
  }
PROTECTED_SETTINGS  

  depends_on = [ azurerm_windows_virtual_machine.avd ]

  lifecycle {
    ignore_changes = all
  }
}

#Add FXLogix Profile Location in Registry
#Install Active Directory on the DC01 VM
resource "azurerm_virtual_machine_extension" "install_fslogix_regfiles" {
  count                = var.NumberOfSessionHosts
  name                 = "regedit_fslogix"
  virtual_machine_id   = element(azurerm_windows_virtual_machine.avd.*.id, count.index)
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  protected_settings = <<SETTINGS
  {    
    "commandToExecute": "powershell -encodedCommand ${textencodebase64(file("fslogix.ps1"), "UTF-16LE")}"
  }
  SETTINGS

  depends_on = [ azurerm_windows_virtual_machine.avd ]
}

/*
resource "null_resource" "FSLogix" {
  count = var.NumberOfSessionHosts
  provisioner "local-exec" {
    command     = "az vm run-command invoke --command-id RunPowerShellScript --name ${element(azurerm_windows_virtual_machine.avd.*.name, count.index)} -g ${azurerm_resource_group.rg.name} --scripts 'New-ItemProperty -Path HKLM:\\SOFTWARE\\FSLogix\\Profiles -Name VHDLocations -Value \\\\${azurerm_storage_account.sa_avd.name}.file.core.windows.net\\${azurerm_storage_share.profiles} -PropertyType MultiString;New-ItemProperty -Path HKLM:\\SOFTWARE\\FSLogix\\Profiles -Name Enabled -Value 1 -PropertyType DWORD;New-ItemProperty -Path HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Lsa\\Kerberos\\Parameters -Name CloudKerberosTicketRetrievalEnabled -Value 1 -PropertyType DWORD;New-Item -Path HKLM:\\Software\\Policies\\Microsoft\\ -Name AzureADAccount;New-ItemProperty -Path HKLM:\\Software\\Policies\\Microsoft\\AzureADAccount  -Name LoadCredKeyFromProfile -Value 1 -PropertyType DWORD;Restart-Computer'"
    interpreter = ["PowerShell", "-Command"]
  }
  depends_on = [ azurerm_virtual_machine_extension.avd_dsc ]
}
*/