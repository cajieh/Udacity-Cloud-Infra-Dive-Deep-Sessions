module "resource_group" {
  source = "../common/modules/resource_group"
  name     = var.name
  location = var.location
  tags     = var.tags
}

resource "random_string" "fqdn" {
  length  = 6
  special = false
  upper   = false
  numeric = false
}

module "kubernetes_cluster" {
  source              = "./modules/kubernetes_cluster"
  cluster_name        = "aks-cluster"
  location            = var.location
  resource_group_name = module.resource_group.name
  dns_prefix          = "aks-${random_string.fqdn.result}"
  appId               = var.appId
  password            = var.password 
  tags = var.tags
}