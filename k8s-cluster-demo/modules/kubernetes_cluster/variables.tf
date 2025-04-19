variable "cluster_name" {
  description = "The name of the Kubernetes cluster"
  type        = string
}

variable "location" {
  description = "The location/region where the Kubernetes cluster will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which the Kubernetes cluster will be created"
  type        = string
}

variable "dns_prefix" {
  description = "The DNS prefix for the Kubernetes cluster"
  type        = string
}

variable "default_node_pool_name" {
  description = "The name of the default node pool"
  type        = string
  default     = "default"
}

variable "default_node_pool_node_count" {
  description = "The number of nodes in the default node pool"
  type        = number
  default     = 2
}

variable "default_node_pool_vm_size" {
  description = "The size of the VMs in the default node pool"
  type        = string
  default     = "Standard_B2ms"
}

variable "network_plugin" {
  description = "The network plugin to use for the Kubernetes cluster"
  type        = string
  default     = "azure"
}

variable "load_balancer_sku" {
  description = "The SKU of the load balancer to use for the Kubernetes cluster"
  type        = string
  default     = "standard"
}

variable "tags" {
  description = "Tags to associate with the Kubernetes cluster"
  type        = map(string)
}