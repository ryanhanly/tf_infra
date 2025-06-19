# stack4-central-mirror/update-manager.tf
# Azure Update Manager configuration for Mirror Server

# Maintenance configuration for Mirror Server (scheduled separately from test VMs)
resource "azurerm_maintenance_configuration" "mirror_updates" {
  name                     = "${var.infprefix}-mirror-updates"
  resource_group_name      = azurerm_resource_group.mirror_rg.name
  location                 = azurerm_resource_group.mirror_rg.location
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

  tags = merge(var.tags, {
    Purpose = "MirrorServerPatching"
    Service = "RepositoryMirror"
  })
}

# Assign mirror server to the maintenance configuration
resource "azurerm_maintenance_assignment_virtual_machine" "mirror_vm_assignment" {
  location                     = azurerm_resource_group.mirror_rg.location
  maintenance_configuration_id = azurerm_maintenance_configuration.mirror_updates.id
  virtual_machine_id          = azurerm_linux_virtual_machine.mirror_vm.id
}