variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "name" {
  description = "Name of the resource group"
  type        = string
  default     = "modern-cloud-infra"
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = { env: "dev"}
}