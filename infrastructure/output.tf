output "dps_id_scope" {
  value = azurerm_iothub_dps.default.id_scope
}

output "iotedge_public_ip" {
  value = azurerm_public_ip.edgegateway.ip_address
}

output "iotedge_connect" {
  value = "ssh edgegateway@${azurerm_public_ip.edgegateway.ip_address}"
}
