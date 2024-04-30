data "azurerm_client_config" "current" {}
data "azuread_client_config" "current" {}
data "azurerm_subscription" "current" {}

output "current_subscription_id" {
  value = data.azurerm_subscription.current.id
}

data "azuread_group" "avd_prod_users" {
  display_name     = "sg_avd_prod_users"  
}

data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.rg_name
}

data "azurerm_subnet" "snet" {
  name                 = var.snet-avdprod
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = var.rg_name
}

output "subnet_id" {
  value = data.azurerm_subnet.snet.id
}

data "azurerm_log_analytics_workspace" "law" {
  name = var.law_name
  resource_group_name = var.rg_name
}

output "law_id" {
  value = data.azurerm_log_analytics_workspace.law.workspace_id
}

locals {
  current_timestamp = timestamp()
  current_day       = formatdate("DDMMYYYY", local.current_timestamp)
  #timestamp_sanitized = replace("${local.timestamp}", "/[-| |T|Z|:]/", "")
}

#Get Client IP Address for NSG
data "http" "clientip" {
  url = "https://ipv4.icanhazip.com/"
}