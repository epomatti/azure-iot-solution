output "public_ip" {
  value = azurerm_public_ip.downstream.ip_address
}
