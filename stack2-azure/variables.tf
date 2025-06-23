# stack2-azure/variables.tf
# Variable definitions only - no defaults for required values

# Reference shared values
module "shared_values" {
  source = "../shared"
}


# Azure Authentication
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
  sensitive   = true
}

variable "tenant_id" {
  type        = string
  description = "Azure tenant ID"
}


variable "location" {
  type        = string
  description = "Azure Region for deploying resources"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "srvprefix" {
  type        = string
  description = "Prefix for naming server resources"
}

variable "infprefix" {
  type        = string
  description = "Prefix for naming infrastructure resources"
}

variable "admin_username" {
  type        = string
  description = "Standard Admin Username"
}

variable "environment" {
  type        = string
  description = "Define the operating environment"
}

variable "mirror_server_ip" {
  type        = string
  description = "IP address of the Ubuntu mirror server"
  default     = "" # Optional
}

variable "virtual_machines" {
  type = map(object({
    vm_size        = string
    admin_username = string
    index          = number
    tags           = map(string)
  }))
  description = "Map of virtual machines to create with their configurations"
  validation {
    condition = alltrue([
      for vm in values(var.virtual_machines) :
      contains(module.shared_values.allowed_business_units, vm.business_unit)
    ])
    error_message = "Business unit must be one of: ${join(", ", module.shared_values.allowed_business_units)}."
  }

  validation {
    condition = alltrue([
      for vm in values(var.virtual_machines) :
      contains(module.shared_values.allowed_environments, vm.environment)
    ])
    error_message = "Environment must be one of: ${join(", ", module.shared_values.allowed_environments)}."
  }
}

# Cost optimization
variable "enable_auto_shutdown" {
  type        = bool
  description = "Enable auto-shutdown for cost savings"
}

variable "auto_shutdown_time" {
  type        = string
  description = "Auto-shutdown time in HHMM format (24-hour)"
}

variable "auto_shutdown_timezone" {
  type        = string
  description = "Timezone for auto-shutdown"
}

variable "auto_shutdown_notification_email" {
  type        = string
  description = "Email for shutdown notifications (optional)"
  default     = ""
}

# Azure Update Manager variables
variable "maintenance_start_datetime" {
  type        = string
  description = "Start date and time for maintenance window (YYYY-MM-DD HH:MM format)"
}

variable "maintenance_expiration_datetime" {
  type        = string
  description = "Expiration date and time for maintenance window (YYYY-MM-DD HH:MM format)"
}

variable "maintenance_duration" {
  type        = string
  description = "Duration of maintenance window (HH:MM format)"
}

variable "maintenance_timezone" {
  type        = string
  description = "Time zone for maintenance window"
}

variable "maintenance_recurrence" {
  type        = string
  description = "Recurrence pattern (e.g., 'Month Second Tuesday', 'Week', '1Day')"
}

variable "linux_classifications_to_include" {
  type        = list(string)
  description = "Linux update classifications to include"
}

variable "linux_packages_to_include" {
  type        = list(string)
  description = "Linux package names to include (empty for all)"
  default     = []
}

variable "linux_packages_to_exclude" {
  type        = list(string)
  description = "Linux package names to exclude"
  default     = []
}

variable "reboot_setting" {
  type        = string
  description = "Reboot setting (Never, Always, IfRequired)"

  validation {
    condition     = contains(["Never", "Always", "IfRequired"], var.reboot_setting)
    error_message = "Reboot setting must be one of: Never, Always, IfRequired."
  }
}

# Required Tagging Variables
variable "business_unit" {
  type        = string
  description = "Business Unit (e.g., SC, MSH, TMS)"

  validation {
    condition     = contains(["SC", "MSH", "TMS"], var.business_unit)
    error_message = "Business unit must be one of: SC, MSH, TMS."
  }
}

variable "patch_group" {
  type        = string
  description = "Patch group for update management (auto-generated from BU and Environment)"
  default     = ""
}