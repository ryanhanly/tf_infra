# shared/outputs.tf
output "allowed_business_units" {
  value = local.allowed_business_units
}

output "allowed_environments" {
  value = local.allowed_environments
}

output "environment_abbreviations" {
  value = local.environment_abbreviations
}