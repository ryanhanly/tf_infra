variable "name" {
  type        = string
  description = "Name of the virtual machine"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region where resources will be created"
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet where the VM will be connected"
}

variable "nsg_id" {
  type        = string
  description = "ID of the network security group"
}

variable "vm_size" {
  type        = string
  default     = "Standard_B1s"
  description = "Size of the virtual machine"
}

variable "admin_username" {
  type        = string
  default     = "azureadmin"
  description = "Username for the VM admin"
}

variable "ssh_public_key" {
  type        = string
  description = "Path to the SSH public key"
}

variable "os_disk_type" {
  type        = string
  default     = "Standard_LRS"
  description = "Type of OS disk storage"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to resources"
}