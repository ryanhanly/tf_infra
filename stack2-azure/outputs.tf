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