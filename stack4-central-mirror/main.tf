# stack4-central-mirror/main.tf
# Central Linux Repository Mirror Server

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

# Generate random suffix for storage account
resource "random_id" "storage_suffix" {
  byte_length = 4
}

# Resource Group
resource "azurerm_resource_group" "mirror_rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Storage Account for Repository Storage
resource "azurerm_storage_account" "repo_storage" {
  name                     = "repostore${random_id.storage_suffix.hex}"
  resource_group_name      = azurerm_resource_group.mirror_rg.name
  location                 = azurerm_resource_group.mirror_rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  # Allow public access for now - can restrict manually later
  public_network_access_enabled = true

  blob_properties {
    delete_retention_policy {
      days = var.retention_days
    }

    versioning_enabled = true
  }

  tags = var.tags
}

# Apply network restrictions after container creation
# this messes about with TF, maybe leave them out
# resource "azurerm_storage_account_network_rules" "repo_storage_rules" {
#   storage_account_id = azurerm_storage_account.repo_storage.id

#   default_action = "Deny"
#   bypass         = ["AzureServices"]

#   virtual_network_subnet_ids = [azurerm_subnet.mirror_subnet.id]

#   depends_on = [azurerm_storage_container.repo_container]
# }

resource "azurerm_storage_management_policy" "repo_lifecycle" {
  storage_account_id = azurerm_storage_account.repo_storage.id

  rule {
    name    = "deleteOldPackages"
    enabled = true

    filters {
      prefix_match = ["rhel-updates/"]
      blob_types   = ["blockBlob"]
    }

    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 30
        tier_to_archive_after_days_since_modification_greater_than = 90
        delete_after_days_since_modification_greater_than          = 365
      }
    }
  }
}

# Blob Container for repositories
resource "azurerm_storage_container" "repo_container" {
  name                  = "linux-repos"
  storage_account_id    = azurerm_storage_account.repo_storage.id
  container_access_type = "blob"
}

# Virtual Network
resource "azurerm_virtual_network" "mirror_vnet" {
  name                = "${var.infprefix}-mirror-vnet"
  address_space       = ["172.16.0.0/16"]
  location            = azurerm_resource_group.mirror_rg.location
  resource_group_name = azurerm_resource_group.mirror_rg.name
  tags                = var.tags
}

# Subnet for private endpoints
resource "azurerm_subnet" "private_endpoint_subnet" {
  name                 = "${var.infprefix}-pe-subnet"
  resource_group_name  = azurerm_resource_group.mirror_rg.name
  virtual_network_name = azurerm_virtual_network.mirror_vnet.name
  address_prefixes     = ["172.16.2.0/24"]
}

# Subnet
resource "azurerm_subnet" "mirror_subnet" {
  name                 = "${var.infprefix}-mirror-subnet"
  resource_group_name  = azurerm_resource_group.mirror_rg.name
  virtual_network_name = azurerm_virtual_network.mirror_vnet.name
  address_prefixes     = ["172.16.1.0/24"]

  service_endpoints    = ["Microsoft.Storage"]
}

# Public IP (conditionally created)
resource "azurerm_public_ip" "mirror_pip" {
  count               = var.enable_public_access ? 1 : 0
  name                = "${var.infprefix}-mirror-pip"
  location            = azurerm_resource_group.mirror_rg.location
  resource_group_name = azurerm_resource_group.mirror_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Private DNS Zone for storage
resource "azurerm_private_dns_zone" "storage_dns" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.mirror_rg.name
  tags                = var.tags
}

# Link private DNS zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "storage_dns_link" {
  name                  = "${var.infprefix}-storage-dns-link"
  resource_group_name   = azurerm_resource_group.mirror_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_dns.name
  virtual_network_id    = azurerm_virtual_network.mirror_vnet.id
  registration_enabled  = false
  tags                  = var.tags
}

# Private endpoint for storage account
resource "azurerm_private_endpoint" "storage_pe" {
  name                = "${var.infprefix}-storage-pe"
  location            = azurerm_resource_group.mirror_rg.location
  resource_group_name = azurerm_resource_group.mirror_rg.name
  subnet_id           = azurerm_subnet.private_endpoint_subnet.id

  private_service_connection {
    name                           = "${var.infprefix}-storage-psc"
    private_connection_resource_id = azurerm_storage_account.repo_storage.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "storage-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage_dns.id]
  }

  tags = var.tags
}

# NSG
resource "azurerm_network_security_group" "mirror_nsg" {
  name                = "${var.infprefix}-mirror-nsg"
  location            = azurerm_resource_group.mirror_rg.location
  resource_group_name = azurerm_resource_group.mirror_rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.admin_source_ips
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAWSIPs"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"]
    source_address_prefixes    = length(var.allowed_aws_ips) > 0 ? var.allowed_aws_ips : ["10.255.255.255/32"]
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAzureVNets"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"]
    source_address_prefixes    = length(var.allowed_azure_vnets) > 0 ? var.allowed_azure_vnets : ["10.255.255.255/32"]
    destination_address_prefix = "*"
  }

  # Explicit deny rule (optional - default deny exists)
  security_rule {
    name                       = "DenyAllOther"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# Network Interface
resource "azurerm_network_interface" "mirror_nic" {
  name                = "${var.infprefix}-mirror-nic"
  location            = azurerm_resource_group.mirror_rg.location
  resource_group_name = azurerm_resource_group.mirror_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mirror_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.enable_public_access ? azurerm_public_ip.mirror_pip[0].id : null
  }

  tags = var.tags
}

# Associate NSG with subnet
resource "azurerm_subnet_network_security_group_association" "mirror_nsg_assoc" {
  subnet_id                 = azurerm_subnet.mirror_subnet.id
  network_security_group_id = azurerm_network_security_group.mirror_nsg.id
}

# Generate SSH key
resource "tls_private_key" "mirror_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save private key locally
resource "local_file" "mirror_private_key" {
  content         = tls_private_key.mirror_ssh_key.private_key_pem
  filename        = "${path.module}/ssh_keys/azr-srv-mirror-01.pem"
  file_permission = "0600"

  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/ssh_keys"
  }
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "mirror_vm" {
  name                = "azr-srv-mirror-01"
  resource_group_name = azurerm_resource_group.mirror_rg.name
  location            = azurerm_resource_group.mirror_rg.location
  size                = var.vm_size
  admin_username      = var.admin_username

  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.mirror_nic.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.mirror_ssh_key.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"  # Cheaper than Premium for lab
    disk_size_gb         = 64              # Reduced from 128GB
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Cloud-init script for initial setup
  custom_data = base64encode(templatefile("${path.module}/cloud-init.yml", {
    storage_account_name = azurerm_storage_account.repo_storage.name
    storage_account_key  = azurerm_storage_account.repo_storage.primary_access_key
    container_name       = azurerm_storage_container.repo_container.name
    redhat_username      = var.redhat_username
    redhat_password      = var.redhat_password
  }))

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Auto-shutdown schedule (for cost optimization in lab environments)
resource "azurerm_dev_test_global_vm_shutdown_schedule" "mirror_shutdown" {
  count              = var.enable_auto_shutdown ? 1 : 0
  virtual_machine_id = azurerm_linux_virtual_machine.mirror_vm.id
  location           = azurerm_resource_group.mirror_rg.location
  enabled            = true

  daily_recurrence_time = var.auto_shutdown_time
  timezone              = var.auto_shutdown_timezone

  notification_settings {
    enabled         = var.auto_shutdown_notification_email != ""
    time_in_minutes = 30  # 30 minutes warning
    email           = var.auto_shutdown_notification_email
  }

  tags = var.tags
}

# Data disk for repository storage
resource "azurerm_managed_disk" "mirror_data_disk" {
  name                 = "${azurerm_linux_virtual_machine.mirror_vm.name}-datadisk"
  location             = azurerm_resource_group.mirror_rg.location
  resource_group_name  = azurerm_resource_group.mirror_rg.name
  storage_account_type = "Standard_LRS"  # Cost-effective for lab
  create_option        = "Empty"
  disk_size_gb         = 256             # Reduced from 512GB
  tags                 = var.tags
}

# Attach data disk
resource "azurerm_virtual_machine_data_disk_attachment" "mirror_disk_attach" {
  managed_disk_id    = azurerm_managed_disk.mirror_data_disk.id
  virtual_machine_id = azurerm_linux_virtual_machine.mirror_vm.id
  lun                = "0"
  caching            = "ReadWrite"
}

# Grant VM access to storage account (commented out due to permissions)
# resource "azurerm_role_assignment" "mirror_storage_access" {
#   scope                = azurerm_storage_account.repo_storage.id
#   role_definition_name = "Storage Blob Data Contributor"
#   principal_id         = azurerm_linux_virtual_machine.mirror_vm.identity[0].principal_id
# }

# Azure Automation Account for scheduled sync
resource "azurerm_automation_account" "repo_automation" {
  name                = "${var.infprefix}-repo-automation"
  location            = azurerm_resource_group.mirror_rg.location
  resource_group_name = azurerm_resource_group.mirror_rg.name
  sku_name           = "Basic"
  tags               = var.tags
}

# Automation runbook for azcopy sync
resource "azurerm_automation_runbook" "sync_repos" {
  name                    = "Sync-Linux-Repos"
  location                = azurerm_resource_group.mirror_rg.location
  resource_group_name     = azurerm_resource_group.mirror_rg.name
  automation_account_name = azurerm_automation_account.repo_automation.name
  log_verbose             = true
  log_progress            = true
  runbook_type           = "PowerShell"

  content = templatefile("${path.module}/sync-repos.ps1", {
    vm_name              = azurerm_linux_virtual_machine.mirror_vm.name
    resource_group_name  = azurerm_resource_group.mirror_rg.name
    storage_account_name = azurerm_storage_account.repo_storage.name
    container_name       = azurerm_storage_container.repo_container.name
  })

  tags = var.tags
}

# Schedule for daily sync
resource "azurerm_automation_schedule" "daily_sync" {
  name                    = "DailyRepoSync"
  resource_group_name     = azurerm_resource_group.mirror_rg.name
  automation_account_name = azurerm_automation_account.repo_automation.name
  frequency               = "Day"
  interval                = 1
  start_time             = timeadd(timestamp(), "10m")
  description            = "Daily repository synchronization"
}

# Link schedule to runbook
resource "azurerm_automation_job_schedule" "sync_schedule" {
  resource_group_name     = azurerm_resource_group.mirror_rg.name
  automation_account_name = azurerm_automation_account.repo_automation.name
  schedule_name          = azurerm_automation_schedule.daily_sync.name
  runbook_name           = azurerm_automation_runbook.sync_repos.name
}