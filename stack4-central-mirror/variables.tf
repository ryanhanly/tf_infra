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
  default     = "azr-rhel-mirror-rg"
  description = "Name of the resource group for RHEL mirror infrastructure"
}

variable "infprefix" {
  type        = string
  default     = "azr-rhel"
  description = "Prefix for naming infrastructure resources"
}

variable "vm_size" {
  type        = string
  default     = "Standard_D4s_v3"
  description = "Size of the RHEL mirror VM (needs substantial resources for repo sync)"
}

variable "admin_username" {
  type        = string
  default     = "rhel-admin"
  description = "Admin username for the RHEL VM"
}

variable "environment" {
  type        = string
  default     = "lab"
  description = "Environment designation"
}

variable "redhat_username" {
  type        = string
  description = "Red Hat Developer subscription username"
  sensitive   = true
}

variable "redhat_password" {
  type        = string
  description = "Red Hat Developer subscription password"
  sensitive   = true
}

variable "rhel_versions" {
  type        = list(string)
  default     = ["8", "9"]
  description = "RHEL major versions to mirror"
}

variable "include_centos_stream" {
  type        = bool
  default     = true
  description = "Include CentOS Stream repositories"
}

variable "centos_stream_versions" {
  type        = list(string)
  default     = ["8", "9"]
  description = "CentOS Stream versions to mirror"
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
  default     = 180
  description = "Blob retention period in days (longer for enterprise repos)"

  validation {
    condition     = var.retention_days >= 90 && var.retention_days <= 365
    error_message = "Retention days must be between 90 and 365."
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
    "82.0.0.0/12",        # ISP range
    "10.0.0.0/8",         # RFC-1918 Class A private
    "172.16.0.0/12",      # RFC-1918 Class B private
    "192.168.0.0/16"      # RFC-1918 Class C private
  ]
  description = "IP ranges allowed for SSH admin access"
}

variable "allowed_aws_ips" {
  type        = list(string)
  default     = []
  description = "List of AWS public IPs allowed to access the RHEL mirror (e.g., NAT Gateway IPs)"
}

variable "allowed_azure_vnets" {
  type        = list(string)
  default     = ["10.0.0.0/16"]
  description = "List of Azure VNet CIDR blocks allowed to access the mirror"
}

variable "enable_public_access" {
  type        = bool
  default     = false
  description = "Enable public access to the RHEL mirror server (not recommended for production)"
}

variable "data_disk_size_gb" {
  type        = number
  default     = 1024
  description = "Size of data disk for RHEL repositories in GB (RHEL repos are large)"

  validation {
    condition     = var.data_disk_size_gb >= 512 && var.data_disk_size_gb <= 4096
    error_message = "Data disk size must be between 512GB and 4TB for RHEL repositories."
  }
}

variable "enable_rhel_insights" {
  type        = bool
  default     = true
  description = "Enable Red Hat Insights for system monitoring and recommendations"
}

variable "tags" {
  type        = map(string)
  default     = {
    Environment = "Lab"
    Service     = "RHELMirror"
    Purpose     = "RedHatRepositoryMirror"
    CostCenter  = "Learning"
    AutoShutdown = "Enabled"
    OS          = "RHEL"
    Subscription = "RedHatDeveloper"
  }
  description = "Tags to apply to resources"
}