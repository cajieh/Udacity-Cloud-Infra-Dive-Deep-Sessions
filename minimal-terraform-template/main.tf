
# This Terraform configuration sets up the Azure Resource Manager (azurerm) provider.
# The `azurerm` provider is used to manage resources in Microsoft Azure.
# The `features {}` block is required but can be left empty for default settings.
provider "azurerm" {
  features {}
}

# This Terraform configuration defines an Azure Resource Group.
# 
# Resource: azurerm_resource_group
# - `name`: Specifies the name of the resource group. In this case, it is set to "example-rg".
# - `location`: Specifies the Azure region where the resource group will be created. Here, it is set to "East US".
# 
# This resource group can be used as a container to manage and organize related Azure resources.
resource "azurerm_resource_group" "example" {
  name     = "k8s-cluster-demo-rg"
  location = "East US"
  tags = { Project: "Deploying-a-Web-Server-in-Azure"}
}


# This Terraform configuration defines an Azure Virtual Network resource.
# 
# Resource: azurerm_virtual_network "example"
# 
# - `name`: Specifies the name of the virtual network. In this case, it is set to "example-vnet".
# - `address_space`: Defines the address space for the virtual network. Here, it is set to "10.0.0.0/16".
# - `location`: Specifies the Azure region where the virtual network will be created. It references the location of the associated resource group.
# - `resource_group_name`: Specifies the name of the resource group in which the virtual network will be created. It references the name of the associated resource group.
# 
# This resource is part of a minimal Terraform template for provisioning Azure infrastructure.
resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tags = { Project: "Deploying-a-Web-Server-in-Azure"}
}


# This Terraform configuration defines an Azure Subnet resource.
# 
# - `name`: Specifies the name of the subnet.
# - `resource_group_name`: References the name of the resource group where the subnet will be created. 
#   This is dynamically linked to the `azurerm_resource_group.example` resource.
# - `virtual_network_name`: Specifies the name of the virtual network to which the subnet belongs. 
#   This is dynamically linked to the `azurerm_virtual_network.example` resource.
# - `address_prefixes`: Defines the address range for the subnet in CIDR notation. 
#   In this case, the subnet uses the range `10.0.1.0/24`.
resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}


# This Terraform configuration block defines an Azure Public IP resource.
# 
# Resource: azurerm_public_ip
# 
# Attributes:
# - `name`: Specifies the name of the Public IP resource.
# - `location`: The Azure region where the Public IP will be created. It is dynamically set to match the location of the associated resource group.
# - `resource_group_name`: The name of the resource group in which the Public IP will be created.
# - `allocation_method`: Specifies the allocation method for the Public IP. In this case, it is set to "Static".
# - `sku`: Defines the SKU of the Public IP. Here, it is set to "Standard".
# - `domain_name_label`: A unique label used to create a fully qualified domain name (FQDN) for the Public IP. Replace the placeholder value with a unique label to avoid conflicts.
# 
# Note:
# - Ensure that the `domain_name_label` is globally unique within Azure to avoid deployment errors.
# - This resource depends on the existence of an `azurerm_resource_group` resource named `example`.
resource "azurerm_public_ip" "example" {
  name                = "example-public-ip"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "example-testing-vm" # Replace with a unique label
  tags = { Project: "Deploying-a-Web-Server-in-Azure"}
}


# This Terraform configuration defines an Azure Network Interface resource.
# 
# Resource: azurerm_network_interface
# 
# - `name`: Specifies the name of the network interface.
# - `location`: The Azure region where the network interface will be created. It is dynamically set to match the location of the associated resource group.
# - `resource_group_name`: The name of the resource group in which the network interface will be created.
# 
# Nested Block: `ip_configuration`
# - `name`: The name of the IP configuration for the network interface.
# - `subnet_id`: The ID of the subnet to which the network interface will be connected.
# - `private_ip_address_allocation`: Specifies how the private IP address is allocated. In this case, it is set to "Dynamic".
# - `public_ip_address_id`: The ID of the public IP address associated with the network interface.
resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tags = { Project: "Deploying-a-Web-Server-in-Azure"}
  
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}


# This Terraform configuration defines an Azure Virtual Machine resource.
# 
# Resource: azurerm_virtual_machine "example"
# 
# - `name`: Specifies the name of the virtual machine.
# - `location`: The Azure region where the virtual machine will be created. It is derived from the associated resource group.
# - `resource_group_name`: The name of the resource group in which the virtual machine will be created.
# - `network_interface_ids`: A list of network interface IDs to associate with the virtual machine.
# - `vm_size`: Specifies the size of the virtual machine (e.g., "Standard_B1s").
# 
# Storage OS Disk:
# - `name`: The name of the OS disk.
# - `caching`: Specifies the caching mode for the OS disk (e.g., "ReadWrite").
# - `create_option`: Specifies how the OS disk is created (e.g., "FromImage").
# - `managed_disk_type`: The type of managed disk to use (e.g., "Standard_LRS").
# 
# Storage Image Reference:
# - `publisher`: The publisher of the image (e.g., "Canonical").
# - `offer`: The offer of the image (e.g., "UbuntuServer").
# - `sku`: The SKU of the image (e.g., "18.04-LTS").
# - `version`: The version of the image to use (e.g., "latest").
# 
# OS Profile:
# - `computer_name`: The hostname of the virtual machine.
# - `admin_username`: The administrator username for the virtual machine.
# - `admin_password`: The administrator password for the virtual machine.
# 
# OS Profile Linux Config:
# - `disable_password_authentication`: A boolean indicating whether password authentication is disabled for SSH (set to `false` to allow password authentication).
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

  tags = { Project: "Deploying-a-Web-Server-in-Azure"}
}

# Update to use image built with Packer
/*
# This block defines a data source for an Azure Resource Manager (ARM) image.
# The `azurerm_image` data source is used to retrieve information about an existing
# custom image in Azure. The image is identified by its name and the resource group
# it belongs to.
#
# Attributes:
# - `name`: Specifies the name of the custom image to retrieve. In this case, it is
#   "custom-ubuntu-nginx".
# - `resource_group_name`: Specifies the name of the resource group where the custom
#   image is located. The value is dynamically fetched from the `azurerm_resource_group`
#   resource named `example`.
data "azurerm_image" "custom_image" {
  name                = "custom-ubuntu-nginx"
  resource_group_name = azurerm_resource_group.example.name
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

  # The `storage_image_reference` block specifies the reference to a custom image in Azure.
  # The `id` attribute is set to the ID of the custom image retrieved using the `azurerm_image` data source.
  # This allows the virtual machine to use the specified custom image for deployment.
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
*/

# Update: Add NSG for SSH inbound traffic
# This Terraform configuration defines an Azure Network Security Group (NSG) resource.
# 
# Resource: azurerm_network_security_group "example"
# 
# - `name`: Specifies the name of the NSG.
# - `location`: The Azure region where the NSG will be created. It is dynamically set to match the location of the associated resource group.
# - `resource_group_name`: The name of the resource group where the NSG will be deployed.
# 
# Security Rules:
# 
# 1. **AllowSSH**:
#    - Allows inbound SSH traffic (TCP port 22) from any IP address.
#    - `priority`: 100 (lower numbers have higher priority).
#    - `direction`: Inbound traffic.
#    - `access`: Allow traffic.
#    - `protocol`: TCP.
#    - `source_port_range`: Any source port.
#    - `destination_port_range`: Port 22 (SSH).
#    - `source_address_prefix`: Any IP address (`*`). For better security, replace this with a specific IP or range.
#    - `destination_address_prefix`: Any destination (`*`).
# 
# Note:
# - The HTTP rule is currently commented out. If enabled, it would allow inbound HTTP traffic (TCP port 80) from any IP address.
# - For enhanced security, replace `source_address_prefix` with a specific IP or range instead of using `*`.
resource "azurerm_network_security_group" "example" {
  name                = "example-nsg"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  tags = { Project: "Deploying-a-Web-Server-in-Azure"}
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

  # Allow HTTP from any IP
  /*
  security_rule {
    name                       = "AllowHTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*" # Replace with your IP for better security
    destination_address_prefix = "*"
  }
  */

    
}


# This resource block defines an association between a network interface and a network security group in Azure.
# 
# - `network_interface_id`: Specifies the ID of the network interface to associate with the network security group.
# - `network_security_group_id`: Specifies the ID of the network security group to associate with the network interface.
# 
# This association ensures that the specified network security group applies its security rules to the specified network interface.
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.example.id
  network_security_group_id = azurerm_network_security_group.example.id
}

# This output block defines an output variable named "public_ip_address".
# It retrieves the IP address of the public IP resource associated with the virtual machine.
# The "value" attribute references the "ip_address" property of the "azurerm_public_ip.example" resource.
# The "description" provides additional context, indicating that this IP address is used for SSH access to the virtual machine.
output "public_ip_address" {
  value = azurerm_public_ip.example.ip_address
  description = "The public IP address of the virtual machine for SSH access."
}


# This output block defines an output variable named "public_ip_fqdn".
# It retrieves the fully qualified domain name (FQDN) of the public IP
# associated with the virtual machine. The "value" attribute references
# the FQDN property of the "azurerm_public_ip.example" resource, and the
# "description" provides a brief explanation of the output's purpose.
output "public_ip_fqdn" {
  value       = azurerm_public_ip.example.fqdn
  description = "The fully qualified domain name (FQDN) of the public IP for the virtual machine."
}