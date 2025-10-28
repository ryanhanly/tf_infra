# stack6-patch-management/main.tf
# Centralized patch management using Dynamic Scopes

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
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

# Use existing Arc resource group
data "azurerm_resource_group" "arc_rg" {
  name = var.arc_resource_group_name
}

# Maintenance configurations for each BU-Environment combination
resource "azurerm_maintenance_configuration" "patch_configs" {
  for_each = local.patch_combinations

  name                     = "patch-${each.key}"
  resource_group_name      = data.azurerm_resource_group.arc_rg.name
  location                 = data.azurerm_resource_group.arc_rg.location
  scope                    = "InGuestPatch"
  in_guest_user_patch_mode = "User"
  visibility               = "Custom"

  window {
    start_date_time = each.value.schedule.start_datetime
    duration        = each.value.schedule.duration
    time_zone       = var.timezone
    recur_every     = each.value.schedule.recurrence
  }

  install_patches {
    linux {
      classifications_to_include    = var.linux_classifications
      package_names_mask_to_exclude = each.value.schedule.exclude_packages
    }
    reboot = var.reboot_setting
  }

  tags = merge(var.tags, {
    BusinessUnit = each.value.business_unit
    Environment  = each.value.environment
    PatchGroup   = each.key
  })
}

# Dynamic scope assignments based on OS type and tags
resource "azurerm_maintenance_assignment_dynamic_scope" "patch_scopes" {
  for_each = local.patch_combinations

  name                         = "scope-${each.key}"
  maintenance_configuration_id = azurerm_maintenance_configuration.patch_configs[each.key].id

  filter {
    # Linux machines only
    resource_types = ["Microsoft.Compute/virtualMachines", "Microsoft.HybridCompute/machines"]
    os_types       = ["Linux"]

    # Filter by subscription (select all if multiple)
    locations = [data.azurerm_resource_group.arc_rg.location]

    # Tag filter - must match ALL tags (BU AND Environment)
    tag_filter = "All"

    tags {
      tag    = "BU"
      values = [each.value.business_unit]
    }

    tags {
      tag    = "Environment"
      values = [each.value.environment]
    }
  }
}