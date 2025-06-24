# stack6-patch-management/variables.tf

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
  description = "Azure region"
}

variable "patch_resource_group_name" {
  type        = string
  default     = "rg-patch-management"
  description = "Resource group for patch configurations"
}

variable "arc_resource_group_name" {
  type        = string
  description = "Resource group containing Arc machines"
}

variable "azure_vm_resource_group_name" {
  type        = string
  description = "Resource group containing Azure VMs"
}

variable "aws_arc_server_ids" {
  type        = list(string)
  description = "List of AWS instance IDs (Arc machine names)"
}

variable "azure_vm_names" {
  type        = list(string)
  description = "List of Azure VM names"
}

variable "business_unit_schedules" {
  type = map(object({
    start_datetime    = string
    duration         = string
    recurrence       = string
    exclude_packages = list(string)
  }))
  description = "Patch schedules per business unit"
}

variable "server_bu_mapping" {
  type        = map(string)
  description = "Map server names to business units"
}

variable "timezone" {
  type        = string
  default     = "GMT Standard Time"
  description = "Timezone for patch windows"
}

variable "linux_classifications" {
  type        = list(string)
  default     = ["Critical", "Security"]
  description = "Linux patch classifications"
}

variable "reboot_setting" {
  type        = string
  default     = "IfRequired"
  description = "Reboot behavior"
}

variable "tags" {
  type = map(string)
  default = {
    Service   = "PatchManagement"
    ManagedBy = "Terraform"
  }
  description = "Common tags"
}