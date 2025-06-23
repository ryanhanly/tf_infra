# stack2-azure/terraform.tfvars
# Example configuration - copy to terraform.tfvars and update values

# Azure Creds
subscription_id = "810ef0ef-448f-48b1-88b9-1f3f0f26a320"
client_id       = "64e1338f-0ccc-4acb-83d7-3d15d68511a1"
client_secret   = "5RZ8Q~YZK12LfzASsLfU0Gy2jaBiJIP3sIc-Aay0"
tenant_id       = "479bd166-4e88-4b05-8091-599ef34318e0"

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
    business_unit  = "SC"
    environment    = "Development"
    tags = {
      Name        = "ubuntu_vm_01"
      Purpose     = "Testing"
    }
  },
  "ubuntu-vm02" = {
    vm_size        = "Standard_B2s"
    admin_username = "ubuntu"
    index          = 2
    business_unit  = "MSH"
    environment    = "Production"
    tags = {
      Name        = "ubuntu_vm_02"
      Purpose     = "Database"
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
