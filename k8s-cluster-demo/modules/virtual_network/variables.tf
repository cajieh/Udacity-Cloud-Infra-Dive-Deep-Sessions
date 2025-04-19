variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
}

variable "address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
}

variable "location" {
  description = "Azure region where the Virtual Network will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group for the Virtual Network"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the Virtual Network resources"
  type        = map(string)
  default     = {}
}

variable "subnet_name" {
  description = "Name of the Subnet"
  type        = string
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for the Subnet"
  type        = list(string)
}