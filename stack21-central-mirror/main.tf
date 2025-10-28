# stack4-central-mirror/main.tf
# Central Ubuntu Repository Mirror Server

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
  name                     = "ubunturepo${random_id.storage_suffix.hex}"
  resource_group_name      = azurerm_resource_group.mirror_rg.name
  location                 = azurerm_resource_group.mirror_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS" # Cheaper for lab use

  public_network_access_enabled = true

  blob_properties {
    delete_retention_policy {
      days = var.retention_days
    }
    versioning_enabled = true
  }

  tags = var.tags
}

# Blob Container for repositories
resource "azurerm_storage_container" "repo_container" {
  name                  = "ubuntu-repos"
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

# Subnet
resource "azurerm_subnet" "mirror_subnet" {
  name                 = "${var.infprefix}-mirror-subnet"
  resource_group_name  = azurerm_resource_group.mirror_rg.name
  virtual_network_name = azurerm_virtual_network.mirror_vnet.name
  address_prefixes     = ["172.16.1.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
}

# Public IP
resource "azurerm_public_ip" "mirror_pip" {
  name                = "${var.infprefix}-mirror-pip"
  location            = azurerm_resource_group.mirror_rg.location
  resource_group_name = azurerm_resource_group.mirror_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# NSG with Ubuntu-specific rules
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
    name                       = "HTTP_Ubuntu_Repos"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefixes    = concat(var.allowed_aws_ips, var.allowed_azure_vnets)
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
    public_ip_address_id          = azurerm_public_ip.mirror_pip.id
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

# Ubuntu Virtual Machine
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
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 64
  }

  # Ubuntu 22.04 LTS
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Configure patch orchestration for Azure Update Manager
  patch_assessment_mode                                  = "AutomaticByPlatform"
  patch_mode                                             = "AutomaticByPlatform"
  bypass_platform_safety_checks_on_user_schedule_enabled = true

  # Ubuntu cloud-init
  custom_data = base64encode(templatefile("${path.module}/cloud-init.yml", {
    storage_account_name = azurerm_storage_account.repo_storage.name
    storage_account_key  = azurerm_storage_account.repo_storage.primary_access_key
    container_name       = azurerm_storage_container.repo_container.name
  }))

  identity {
    type = "SystemAssigned"
  }

  tags = merge(var.tags, {
    OS        = "Ubuntu"
    OSVersion = "22.04"
  })
}

# Auto-shutdown schedule
resource "azurerm_dev_test_global_vm_shutdown_schedule" "mirror_shutdown" {
  count              = var.enable_auto_shutdown ? 1 : 0
  virtual_machine_id = azurerm_linux_virtual_machine.mirror_vm.id
  location           = azurerm_resource_group.mirror_rg.location
  enabled            = true

  daily_recurrence_time = var.auto_shutdown_time
  timezone              = var.auto_shutdown_timezone

  notification_settings {
    enabled         = var.auto_shutdown_notification_email != ""
    time_in_minutes = 30
    email           = var.auto_shutdown_notification_email
  }

  tags = var.tags
}

# Data disk for repository storage
resource "azurerm_managed_disk" "mirror_data_disk" {
  name                 = "${azurerm_linux_virtual_machine.mirror_vm.name}-datadisk"
  location             = azurerm_resource_group.mirror_rg.location
  resource_group_name  = azurerm_resource_group.mirror_rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_size_gb
  tags                 = var.tags
}

# Attach data disk
resource "azurerm_virtual_machine_data_disk_attachment" "mirror_disk_attach" {
  managed_disk_id    = azurerm_managed_disk.mirror_data_disk.id
  virtual_machine_id = azurerm_linux_virtual_machine.mirror_vm.id
  lun                = "0"
  caching            = "ReadWrite"
}