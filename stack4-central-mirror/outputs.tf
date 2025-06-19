# stack4-central-mirror/outputs.tf

output "mirror_server_public_ip" {
  description = "Public IP address of the Ubuntu mirror server"
  value       = azurerm_public_ip.mirror_pip.ip_address
}

output "mirror_server_private_ip" {
  description = "Private IP address of the Ubuntu mirror server"
  value       = azurerm_network_interface.mirror_nic.private_ip_address
}

output "ssh_connection_command" {
  description = "SSH command to connect to the mirror server"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.mirror_pip.ip_address} -i ${path.module}/ssh_keys/azr-srv-mirror-01.pem"
}

output "ssh_key_location" {
  description = "Location of the SSH private key"
  value       = "${path.module}/ssh_keys/azr-srv-mirror-01.pem"
}

output "mirror_url" {
  description = "URL to access the Ubuntu mirror"
  value       = "http://${azurerm_public_ip.mirror_pip.ip_address}/ubuntu/"
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.mirror_rg.name
}

output "vm_name" {
  description = "Name of the mirror server VM"
  value       = azurerm_linux_virtual_machine.mirror_vm.name
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.repo_storage.name
}

# Azure Update Manager outputs
output "maintenance_configuration_id" {
  description = "ID of the maintenance configuration for mirror server"
  value       = azurerm_maintenance_configuration.mirror_updates.id
}

output "update_manager_summary" {
  description = "Summary of Update Manager configuration for mirror"
  value = {
    maintenance_schedule = "${var.maintenance_start_datetime} (${var.maintenance_timezone})"
    duration            = var.maintenance_duration
    recurrence          = var.maintenance_recurrence
    reboot_setting      = var.reboot_setting
  }
}