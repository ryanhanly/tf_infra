# stack1-aws/arc-patch-extensions.tf
# Azure Arc VM Extensions for patch management

# Data source to get Arc machine info
data "azurerm_arc_machine" "aws_arc_servers" {
  for_each = aws_instance.ubuntu_servers

  name                = each.value.id # AWS instance ID becomes Arc machine name
  resource_group_name = var.arc_resource_group

  depends_on = [null_resource.install_arc_agent]
}

# Create combined patch management and scheduler extension
resource "azurerm_arc_machine_extension" "patch_management" {
  for_each = data.azurerm_arc_machine.aws_arc_servers

  name                 = "PatchManagement"
  location             = var.azure_region
  arc_machine_id       = each.value.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = jsonencode({
    script = base64encode(templatefile("${path.module}/combined-patch-setup.sh", {
      server_name = local.server_names[each.key]
    }))
  })

  tags = {
    Environment = "Development"
    Purpose     = "PatchManagement"
    ManagedBy   = "Terraform"
  }
}

# Output Arc extension info
output "arc_patch_extensions" {
  description = "Arc patch management extensions"
  value = {
    for k, ext in azurerm_arc_machine_extension.patch_management :
    local.server_names[k] => {
      extension_id = ext.id
      machine_id   = ext.arc_machine_id
    }
  }
}