# stack5-arc-prereqs/main.tf
# Create Arc prerequisites: Service Principal and Resource Group

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

# Create Resource Group for Arc-enabled servers
resource "azurerm_resource_group" "arc_rg" {
  name     = var.arc_resource_group_name
  location = var.location
  tags     = var.tags
}

# Create Service Principal using Azure CLI (workaround for permissions)
resource "null_resource" "create_arc_sp" {
  provisioner "local-exec" {
    command = <<-EOT
      az ad sp create-for-rbac \
        --name "${var.arc_sp_name}" \
        --role "Azure Connected Machine Onboarding" \
        --scope "/subscriptions/${var.subscription_id}" \
        --output json > ${path.module}/arc-sp-output.json
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -f ${path.module}/arc-sp-output.json"
  }
}

# Read the service principal output
data "local_file" "arc_sp_output" {
  filename   = "${path.module}/arc-sp-output.json"
  depends_on = [null_resource.create_arc_sp]
}

locals {
  arc_sp_data = jsondecode(data.local_file.arc_sp_output.content)
}

# Get subscription data
data "azurerm_client_config" "current" {}

# Note: Additional role assignments would go here if needed
# The CLI command already assigned "Azure Connected Machine Onboarding" role