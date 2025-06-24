# stack6-patch-management/locals.tf

locals {
  # Create combinations of Arc servers and their business units
  arc_bu_combinations = [
    for server_id in var.aws_arc_server_ids : {
      server = server_id
      bu     = var.server_bu_mapping[server_id]
    }
  ]

  # Create combinations of Azure VMs and their business units
  azure_bu_combinations = [
    for vm_name in var.azure_vm_names : {
      vm = vm_name
      bu = var.server_bu_mapping[vm_name]
    }
  ]
}