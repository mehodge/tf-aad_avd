terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.67.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.43.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3"
    }
    
    http = {
      source = "hashicorp/http"
      version = "~>3"
    }
    
  }

  /*
  backend "azurerm" {
    resource_group_name  = "rg-tf-avd-backend-prod-neu-001"
    storage_account_name = "avd1459655330"
    container_name       = "prodtfstate"
    key                  = "terraform.tfstate"
    }
    */

    backend "azurerm" {
    resource_group_name  = "rg-tf-avd-backend-prod-neu-001"
    storage_account_name = "avd1935549823"
    container_name       = "prodtfstate"
    key                  = "terraform.tfstate"
    }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    virtual_machine {
    delete_os_disk_on_deletion     = true
    }
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}