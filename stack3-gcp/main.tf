terraform {
  cloud {

    organization = "seneca_org"

    workspaces {
      name = "stack3-gcp-core"
    }
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}