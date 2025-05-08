# stack3-azure-upd-manager/main.tf

provider "azurerm" {
  features {}

  # Uncomment and use these if needed for authentication
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

# Resource Group for Update Management
resource "azurerm_resource_group" "update_mgmt_rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Output the resource group for future reference
output "resource_group_id" {
  description = "The ID of the Resource Group"
  value       = azurerm_resource_group.update_mgmt_rg.id
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.update_mgmt_rg.name
}