# Create a new resource group
 resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location
  tags     = var.tags
}


# Using an existing resource group
/* data "azurerm_resource_group" "this" {
  name = var.name
}*/