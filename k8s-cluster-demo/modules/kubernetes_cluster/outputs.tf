
output "kube_config_raw" {
  description = "The raw kubeconfig for the Kubernetes cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "kubernetes_cluster_name" {
  description = "The name of the Kubernetes cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}
