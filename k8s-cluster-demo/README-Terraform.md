## Cloud Infra Demo - Terrform

### Introduction
This Terraform configuration defines a complete infrastructure setup in Azure, including a resource group, virtual network, jumpbox virtual machines, virtual machine scale set (VMSS), load balancer, network security group (NSG), and a Kubernetes cluster. Below is a detailed explanation of the key components:

#### Preinstallation:
Configure your environment:
- Azure subscription: If you don't have an Azure subscription, create a free account before you begin.
- Setup Configure Azure CLI, Packer, Terraform
- Create Resource Group
    ```
    az group create -n k8s-cluster-demo-rg -l eastus
    ```
- Show Azure Subscription ID
    ```
    az account show --query "{ subscription_id: id }"
    ```
- Run `az ad sp create-for-rbac` to to authenticate to Azure using a service principal.
    ```
    az ad sp create-for-rbac --role Contributor --scopes /subscriptions/<subscription_id> --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"
    ```
Key points: Make note of the output values (appId, client_secret, tenant_id)


1. Terraform Configuration and Providers

```
terraform {
  required_version = ">=0.12"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~>3.0" }
    azapi   = { source = "Azure/azapi", version = "~> 1.0" }
    local   = { source = "hashicorp/local", version = "2.4.0" }
    random  = { source = "hashicorp/random", version = "3.5.1" }
    tls     = { source = "hashicorp/tls", version = "4.0.4" }
  }
}
```

- Providers: Specifies the required providers for Azure (azurerm), Azure API (azapi), and utility providers like random, local, and tls.
- Version Constraints: Ensures compatibility with specific versions of Terraform and providers.

2. Resource Group

```
module "resource_group" {
  source   = "./modules/resource_group"
  name     = var.name
  location = var.location
  tags     = var.tags
}
```
Resource Group: A module is used to create a resource group. The name, location, and tags are passed as variables.

3. Virtual Network
```
module "virtual_network" {
  source                = "./modules/virtual_network"
  vnet_name             = "vmss-vnet"
  address_space         = ["10.0.0.0/16"]
  location              = var.location
  resource_group_name   = module.resource_group.name
  tags                  = var.tags
  subnet_name           = "vmss-subnet"
  subnet_address_prefixes = ["10.0.2.0/24"]
}
```

- Virtual Network: Another module is used to create a virtual network with a subnet.
- Address Space: The VNet has an address space of 10.0.0.0/16, and the subnet uses 10.0.2.0/24.

4. Random Resources

```
resource "random_pet" "id" {}
resource "random_string" "fqdn" {
  length  = 6
  special = false
  upper   = false
  numeric = false
}
```

- Random Pet: Generates a random name for resources.
- Random String: Generates a random string for the fully qualified domain name (FQDN) of the public IP.

5. Load Balancer

```
resource "azurerm_public_ip" "vmss" { ... }
resource "azurerm_lb" "vmss" { ... }
resource "azurerm_lb_backend_address_pool" "bpepool" { ... }
resource "azurerm_lb_probe" "vmss" { ... }
resource "azurerm_lb_rule" "lbnatrule" { ... }
```

- Public IP: A static public IP is created for the load balancer.
- Load Balancer: Configures a load balancer with a backend address pool and health probe.
- Load Balancer Rule: Forwards HTTP traffic (port 80) to the backend VMs.

6. Virtual Machine Scale Set (VMSS)

```
resource "azurerm_virtual_machine_scale_set" "vmss" { ... }
```

- VMSS: Creates a scale set with 2 instances (capacity = 2).
- Image: Uses a custom image created by Packer (data.azurerm_image.image.id).
- OS Profile: Configures the admin username, password, and SSH keys.
- Network Profile: Associates the VMSS with the load balancer's backend pool.

7. Jumpbox Virtual Machines

```
resource "azurerm_virtual_machine" "jumpbox" { ... }
resource "azurerm_public_ip" "jumpbox" { ... }
resource "azurerm_network_interface" "jumpbox" { ... }
resource "azurerm_network_security_group" "jumpbox" { ... }
resource "azurerm_network_interface_security_group_association" "jumpbox" { ... }
```

- Jumpbox VMs: Creates one or more VMs (count = var.vm_count) for administrative access.
- Public IP: Each VM gets a static public IP.
- Network Interface: Each VM gets a network interface associated with the NSG.
- NSG: Allows SSH (port 22) and HTTP (port 80) traffic while denying all other inbound traffic.

8. Kubernetes Cluster

```
module "kubernetes_cluster" {
  source              = "./modules/kubernetes_cluster"
  cluster_name        = "aks-cluster"
  location            = var.location
  resource_group_name = module.resource_group.name
  dns_prefix          = "aks-${random_string.fqdn.result}"
  default_node_pool_name       = "default"
  default_node_pool_node_count = 2
  default_node_pool_vm_size    = "Standard_B2ms"
  network_plugin    = "azure"
  load_balancer_sku = "standard"
  tags = var.tags
}
```
- Kubernetes Cluster: A module is used to create an Azure Kubernetes Service (AKS) cluster.
- Node Pool: Configures a default node pool with 2 nodes of size Standard_B2ms.
- Networking: Uses the Azure CNI plugin and a standard load balancer.

9. SSH Key Management

```
resource "azapi_resource" "ssh_public_key" { ... }
resource "azapi_resource_action" "ssh_public_key_gen" { ... }
```
SSH Public Key: Uses the azapi provider to create and manage SSH keys for the VMs and VMSS.

11. Tags

All resources include tags for better organization and management:
```
tags = var.tags
```


### Key Features

#### Modular Design:
- Uses modules for the resource group, virtual network, and Kubernetes cluster.
- Makes the configuration reusable and easier to manage.

#### Dynamic Scaling:
- The count meta-argument is used to dynamically create multiple jumpbox VMs.
Security:
- NSG rules restrict inbound traffic to SSH and HTTP while denying all other traffic.

#### Load Balancer:
Distributes traffic to the VMSS backend pool.

#### Kubernetes Integration:
Deploys an AKS cluster with a default node pool.


### How to Use
1. Set Variables:

Define values for variables like vm_count, admin_user, and admin_password in a terraform.tfvars file.

2. Initialize Terraform:

```
terraform init
```

3. Run plan
```
terraform plan
```

4. Apply Configuration:

```
terraform apply
```

Optional: Use `terraform output` to print the details of resources

5. Access Resources:

- Use the public IP of the jumpbox to SSH into the environment.
  After applying your Terraform configuration, retrieve the private key using:

    ```
    terraform output -raw ssh_private_key > private_key.pem
    chmod 600 private_key.pem

    ```
    This saves the private key to a file named private_key.pem and sets the correct permissions.
    Connect to the Jumpbox Using SSH Use the private key to connect to the jumpbox:
    
    ```
    ssh -i private_key.pem azureuser@<jumpbox-public-ip-or-dns>
    ```

- Access the Kubernetes cluster using the kubeconfig file.