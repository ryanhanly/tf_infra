variable "aws_region" {
  type        = string
  default     = "eu-west-2"
  description = "AWS Region for deploying resources"
}

variable "name_prefix" {
  type        = string
  default     = "aws-infra"
  description = "Prefix for naming infrastructure resources"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for the VPC"
}

variable "subnet_cidr" {
  type        = string
  default     = "10.0.1.0/24"
  description = "CIDR block for the subnet"
}

variable "ssh_allowed_cidr" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "CIDR blocks allowed for SSH access (restrict in production)"
}

variable "server_instances" {
  type = map(object({
    ami_id          = string
    instance_type   = string
    os_type         = string
    index           = number
    additional_tags = map(string)
  }))
  description = "Map of servers to create with their configurations"

  default = {
    "server1" = {
      ami_id          = "ami-0903ff18cc3c8e341"  # Ubuntu 22.04 in eu-west-2
      instance_type   = "t2.micro"
      os_type         = "ubuntu"
      index           = 1
      additional_tags = {}
    }
    "server2" = {
      ami_id          = "ami-0903ff18cc3c8e341"  # Ubuntu 22.04 in eu-west-2
      instance_type   = "t2.micro"
      os_type         = "ubuntu"
      index           = 2
      additional_tags = { "Purpose" = "Testing" }
    }
    "server3" = {
      ami_id          = "ami-0903ff18cc3c8e341"  # Ubuntu 22.04 in eu-west-2
      instance_type   = "t2.micro"
      os_type         = "ubuntu"
      index           = 3
      additional_tags = { "Purpose" = "Development" }
    }
  }
}