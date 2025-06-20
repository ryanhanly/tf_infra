# stack3-azure-upd-manager/arc-update-manager.tf
# Add Arc-enabled AWS servers to Azure Update Manager

# # Data source to find Arc-enabled servers
# this is duplicating
# data "azurerm_arc_machine" "aws_servers" {
#   count               = length(var.arc_server_names)
#   name                = var.arc_server_names[count.index]
#   resource_group_name = var.arc_resource_group_name
# }

# duplicating
# resource "azurerm_maintenance_assignment_virtual_machine" "arc_assignments" {
#   count = length(data.azurerm_arc_machine.aws_servers)
#   location                     = var.location
#   maintenance_configuration_id = azurerm_maintenance_configuration.update_schedule.id
#   virtual_machine_id          = data.azurerm_arc_machine.aws_servers[count.index].id
# }

# Output Arc assignments
# duplicating
# output "arc_server_assignments" {
#   description = "Arc servers assigned to Update Manager"
#   value = {
#     for i, assignment in azurerm_maintenance_assignment_virtual_machine.arc_assignments :
#     var.arc_server_names[i] => assignment.virtual_machine_id
#   }
# }