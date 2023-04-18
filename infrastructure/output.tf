output "iotedge_public_ip" {
  value = azurerm_public_ip.edgegateway.ip_address
}

output "iotedge_connect" {
  value = "ssh edgegateway@${azurerm_public_ip.edgegateway.ip_address}"
}
