# stack4-central-mirror/terraform.tfvars
# Azure authentication
subscription_id = "810ef0ef-448f-48b1-88b9-1f3f0f26a320"
client_id       = "64e1338f-0ccc-4acb-83d7-3d15d68511a1"
client_secret   = "5RZ8Q~YZK12LfzASsLfU0Gy2jaBiJIP3sIc-Aay0"
tenant_id       = "479bd166-4e88-4b05-8091-599ef34318e0"

# Infrastructure configuration
location            = "UK South"
resource_group_name = "azr-ubuntu-mirror-rg"
vm_size            = "Standard_D2s_v3"
data_disk_size_gb  = 512

# Network access control (open for lab - restrict in production)
admin_source_ips = ["0.0.0.0/0"]
allowed_aws_ips  = ["0.0.0.0/0"]

# Cost optimization
enable_auto_shutdown = true
auto_shutdown_time   = "1800"  # 6 PM

# Email for shutdown notifications (optional)
auto_shutdown_notification_email = "ryanhanly@gmail.com"