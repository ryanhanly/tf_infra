# stack1-aws/terraform.tfvars
# Red Hat Developer credentials
redhat_username = "your-redhat-developer-username"
redhat_password = "your-redhat-developer-password"

# Mirror server IP (set this after deploying stack4)
mirror_server_ip = "mirror-server-public-ip"  # Update with actual mirror server IP

# RHEL server configuration
server_instances = {
  "rhel-server1" = {
    instance_type    = "t3.medium"
    rhel_version     = "9.4"
    index           = 1
    additional_tags = {
      Purpose = "Development"
    }
  },
  "rhel-server2" = {
    instance_type    = "t3.medium"
    rhel_version     = "9.4"
    index           = 2
    additional_tags = {
      Purpose = "Testing"
    }
  },
  "rhel-server3" = {
    instance_type    = "t3.medium"
    rhel_version     = "8.9"  # Mix of RHEL versions
    index           = 3
    additional_tags = {
      Purpose = "Legacy"
    }
  }
}

# Network configuration
aws_region = "eu-west-2"
vpc_cidr   = "10.0.0.0/16"
subnet_cidr = "10.0.1.0/24"

# Security - restrict SSH access to your IP
ssh_allowed_cidr = ["your.public.ip.address/32"]