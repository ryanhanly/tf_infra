locals {
  environment_abbrev = module.shared_values.environment_abbreviations

  # Generate tags per VM
  vm_tags = {
    for k, v in var.virtual_machines : k => merge(
      {
        BU          = v.business_unit
        Environment = v.environment
        PatchGroup  = "AUM-${v.business_unit}-${local.environment_abbrev[v.environment]}"
        OS          = "Ubuntu"
        Cloud       = "Azure"
        ManagedBy   = "Terraform"
        Name        = "azr-srv-ubuntu-${format("%02d", v.index)}"
      },
      v.tags
    )
  }
}