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

### Group ###

resource "azurerm_resource_group" "default" {
  name     = "rg${var.app}"
  location = var.location
}


### IoT Hub ###

resource "azurerm_iothub" "default" {
  name                = "iot${var.app}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location

  sku {
    name     = var.iothub_sku_name
    capacity = var.iothub_sku_capacity
  }
}

### IoT Hub DPS ###

resource "azurerm_iothub_dps" "default" {
  name                = "dps${var.app}"
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

# output "sas" {
#   value = azurerm_iothub.default.shared_access_policy[0]
# }
