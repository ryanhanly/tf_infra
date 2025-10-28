# Terraform Infrastructure Code
This repository contains Terraform configurations for deploying cloud infrastructure across multiple stacks (AWS and Azure). All deployments are designed for educational purposes only, demonstrating infrastructure as code (IaC) practices. State files are stored remotely on HashiCorp Cloud Platform (HCP) Terraform for security and collaboration.

## Overview
- Shared Module: shared - Contains common values like allowed business units and environments, reused across stacks.
- Stacks: Each stack is a self-contained Terraform configuration for a specific cloud environment or service.
- Backend: HCP Terraform (formerly Terraform Cloud) for remote state management.
- Purpose: Educational lab for learning Terraform, cloud deployments, and DevOps practices.
- Cost Considerations: Configurations prioritize cost-efficiency for personal lab use (e.g., using free tiers, spot instances where possible, and minimal resources).

## Stacks
### stack1-aws
Deploys AWS infrastructure for Ubuntu-based servers in a VPC.

- Resources: VPC, subnets, security groups, EC2 instances, Elastic IPs, key pairs.
- Use Case: Basic server setup for testing or development.
- Cloud: AWS.
- Notes: Includes SSH access controls and optional mirror server integration.

### stack2-azure
Deploys Azure virtual machines with networking.

- Resources: Resource groups, virtual networks, subnets, VMs, public IPs, NSGs.
- Use Case: VM-based workloads in Azure.
- Cloud: Azure.
- Notes: Uses modules for VM creation; supports multiple VMs.

### stack3-azure-upd-manager
Configures Azure Update Manager for patch management.

- Resources: Update schedules, policies, and integrations.
- Use Case: Automated patching for Azure resources.
- Cloud: Azure.
- Notes: Depends on Azure VMs; educational for compliance and maintenance.

### stack4-central-mirror
Sets up a central mirror server for package repositories.

- Resources: Servers or storage for mirroring (e.g., Ubuntu mirrors).
- Use Case: Offline package access or reduced bandwidth.
- Cloud: Likely AWS or Azure (check code for specifics).
- Notes: Integrates with other stacks for server updates.

### stack5-arc-prereqs
Prerequisites for Azure Arc (hybrid cloud management).

- Resources: Agents, policies, and connectors.
- Use Case: Enabling Azure management for on-premises or multi-cloud resources.
- Cloud: Azure (with potential multi-cloud extensions).
- Notes: Prepares for Arc-enabled servers.

### stack6-patch-management
Advanced patch management across clouds.

- Resources: Extensions, schedules, and monitoring.
- Use Case: Centralized patching for servers.
- Cloud: AWS/Azure hybrid.
- Notes: Builds on Arc; includes custom scripts.

## Security and Best Practices
- State Files: Stored on HCP Terraform to avoid local exposure and enable team collaboration.
- Credentials: Use environment variables or HCP Variable Sets; never commit secrets.
- Access: Restrict cloud provider access to least privilege.
- Compliance: Configurations include basic security (e.g., NSGs, security groups) but are for learning—audit for production.

## Getting Started
1. Install Terraform and authenticate with HCP (terraform login).
2. Clone the repo and navigate to a stack folder (e.g., cd stack1-aws).
3. Set variables in terraform.tfvars or via HCP.
4. Run terraform init, terraform plan, terraform apply.
5. For cost monitoring, use cloud provider consoles.

## Contributing
- Follow Terraform best practices (e.g., modules, validations).
- Test changes locally before HCP runs.
- Update this README for new stacks.
- For issues or questions, refer to dev_notes.md. All infrastructure is for educational use only—destroy resources when not in use to minimize costs.
