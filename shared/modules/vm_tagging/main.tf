locals {
  # Standard keys (consistent across clouds)
  standard_tags = {
    Environment   = var.environment
    BusinessUnit  = var.business_unit
    OS            = var.os
    ServerNumber  = tostring(var.server_num)
    ManagedBy     = "Terraform"
  }

  # Cloud-specific key mappings
  tag_mappings = {
    aws = {
      Environment   = "Environment"
      BusinessUnit  = "BusinessUnit"
      OS            = "OS"
      ServerNumber  = "ServerNumber"
      ManagedBy     = "ManagedBy"
    }
    azure = {
      Environment   = "environment"
      BusinessUnit  = "business_unit"
      OS            = "os"
      ServerNumber  = "server_number"
      ManagedBy     = "managed_by"
    }
    gcp = {
      Environment   = "env"
      BusinessUnit  = "bu"
      OS            = "os"
      ServerNumber  = "server_num"
      ManagedBy     = "managed_by"
    }
  }

  # Generate cloud-specific tags
  cloud_tags = {
    for key, value in local.standard_tags :
    lookup(local.tag_mappings[var.cloud], key, key) => value
  }

  # Merge with additional tags
  all_tags = merge(local.cloud_tags, var.additional_tags)
}