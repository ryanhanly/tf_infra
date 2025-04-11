output "id" {
  description = "ID of the virtual machine"
  value       = azurerm_linux_virtual_machine.vm.id
}

output "public_ip" {
  description = "Public IP of the virtual machine"
  value       = azurerm_public_ip.vm_public_ip.ip_address
}

output "private_ip" {
  description = "Private IP of the virtual machine"
  value       = azurerm_network_interface.vm_nic.private_ip_address
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = azurerm_linux_virtual_machine.vm.name
}