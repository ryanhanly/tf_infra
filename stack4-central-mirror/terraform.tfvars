# stack4-central-mirror/terraform.tfvars
# Azure authentication
subscription_id = "810ef0ef-448f-48b1-88b9-1f3f0f26a320"
client_id       = "64e1338f-0ccc-4acb-83d7-3d15d68511a1"
client_secret   = "5RZ8Q~YZK12LfzASsLfU0Gy2jaBiJIP3sIc-Aay0"
tenant_id       = "479bd166-4e88-4b05-8091-599ef34318e0"

# Infrastructure configuration
location            = "UK South"
resource_group_name = "azr-ubuntu-mirror-rg"
vm_size             = "Standard_D2s_v3"
data_disk_size_gb   = 512

# Network access control (open for lab - restrict in production)
admin_source_ips = ["0.0.0.0/0"]
allowed_aws_ips  = ["0.0.0.0/0"]

# Cost optimization
enable_auto_shutdown = true
auto_shutdown_time   = "1800" # 6 PM

# Email for shutdown notifications (optional)
auto_shutdown_notification_email = "ryanhanly@gmail.com"

# Azure Update Manager settings for Mirror Server
maintenance_start_datetime      = "2025-07-15 01:00" # 1 AM - before test VMs
maintenance_expiration_datetime = "2026-07-15 01:00" # Valid for 1 year
maintenance_duration            = "02:00"            # 2 hour window (shorter)
maintenance_timezone            = "GMT Standard Time"
maintenance_recurrence          = "Month First Sunday" # Different day from test VMs

# Update classifications (more conservative for mirror server)
linux_classifications_to_include = ["Critical", "Security"]
linux_packages_to_include        = []                     # Empty means all packages
linux_packages_to_exclude        = ["nginx*", "apache2*"] # Protect web services

# Reboot behavior
reboot_setting = "IfRequired" # Reboot only if required