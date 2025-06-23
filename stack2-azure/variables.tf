# stack2-azure/variables.tf
# Variable definitions only - no defaults for required values

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