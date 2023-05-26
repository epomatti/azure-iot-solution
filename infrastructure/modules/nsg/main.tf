# https://learn.microsoft.com/en-us/azure/iot-edge/production-checklist?view=iotedge-1.4#allow-connections-from-iot-edge-devices

resource "azurerm_network_security_group" "edgegateway_allow_ssh" {
  name                = "nsg-${var.app}-edgegateway"
  location            = var.location
  resource_group_name = var.group

  # Inbound

  security_rule {
    name                       = "AllowSSH"
    description                = "Allow SSH for development purposes only"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Outbound

  security_rule {
    name                       = "AllowHTTP"
    description                = "This is not required by IoT Edge. Allowing for development purposes only"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPS"
    description                = "Allows IoT Edge to connect with HTTPS"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowMQTT"
    description                = "Allows IoT Edge to connect with MQTT"
    priority                   = 120
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8883"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAMQP"
    description                = "Allows IoT Edge to connect with AMQP"
    priority                   = 130
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5671"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

    security_rule {
    name                       = "AllowVnetOutBound"
    priority                   = 1000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

    security_rule {
    name                       = "DenyAllOutBound"
    priority                   = 4000
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "edgegateway" {
  subnet_id                 = var.subnet
  network_security_group_id = azurerm_network_security_group.edgegateway_allow_ssh.id
}
