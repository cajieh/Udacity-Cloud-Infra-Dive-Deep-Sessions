# Create a new resource group
resource "azurerm_resource_group" "rg" {
  name     = var.name
  location = var.location
  tags = {env  =  "dev"}
 }