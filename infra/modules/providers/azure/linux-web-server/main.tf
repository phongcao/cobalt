data "azurerm_resource_group" "webserver" {
  name = var.resource_group_name
}

resource "azurerm_network_security_group" "nsg_core" {
  name                = var.network_security_group_name
  location            = data.azurerm_resource_group.webserver.location
  resource_group_name = data.azurerm_resource_group.webserver.name

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
  name                = var.virtual_network_name
  location            = data.azurerm_resource_group.webserver.location
  resource_group_name = data.azurerm_resource_group.webserver.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "sn_core" {
  name                 = var.subnet_name
  resource_group_name  = data.azurerm_resource_group.webserver.name
  virtual_network_name = azurerm_virtual_network.vnet_core.name
  address_prefix       = "10.1.0.0/24"
}

resource "azurerm_public_ip" "pip_core" {
  name                    = var.public_ip_name
  location                = data.azurerm_resource_group.webserver.location
  resource_group_name     = data.azurerm_resource_group.webserver.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30
}

resource "azurerm_network_interface" "nic_core" {
  name                = var.network_interface_name
  location            = data.azurerm_resource_group.webserver.location
  resource_group_name = data.azurerm_resource_group.webserver.name
  network_security_group_id = azurerm_network_security_group.nsg_core.id

  ip_configuration {
    name                          = "webserver-static-ip"
    subnet_id                     = azurerm_subnet.sn_core.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip_core.id
  }
}

resource "tls_private_key" "webserver_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_virtual_machine" "vm_core" {
  name                  = var.vm_name
  location              = data.azurerm_resource_group.webserver.location
  resource_group_name   = data.azurerm_resource_group.webserver.name
  network_interface_ids = [ azurerm_network_interface.nic_core.id ]
  vm_size               = var.vm_size
  
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = var.os_disk_name
    create_option     = "FromImage"
  }
  os_profile {
    computer_name  = var.vm_name
    admin_username = var.admin_username
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = tls_private_key.webserver_private_key.public_key_openssh
      path = "/home/${var.admin_username}/.ssh/authorized_keys"
    }     
  }
}

data "azurerm_public_ip" "ip_core" {
  name                = azurerm_public_ip.pip_core.name
  resource_group_name = data.azurerm_resource_group.webserver.name
  depends_on          = [ "azurerm_virtual_machine.vm_core" ]
}

resource "null_resource" "provisioner_remote_exec" {
  provisioner "remote-exec" {
    inline = var.remote_exec_inline
    connection {
      type        = "ssh"
      user        = var.admin_username
      private_key = tls_private_key.webserver_private_key.private_key_pem
      host        = data.azurerm_public_ip.ip_core.ip_address
    }
  }
}
