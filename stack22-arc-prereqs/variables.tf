# stack5-arc-prereqs/variables.tf

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
  description = "Azure region for resources"
}

variable "arc_resource_group_name" {
  type        = string
  default     = "rg-arc-aws-servers"
  description = "Name of resource group for Arc-enabled servers"
}

variable "arc_sp_name" {
  type        = string
  default     = "arc-aws-servers-sp"
  description = "Name for the Arc service principal"
}

variable "tags" {
  type = map(string)
  default = {
    Environment = "Lab"
    Service     = "AzureArc"
    Purpose     = "AWSServerManagement"
    ManagedBy   = "Terraform"
  }
  description = "Tags to apply to resources"
}