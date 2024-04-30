#Persistant Storage for Weaviate DB
resource "azurerm_storage_account" "sa_avd" {
  name                          = lower("sapresidioprofile${var.names.environment}")
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  account_tier                  = "Premium"
  account_replication_type      = "LRS"
  account_kind                  = "FileStorage"
  enable_https_traffic_only     = true
  public_network_access_enabled = true
  min_tls_version               = "TLS1_2"

  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [data.azurerm_subnet.snet.id]
    ip_rules                   = ["${chomp(data.http.clientip.body)}"]
    bypass                     = ["Metrics", "Logging", "AzureServices"]
  }

  azure_files_authentication {
    directory_type = "AADKERB"
  }
  
  depends_on = [ azurerm_resource_group.rg ]
}

resource "azurerm_storage_share" "profiles" {
  name                 = "fsprofiles"
  storage_account_name = azurerm_storage_account.sa_avd.name
  quota                = 100
  depends_on           = [azurerm_storage_account.sa_avd]
}

## Azure built-in roles
## https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
data "azurerm_role_definition" "storage_role" {
  name = "Storage File Data SMB Share Contributor"
}

resource "azurerm_role_assignment" "af_role" {
  scope              = azurerm_storage_account.sa_avd.id
  role_definition_id = data.azurerm_role_definition.storage_role.id
  principal_id       = data.azuread_group.avd_prod_users.id
}