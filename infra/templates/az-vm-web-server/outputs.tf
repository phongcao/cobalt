output "webserver_ip" {
  value       = module.linux_web_server.web_server_public_ip
  description = "The ip address of the web server."
}
