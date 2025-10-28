# Shared remote state and common settings
remote_state {
  backend = "remote"
  config = {
    organization = "seneca_org"
    workspaces = {
      name = "${local.env}-${local.stack}"  # Dynamic workspace names
    }
  }
}

locals {
  env   = basename(dirname(get_terragrunt_dir()))  # e.g., "dev"
  stack = basename(get_terragrunt_dir())           # e.g., "aws-vm" \ "aws-networks"
}