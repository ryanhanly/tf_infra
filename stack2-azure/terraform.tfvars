# stack2-azure/terraform.tfvars
# Red Hat Developer credentials
redhat_username = "your-redhat-developer-username"
redhat_password = "your-redhat-developer-password"

# Mirror server IP (set this after deploying stack4)
mirror_server_ip = "172.16.1.4"  # Update with actual mirror server private IP

# RHEL VM configuration
virtual_machines = {
  "rhel-vm01" = {
    vm_size        = "Standard_B2s"
    admin_username = "rhel-admin"
    rhel_version   = "9_4"  # RHEL 9.4
    index          = 1
    tags = {
      Name        = "rhel_vm_01"
      Environment = "Development"
      Purpose     = "Testing"
    }
  },
  "rhel-vm02" = {
    vm_size        = "Standard_B2s"
    admin_username = "rhel-admin"
    rhel_version   = "9_4"  # RHEL 9.4
    index          = 2
    tags = {
      Name        = "rhel_vm_02"
      Environment = "Development"
      Purpose     = "Development"
    }
  }
}

# Infrastructure settings
location            = "UK South"
resource_group_name = "azr-rhel-vms-rg"
environment        = "development"

# Enable RHEL registration
enable_rhel_registration = true

# Cost optimization
enable_auto_shutdown = true
auto_shutdown_time   = "1800"