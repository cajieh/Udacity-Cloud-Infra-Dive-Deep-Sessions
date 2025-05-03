
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