# modules/azure_vm/outputs.tf

output "vm_id" {
  description = "ID of the created virtual machine"
  value       = azurerm_linux_virtual_machine.vm.id
}

output "vm_public_ip" {
  description = "Public IP address of the virtual machine"
  value       = azurerm_linux_virtual_machine.vm.public_ip_address
}

output "ssh_private_key" {
  description = "The private key for SSH access (sensitive)"
  value       = tls_private_key.ssh_key.private_key_pem
  sensitive   = true
}

output "ssh_public_key" {
  description = "The public key used for SSH access"
  value       = tls_private_key.ssh_key.public_key_openssh
}

output "ssh_connection_string" {
  description = "Command to connect to the VM via SSH"
  value       = "ssh ${var.admin_username}@${azurerm_linux_virtual_machine.vm.public_ip_address} -i ${path.module}/ssh_keys/${var.vm_name}_key.pem"
}