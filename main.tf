#############################################################################
# VARIABLES
#############################################################################
#change#

variable "resource_group_name" {
  type = string
  default = "rg-terraform-test-neu-001"
}

variable "location" {
  type    = string
  default = "North Europe"
}


variable "address_space" {
  type    = list(string)
  default = ["10.0.0.0/20"]
}

variable "subnet_prefixes" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "subnet_names" {
  type    = list(string)
  default = ["web", "database","vm", "storage"]
}

variable "vnet_name" {
  type    = string
  default = "vnet-terraform-test-001"
}

variable "storageaccountname" {
  type    = string
  default = "strjagterraform01"
}

#############################################################################
# PROVIDERS
#############################################################################

#Provides configuration details for Terraform
terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = ""
            }
    }
}

# Provides configuration details for the Azure Terraform required_providers
provider "azurerm" {
    features{}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags = {
      Service   = "Terraform"
      Owner     = "Jag Sandhu"
  }
  }

#############################################################################
# RESOURCES
#############################################################################
#Vnet
module "vnet" {
  source              = "Azure/vnet/azurerm"
  version             = "2.3.0"
  resource_group_name = var.resource_group_name
  vnet_name           = var.vnet_name
  address_space       = var.address_space
  subnet_prefixes     = var.subnet_prefixes
  subnet_names        = var.subnet_names
  
  subnet_service_endpoints = {
    database  = ["Microsoft.Sql"],
    storage   = ["Microsoft.Storage"]
  }

tags = {
    Service = "Terraform"
    Owner   = "Jag Sandhu"
  }
  depends_on = [var.resource_group_name]
}

#Storage Account
resource "azurerm_storage_account" "example" {
  name                     = var.storageaccountname
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action             = "Deny"
    ip_rules                   = ["100.0.0.1"]
  }


  tags = {
    Service = "Terraform"
  }
}

terraform {
  backend "azurerm" {
    resource_group_name   = "rg-generic-test-neu-001"
    storage_account_name  = "strjagtestlab001"
    container_name        = "tstate"
    key                   = "FPBWn7nTy29Zvtzl2rpEenKL9tUdGUUUho4sJJsgH+EjSM/QOQ8CzsAe4Ih3vYVd1PVpWSX4ZX9yVJNPp3iZdg=="
}
}