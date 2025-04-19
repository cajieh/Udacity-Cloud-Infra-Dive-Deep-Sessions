variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "name" {
  description = "Name of the resource group"
  type        = string
  default     = "k8s-cluster-demo-rg"
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = {
    env = "dev"
  }
}