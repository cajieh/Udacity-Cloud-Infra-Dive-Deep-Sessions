module "resource_group" {
  source = "./modules/resource_group"
  name     = var.name
  location = var.location
  tags     = var.tags
}

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

resource "random_string" "fqdn" {
  length  = 6
  special = false
  upper   = false
  numeric = false
}

resource "azurerm_public_ip" "vmss" {
  name                = "vmss-public-ip"
  location            = var.location
  resource_group_name = module.resource_group.name
  allocation_method   = "Static"
  domain_name_label   = random_string.fqdn.result
  tags                = var.tags
}

resource "azurerm_lb" "vmss" {
  name                = "vmss-lb"
  location            = var.location
  resource_group_name = module.resource_group.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.vmss.id
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
  loadbalancer_id = azurerm_lb.vmss.id
  name            = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "vmss" {
  loadbalancer_id = azurerm_lb.vmss.id
  name            = "ssh-running-probe"
  port            = var.application_port
}

resource "azurerm_lb_rule" "lbnatrule" {
  loadbalancer_id                = azurerm_lb.vmss.id
  name                           = "http"
  protocol                       = "Tcp"
  frontend_port                  = var.application_port
  backend_port                   = var.application_port
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bpepool.id]
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.vmss.id
}

data "azurerm_resource_group" "image" {
  name = module.resource_group.name
}

data "azurerm_image" "image" {
  name                = var.packer_image_name
  resource_group_name = data.azurerm_resource_group.image.name
}

resource "azurerm_virtual_machine_scale_set" "vmss" {
  name                = "vmscaleset"
  location            = var.location
  resource_group_name = module.resource_group.name
  upgrade_policy_mode = "Manual"

  sku {
    name     = "Standard_B1s"
    tier     = "Standard"
    capacity = 2
  }

  storage_profile_image_reference {
    id = data.azurerm_image.image.id
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun           = 0
    caching       = "ReadWrite"
    create_option = "Empty"
    disk_size_gb  = 10
  }

  os_profile {
    computer_name_prefix = "vmlab"
    admin_username       = var.admin_user
    admin_password       = var.admin_password
  }

  os_profile_linux_config {
  disable_password_authentication = false

  ssh_keys {
    path     = "/home/azureuser/.ssh/authorized_keys"
    key_data = azapi_resource_action.ssh_public_key_gen.output.publicKey
  }
}

  network_profile {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name                                   = "IPConfiguration"
      subnet_id                              = module.virtual_network.subnet_id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
      primary                                = true
    }
  }

  tags = var.tags
}

resource "azurerm_public_ip" "jumpbox" {
  count                = var.vm_count
  name                 = "jumpbox-public-ip-${count.index}"
  location             = var.location
  resource_group_name  = module.resource_group.name
  allocation_method    = "Static"
  domain_name_label    = "jumpbox-${random_string.fqdn.result}-${count.index}"
  tags                 = var.tags
}

resource "azurerm_network_interface" "jumpbox" {
  count                = var.vm_count
  name                 = "jumpbox-nic-${count.index}"
  location             = var.location
  resource_group_name  = module.resource_group.name

  ip_configuration {
    name                          = "IPConfiguration"
    subnet_id                     = module.virtual_network.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          =  azurerm_public_ip.jumpbox[count.index].id
  }

  tags = var.tags
}

# A Network Security Group (NSG) that allows SSH (port 22) and HTTP 
# (port 80) traffic while denying all other inbound traffic
resource "azurerm_network_security_group" "jumpbox" {
  name                = "jumpbox-nsg"
  location            = var.location
  resource_group_name = module.resource_group.name

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

  # Deny all other inbound traffic
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


resource "azurerm_network_interface_security_group_association" "jumpbox" {
  count                     = var.vm_count
  network_interface_id      = azurerm_network_interface.jumpbox[count.index].id
  network_security_group_id = azurerm_network_security_group.jumpbox.id
}


resource "azurerm_virtual_machine" "jumpbox" {
  count                 = var.vm_count
  name                  = "jumpbox-${count.index}"
  location              = var.location
  resource_group_name   = module.resource_group.name
  network_interface_ids = [element(azurerm_network_interface.jumpbox.*.id, count.index)]
  vm_size               = "Standard_B1s"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "jumpbox-osdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "jumpbox-${count.index}"
    admin_username = var.admin_user
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = azapi_resource_action.ssh_public_key_gen.output.publicKey
    }
  }

  tags = var.tags
}

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