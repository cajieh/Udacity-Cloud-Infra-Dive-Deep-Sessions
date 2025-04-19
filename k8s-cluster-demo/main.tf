terraform {

  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 1.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

module "resource_group" {
  source = "./modules/resource_group"
  name     = var.name
  location = var.location
  tags     = var.tags
}

module "virtual_network" {
  source                = "./modules/virtual_network"
  vnet_name             = "vmss-vnet"
  address_space         = ["10.0.0.0/16"]
  location              = var.location
  resource_group_name   = module.resource_group.name
  tags                  = var.tags
  subnet_name           = "vmss-subnet"
  subnet_address_prefixes = ["10.0.2.0/24"]
}