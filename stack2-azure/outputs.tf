output "vm_public_ips" {
  description = "Public IPs of all VMs"
  value = {
    for name, vm_module in module.linux_vm : name => vm_module.vm_public_ip
  }
}

output "ssh_connection_strings" {
  description = "Commands to connect to the VMs via SSH"
  value = {
    for name, vm_module in module.linux_vm : name => vm_module.ssh_connection_string
  }
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.rg.name
}