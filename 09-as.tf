resource "azurerm_availability_set" "as" {
  name                = lower("as-presidio-${var.names.product_group}-${var.names.environment}-${var.names.location}-001")
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = var.tags
}