# stack1-aws/terraform.tfvars.example
# Example configuration - copy to terraform.tfvars and update values

# AWS Configuration
aws_region  = "eu-west-2"
name_prefix = "aws-infra"

# Network Configuration
vpc_cidr    = "10.0.0.0/16"
subnet_cidr = "10.0.1.0/24"

# Security - restrict in production
ssh_allowed_cidr = ["0.0.0.0/0"]

# Mirror server IP (set after deploying stack4)
mirror_server_ip = "172.166.188.125"

# Server Configuration
server_instances = {
  "ubuntu-server1" = {
    instance_type = "t3.medium"
    index         = 1
    bu           = "SC"
    environment  = "Development"
    additional_tags = {
      Purpose = "Development"
    }
  },
  "ubuntu-server2" = {
    instance_type = "t3.medium"
    index         = 2
    bu            = "MSH"
    environment   = "Test"
    additional_tags = {
      Purpose = "Database Server"
    }
  },
  "ubuntu-server3" = {
    instance_type = "t3.medium"
    index         = 3
    bu            = "TMS"
    environment   = "Production"
    additional_tags = {
      Purpose = "Web Server"
    }
  }
}

# Azure Arc Configuration
arc_resource_group    = "rg-arc-aws-servers"
azure_region          = "UK South"
azure_subscription_id = "810ef0ef-448f-48b1-88b9-1f3f0f26a320"
arc_client_id         = "64e1338f-0ccc-4acb-83d7-3d15d68511a1"
arc_client_secret     = "5RZ8Q~YZK12LfzASsLfU0Gy2jaBiJIP3sIc-Aay0"
azure_tenant_id       = "479bd166-4e88-4b05-8091-599ef34318e0"