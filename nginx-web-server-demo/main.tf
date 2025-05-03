
module "resource_group" {
  source = "../k8s-cluster-demo/modules/resource_group"
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

data "azurerm_resource_group" "image" {
  name = module.resource_group.name
}

data "azurerm_image" "image" {
  name                = var.packer_image_name
  resource_group_name = data.azurerm_resource_group.image.name
}