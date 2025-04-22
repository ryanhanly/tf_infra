variable "ssh_public_key_content" {
  description = "The content of the SSH public key"
  type        = string
  default     = ""  # Empty default, will be generated if not provided
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
  type        = string
  default     = "tf-srv"
  description = "Prefix for naming server resources"
}

variable "infprefix" {
  type        = string
  default     = "tf-inf"
  description = "Prefix for naming infrastructure resources"
}

variable "admin_username" {
  type        = string
  default     = "azureadmin"
  description = "Standard Admin Username"
}

variable "environment" {
  type        = string
  default     = "development"
  description = "Define the operating environment"
}

# Define the virtual_machines variable
variable "virtual_machines" {
  type = map(object({
    vm_size        = string
    admin_username = string
    tags           = map(string)
  }))
  description = "Map of virtual machines to create with their configurations"
  default = {
    "vm01" = {
      vm_size        = "Standard_B1s"
      admin_username = "azureadmin"
      tags = {
        Name = "vm_ubuntu_01"
      }
    }
  }
}