// ---- General Configuration ----

variable "name" {
  description = "An identifier used to construct the names of all resources in this template."
  type        = string
}

variable "resource_group_location" {
  description = "The Azure region where all resources in this template should be created."
  type        = string
}

variable "randomization_level" {
  description = "Number of additional random characters to include in resource names to insulate against unexpected resource name collisions."
  type        = number
  default     = 8
}

variable "vm_name" {
  description = "The computer name of the Azure virtual machine."
  type        = string
}

variable "vm_size" {
  description = "The size of the Azure virtual machine."
  type        = string
}
