# stack3-azure-upd-manager/variables.tf

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
  default     = "UK South"
  description = "Azure Region for deploying resources"
}

variable "resource_group_name" {
  type        = string
  default     = "rg-update-management"
  description = "Name of the resource group for Update Management"
}

# Maintenance configuration variables
variable "maintenance_config_name" {
  type        = string
  default     = "monthly-updates"
  description = "Name of the maintenance configuration"
}

variable "maintenance_start_date" {
  type        = string
  default     = "2025-05-15"  # Just the date portion
  description = "Start date for maintenance window (YYYY-MM-DD format)"
}

variable "maintenance_start_time" {
  type        = string
  default     = "22:00"  # Just the time portion
  description = "Start time for maintenance window (HH:MM format)"
}

variable "maintenance_expiration_date" {
  type        = string
  default     = "2026-05-15"  # Just the date portion, can be empty for no expiration
  description = "Expiration date for maintenance window (YYYY-MM-DD format, leave empty for no expiration)"
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
  default     = "1Month"
  description = "Recurrence pattern for maintenance (e.g., 1Day, 1Week, 1Month)"
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

variable "windows_classifications_to_include" {
  type        = list(string)
  default     = ["Critical", "Security"]
  description = "Windows update classifications to include"
}

variable "windows_kb_to_include" {
  type        = list(string)
  default     = []
  description = "Windows KB numbers to include (empty for all)"
}

variable "windows_kb_to_exclude" {
  type        = list(string)
  default     = []
  description = "Windows KB numbers to exclude"
}

variable "reboot_setting" {
  type        = string
  default     = "IfRequired"
  description = "Reboot setting (Never, Always, IfRequired)"
}

variable "tags" {
  type        = map(string)
  default     = {
    Environment = "Production"
    Service     = "UpdateManagement"
  }
  description = "Tags to apply to resources"
}

variable "arc_server_names" {
  type        = list(string)
  default     = []
  description = "List of Arc-enabled server names to include in Update Manager"
}

variable "arc_resource_group_name" {
  type        = string
  default     = "rg-arc-aws-servers"
  description = "Resource group containing Arc-enabled servers"
}