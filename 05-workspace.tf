resource "azurerm_virtual_desktop_workspace" "ws" {
  name                = var.ws_friendly_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  friendly_name = "${var.ws_friendly_name} Workspace"
  description   = "${var.ws_friendly_name} Workspace"

  tags = var.tags

  depends_on          = [azurerm_resource_group.rg]
}

resource "azurerm_monitor_diagnostic_setting" "avd-ws-logs" {
  name = lower("diag-${var.names.environment}-workspace")
  target_resource_id =  azurerm_virtual_desktop_workspace.ws.id 
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id
  depends_on = [azurerm_virtual_desktop_workspace.ws]
   enabled_log {
    category = "Error"

    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "Checkpoint"

    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "Management"

    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "Feed"

    retention_policy {
      enabled = false
    }
  }
}