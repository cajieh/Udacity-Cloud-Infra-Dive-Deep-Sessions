resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = "1.30.11" # Check for version supported in your region using `az aks get-versions --location <region-name>`.

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_B2ms"
    os_disk_size_gb = 30
  }

service_principal {
    client_id     = var.appId
    client_secret = var.password
  }

  network_profile {
    network_plugin     = "azure"
    load_balancer_sku  = "standard"
  }

role_based_access_control_enabled = true

  tags = var.tags
}