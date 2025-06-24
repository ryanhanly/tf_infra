# stack6-patch-management/main.tf
# Centralized patch management using dynamic queries

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

# Get all Arc machines with BU tags
data "azurerm_resources" "arc_machines" {
  resource_group_name = var.arc_resource_group_name
  type                = "Microsoft.HybridCompute/machines"
}

# Get all Azure VMs with BU tags
data "azurerm_resources" "azure_vms" {
  resource_group_name = var.azure_vm_resource_group_name
  type                = "Microsoft.Compute/virtualMachines"
}

# Filter resources by BU tags
locals {
  # Extract Arc machines by BU
  arc_machines_by_bu = {
    for bu in keys(var.business_unit_schedules) : bu => [
      for vm in data.azurerm_resources.arc_machines.resources :
      vm if lookup(vm.tags, "BU", "") == bu
    ]
  }

  # Extract Azure VMs by BU
  azure_vms_by_bu = {
    for bu in keys(var.business_unit_schedules) : bu => [
      for vm in data.azurerm_resources.azure_vms.resources :
      vm if lookup(vm.tags, "BU", "") == bu
    ]
  }
}

# Business Unit specific maintenance configurations with dynamic queries
resource "azurerm_maintenance_configuration" "bu_configs" {
  for_each = var.business_unit_schedules

  name                     = "patch-${each.key}"
  resource_group_name      = data.azurerm_resource_group.arc_rg.name
  location                 = data.azurerm_resource_group.arc_rg.location
  scope                    = "InGuestPatch"
  in_guest_user_patch_mode = "User"
  visibility               = "Custom"

  window {
    start_date_time = each.value.start_datetime
    duration        = each.value.duration
    time_zone       = var.timezone
    recur_every     = each.value.recurrence
  }

  install_patches {
    linux {
      classifications_to_include    = var.linux_classifications
      package_names_mask_to_exclude = each.value.exclude_packages
    }
    reboot = var.reboot_setting
  }

  tags = merge(var.tags, {
    BusinessUnit = each.key
    PatchGroup   = "AUM-${each.key}"
  })
}

# Note: Dynamic scope assignments can be configured manually in Azure portal
# using the BU tag to filter servers by business unit