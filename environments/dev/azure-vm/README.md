# Azure Infrastructure with Terraform

This Terraform configuration creates a scalable Azure infrastructure for deploying multiple virtual machines.

## Features

- Modular approach that allows easy scaling of VMs
- Cost-optimized for learning/development (using low-cost resources)
- Network security group for controlled access
- Public IPs for each VM for easy access

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (version >= 1.0.0)
- An Azure account (free tier is sufficient)
- Azure CLI installed and configured
- SSH key pair for VM access

## Project Structure

```
stack2-azure/
├── main.tf                # Main Terraform configuration
├── variables.tf           # Input variables definition
├── outputs.tf             # Output definitions
├── versions.tf            # Terraform and provider versions
├── terraform.tfvars.example  # Example variables file
└── modules/               # Reusable modules directory
    └── azure_vm/          # VM module
        ├── main.tf        # Module main configuration
        ├── variables.tf   # Module variables
        └── outputs.tf     # Module outputs
```

## Cost Information

This configuration uses the following cost-effective resources:

- **VM Size**: `Standard_B1s` - One of the cheapest VM sizes in Azure
- **Storage**: `Standard_LRS` - Lowest cost storage option
- **Region**: Default is `East US` (can be changed as needed)

## Getting Started

1. Clone this repository

2. Initialize Terraform
   ```
   cd stack2-azure
   terraform init
   ```

3. Create your own `terraform.tfvars` file based on the example
   ```
   cp terraform.tfvars.example terraform.tfvars
   ```

4. Edit your `terraform.tfvars` file to add or modify VMs

5. Generate an SSH key pair if you don't already have one
   ```
   ssh-keygen -t rsa -b 4096
   ```

6. Plan the deployment
   ```
   terraform plan
   ```

7. Apply the configuration
   ```
   terraform apply
   ```

## Adding More VMs

To add more VMs, simply add more entries to the `virtual_machines` map in your `terraform.tfvars` file:

```hcl
virtual_machines = {
  "vm-ubuntu-01" = {
    vm_size        = "Standard_B1s"
    admin_username = "azureadmin"
    ssh_public_key = "~/.ssh/id_rsa.pub"
    os_disk_type   = "Standard_LRS"
    tags = {
      Name = "vm_ubuntu_01"
      Environment = "Development"
    }
  },
  "vm-ubuntu-02" = {
    vm_size        = "Standard_B1s"
    admin_username = "azureadmin"
    ssh_public_key = "~/.ssh/id_rsa.pub"
    os_disk_type   = "Standard_LRS"
    tags = {
      Name = "vm_ubuntu_02"
      Environment = "Development"
    }
  },
  "vm-ubuntu-03" = {
    vm_size        = "Standard_B1s"
    admin_username = "azureadmin"
    ssh_public_key = "~/.ssh/id_rsa.pub"
    os_disk_type   = "Standard_LRS"
    tags = {
      Name = "vm_ubuntu_03"
      Environment = "Development"
    }
  }
}
```

## Security Considerations

The current configuration allows SSH access from any IP address (0.0.0.0/0). For production environments, you should restrict this to only your IP address or your organization's IP range by modifying the security rule in `main.tf`.