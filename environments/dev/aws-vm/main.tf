terraform {
  cloud {
    organization = "seneca_org"
    workspaces {
      name = "dev-aws-vm"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "shared_values" {
  source = "../../../shared"
}


resource "aws_instance" "vms" {
  for_each = var.server_instances

  ami           = each.value.os == "linux" ? "ami-0c55b159cbfafe1d0" : "ami-0c02fb55956c7d316"
  instance_type = each.value.instance_type
  subnet_id     = dependency.networks.outputs.subnet_id
  vpc_security_group_ids = [dependency.security.outputs.sg_id]
  key_name      = dependency.security.outputs.key_name

  tags = {
    Name = module.vm_name[each.key].vm_name
  }
}

provider "aws" {
  region = module.shared_values.aws_region

}

module "vm_name" {
  for_each = var.server_instances
  source   = "../../../shared/modules/vm_name_generator"

  cloud_abbrev  = var.cloud_abbrev  # From terragrunt input (already "aw")
  region_abbrev = var.region_abbrev  # From terragrunt input (e.g., "lnd")
  os_code       = each.value.os == "linux" ? "lnx" : "win"  # Map to abbrev
  bu_abbrev     = module.shared_values.bu_abbrevs[each.value.bu]  # Map "retail" to "ret"
  env_abbrev    = module.shared_values.environment_abbreviations[var.environment]  # Map "dev" to "dev"
  server_num    = each.value.index
}