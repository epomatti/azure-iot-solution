resource "azurerm_public_ip" "downstream" {
  name                = "pip-${var.app}-downstream"
  resource_group_name = var.group
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "downstream" {
  name                = "nic-${var.app}-downstream"
  location            = var.location
  resource_group_name = var.group

  ip_configuration {
    name                          = "dns"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.downstream.id
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_linux_virtual_machine" "downstream" {
  name                  = "vm-${var.app}-downstream001"
  resource_group_name   = var.group
  location              = var.location
  size                  = "Standard_B1ls"
  admin_username        = "downstream"
  admin_password        = "P@ssw0rd.123"
  network_interface_ids = [azurerm_network_interface.downstream.id]

  custom_data = filebase64("${path.module}/cloud-init.sh")

  admin_ssh_key {
    username   = "downstream"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    name                 = "osdisk-${var.app}-downstream001"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  lifecycle {
    ignore_changes = [
      custom_data
    ]
  }
}
