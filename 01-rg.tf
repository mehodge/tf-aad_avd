# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = lower("rg-presidio-${var.names.product_group}-${var.names.environment}-${var.names.location}-001")
  location = var.location
  tags     = var.tags
}