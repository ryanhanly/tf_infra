output "vm_public_ips" {
  description = "Public IPs of all VMs"
  value = {
    for name, ubuntu_vm in module.ubuntu_vm : name => ubuntu_vm.vm_public_ip
  }
}

output "ssh_connection_strings" {
  description = "Commands to connect to the VMs via SSH"
  value = {
    for name, ubuntu_vm in module.ubuntu_vm : name => ubuntu_vm.ssh_connection_string
  }
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.rg.name
}

# Azure Update Manager outputs
output "maintenance_configuration_id" {
  description = "ID of the maintenance configuration"
  value       = azurerm_maintenance_configuration.ubuntu_updates.id
}

output "maintenance_configuration_name" {
  description = "Name of the maintenance configuration"
  value       = azurerm_maintenance_configuration.ubuntu_updates.name
}

output "assigned_vms" {
  description = "VMs assigned to Update Manager"
  value = {
    for k, assignment in azurerm_maintenance_assignment_virtual_machine.ubuntu_vm_assignments :
    k => assignment.virtual_machine_id
  }
}

output "update_manager_summary" {
  description = "Summary of Update Manager configuration"
  value = {
    maintenance_schedule = "${var.maintenance_start_datetime} (${var.maintenance_timezone})"
    duration            = var.maintenance_duration
    recurrence          = var.maintenance_recurrence
    reboot_setting      = var.reboot_setting
    vm_count           = length(var.virtual_machines)
  }
}