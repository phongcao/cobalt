// ---- General Configuration ----

variable "name" {
  description = "An identifier used to construct the names of all resources in this template."
  type        = string
}

variable "randomization_level" {
  description = "Number of additional random characters to include in resource names to insulate against unexpected resource name collisions."
  type        = number
  default     = 8
}

variable "resource_group_location" {
  description = "The Azure region where all resources in this template should be created."
  type        = string
}

variable "os_profile_computer_name" {
  description = "The computer name of the virtual machine"
  type        = string
}

variable "os_profile_admin_username" {
  description = "The admin username of the virtual machine"
  type        = string
}

variable "storage_os_disk_name" {
  description = "The os disk name of the virtual machine"
  type        = string
}

variable "azurerm_network_security_group_name" {
  description = "The network security group name"
  type        = string
}

variable "azurerm_network_interface_name" {
  description = "The network interface name"
  type        = string
}

variable "azurerm_virtual_network_name" {
  description = "The virtual network name"
  type        = string
}