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

variable "admin_source_ips" {
  type        = list(string)
  default     = [
    "0.0.0.0/0"  # Allow from anywhere - restrict this in production
  ]
  description = "IP ranges allowed for SSH admin access"
}

variable "allowed_aws_ips" {
  type        = list(string)
  default     = []  # Empty by default - set in terraform.tfvars
  description = "List of AWS public IPs allowed to access the Ubuntu mirror"
}

variable "allowed_azure_vnets" {
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Allow from anywhere for lab
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
    Environment = "Lab"
    Service     = "UbuntuMirror"
    Purpose     = "UbuntuRepositoryMirror"
    CostCenter  = "Learning"
    AutoShutdown = "Enabled"
    OS          = "Ubuntu"
  }
  description = "Tags to apply to resources"
}