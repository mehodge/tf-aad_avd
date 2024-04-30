#Locals
names = {
  product_group : "AVD"
  environment : "Prod"
  location : "NEU"
}

#Tags
tags = {
  "Application"         = "AVD"
  "Data Classification" = "Internal"
  "Environment"         = "Prod"
  "Monitoring"          = "PresMoff"
  "Owner"               = "Mehodge"
  "Vendor"              = "Mehodge"
}

#Location
location = "northeurope"

#RG Name for AVD Shared Resources
rg_name = "rg-shared-avd-prod-neu-001"

#VNet Name for AVD Shared Resources
vnet_name = "vnet-shared-avd-prod-neu-001"
snet-avdprod = "snet-avdprod"

#LAW Name
law_name = "law-avd-prod-neu-001"

#Workspace
load_balancer_type = "DepthFirst"

ws_friendly_name = "Presidio-AVD"
#Desktop Application Groups


#Hostpool
NumberOfSessionHosts = 1
vm_prefix = "presidio"
vm_size = "Standard_E2ds_v5"