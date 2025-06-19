# stack2-azure/variable.tf


variable "ssh_public_key_content" {
  description = "The content of the SSH public key"
  type        = string
  default     = ""  # Empty default, will be generated if not provided
}

variable "location" {
  type        = string
  default     = "UK South"
  description = "Azure Region for deploying resources"
}

variable "resource_group_name" {
  type        = string
  default     = "azr-ubuntu-rg"
  description = "Name of the resource group"
}

variable "srvprefix" {
  type        = string
  default     = "azr-srv"
  description = "Prefix for naming server resources"
}

variable "infprefix" {
  type        = string
  default     = "azr-inf"
  description = "Prefix for naming infrastructure resources"
}

variable "admin_username" {
  type        = string
  default     = "ubuntu"
  description = "Standard Admin Username"
}

variable "environment" {
  type        = string
  default     = "development"
  description = "Define the operating environment"
}

variable "mirror_server_ip" {
  description = "IP address of the Ubuntu mirror server"
  type        = string
  default     = ""
}

# Define the virtual_machines variable with index field
variable "virtual_machines" {
  type = map(object({
    vm_size        = string
    admin_username = string
    index          = number
    tags           = map(string)
  }))
  description = "Map of virtual machines to create with their configurations"
  default = {
    "vm01" = {
      vm_size        = "Standard_B1s"
      admin_username = "ubuntu"
      index          = 1
      tags = {
        Name = "ubuntu_vm_01"
      }
    }
  }
}

variable "enable_auto_shutdown" {
  type        = bool
  default     = true
  description = "Enable auto-shutdown for cost savings (lab environments only)"
}

variable "auto_shutdown_time" {
  type        = string
  default     = "1800"  # 18:00 (6 PM)
  description = "Auto-shutdown time in HHMM format (24-hour)"
}

variable "auto_shutdown_timezone" {
  type        = string
  default     = "GMT Standard Time"
  description = "Timezone for auto-shutdown"
}

variable "auto_shutdown_notification_email" {
  type        = string
  default     = ""
  description = "Email for shutdown notifications (optional)"
}