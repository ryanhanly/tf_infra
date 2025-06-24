# stack6-patch-management/outputs.tf

output "maintenance_configurations" {
  description = "Created maintenance configurations"
  value = {
    for k, config in azurerm_maintenance_configuration.bu_configs :
    k => {
      id       = config.id
      schedule = "${var.business_unit_schedules[k].start_datetime} (${var.timezone})"
    }
  }
}

output "discovered_arc_machines" {
  description = "Arc machines discovered by BU tag"
  value = {
    for bu, machines in local.arc_machines_by_bu :
    bu => [for m in machines : m.name]
  }
}

output "discovered_azure_vms" {
  description = "Azure VMs discovered by BU tag"
  value = {
    for bu, vms in local.azure_vms_by_bu :
    bu => [for vm in vms : vm.name]
  }
}

output "patch_summary" {
  description = "Patch management summary"
  value = {
    total_arc_machines = sum([for machines in local.arc_machines_by_bu : length(machines)])
    total_azure_vms    = sum([for vms in local.azure_vms_by_bu : length(vms)])
    business_units     = keys(var.business_unit_schedules)
    schedule_timezone  = var.timezone
  }
}