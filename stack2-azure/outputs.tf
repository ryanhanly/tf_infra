output "vm_public_ips" {
  description = "Public IPs of all VMs"
  value = {
    for name, vm in module.linux_vm : name => vm.public_ip
  }
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.rg.name
}