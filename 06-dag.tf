resource "azurerm_virtual_desktop_application_group" "dag" {
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  type          = "Desktop"
  name          = var.ws_friendly_name
  host_pool_id  = azurerm_virtual_desktop_host_pool.hp.id
  friendly_name = "${var.ws_friendly_name} Desktop App Group"
  description   = "${var.ws_friendly_name} Desktop Group"
  default_desktop_display_name = "${var.ws_friendly_name} Desktop"
  tags = var.tags

  depends_on          = [azurerm_virtual_desktop_host_pool.hp, azurerm_virtual_desktop_workspace.ws]
}

# Associate Workspace and DAG
resource "azurerm_virtual_desktop_workspace_application_group_association" "ws-dag" {
  application_group_id = azurerm_virtual_desktop_application_group.dag.id
  workspace_id         = azurerm_virtual_desktop_workspace.ws.id
}

# Add AVD Users to DAG
resource "azurerm_role_assignment" "AVDGroupDesktopAssignment" {
  scope                = azurerm_virtual_desktop_application_group.dag.id
  role_definition_name = "Desktop Virtualization User"
  principal_id         = data.azuread_group.avd_prod_users.object_id
}

# Add RBAC Role Virtual Desktop User Login to Users
resource "azurerm_role_assignment" "RBACAssignment" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Virtual Machine User Login"
  principal_id         = data.azuread_group.avd_prod_users.object_id
}

resource "azurerm_monitor_diagnostic_setting" "fd-logs" {
  name = lower("diag-${var.names.environment}-dag")
  target_resource_id = azurerm_virtual_desktop_application_group.dag.id 
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id
  depends_on = [
    azurerm_virtual_desktop_application_group.dag
  ]
  enabled_log {
    category = "Checkpoint"

    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "Error"

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
}