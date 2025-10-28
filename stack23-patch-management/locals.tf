# stack6-patch-management/locals.tf

# Reference shared values for validation
module "shared_values" {
  source = "../shared"
}

locals {
  # Create all valid BU-Environment combinations
  patch_combinations = {
    for combo in setproduct(module.shared_values.allowed_business_units, module.shared_values.allowed_environments) :
    "${combo[0]}-${combo[1]}" => {
      business_unit = combo[0]
      environment   = combo[1]
      schedule      = var.patch_schedules[combo[1]]  # Schedule by environment type
    }
  }
}