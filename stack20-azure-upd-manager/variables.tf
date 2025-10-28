# stack3-azure-upd-manager/variables.tf
# Variable definitions only - no defaults for required values

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

# Resource Configuration
variable "location" {
  type        = string
  description = "Azure Region for deploying resources"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group for Update Management"
}

# Maintenance Configuration
variable "maintenance_config_name" {
  type        = string
  description = "Name of the maintenance configuration"
}

variable "maintenance_start_date" {
  type        = string
  description = "Start date for maintenance window (YYYY-MM-DD format)"
}

variable "maintenance_start_time" {
  type        = string
  description = "Start time for maintenance window (HH:MM format)"
}

variable "maintenance_expiration_date" {
  type        = string
  description = "Expiration date for maintenance window (YYYY-MM-DD format, leave empty for no expiration)"
  default     = ""
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
  description = "Recurrence pattern for maintenance (e.g., 'Month Second Tuesday')"
}

# Linux Update Settings
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

# Windows Update Settings
variable "windows_classifications_to_include" {
  type        = list(string)
  description = "Windows update classifications to include"
}

variable "windows_kb_to_include" {
  type        = list(string)
  description = "Windows KB numbers to include (empty for all)"
  default     = []
}

variable "windows_kb_to_exclude" {
  type        = list(string)
  description = "Windows KB numbers to exclude"
  default     = []
}

# Reboot Configuration
variable "reboot_setting" {
  type        = string
  description = "Reboot setting (Never, Always, IfRequired)"

  validation {
    condition     = contains(["Never", "Always", "IfRequired"], var.reboot_setting)
    error_message = "Reboot setting must be one of: Never, Always, IfRequired."
  }
}

# Resource Tagging
variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}

# Arc Server Configuration
variable "arc_server_names" {
  type        = list(string)
  description = "List of Arc-enabled server names to include in Update Manager"
  default     = []
}

variable "arc_resource_group_name" {
  type        = string
  description = "Resource group containing Arc-enabled servers"
}