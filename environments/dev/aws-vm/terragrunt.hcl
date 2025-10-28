include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  cloud_abbrev  = "aw"
  environment   = "dev"
  name_prefix   = "dev-aws"
  region        = "eu-west-2"
  region_abbrev = "lnd"
  server_instances = {
    "linux1" = {
      index = 1
      instance_type = "t2.micro"
      os = "linux"
      bu = "retail"
      additional_tags = {
        Project = "Lab"
        ApplicationName = "Web"
      }
    }
    "linux2" = {
      index = 2
      instance_type = "t2.micro"
      os = "linux"
      bu = "marketing"
      additional_tags = {
        Project = "Lab"
        ApplicationName = "DB"
      }
    }
    "win1" = {
      index = 1
      instance_type = "t2.micro"
      os = "windows"
      bu = "marketing"
      additional_tags = {
        Project = "Lab"
        ApplicationName = "App"
      }
    }
    "win2" = {
      index = 2
      instance_type = "t2.micro"
      os = "windows"
      bu = "it"
      additional_tags = {
        Project = "Lab"
        ApplicationName = "Monitor"
      }
    }
  }
}

dependency "networks" {
  config_path = "../aws-networks"
  mock_outputs = {
    subnet_id = "subnet-12345"
  }
}

dependency "security" {
  config_path = "../aws-security"
  mock_outputs = {
    sg_id    = "sg-12345"
    key_name = "key-123"
  }
}
