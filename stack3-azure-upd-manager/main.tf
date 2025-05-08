# stack3-azure-upd-manager/main.tf

provider "azurerm" {
  features {}

  # Authentication parameters
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

# Create maintenance configuration for patching (modern approach)
resource "azurerm_maintenance_configuration" "update_schedule" {
  name                     = var.maintenance_config_name
  resource_group_name      = azurerm_resource_group.update_mgmt_rg.name
  location                 = azurerm_resource_group.update_mgmt_rg.location
  scope                    = "InGuestPatch"
  in_guest_user_patch_mode = "User"
  visibility               = "Custom"

  window {
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

# Output resource info
output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.update_mgmt_rg.name
}

output "maintenance_configuration_id" {
  description = "The ID of the maintenance configuration"
  value       = azurerm_maintenance_configuration.update_schedule.id
}