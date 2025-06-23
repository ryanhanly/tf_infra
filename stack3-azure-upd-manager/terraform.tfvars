# stack3-azure-upd-manager/terraform.tfvars.example
# Example configuration - copy to terraform.tfvars and update values

# Azure Authentication
subscription_id = "810ef0ef-448f-48b1-88b9-1f3f0f26a320"
client_id       = "64e1338f-0ccc-4acb-83d7-3d15d68511a1"
client_secret   = "5RZ8Q~YZK12LfzASsLfU0Gy2jaBiJIP3sIc-Aay0"
tenant_id       = "479bd166-4e88-4b05-8091-599ef34318e0"

# Resource Configuration
location            = "UK South"
resource_group_name = "rg-arc-aws-servers" # Same as Arc servers for simplicity

# Maintenance Configuration
maintenance_config_name = "monthly-updates"
maintenance_start_date  = "2025-05-15"
maintenance_start_time  = "22:00"
maintenance_duration    = "03:00"
maintenance_timezone    = "UTC"
maintenance_recurrence  = "Month Second Tuesday"

# Linux Update Settings
linux_classifications_to_include = ["Critical", "Security"]
linux_packages_to_include        = [] # Empty means all packages
linux_packages_to_exclude        = []

# Windows Update Settings
windows_classifications_to_include = ["Critical", "Security"]
windows_kb_to_include              = [] # Empty means all updates
windows_kb_to_exclude              = []

# Reboot Configuration
reboot_setting = "IfRequired"

# Resource Tagging
tags = {
  Environment = "Production"
  Service     = "UpdateManagement"
  ManagedBy   = "Terraform"
  Department  = "IT Operations"
  CostCenter  = "IT-123"
}

# Arc Server Configuration
arc_server_names = [
  "i-0cc27d9245db9c2a5", # aws-srv-ubuntu-01
  "i-0e32269c258e57da8", # aws-srv-ubuntu-02
  "i-03fd5a884d2b006d9"  # aws-srv-ubuntu-03
]
arc_resource_group_name = "rg-arc-aws-servers"