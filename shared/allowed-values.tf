# shared/allowed-values.tf
# Centralized governance values for all stacks

locals {
  allowed_business_units = ["SC", "MSH", "TMS"]
  allowed_environments   = ["Development", "Test", "Production"]

  environment_abbreviations = {
    "Development" = "Dev"
    "Test"        = "Test"
    "Production"  = "Prod"
  }
}