# modules/azure_vm/main.tf

# Generate a new SSH key pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create the Ubuntu VM with the generated SSH key
resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    var.network_interface_id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.ssh_key.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Ubuntu image configuration
  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  # Configure patch orchestration for Azure Update Manager
  patch_assessment_mode = "AutomaticByPlatform"
  patch_mode           = "AutomaticByPlatform"
  bypass_platform_safety_checks_on_user_schedule_enabled = true

  # Basic cloud-init for Ubuntu setup
  custom_data = var.mirror_server_ip != "" ? base64encode(templatefile("${path.module}/ubuntu-init.yml", {
    mirror_server_ip = var.mirror_server_ip
  })) : null

  tags = var.tags
}

# Auto-shutdown schedule (for cost optimization in lab environments)
resource "azurerm_dev_test_global_vm_shutdown_schedule" "vm_shutdown" {
  count              = var.enable_auto_shutdown ? 1 : 0
  virtual_machine_id = azurerm_linux_virtual_machine.vm.id
  location           = var.location
  enabled            = true

  daily_recurrence_time = var.auto_shutdown_time
  timezone              = var.auto_shutdown_timezone

  notification_settings {
    enabled         = var.auto_shutdown_notification_email != ""
    time_in_minutes = 30
    email           = var.auto_shutdown_notification_email
  }

  tags = var.tags
}

# Save the SSH private key to a local file for easy access
resource "local_file" "private_key" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "${path.module}/ssh_keys/${var.vm_name}_key.pem"
  file_permission = "0600"

  # Make sure the directory exists
  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/ssh_keys"
  }
}