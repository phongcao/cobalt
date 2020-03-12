variable "resource_group_name" {
  description = "The name of the resource group in which to create the storage account."
  type        = string
}

variable "vm_name" {
  description = "The computer name of the Azure virtual machine."
  type        = string
}

variable "vm_size" {
  description = "The size of the Azure virtual machine."
  type        = string
}

variable "remote_exec_inline" {
  description = "The list of command strings. They are executed in the order they are provided."
  type        = list(string)
}

variable "admin_username" {
  description = "The admin username of the Azure virtual machine."
  type        = string
  default     = "webservervm"
}

variable "os_disk_name" {
  description = "The os disk name of the Azure virtual machine."
  type        = string
  default     = "dskmain"
}

variable "network_security_group_name" {
  description = "The network security group name (providing security rules for inbound/outbound ports)."
  type        = string
  default     = "nsgmain"
}

variable "network_interface_name" {
  description = "The network interface name (providing ip address and other network info)."
  type        = string
  default     = "nicmain"
}

variable "virtual_network_name" {
  description = "The virtual network name (required for creating azurerm_subnet)."
  type        = string
  default     = "vnetmain"
}

variable "subnet_name" {
  description = "The subnet name (representing network segments within the IP space defined by the virtual network)."
  type        = string
  default     = "snetmain"
}

variable "public_ip_name" {
  description = "The public ip name of the Azure virtual machine."
  type        = string
  default     = "pipmain"
}
