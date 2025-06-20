# stack1-aws/terraform.tfvars
# Mirror server IP (set this after deploying stack4)
mirror_server_ip = "172.166.188.125"  # asr-srv-ubuntu-01 (Mirror Server in Azure)

# Ubuntu server configuration
server_instances = {
  "ubuntu-server1" = {
    instance_type    = "t3.medium"
    index           = 1
    additional_tags = {
      Purpose = "Development"
    }
  },
  "ubuntu-server2" = {
    instance_type    = "t3.medium"
    index           = 2
    additional_tags = {
      Purpose = "Testing"
    }
  },
  "ubuntu-server3" = {
    instance_type    = "t3.medium"
    index           = 3
    additional_tags = {
      Purpose = "Staging"
    }
  }
}

# Network configuration
aws_region = "eu-west-2"
vpc_cidr   = "10.0.0.0/16"
subnet_cidr = "10.0.1.0/24"

# Security - open for lab (restrict in production)
ssh_allowed_cidr = ["0.0.0.0/0"]

# Azure Arc configuration
azure_subscription_id = "810ef0ef-448f-48b1-88b9-1f3f0f26a320"
azure_tenant_id      = "479bd166-4e88-4b05-8091-599ef34318e0"
arc_client_id         = "41f45bbc-3c67-40f1-8462-51d391eb100c"
arc_client_secret     = "3ou8Q~4JR7rnySWJ.GL3xsr8QW_s5rpdkMLryaRQ%"
arc_resource_group    = "rg-arc-aws-servers"
