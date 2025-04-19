packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2"
    }
  }
}

variable client_id {
  type    = string
  description = "Enter client_id"
}
variable client_secret {
  type    = string
  description = "Enter client_secret"
}

variable subscription_id {
  type    = string
  description = "Enter subscription_id"
}

variable tenant_id {
  type    = string
  description = "Enter tenant_id"
}

variable location {
  description = "Enter location"
}

variable "image_resource_group_name" {
  description = "Name of the resource group in which the Packer image will be created"
  default     = "k8s-cluster-demo-rg"
}

variable "oidc_request_url" {
  default = null
}

variable "oidc_request_token" {
  default = null
}

# arm builder
source "azure-arm" "builder" {
  client_id                         = var.client_id
  client_secret                     = var.client_secret
  image_offer                       = "UbuntuServer"
  image_publisher                   = "canonical"
  image_sku                         = "16.04-LTS"
  location                          = var.location
  managed_image_name                = "myPackerImage"
  managed_image_resource_group_name = var.image_resource_group_name
  os_type                           = "Linux"
  subscription_id                   = var.subscription_id
  tenant_id                         = var.tenant_id
  oidc_request_url                  = var.oidc_request_url
  oidc_request_token                = var.oidc_request_token
  vm_size                           = "Standard_B1s"
  azure_tags = {
       DeploymentId = "277109"
  }
}

build {
  sources = ["source.azure-arm.builder"]
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline = [
      "apt-get update",
      "apt-get upgrade -y",
      "apt-get -y install nginx",
      "echo '<!DOCTYPE html><html><head><title>Welcome</title></head><body><h1>Welcome to Udacity Deep Dive Session on Modern Cloud Infrastructure</h1></body></html>' > /var/www/html/index.html",
      "/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync",
    ]
  }
}