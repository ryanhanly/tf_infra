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

# Removed variables related to Log Analytics, Automation Account, and OMS agent

variable "tags" {
  type        = map(string)
  default     = {
    Environment = "Production"
    Service     = "UpdateManagement"
  }
  description = "Tags to apply to resources"
}