terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"  # Using version 3.x
    }
  }
  required_version = ">= 1.0.0"
}