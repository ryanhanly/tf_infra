locals {
  cloud_abbrev = var.cloud_abbrev
  region_abbrev = var.region_abbrev
  aws_region = var.aws_region
}

output "bu_abbrevs" {
  value = local.bu_abbrevs
}

output "environment_abbreviations" {
  value = local.environment_abbreviations
}

output "cloud_abbrevs" {
  value = local.cloud_abbrevs
}

output "region_abbrevs" {
  value = local.region_abbrevs
}

output "os_codes" {
  value = local.os_codes
}