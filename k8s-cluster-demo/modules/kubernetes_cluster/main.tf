resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix  # The `dns_prefix` variable specifies the DNS prefix to be used for the Kubernetes cluster.
  kubernetes_version  = "1.30.11" # Check for version supported in your region using `az aks get-versions --location <region-name>`.


    # This block defines the default node pool configuration for a Kubernetes cluster.
    default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_B2ms"
    os_disk_size_gb = 30 # The size of the operating system disk for each node.
  }

service_principal {
    client_id     = var.appId
    client_secret = var.password
  }

  # The `network_profile` block defines the network configuration for the Kubernetes cluster.
    network_profile {
    network_plugin     = "azure"
    load_balancer_sku  = "standard"
  }

# Setting this to `true` ensures that access to the cluster is managed using RBAC policies.
role_based_access_control_enabled = true

  tags = var.tags
}