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

# Add these variables to your existing stack2-azure/variables.tf file
# (append to the bottom)

# Azure Update Manager variables
variable "maintenance_start_datetime" {
  type        = string
  default     = "2025-07-01 02:00"
  description = "Start date and time for maintenance window (YYYY-MM-DD HH:MM format)"
}

variable "maintenance_expiration_datetime" {
  type        = string
  default     = "2026-07-01 02:00"
  description = "Expiration date and time for maintenance window (YYYY-MM-DD HH:MM format)"
}

variable "maintenance_duration" {
  type        = string
  default     = "03:00"
  description = "Duration of maintenance window (HH:MM format)"
}

variable "maintenance_timezone" {
  type        = string
  default     = "UTC"
  description = "Time zone for maintenance window"
}

variable "maintenance_recurrence" {
  type        = string
  default     = "Month Second Tuesday"
  description = "Recurrence pattern (e.g., 'Month Second Tuesday', 'Week', '1Day')"
}

variable "linux_classifications_to_include" {
  type        = list(string)
  default     = ["Critical", "Security"]
  description = "Linux update classifications to include"
}

variable "linux_packages_to_include" {
  type        = list(string)
  default     = []
  description = "Linux package names to include (empty for all)"
}

variable "linux_packages_to_exclude" {
  type        = list(string)
  default     = []
  description = "Linux package names to exclude"
}

variable "reboot_setting" {
  type        = string
  default     = "IfRequired"
  description = "Reboot setting (Never, Always, IfRequired)"

  validation {
    condition     = contains(["Never", "Always", "IfRequired"], var.reboot_setting)
    error_message = "Reboot setting must be one of: Never, Always, IfRequired."
  }
}