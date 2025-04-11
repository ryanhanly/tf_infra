variable "azure_region" {
  type        = string
  default     = "East US"
  description = "Azure Region for deploying resources"
}

variable "resource_group_name" {
  type        = string
  default     = "terraform-learning-rg"
  description = "Name of the resource group"
}

# Map of virtual machines to create
variable "virtual_machines" {
  type = map(object({
    vm_size        = string
    admin_username = string
    ssh_public_key = string
    os_disk_type   = string
    tags           = map(string)
  }))
  default = {
    "vm-ubuntu-01" = {
      vm_size        = "Standard_B1s"
      admin_username = "azureadmin"
      ssh_public_key = "~/.ssh/id_rsa.pub"
      os_disk_type   = "Standard_LRS"
      tags = {
        Name = "vm_ubuntu_01"
        Environment = "Development"
      }
    }
  }
  description = "Map of virtual machines to create with their configurations"
}