# shared/allowed-values.tf
# Centralized governance values for all stacks
locals {
  allowed_business_units = ["retail", "marketing", "finance", "hr", "it"]
  allowed_environments   = ["development", "test", "production"]

  environment_abbreviations = {
    "development" = "dev"
    "test"        = "tes"
    "production"  = "pro"
  }

  # Cloud abbreviations (lowercase)
  cloud_abbrevs = {
    "aws"   = "aw"
    "azure" = "az"
    "gcp"   = "gc"
  }

  # Region abbreviations to normalise across clouds (lowercase)
  region_abbrevs = {
    "us-east-1"  = "nva"
    "eu-west-2"  = "lnd"
    "eastus"     = "eus"
    "europe-west1" = "euw"
  }

  # OS codes (lowercase)
  os_codes = {
    "linux"   = "lnx"
    "windows" = "win"
  }

  # Business unit abbreviations (lowercase)
  bu_abbrevs = {
    "retail"     = "ret"
    "marketing"  = "mar"
    "finance"    = "fin"
    "hr"         = "hum"
    "it"         = "tec"
  }
}