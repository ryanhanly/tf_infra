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
  default     = "azr-mirror-rg"
  description = "Name of the resource group for central mirror infrastructure"
}

variable "storage_account_name" {
  type        = string
  default     = "azrmirrorreposts"
  description = "Storage account name for repository storage (must be globally unique)"

  validation {
    condition     = length(var.storage_account_name) >= 3 && length(var.storage_account_name) <= 24
    error_message = "Storage account name must be between 3 and 24 characters."
  }
}

variable "infprefix" {
  type        = string
  default     = "azr-mirror"
  description = "Prefix for naming infrastructure resources"
}

variable "vm_size" {
  type        = string
  default     = "Standard_D2s_v3"
  description = "Size of the central mirror VM (needs more resources for repo sync)"
}

variable "admin_username" {
  type        = string
  default     = "azureadmin"
  description = "Admin username for the VM"
}

variable "environment" {
  type        = string
  default     = "lab"
  description = "Environment designation"
}

variable "enable_redhat_repos" {
  type        = bool
  default     = false
  description = "Enable RedHat repository mirroring (requires RHEL subscription)"
}

variable "redhat_username" {
  type        = string
  default     = ""
  description = "RedHat subscription username (if using RHEL repos)"
  sensitive   = true
}

variable "redhat_password" {
  type        = string
  default     = ""
  description = "RedHat subscription password (if using RHEL repos)"
  sensitive   = true
}

variable "sync_schedule_hour" {
  type        = number
  default     = 2
  description = "Hour to run daily repository sync (0-23)"

  validation {
    condition     = var.sync_schedule_hour >= 0 && var.sync_schedule_hour <= 23
    error_message = "Schedule hour must be between 0 and 23."
  }
}

variable "retention_days" {
  type        = number
  default     = 90
  description = "Blob retention period in days (recommended: 90 for full patch cycles)"

  validation {
    condition     = var.retention_days >= 30 && var.retention_days <= 365
    error_message = "Retention days must be between 30 and 365."
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

variable "admin_source_ips" {
  type        = list(string)
  default     = [
    "82.0.0.0/12",        # ISP ASN public range
    "10.0.0.0/8",         # RFC-1918 Class A private
    "172.16.0.0/12",      # RFC-1918 Class B private
    "192.168.0.0/16"      # RFC-1918 Class C private
  ]
  description = "IP ranges allowed for SSH admin access (ISP + RFC-1918 private ranges)"
}

variable "allowed_aws_ips" {
  type        = list(string)
  default     = []
  description = "List of AWS public IPs allowed to access the mirror (e.g., NAT Gateway IPs)"
}

variable "allowed_azure_vnets" {
  type        = list(string)
  default     = ["10.0.0.0/16"]  # Your existing Azure VNet CIDR
  description = "List of Azure VNet CIDR blocks allowed to access the mirror"
}

variable "enable_public_access" {
  type        = bool
  default     = false
  description = "Enable public access to the mirror server (not recommended for production)"
}

variable "tags" {
  type        = map(string)
  default     = {
    Environment = "Lab"
    Service     = "CentralMirror"
    Purpose     = "LinuxRepositoryMirror"
    CostCenter  = "Learning"
    AutoShutdown = "Enabled"
  }
  description = "Tags to apply to resources"
}