# stack4-central-mirror/terraform.tfvars
# Azure authentication
# subscription_id = "your-azure-subscription-id"
# client_id       = "your-azure-client-id"
# client_secret   = "your-azure-client-secret"
# tenant_id       = "your-azure-tenant-id"

# Red Hat Developer credentials
redhat_username = "ryanhanly"
redhat_password = "S6FADnehL6zs6jye"

# Infrastructure configuration
location            = "UK South"
resource_group_name = "azr-rhel-mirror-rg"
vm_size            = "Standard_D4s_v3"
data_disk_size_gb  = 1024

# Network access control
enable_public_access = false
admin_source_ips = [
    "your.public.ip.address/32",  # Replace with your actual IP
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
]

# Cost optimization
enable_auto_shutdown = true
auto_shutdown_time   = "1800"  # 6 PM

# Email for shutdown notifications (optional)
auto_shutdown_notification_email = "ryanhanly@gmail.com"