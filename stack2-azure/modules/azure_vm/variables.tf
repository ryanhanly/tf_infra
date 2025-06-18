# modules/azure_vm/variables.tf

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for the resources"
  type        = string
}

variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_B2s"  # Better for RHEL workloads
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "rhel-admin"
}

variable "network_interface_id" {
  description = "ID of the network interface to attach to the VM"
  type        = string
}

variable "image_publisher" {
  description = "Publisher of the VM image"
  type        = string
  default     = "RedHat"
}

variable "image_offer" {
  description = "Offer of the VM image"
  type        = string
  default     = "RHEL"
}

variable "image_sku" {
  description = "SKU of the VM image"
  type        = string
  default     = "9_4"  # RHEL 9.4
}

variable "image_version" {
  description = "Version of the VM image"
  type        = string
  default     = "latest"
}

variable "enable_rhel_registration" {
  description = "Enable RHEL registration with Red Hat"
  type        = bool
  default     = true
}

variable "redhat_username" {
  description = "Red Hat subscription username"
  type        = string
  default     = ""
  sensitive   = true
}

variable "redhat_password" {
  description = "Red Hat subscription password"
  type        = string
  default     = ""
  sensitive   = true
}

variable "mirror_server_ip" {
  description = "IP address of the RHEL mirror server"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to the resources"
  type        = map(string)
  default     = {}
}

variable "enable_auto_shutdown" {
  type        = bool
  default     = true
  description = "Enable auto-shutdown for cost savings"
}

variable "auto_shutdown_time" {
  type        = string
  default     = "1800"
  description = "Auto-shutdown time in HHMM format"
}

variable "auto_shutdown_timezone" {
  type        = string
  default     = "GMT Standard Time"
  description = "Timezone for auto-shutdown"
}

variable "auto_shutdown_notification_email" {
  type        = string
  default     = ""
  description = "Email for shutdown notifications"
}