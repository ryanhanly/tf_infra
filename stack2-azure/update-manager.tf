# stack2-azure/update-manager.tf
# Azure Update Manager configuration for Ubuntu VMs

# Maintenance configuration for Ubuntu patching
resource "azurerm_maintenance_configuration" "ubuntu_updates" {
  name                     = "${var.infprefix}-ubuntu-updates"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  scope                    = "InGuestPatch"
  in_guest_user_patch_mode = "User"
  visibility               = "Custom"

  window {
    start_date_time      = var.maintenance_start_datetime
    expiration_date_time = var.maintenance_expiration_datetime
    duration             = var.maintenance_duration
    time_zone            = var.maintenance_timezone
    recur_every          = var.maintenance_recurrence
  }

  install_patches {
    linux {
      classifications_to_include     = var.linux_classifications_to_include
      package_names_mask_to_include  = var.linux_packages_to_include
      package_names_mask_to_exclude  = var.linux_packages_to_exclude
    }

    reboot = var.reboot_setting
  }

  tags = {
    Environment = var.environment
    Service     = "UpdateManagement"
    ManagedBy   = "Terraform"
    Purpose     = "UbuntuPatching"
  }
}

# Assign each VM to the maintenance configuration
resource "azurerm_maintenance_assignment_virtual_machine" "ubuntu_vm_assignments" {
  for_each = module.ubuntu_vm

  location                     = azurerm_resource_group.rg.location
  maintenance_configuration_id = azurerm_maintenance_configuration.ubuntu_updates.id
  virtual_machine_id          = each.value.vm_id
}