# main.tf (root module)

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
  allocation_method   = "Dynamic"
}

# Create a network security group
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

# Use our VM module with the generated SSH key for each VM
module "linux_vm" {
  source   = "./modules/azure_vm"
  for_each = var.virtual_machines

  resource_group_name  = azurerm_resource_group.rg.name
  location             = azurerm_resource_group.rg.location
  vm_name              = local.generate_vm_name(
    "azr",
    each.value.os_type,  # Using OS type from variable
    each.value.index     # Using index from variable
  )
  vm_size              = each.value.vm_size
  network_interface_id = azurerm_network_interface.nic[each.key].id
  admin_username       = each.value.admin_username

  tags = merge(
    {
      Environment = var.environment
      Project     = "TerraformLearning"
    },
    each.value.tags
  )
}