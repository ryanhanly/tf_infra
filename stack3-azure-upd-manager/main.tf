# stack3-azure-upd-manager/main.tf

provider "azurerm" {
  features {}

  # Uncomment and use these if needed for authentication
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

locals {
  # Handle empty expiration date (converts to null)
  maintenance_expiration_datetime = var.maintenance_expiration_date != "" ? "${var.maintenance_expiration_date} ${var.maintenance_start_time}" : null
}

# Resource Group for Update Management
resource "azurerm_resource_group" "update_mgmt_rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Log Analytics Workspace (required for Update Management)
resource "azurerm_log_analytics_workspace" "update_workspace" {
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.update_mgmt_rg.location
  resource_group_name = azurerm_resource_group.update_mgmt_rg.name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_retention_days
  tags                = var.tags
}

# Automation Account (required for Update Management)
resource "azurerm_automation_account" "update_automation" {
  name                = var.automation_account_name
  location            = azurerm_resource_group.update_mgmt_rg.location
  resource_group_name = azurerm_resource_group.update_mgmt_rg.name
  sku_name            = "Basic"
  tags                = var.tags
}

# Link Automation Account to Log Analytics
resource "azurerm_log_analytics_linked_service" "update_linked_service" {
  resource_group_name = azurerm_resource_group.update_mgmt_rg.name
  workspace_id        = azurerm_log_analytics_workspace.update_workspace.id
  read_access_id      = azurerm_automation_account.update_automation.id
}

# Enable Update Management Solution
resource "azurerm_log_analytics_solution" "update_mgmt_solution" {
  solution_name         = "Updates"
  location              = azurerm_resource_group.update_mgmt_rg.location
  resource_group_name   = azurerm_resource_group.update_mgmt_rg.name
  workspace_resource_id = azurerm_log_analytics_workspace.update_workspace.id
  workspace_name        = azurerm_log_analytics_workspace.update_workspace.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Updates"
  }

  tags = var.tags
}

# Create maintenance configuration (schedule)
resource "azurerm_maintenance_configuration" "update_schedule" {
  name                     = var.maintenance_config_name
  resource_group_name      = azurerm_resource_group.update_mgmt_rg.name
  location                 = azurerm_resource_group.update_mgmt_rg.location
  scope                    = "InGuestPatch"
  in_guest_user_patch_mode = "User"
  visibility               = "Custom"

  window {
    # Use the exact format shown in sample.json: "YYYY-MM-DD HH:MM"
    start_date_time      = "${var.maintenance_start_date} ${var.maintenance_start_time}"
    expiration_date_time = var.maintenance_expiration_date != "" ? "${var.maintenance_expiration_date} ${var.maintenance_start_time}" : null
    duration             = var.maintenance_duration
    time_zone            = var.maintenance_timezone
    recur_every          = var.maintenance_recurrence
  }

  install_patches {
    linux {
      classifications_to_include = var.linux_classifications_to_include
      package_names_mask_to_include = var.linux_packages_to_include
      package_names_mask_to_exclude = var.linux_packages_to_exclude
    }

    windows {
      classifications_to_include = var.windows_classifications_to_include
      kb_numbers_to_include      = var.windows_kb_to_include
      kb_numbers_to_exclude      = var.windows_kb_to_exclude
    }

    reboot = var.reboot_setting
  }

  tags = var.tags
}

# Output the workspace ID and primary key for Ansible integration
output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.update_workspace.id
}

output "log_analytics_workspace_primary_key" {
  description = "The primary key of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.update_workspace.primary_shared_key
  sensitive   = true
}

output "automation_account_id" {
  description = "The ID of the Automation account"
  value       = azurerm_automation_account.update_automation.id
}

output "maintenance_configuration_id" {
  description = "The ID of the maintenance configuration"
  value       = azurerm_maintenance_configuration.update_schedule.id
}