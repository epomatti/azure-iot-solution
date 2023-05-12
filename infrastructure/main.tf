terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.52.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

locals {
  private_zone_domain = "fusiontech.iot"
}


### Group ###

resource "azurerm_resource_group" "default" {
  name     = "rg-${var.app}"
  location = var.location
}

### ACR ###
resource "azurerm_container_registry" "acr" {
  name                  = "acriotedgefusion789"
  resource_group_name   = azurerm_resource_group.default.name
  location              = azurerm_resource_group.default.location
  sku                   = "Basic"
  admin_enabled         = true
}


### IoT Hub ###

resource "azurerm_iothub" "default" {
  name                = "iot-${var.app}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  min_tls_version     = "1.2"

  sku {
    name     = var.iothub_sku_name
    capacity = var.iothub_sku_capacity
  }
}

resource "azurerm_iothub_certificate" "default" {
  name                = "TerraformRootCA"
  resource_group_name = azurerm_resource_group.default.name
  iothub_name         = azurerm_iothub.default.name
  is_verified         = true
  certificate_content = filebase64("${path.module}/secrets/azure-iot-test-only.root.ca.cert.pem")
}


### IoT Hub DPS ###

resource "azurerm_iothub_dps" "default" {
  name                = "provs-${var.app}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  allocation_policy   = "Hashed"

  sku {
    name     = "S1"
    capacity = "1"
  }

  linked_hub {
    location          = azurerm_resource_group.default.location
    connection_string = "HostName=${azurerm_iothub.default.hostname};SharedAccessKeyName=${azurerm_iothub.default.shared_access_policy[0].key_name};SharedAccessKey=${azurerm_iothub.default.shared_access_policy[0].primary_key}"
  }
}

resource "azurerm_iothub_dps_certificate" "default" {
  name                = "TerraformRootCA"
  resource_group_name = azurerm_resource_group.default.name
  iot_dps_name        = azurerm_iothub_dps.default.name
  is_verified         = true
  certificate_content = filebase64("${path.module}/secrets/azure-iot-test-only.root.ca.cert.pem")
}


### Network ###

resource "azurerm_virtual_network" "default" {
  name                = "vnet-${var.app}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
}

resource "azurerm_subnet" "default" {
  name                 = "subnet-default"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "downstream" {
  name                 = "subnet-downstream"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.90.0/24"]
}

resource "azurerm_private_dns_zone" "default" {
  name                = local.private_zone_domain
  resource_group_name = azurerm_resource_group.default.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "default" {
  name                  = "edge-network-link"
  resource_group_name   = azurerm_resource_group.default.name
  private_dns_zone_name = azurerm_private_dns_zone.default.name
  virtual_network_id    = azurerm_virtual_network.default.id
  registration_enabled  = true
}

// TODO: Add NSG


### Iot Edge ###

resource "azurerm_public_ip" "edgegateway" {
  name                = "pip-${var.app}-edgegateway"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "edgegateway" {
  name                = "nic-${var.app}-edgegateway"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  ip_configuration {
    name                          = "dns"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.edgegateway.id
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_linux_virtual_machine" "edgegateway" {
  name                  = "vm-${var.app}-edgegateway"
  resource_group_name   = azurerm_resource_group.default.name
  location              = azurerm_resource_group.default.location
  size                  = var.vm_edgegateway_size
  admin_username        = "edgegateway"
  admin_password        = "P@ssw0rd.123"
  network_interface_ids = [azurerm_network_interface.edgegateway.id]

  custom_data = filebase64("${path.module}/cloud-init.sh")

  admin_ssh_key {
    username   = "edgegateway"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
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

resource "azurerm_private_dns_cname_record" "edgegateway" {
  name                = "edgegateway"
  zone_name           = azurerm_private_dns_zone.default.name
  resource_group_name = azurerm_resource_group.default.name
  ttl                 = 300
  record              = "${azurerm_linux_virtual_machine.edgegateway.name}.${local.private_zone_domain}."
}

### Downstream device ###

module "downstream" {
  source    = "./modules/downstream-device"
  app       = var.app
  group     = azurerm_resource_group.default.name
  location  = azurerm_resource_group.default.location
  subnet_id = azurerm_subnet.downstream.id
}

resource "azurerm_private_dns_cname_record" "downstream_device_01" {
  name                = "downstream-device-01"
  zone_name           = azurerm_private_dns_zone.default.name
  resource_group_name = azurerm_resource_group.default.name
  ttl                 = 300
  record              = "vm-fusiontech-downstream001.${local.private_zone_domain}."
}


### Output JSON ###

resource "local_file" "config" {
  content = jsonencode(
    {
      "id_scope" : "${azurerm_iothub_dps.default.id_scope}",
      "edgegateway_ip" : "${azurerm_public_ip.edgegateway.ip_address}",
      "iothub_name" : "${azurerm_iothub.default.name}",
      "dps_name" : "${azurerm_iothub_dps.default.name}",
      "resource_group_name" : "${azurerm_resource_group.default.name}",
      "root_ca_name" : "${azurerm_iothub_dps_certificate.default.name}",
      "iothub_hostname" : "${azurerm_iothub.default.hostname}",
      "downstream_device_01_ip" : "${module.downstream.public_ip}",
    }
  )
  filename = "output.json"
}
