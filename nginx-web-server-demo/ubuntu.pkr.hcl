# This configuration file is used for defining a Packer template.
# It specifies the required plugins for building images, particularly the Azure plugin.
# The `packer` block declares the dependencies needed for the build process.
# The `required_plugins` section includes the Azure plugin, sourced from HashiCorp's repository,
# with a version constraint of `~> 2`, ensuring compatibility with version 2.x.
packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2"
    }
  }
}
# This file defines variables for a Packer template configuration.
# Each variable is used to parameterize the Packer build process for creating resources in a cloud environment.
#
# Variables:
# - `client_id` (string): The client ID for authentication. This is required to access the cloud provider's API.
# - `client_secret` (string): The client secret for authentication. This is required to securely authenticate the client.
# - `subscription_id` (string): The subscription ID associated with the cloud account. This identifies the subscription to use.
# - `tenant_id` (string): The tenant ID for the cloud environment. This is used for multi-tenant authentication.
# - `location` (string): The geographical location where the resources will be deployed. This determines the data center region.

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
  default     = "modern-cloud-infra"
}

variable "oidc_request_url" {
  default = null
}

variable "oidc_request_token" {
  default = null
}

# arm builder
/**
 * This configuration defines a Packer template for building a managed image in Azure.
 * 
 * - **source "azure-arm" "builder"**: Specifies the Azure Resource Manager (ARM) builder.
 * - **client_id**: The client ID of the Azure service principal used for authentication.
 * - **client_secret**: The client secret of the Azure service principal used for authentication.
 * - **image_offer**: The offer of the base image to use (e.g., "UbuntuServer").
 * - **image_publisher**: The publisher of the base image (e.g., "canonical").
 * - **image_sku**: The SKU of the base image (e.g., "16.04-LTS").
 * - **location**: The Azure region where the image will be built.
 * - **managed_image_name**: The name of the managed image to be created.
 * - **managed_image_resource_group_name**: The resource group where the managed image will be stored.
 * - **os_type**: The operating system type of the image (e.g., "Linux").
 * - **subscription_id**: The Azure subscription ID where the image will be created.
 * - **tenant_id**: The Azure tenant ID for authentication.
 * - **oidc_request_url**: The URL for OpenID Connect (OIDC) authentication requests.
 * - **oidc_request_token**: The token for OIDC authentication requests.
 * - **vm_size**: The size of the virtual machine used during the image build process (e.g., "Standard_B1s").
 * - **azure_tags**: A map of tags to apply to the Azure resources created during the build process.
 *   - **DeploymentId**: A custom tag to identify the deployment (e.g., "277109").
 */
source "azure-arm" "builder" {
  client_id                         = var.client_id
  client_secret                     = var.client_secret
  image_offer                       = "UbuntuServer"
  image_publisher                   = "canonical"
  image_sku                         = "16.04-LTS"
  location                          = var.location
  managed_image_name                = "customPackerImage"
  managed_image_resource_group_name = var.image_resource_group_name
  os_type                           = "Linux"
  subscription_id                   = var.subscription_id
  tenant_id                         = var.tenant_id
  oidc_request_url                  = var.oidc_request_url
  oidc_request_token                = var.oidc_request_token
  vm_size                           = "Standard_B1s"
  azure_tags = {
      env: "dev"
  }
}
/**
 * This Packer template defines a build configuration for creating a custom Ubuntu image.
 * 
 * - **Build Sources**: The image is built using the Azure ARM builder source.
 * - **Provisioner**: A shell provisioner is used to configure the image.
 *   - **execute_command**: Specifies the command to execute the shell script with elevated privileges.
 *   - **inline**: Contains a series of shell commands to:
 *     1. Update the package list (`apt-get update`).
 *     2. Upgrade all installed packages to their latest versions (`apt-get upgrade -y`).
 *     3. Install the Nginx web server (`apt-get -y install nginx`).
 *     4. Create a custom HTML file at `/var/www/html/index.html` with a welcome message.
 *     5. Deprovision the VM using the Azure Linux Agent (`waagent`) to prepare it for reuse, clear the shell history, and sync the filesystem.
 * 
 * This configuration is intended for use in a Kubernetes cluster demo as part of Udacity's Deep Dive Session on Modern Cloud Infrastructure.
 */

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