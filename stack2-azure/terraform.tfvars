# stack2-azure/terraform.tfvars.example
# Example configuration - copy to terraform.tfvars and update values

# Azure Configuration
location            = "UK South"
resource_group_name = "azr-ubuntu-vms-rg"
environment         = "development"

# Naming Conventions
srvprefix      = "azr-srv"
infprefix      = "azr-inf"
admin_username = "ubuntu"

# Mirror server IP (stack4 VM IP)
mirror_server_ip = "172.16.1.4"

# Virtual Machine Configuration
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

# Cost Optimization
enable_auto_shutdown             = true
auto_shutdown_time               = "1800"
auto_shutdown_timezone           = "GMT Standard Time"
auto_shutdown_notification_email = "your-email@example.com"

# Azure Update Manager Configuration
maintenance_start_datetime      = "2025-07-15 22:00"
maintenance_expiration_datetime = "2026-07-15 22:00"
maintenance_duration            = "03:00"
maintenance_timezone            = "GMT Standard Time"
maintenance_recurrence          = "Month Second Tuesday"

# Update Classifications
linux_classifications_to_include = ["Critical", "Security"]
linux_packages_to_include        = []
linux_packages_to_exclude        = ["kernel*"]

# Reboot Behavior
reboot_setting = "IfRequired"