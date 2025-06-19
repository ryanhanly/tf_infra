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

# Azure Update Manager settings
maintenance_start_datetime     = "2025-07-15 22:00"  # Start patches at 10 PM
maintenance_expiration_datetime = "2026-07-15 22:00"  # Valid for 1 year
maintenance_duration          = "03:00"              # 3 hour window
maintenance_timezone          = "GMT Standard Time"
maintenance_recurrence        = "Month Second Tuesday"  # Monthly patching on 2nd Tuesday

# Update classifications
linux_classifications_to_include = ["Critical", "Security"]
linux_packages_to_include       = []  # Empty means all packages
linux_packages_to_exclude       = ["kernel*"]  # Example: exclude kernel updates

# Reboot behavior
reboot_setting = "IfRequired"  # Reboot only if required by updates