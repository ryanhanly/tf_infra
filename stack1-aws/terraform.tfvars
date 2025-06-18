# stack1-aws/terraform.tfvars
# Mirror server IP (set this after deploying stack4)
mirror_server_ip = "172.166.188.125"  # Update with actual mirror server IP

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