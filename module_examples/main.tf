provider "azurerm" {
  features {}
}

# Reference for child module in root module
module "resource_group" {
  source = "./modules/resource_group"
  name     = "rg-example-1"  # Required field
  location = var.location  # Required field
}

module "resource_group_2" {
  source = "./modules/resource_group"
  name     = "rg-example-2"  # Required field
  location = var.location  # Required field
}

module "resource_group_3" {
  source = "./modules/resource_group"
  name     = "rg-example-3"  # Required field
  location = var.location  # Required field
}