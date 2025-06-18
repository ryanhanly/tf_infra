# stack2-azure/main.tf (root module) - Updated for RHEL

provider "azurerm" {
  features {}

  # Uncomment and use these if needed for authentication
  # subscription_id = var.subscription_id
  # client_id       = var.client_id
  # client_secret   = var.client_secret
  # tenant_id       = var.tenant_id
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.infprefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create a subnet
resource "azurerm_subnet" "subnet" {
  name                 = "${var.infprefix}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a public IP for each VM
resource "azurerm_public_ip" "public_ip" {
  for_each            = var.virtual_machines
  name                = "${var.infprefix}-${each.key}-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# Create a network security group with RHEL-specific rules
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.infprefix}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Allow SSH
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"  # In production, limit this to your IP
    destination_address_prefix = "*"
  }

  # Allow HTTP for RHEL repo access
  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "10.0.0.0/16"  # Only from local VNet
    destination_address_prefix = "*"
  }
}

# Create a network interface for each VM
resource "azurerm_network_interface" "nic" {
  for_each            = var.virtual_machines
  name                = "${var.infprefix}-${each.key}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip[each.key].id
  }
}

# Associate the NSG with the subnet
resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

module "rhel_vm" {
  source   = "./modules/azure_vm"
  for_each = var.virtual_machines

  resource_group_name  = azurerm_resource_group.rg.name
  location             = azurerm_resource_group.rg.location
  vm_name              = "azr-srv-rhel-${format("%02d", each.value.index)}"
  vm_size              = each.value.vm_size
  network_interface_id = azurerm_network_interface.nic[each.key].id
  admin_username       = each.value.admin_username

  # RHEL-specific configuration
  image_publisher = "RedHat"
  image_offer     = "RHEL"
  image_sku       = each.value.rhel_version
  image_version   = "latest"

  # Red Hat subscription details
  enable_rhel_registration = var.enable_rhel_registration
  redhat_username         = var.redhat_username
  redhat_password         = var.redhat_password
  mirror_server_ip        = var.mirror_server_ip

  # Pass auto-shutdown variables to module
  enable_auto_shutdown                = var.enable_auto_shutdown
  auto_shutdown_time                  = var.auto_shutdown_time
  auto_shutdown_timezone              = var.auto_shutdown_timezone
  auto_shutdown_notification_email    = var.auto_shutdown_notification_email

  tags = merge(
    {
      Environment = var.environment
      Project     = "RHELLearning"
      OS          = "RHEL"
    },
    each.value.tags
  )
}