# Use locals to build the configuration with variable references
locals {
  default_vms = {
    "vm-ubuntu-01" = {
      vm_size        = "Standard_B1s"
      admin_username = var.admin_username
      ssh_public_key = "~/.ssh/id_rsa.pub"
      os_disk_type   = "Standard_LRS"
      tags = {
        Name = "vm_ubuntu_01"
        Environment = var.environment
      }
    }
  }

  # Merge any user-provided VMs with our defaults
  linux_vms = merge(local.default_vms, var.linux_vm)
}