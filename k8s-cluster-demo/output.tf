output "resource_group_name" {
  value = module.resource_group.name
}

output "kubernetes_cluster_name" {
  description = "The name of the Kubernetes cluster"
  value       = module.kubernetes_cluster.kubernetes_cluster_name
}
