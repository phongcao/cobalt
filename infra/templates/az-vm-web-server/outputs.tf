output "webserver_ip" {
  value       = "${data.azurerm_public_ip.ip_webserver.ip_address}"
  description = "The ip address of the web server."
}
