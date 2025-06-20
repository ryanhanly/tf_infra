# stack5-arc-prereqs/outputs.tf

output "arc_resource_group_name" {
  description = "Name of the Arc resource group"
  value       = azurerm_resource_group.arc_rg.name
}

output "arc_client_id" {
  description = "Service principal client ID for Arc registration"
  value       = local.arc_sp_data.clientId
}

output "arc_client_secret" {
  description = "Service principal client secret for Arc registration"
  value       = local.arc_sp_data.clientSecret
  sensitive   = true
}

output "arc_sp_object_id" {
  description = "Service principal object ID"
  value       = local.arc_sp_data.clientId
}

output "arc_setup_summary" {
  description = "Summary of Arc prerequisites"
  value = {
    resource_group = azurerm_resource_group.arc_rg.name
    app_name      = var.arc_sp_name
    sp_client_id  = local.arc_sp_data.clientId
    location      = azurerm_resource_group.arc_rg.location
  }
}