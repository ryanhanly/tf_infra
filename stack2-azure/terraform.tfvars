# stack2-azure/terraform.tfvars
# Mirror server IP (set this after deploying stack4)
mirror_server_ip = "172.16.1.4"  # Update with actual mirror server private IP

# Ubuntu VM configuration
virtual_machines = {
  "ubuntu-vm01" = {
    vm_size        = "Standard_B2s"
    admin_username = "ubuntu"
    index          = 1
    tags = {
      Name        = "ubuntu_vm_01"
      Environment = "Development"
      Purpose     = "Testing"
    }
  },
  "ubuntu-vm02" = {
    vm_size        = "Standard_B2s"
    admin_username = "ubuntu"
    index          = 2
    tags = {
      Name        = "ubuntu_vm_02"
      Environment = "Development"
      Purpose     = "Development"
    }
  }
}

# Infrastructure settings
location            = "UK South"
resource_group_name = "azr-ubuntu-vms-rg"
environment        = "development"

# Cost optimization
enable_auto_shutdown = true
auto_shutdown_time   = "1800"