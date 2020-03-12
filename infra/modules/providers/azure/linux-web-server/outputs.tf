output "web_server_public_ip" {
  value       = data.azurerm_public_ip.ip_core.ip_address
  description = "The public ip address of the web server."
}
