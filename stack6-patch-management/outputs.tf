# stack6-patch-management/outputs.tf

output "maintenance_configurations" {
  description = "Created maintenance configurations with dynamic scopes"
  value = {
    for k, config in azurerm_maintenance_configuration.patch_configs :
    k => {
      id       = config.id
      schedule = "${local.patch_combinations[k].schedule.start_datetime} (${var.timezone})"
      bu       = local.patch_combinations[k].business_unit
      env      = local.patch_combinations[k].environment
    }
  }
}

output "dynamic_scopes" {
  description = "Dynamic scope assignments"
  value = {
    for k, scope in azurerm_maintenance_assignment_dynamic_scope.patch_scopes :
    k => {
      scope_id = scope.id
      filters  = "OS=Linux, BU=${local.patch_combinations[k].business_unit}, Environment=${local.patch_combinations[k].environment}"
    }
  }
}

output "patch_summary" {
  description = "Patch management summary"
  value = {
    total_configurations = length(azurerm_maintenance_configuration.patch_configs)
    business_units      = module.shared_values.allowed_business_units
    environments        = module.shared_values.allowed_environments
    schedule_timezone   = var.timezone
  }
}