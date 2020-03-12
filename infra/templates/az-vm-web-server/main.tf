resource "azurerm_resource_group" "main" {
  name     = local.app_rg_name
  location = local.region
}

module "linux_web_server" {
  source                    = "../../modules/providers/azure/linux-web-server"
  resource_group_name       = azurerm_resource_group.main.name
  vm_name                   = var.vm_name
  vm_size                   = var.vm_size
  remote_exec_inline        = [
      "sudo apt-get update",
      "sudo apt-get install docker.io -y",
      "sudo groupadd docker",
      "sudo usermod -aG docker $(whoami)",
      "sudo service docker restart",
      "sudo docker run -P -d -p 80:80 nginxdemos/hello"
    ]
}
