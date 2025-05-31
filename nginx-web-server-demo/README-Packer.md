## Cloud Infra Demo - Packer

### Introduction

This Packer template (ubuntu.pkr.hcl) is used to create a custom Azure Managed Image based on Ubuntu Server 16.04-LTS. The image is provisioned with Nginx and a custom HTML page, and it is prepared for deployment in Azure. Below is a detailed explanation of the key components:

GitHub Copilot
This Packer template (ubuntu.pkr.hcl) is used to create a custom Azure Managed Image based on Ubuntu Server 16.04-LTS. The image is provisioned with Nginx and a custom HTML page, and it is prepared for deployment in Azure. Below is a detailed explanation of the key components:

1. Packer Configuration

```
packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2"
    }
  }
}
```

- Packer Plugins: Specifies the required plugin for Azure (azure).
- Version: Ensures compatibility with version ~> 2 of the Azure plugin.

2. Variables

```
variable client_id { ... }
variable client_secret { ... }
variable subscription_id { ... }
variable tenant_id { ... }
variable location { ... }
variable "image_resource_group_name" { ... }
variable "oidc_request_url" { ... }
variable "oidc_request_token" { ... }
```

- Purpose: These variables allow you to pass credentials, subscription details, and other configurations dynamically.
- Key Variables:
  `client_id`, `client_secret`, `subscription_id`, `tenant_id`: Required for authenticating with Azure.
- `location`: Specifies the Azure region where the image will be created.
- `image_resource_group_name`: The resource group where the managed image will be stored.
- `oidc_request_url` and `oidc_request_token`: Optional variables for OpenID Connect (OIDC) authentication.

3. Azure ARM Builder

```
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
```

- Builder Type: azure-arm is used to create an Azure Managed Image.
- Key Attributes:
  `client_id`, `client_secret`, `subscription_id`, `tenant_id`: Used for Azure authentication.
- Image Details:
  - `image_offer`: Specifies the base image offer (UbuntuServer).
  - `image_publisher`: Specifies the publisher (Canonical).
  - `image_sku`: Specifies the SKU (16.04-LTS).
  - `managed_image_name`: The name of the custom image to be created (myPackerImage).
  - `managed_image_resource_group_name`: The resource group where the image will be stored.
  - `VM Size`: The temporary VM used for building the image is of size Standard_B1s.
  - `Tags`: Adds metadata tags to the image (e.g., DeploymentId).

4. Build Block

```
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
```

- Sources: Specifies the builder (source.azure-arm.builder) to use for creating the image.
- Provisioner: Executes shell commands to configure the image.
- Commands: 1. Update and Upgrade:

      ```
      apt-get update
      apt-get upgrade -y
      ````

  Ensures the base image is up-to-date.

2. Install Nginx:
   ```
   apt-get -y install nginx
   ````
   Installs the Nginx web server.
3. Custom HTML Page:

   ```
   echo '<!DOCTYPE html><html><head><title>Welcome</title></head><body><h1>Welcome to Udacity Deep Dive Session on Modern Cloud Infrastructure</h1></body></html>' > /var/www/html/index.html
   ```

   Creates a custom HTML page to be served by Nginx.

4. Deprovision the VM:

```
/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync
```

Prepares the VM for imaging by removing sensitive data and resetting the machine.

5. Key Features
   Custom HTML Page:

- The custom HTML page is created at `/var/www/html/index.html` and will be served by Nginx when the VM is deployed.
- Nginx Installation: Ensures that the image is pre-configured with a web server.
- Deprovisioning: The waagent command ensures that the VM is properly deprovisioned before creating the image, making it ready for reuse.
- Dynamic Variables: Credentials and configuration details are passed as variables, making the template reusable across different environments.

### How to Use This Template

#### Step 1: Create a variables.pkrvars.hcl File

Define the required variables in a `variables.pkrvars.hcl` file:

```
client_id       = "<your-client-id>"
client_secret   = "<your-client-secret>"
subscription_id = "<your-subscription-id>"
tenant_id       = "<your-tenant-id>"
location        = "eastus"
```

GitHub Copilot
This Packer template (ubuntu.pkr.hcl) is used to create a custom Azure Managed Image based on Ubuntu Server 16.04-LTS. The image is provisioned with Nginx and a custom HTML page, and it is prepared for deployment in Azure. Below is a detailed explanation of the key components:

1. Packer Configuration
   Packer Plugins: Specifies the required plugin for Azure (azure).
   Version: Ensures compatibility with version ~> 2 of the Azure plugin.
2. Variables
   Purpose: These variables allow you to pass credentials, subscription details, and other configurations dynamically.
   Key Variables:
   client_id, client_secret, subscription_id, tenant_id: Required for authenticating with Azure.
   location: Specifies the Azure region where the image will be created.
   image_resource_group_name: The resource group where the managed image will be stored.
   oidc_request_url and oidc_request_token: Optional variables for OpenID Connect (OIDC) authentication.
3. Azure ARM Builder
   Builder Type: azure-arm is used to create an Azure Managed Image.
   Key Attributes:
   client_id, client_secret, subscription_id, tenant_id: Used for Azure authentication.
   Image Details:
   image_offer: Specifies the base image offer (UbuntuServer).
   image_publisher: Specifies the publisher (Canonical).
   image_sku: Specifies the SKU (16.04-LTS).
   managed_image_name: The name of the custom image to be created (myPackerImage).
   managed_image_resource_group_name: The resource group where the image will be stored.
   VM Size: The temporary VM used for building the image is of size Standard_B1s.
   Tags: Adds metadata tags to the image (e.g., DeploymentId).
4. Build Block
   Sources: Specifies the builder (source.azure-arm.builder) to use for creating the image.
   Provisioner: Executes shell commands to configure the image.
   Commands:
   Update and Upgrade:
   Ensures the base image is up-to-date.
   Install Nginx:
   Installs the Nginx web server.
   Custom HTML Page:
   Creates a custom HTML page to be served by Nginx.
   Deprovision the VM:
   Prepares the VM for imaging by removing sensitive data and resetting the machine.
5. Key Features
   Custom HTML Page:

The custom HTML page is created at /var/www/html/index.html and will be served by Nginx when the VM is deployed.
Nginx Installation:

Ensures that the image is pre-configured with a web server.
Deprovisioning:

The waagent command ensures that the VM is properly deprovisioned before creating the image, making it ready for reuse.
Dynamic Variables:

Credentials and configuration details are passed as variables, making the template reusable across different environments.
How to Use This Template
Step 1: Create a variables.pkrvars.hcl File
Define the required variables in a variables.pkrvars.hcl file:

#### Step 2: Run the Packer Build Command

Run the following command to build the image:

```
packer build -var-file=variables.pkrvars.hcl ubuntu.pkr.hcl
```

#### Conclusion:

##### Expected Outcome

- A custom Azure Managed Image named myPackerImage will be created in the resource group modern-cloud-infra.
- The image will have:
  Nginx installed.
  A custom HTML page at `/var/www/html/index.html`.
- The image can be used to deploy VMs or VM scale sets in Azure.

#### Instal Packer on Azure CLI Shell
Link: https://gist.github.com/Adron/90863e51c8c5c0ad2049890bcd8abbfb