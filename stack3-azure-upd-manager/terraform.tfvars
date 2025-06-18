# azure-update-manager/terraform.tfvars.example

# Authentication details
subscription_id = "810ef0ef-448f-48b1-88b9-1f3f0f26a320"  # Example ID, replace with your actual subscription ID
client_id       = "64e1338f-0ccc-4acb-83d7-3d15d68511a1"  # Example ID, replace with your actual client ID
client_secret   = ""  # Add your client secret here
tenant_id       = "479bd166-4e88-4b05-8091-599ef34318e0"  # Example ID, replace with your actual tenant ID

# Resource names and location
location                    = "UK South"
resource_group_name         = "rg-update-management"

# Maintenance configuration
maintenance_config_name = "monthly-updates"
maintenance_start_date  = "2025-05-15"
maintenance_start_time  = "22:00"
maintenance_duration    = "03:00"
maintenance_timezone    = "UTC"
maintenance_recurrence  = "1Month"

# Update settings
linux_classifications_to_include = ["Critical", "Security"]
linux_packages_to_include       = []  # Empty means all packages
linux_packages_to_exclude       = []

windows_classifications_to_include = ["Critical", "Security"]
windows_kb_to_include             = []  # Empty means all updates
windows_kb_to_exclude             = []

reboot_setting = "IfRequired"

# Resource tagging
tags = {
  Environment  = "Production"
  Service      = "UpdateManagement"
  ManagedBy    = "Terraform"
  Department   = "IT Operations"
  CostCenter   = "IT-123"
}