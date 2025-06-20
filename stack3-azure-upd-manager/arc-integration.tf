# stack3-azure-upd-manager/arc-integration.tf
# Add Arc-enabled AWS servers to Azure Update Manager

# Data source to find Arc-enabled servers
data "azurerm_arc_machine" "aws_servers" {
  count               = length(var.arc_server_names)
  name                = var.arc_server_names[count.index]
  resource_group_name = var.arc_resource_group_name
}

# Assign Arc servers to the existing maintenance configuration
# Use the generic maintenance assignment for Arc machines
resource "azurerm_maintenance_assignment_virtual_machine" "arc_assignments" {
  count = length(data.azurerm_arc_machine.aws_servers)

  location                     = var.location
  maintenance_configuration_id = azurerm_maintenance_configuration.update_schedule.id
  virtual_machine_id          = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.arc_resource_group_name}/providers/Microsoft.HybridCompute/machines/${var.arc_server_names[count.index]}"
}

# Get current client config for subscription ID
data "azurerm_client_config" "current" {}

# Output Arc assignments
output "arc_server_assignments" {
  description = "Arc servers assigned to Update Manager"
  value = {
    for i, assignment in azurerm_maintenance_assignment_virtual_machine.arc_assignments :
    var.arc_server_names[i] => assignment.virtual_machine_id
  }
}

output "arc_update_summary" {
  description = "Summary of Arc servers in Update Manager"
  value = {
    total_arc_servers    = length(var.arc_server_names)
    maintenance_schedule = "${var.maintenance_start_datetime} (${var.maintenance_timezone})"
    arc_server_names    = var.arc_server_names
  }
}