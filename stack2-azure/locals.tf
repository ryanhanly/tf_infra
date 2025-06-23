# locals.tf - Enforce standardized tagging
locals {
  # Environment abbreviation mapping
  environment_abbrev = module.shared_values.environment_abbreviations

  # Generate mandatory tags for each VM
  mandatory_tags = {
    BU          = var.business_unit
    Environment = var.environment
    PatchGroup  = "AUM-${var.business_unit}-${local.environment_abbrev[var.environment]}"
    OS          = "Ubuntu"
    Cloud       = "Azure"
    ManagedBy   = "Terraform"
  }
}