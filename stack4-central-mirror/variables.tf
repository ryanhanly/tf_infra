# stack4-central-mirror/variables.tf

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
  default     = "azr-ubuntu-mirror-rg"
  description = "Name of the resource group for Ubuntu mirror infrastructure"
}

variable "infprefix" {
  type        = string
  default     = "azr-ubuntu"
  description = "Prefix for naming infrastructure resources"
}

variable "vm_size" {
  type        = string
  default     = "Standard_D2s_v3"
  description = "Size of the Ubuntu mirror VM"
}

variable "admin_username" {
  type        = string
  default     = "ubuntu-admin"
  description = "Admin username for the Ubuntu VM"
}

variable "environment" {
  type        = string
  default     = "lab"
  description = "Environment designation"
}

variable "retention_days" {
  type        = number
  default     = 90
  description = "Blob retention period in days"

  validation {
    condition     = var.retention_days >= 30 && var.retention_days <= 365
    error_message = "Retention days must be between 30 and 365."
  }
}

variable "enable_auto_shutdown" {
  type        = bool
  default     = true
  description = "Enable auto-shutdown for cost savings"
}

variable "auto_shutdown_time" {
  type        = string
  default     = "1800"
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

variable "admin_source_ips" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "IP ranges allowed for SSH admin access"
}

variable "allowed_aws_ips" {
  type        = list(string)
  default     = []
  description = "List of AWS public IPs allowed to access the Ubuntu mirror"
}

variable "allowed_azure_vnets" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "List of Azure VNet CIDR blocks allowed to access the mirror"
}

variable "data_disk_size_gb" {
  type        = number
  default     = 512
  description = "Size of data disk for Ubuntu repositories in GB"

  validation {
    condition     = var.data_disk_size_gb >= 256 && var.data_disk_size_gb <= 2048
    error_message = "Data disk size must be between 256GB and 2TB."
  }
}

variable "tags" {
  type        = map(string)
  default     = {
    Environment  = "Lab"
    Service      = "UbuntuMirror"
    Purpose      = "UbuntuRepositoryMirror"
    CostCenter   = "Learning"
    AutoShutdown = "Enabled"
    OS           = "Ubuntu"
  }
  description = "Tags to apply to resources"
}

# Azure Update Manager variables for Mirror Server
variable "maintenance_start_datetime" {
  type        = string
  default     = "2025-07-01 01:00"  # 1 AM - earlier than test VMs
  description = "Start date and time for maintenance window (YYYY-MM-DD HH:MM format)"
}

variable "maintenance_expiration_datetime" {
  type        = string
  default     = "2026-07-01 01:00"
  description = "Expiration date and time for maintenance window (YYYY-MM-DD HH:MM format)"
}

variable "maintenance_duration" {
  type        = string
  default     = "02:00"  # Shorter window for mirror server
  description = "Duration of maintenance window (HH:MM format)"
}

variable "maintenance_timezone" {
  type        = string
  default     = "UTC"
  description = "Time zone for maintenance window"
}

variable "maintenance_recurrence" {
  type        = string
  default     = "Month First Sunday"  # Different day from test VMs
  description = "Recurrence pattern (e.g., 'Month First Sunday', 'Week', '1Day')"
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
  default     = ["nginx*"]  # Exclude nginx to avoid service disruption
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