# stack1-aws/variables.tf
# Variable definitions only - no defaults for required values

# Reference shared values
module "shared_values" {
  source = "../shared"
}


variable "server_instances" {
  type = map(object({
    index         = number
    instance_type = string  # Add for validation
    environment   = string  # Add for validation
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
  default = {}
}

variable "cloud_abbrev" {
  type        = string
  description = "Abbreviated cloud name (e.g., 'aw' for AWS)"
}

variable "region_abbrev" {
  type        = string
  description = "Abbreviated region name (e.g., 'lnd' for eu-west-2)"
}

variable "environment" {
  type        = string
  description = "Abbreviated for Prod,Dev,Test"
}
# ... (keep existing variables)
/*


variable "aws_access_key_id" {
  type        = string
  description = "AWS Access Key ID"
}

variable "aws_secret_access_key" {
  type        = string
  description = "AWS Secret Access Key"
}

variable "aws_session_token" {
  type        = string
  description = "AWS Session Token"
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
*/
