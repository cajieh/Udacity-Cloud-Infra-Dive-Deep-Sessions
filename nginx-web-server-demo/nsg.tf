
# A Network Security Group (NSG) that allows SSH (port 22) and HTTP 
# (port 80) traffic while denying all other inbound traffic
resource "azurerm_network_security_group" "jumpbox" {
  name                = "jumpbox-nsg"
  location            = var.location
  resource_group_name = module.resource_group.name
  tags     = var.tags

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

