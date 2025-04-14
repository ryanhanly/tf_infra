variable "ssh_public_key_content" {
  description = "The content of the SSH public key"
  type        = string
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "client_id" {
  type        = string
  description = "Azure client ID"
}

variable "client_secret" {
  type        = string
  description = "Azure client secret"
}

variable "tenant_id" {
  type        = string
  description = "Azure tenant ID"
}

variable "location" {
  type        = string
  default     = "UK South"
  description = "Azure Region for deploying resources"
}

variable "resource_group_name" {
  type        = string
  default     = "tf-iac-rg"
  description = "Name of the resource group"
}

variable "srvprefix" {
  type     = string
  default  = "tf_srv"
  description = "Prefix for naming hosts resource"
}

variable "infprefix" {
  type     = string
  default  = "tf_inf"
  description = "Prefix for naming hosts resource"
}

variable "admin_username" {
  type     = string
  default  = "azureadmin"
  description = "Standard Admin Username"
}

variable "environment" {
  type     = string
  default  = "development"
  description = "Define the operating environment"
}

# Define an empty linux_vm variable or one with minimal defaults
variable "linux_vm" {
  type = map(object({
    vm_size        = string
    admin_username = string
    ssh_public_key = string
    os_disk_type   = string
    tags           = map(string)
  }))
  default = {}
  description = "Map of virtual machines to create with their configurations"
}
