resource "azurerm_virtual_desktop_host_pool" "hp" {
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  name                     = var.ws_friendly_name
  friendly_name            = var.ws_friendly_name
  validate_environment     = true
  start_vm_on_connect      = true
  custom_rdp_properties    = "targetisaadjoined:i:1;drivestoredirect:s:*;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:1;devicestoredirect:s:*;redirectcomports:i:1;redirectsmartcards:i:1;usbdevicestoredirect:s:*;redirectwebauthn:i:1;use multimon:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;redirectlocation:i:1;keyboardhook:i:0;enablerdsaadauth:i:1"
  description              = "${var.ws_friendly_name} - pooleddepthfirst"
  type                     = "Pooled"
  maximum_sessions_allowed = 4
  
  load_balancer_type       = var.load_balancer_type
  scheduled_agent_updates {
    enabled  = true
    timezone = "GMT Standard Time"
    schedule {
      day_of_week = "Saturday"
      hour_of_day = 2
    }
  }
  tags = var.tags
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "registrationkey" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.hp.id
  expiration_date = timeadd(timestamp(), "180m")
}

resource "azurerm_monitor_diagnostic_setting" "avd-logs" {
    name = lower("diag-${var.names.environment}-hostpool")
    target_resource_id = azurerm_virtual_desktop_host_pool.hp.id
    log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id
    depends_on = [azurerm_virtual_desktop_host_pool.hp]
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
    category = "Connection"

    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "HostRegistration"

    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "AgentHealthStatus"

    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "NetworkData"

    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "SessionHostManagement"

    retention_policy {
      enabled = false
    }
  }
}