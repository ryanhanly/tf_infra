# stack1-aws/locals.tf
# Programmatic tag generation for consistency

locals {
  # Environment abbreviation mapping
  environment_abbrev = module.shared_values.environment_abbreviations

  # Generate server names (existing logic)
  server_names = {
    for k, v in var.server_instances : k => "aws-srv-ubuntu-${format("%02d", v.index)}"
  }

  # Generate standardized tags for each server
  server_tags = {
    for k, v in var.server_instances : k => merge(
      {
        # Standard required tags
        BU          = v.bu
        Environment = v.environment
        PatchGroup  = "AUM-${v.bu}-${local.environment_abbrev[v.environment]}"
        OS          = "Ubuntu"
        Name        = local.server_names[k]
        Cloud       = "AWS"
        ManagedBy   = "Terraform"
      },
      # Add any additional custom tags
      v.additional_tags
    )
  }
}

# Create user data script for Ubuntu configuration
/* --- IGNORE ---
locals {
  ubuntu_user_data = base64encode(templatefile("${path.module}/ubuntu-userdata.sh", {
    mirror_server_ip = var.mirror_server_ip
  }))
}
*/
