# Create Key Vault
resource "azurerm_key_vault" "key_vault" {
  name                        = lower("kv-${var.names.product_group}-${var.names.environment}-${var.names.location}-${random_integer.rand_int.result}")
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"
  tags     = var.tags

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = ["${chomp(data.http.clientip.body)}/32"]
    virtual_network_subnet_ids = [data.azurerm_subnet.snet.id]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azuread_client_config.current.object_id

    secret_permissions = [
      "Get", "Set", "List"
    ]
  }
}

resource "azurerm_key_vault_secret" "key_vault_secret" {
  name         = "localadmin"
  value        = random_password.password.result
  key_vault_id = azurerm_key_vault.key_vault.id
}