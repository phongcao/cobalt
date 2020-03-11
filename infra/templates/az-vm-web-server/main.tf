resource "azurerm_resource_group" "main" {
  name     = local.app_rg_name
  location = local.region
}

resource "azurerm_network_security_group" "nsg_webserver" {
  name                = var.azurerm_network_security_group_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "HTTP_80"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTP_443"
    priority                   = 350
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "SSH"
    priority                   = 400
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_virtual_network" "vnet_core" {
  name                = var.azurerm_virtual_network_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "sn" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet_core.name
  address_prefix       = "10.1.0.0/24"
}

resource "azurerm_public_ip" "pip_webserver" {
  name                    = "internal"
  location                = azurerm_resource_group.main.location
  resource_group_name     = azurerm_resource_group.main.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30
}

resource "azurerm_network_interface" "nic_webserver" {
  name                = var.azurerm_network_interface_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  network_security_group_id = azurerm_network_security_group.nsg_webserver.id

  ip_configuration {
    name                          = "webserver-static-ip"
    subnet_id                     = azurerm_subnet.sn.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip_webserver.id
  }
}

resource "tls_private_key" "vm_webserver_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_virtual_machine" "vm_webserver" {
  name                  = local.vm_name
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [ azurerm_network_interface.nic_webserver.id ]
  vm_size               = "Standard_DS2_v2"
  
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = var.storage_os_disk_name
    create_option     = "FromImage"
  }
  os_profile {
    computer_name  = var.os_profile_computer_name
    admin_username = var.os_profile_admin_username
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = tls_private_key.vm_webserver_private_key.public_key_openssh
      path = "/home/${var.os_profile_admin_username}/.ssh/authorized_keys"
    }     
  }
}

data "azurerm_public_ip" "ip_webserver" {
  name                = azurerm_public_ip.pip_webserver.name
  resource_group_name = azurerm_resource_group.main.name
  depends_on          = [ "azurerm_virtual_machine.vm_webserver" ]
}

resource "null_resource" "docker" {
  provisioner "remote-exec" {
    # Install Docker
    inline = [
      "sudo apt-get update",
      "sudo apt-get install docker.io -y",
      "sudo groupadd docker",
      "sudo usermod -aG docker $(whoami)",
      "sudo service docker restart",
      "sudo docker run -P -d -p 80:80 nginxdemos/hello"
    ]
    connection {
      type        = "ssh"
      user        = var.os_profile_admin_username
      private_key = tls_private_key.vm_webserver_private_key.private_key_pem
      host        = data.azurerm_public_ip.ip_webserver.ip_address
    }
  }
}
