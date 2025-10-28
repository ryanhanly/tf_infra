# stack1-aws/variables.tf
# Variable definitions only - no defaults for required values

# Reference shared values
module "shared_values" {
  source = "../shared"
}


variable "aws_region" {
  type        = string
  description = "AWS Region for deploying resources"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for naming infrastructure resources"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "subnet_cidr" {
  type        = string
  description = "CIDR block for the subnet"
}

variable "ssh_allowed_cidr" {
  type        = list(string)
  description = "CIDR blocks allowed for SSH access"
}

variable "mirror_server_ip" {
  type        = string
  description = "IP address of the Ubuntu mirror server"
  default     = "" # Optional - can be empty
}

variable "server_instances" {
  type = map(object({
    instance_type   = string
    index           = number
    bu              = string
    environment     = string
    additional_tags = map(string)
  }))
  description = "Map of servers to create with their configurations"

  validation {
    condition = alltrue([
      for server in values(var.server_instances) :
      contains(module.shared_values.allowed_business_units, server.bu)
    ])
    error_message = "Business unit must be one of: ${join(", ", module.shared_values.allowed_business_units)}."
  }

  validation {
    condition = alltrue([
      for server in values(var.server_instances) :
      contains(module.shared_values.allowed_environments, server.environment)
    ])
    error_message = "Environment must be one of: ${join(", ", module.shared_values.allowed_environments)}."
  }
}
/* not required, moving to Ansible --- IGNORE ---
# Azure Arc variables
variable "azure_subscription_id" {
  type        = string
  description = "Azure subscription ID for Arc registration"
}

variable "azure_tenant_id" {
  type        = string
  description = "Azure tenant ID"
}

variable "arc_client_id" {
  type        = string
  description = "Service principal client ID for Arc"
}

variable "arc_client_secret" {
  type        = string
  description = "Service principal client secret for Arc"
  sensitive   = true
}

variable "arc_resource_group" {
  type        = string
  description = "Azure resource group for Arc-enabled servers"
}

variable "azure_region" {
  type        = string
  description = "Azure region for Arc resources"
}
*/