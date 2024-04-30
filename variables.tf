variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
}

variable "names" {
  description = "Names to be applied to resources"
  type        = map(string)
}

variable "location" {
  type    = string
  default = "northeurope"
}

variable "rg_name" {
  type = string
  default = "rg-shared-avd-prod-neu-001"
}

#Networking Variables
variable "vnet_name" {
  default = "vnet-shared-avd-prod-neu-001"
}

variable "snet-avdprod" {
  default = "snet-avdprod"
}

variable "law_name" {
  type = string
}

## Azure Virtual Desktop items
variable "ws_friendly_name" {
  type        = string
  description = "Name to be displayed to users in Desktop App"
}

variable "load_balancer_type" {
  type        = string
  description = "Session Host loading type. Can be DepthFirst or BreadthFirst"
}

#Storage Account

# Session Host Vars
variable "NumberOfSessionHosts" {
  type    = number
  default = 1
}

variable "vm_prefix" {
  type    = string
  default = "presidio"
}

variable "vm_size" {
  type = string
  default = "Standard_B2s"
}

# AVD Agent Location
#variable "avd_agent_location" {
#  type    = string
#  default = "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_06-15-2022.zip"
#}