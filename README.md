# Udacity Cloud Infrastructure Dive Deep Session

## Udacity Deep Dive Session on Modern Cloud Infrastructure using Terraform, Packer and Azure cloud

### Course: Azure Infrastructure Operations

### Project: Deploying a Web Server in Azure

### Format: Interactive session with project deep dive and Q&A

### Scope: The session will focus on reviewing key course concepts and providing an in-depth walkthrough of the associated project.

## Introduction:

### Salutation:

Hi everyone, ...

### About the Deep Dive Session on Modern Cloud Infrastructure:

The session will focus on reviewing key course concepts of “Azure Infrastructure Operations” and provide an in-depth walkthrough of the “Deploying a Web Server in Azure” project. Additionally, you will be introduced to provisioning Azure Kubernetes Service and best practices for infrastructure provisioning.

N.B. If you have a quick question, please don't hesitate to ask. Additionally, a Q&A session will be held at the end of the presentation.

### About Me:

- An experienced Cloud-Native Software Engineer by training and trade
- A decade of expertise in open-source and cloud-native technologies, as well as enterprise application development across several industries
- Work at an open-source software company and also serve as a tech mentor at Udacity
- Hold a Master's degree in Computer Science and technology certifications from Microsoft, IBM, and the Cloud Native Computing Foundation
- A Certified Kubernetes Administrator (CKA) and Certified Kubernetes Application Developer certifications (CKAD)
- Happily married with two lovely daughters, I enjoy spending time with my family and friends, sharing Christian faith stories, listening to music, and watching sporting events

### Demo: Deploy modern cloud infrastructure resources on Azure using Terraform and Packer

### Specifications:

- Deploy a Linux Ubuntu Server image using Packer with an Nginx server plus custom content
- Deploy cloud infrastructure resources using Terraform with SSH authentication.
- Update the Terraform template and enforce the Network Security Policy (NSP)
- Update the Terraform template and deploy Azure Kubernetes Service.

## Overview of Terraform and Packer Tools

Terraform is a tool that is used to define, preview, and deploy cloud infrastructure using configuration files written in HCL (HashiCorp Configuration Language). With HCL, you can specify the cloud provider, such as Azure or AWS, and define the components of your cloud infrastructure. After creating the configuration files, you generate an execution plan to preview the proposed infrastructure changes. Once the changes are reviewed and verified, you apply the execution plan to provision the infrastructure.

Packer is a tool used to automate the creation of machine images for multiple platforms, including Azure. It allows you to define an image configuration in a JSON or HCL file and then build consistent, repeatable images that can be used in your infrastructure.

In the context of your Terraform configuration, Packer can be used to create a custom image (e.g., a VM image with pre-installed software or configurations) that can then be referenced in your Terraform deployment, such as in the `azurerm_virtual_machine_scale_set` or `azurerm_virtual_machine` resources.

### In some areas, we have noticed that most students have difficulty in:

1. Structure a production-grade Terraform project
2. Configure an SSH authentication
3. Network Security Groups (NSGs) enforcement.
   NSG are a collection of networking rules that dictate the flow of traffic to and from resources in Azure.

- Adherence to best practices

### A minimal main.tf file for deploying basic infrastructure using Terraform

Here is a minimal main.tf file for deploying basic infrastructure using Terraform. This example creates a resource group, a virtual network, and a virtual machine in Azure:

```
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "East US"
}

resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "example" {
  name                = "example-public-ip"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

resource "azurerm_virtual_machine" "example" {
  name                  = "example-vm"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.example.id]
  vm_size               = "Standard_B1s"

  storage_os_disk {
    name              = "example-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "example-vm"
    admin_username = "azureuser"
    admin_password = "P@ssw0rd1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

output "public_ip_address" {
  value = azurerm_public_ip.example.ip_address
  description = "The public IP address of the virtual machine for SSH access."
}

# Update: Add NSG for SSH inbound traffic
resource "azurerm_network_security_group" "example" {
  name                = "jumpbox-nsg"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name

  # Allow SSH from any IP
  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*" # Replace with your IP for better security
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.example.id
  network_security_group_id = azurerm_network_security_group.example.id
}

```

### Explanation

1. Provider Configuration: The azurerm provider is used to interact with Azure resources.
2. Resource Group: Creates a resource group named example-resources in the East US region.
3. Virtual Network: Creates a virtual network named example-vnet with an address space of 10.0.0.0/16.
4. Subnet: Creates a subnet named example-subnet within the virtual network with an address prefix of 10.0.1.0/24.
5. Network Interface: Creates a network interface named example-nic and associates it with the subnet.
6. Public IP: Allocates a static public IP for the VM.
7. Virtual Machine: Creates a virtual machine named example-vm with the following configurations:

- VM Size: Standard_B1s (small instance for testing).
- OS Disk: Standard managed disk.
- Image: Ubuntu Server 18.04-LTS.
- Admin Credentials: Username azureuser and password P@ssw0rd1234!.
- Network Interface: Associates the VM with the network interface.
- Public IPs: Allocates a static public IP for the VM.

7. Network Security Groups (NSGs): NSG to allow inbound traffic from SSH on port 22

This deploys an Ubuntu Server VM with SSH access. Configures admin credentials and disables password authentication.

### How to us:

1. Initialize Terraform:
   ```
   terraform init
   ```
2. Plan the Deployment:
   ```
   terraform plan
   ```
3. Apply the Configuration:
   ```
   terraform apply
   ```
4. Access the VM:


    Use the public IP of the VM (if configured) to SSH into it:

    ```
    ssh azureuser@<public-ip>
    ```

    This minimal main.tf file provides a basic setup for deploying a VM in Azure. You can expand it by adding more resources like , public IPs, or additional VMs.

### Reference the Custom Image in Terraform

Update the Terraform configuration to use the custom image created by Packer:

```
resource "azurerm_virtual_machine" "example" {
  name                  = "example-vm"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.example.id]
  vm_size               = "Standard_B1s"

  storage_os_disk {
    name              = "example-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    id = data.azurerm_image.custom_image.id
  }

  os_profile {
    computer_name  = "example-vm"
    admin_username = "azureuser"
    admin_password = "P@ssw0rd1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

data "azurerm_image" "custom_image" {
  name                = "custom-ubuntu-nginx"
  resource_group_name = "example-resources"
}
```

### Adherence to Best Practices:

1. Use modular Terraform configurations for better organization and reusability.
2. Secure SSH access by restricting inbound traffic to specific IPs.
3. Use Packer to create consistent, pre-configured VM images.
4. Enforce NSGs to control traffic flow and enhance security.

Common Errors:

-

1.  Error: A resource with the ID "/subscriptions/<subscription_id>/resourceGroups/<resource-group-name>" already existsImport the Existing Resource into Terraform State

```
terraform import azurerm_resource_group.<instance name> /subscriptions/<subscription_id>/resourceGroups/customPackerImages
```
