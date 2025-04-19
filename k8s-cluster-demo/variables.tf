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

variable "packer_resource_group_name" {
  description = "Name of the resource group in which the Packer image will be created"
  default     = "Azuredevops"
}

variable "packer_image_name" {
  description = "Name of the Packer image"
  default     = "myPackerImage"
}

variable "resource_group_name" {
  description = "Name of the resource group in which the Packer image  will be created"
  default     = "Azuredevops"
}

variable "application_port" {
  description = "Port that you want to expose to the external load balancer"
  default     = 80
}

variable "admin_user" {
  description = "User name to use as the admin account on the VMs that will be part of the VM scale set"
  default     = "azureuser"
}

variable "admin_password" {
  description = "Default password for admin account"
  default     = "Love123@"
}

variable "vm_count" {
  description = "The number of virtual machines to create"
  type        = number
  default     = 2
}