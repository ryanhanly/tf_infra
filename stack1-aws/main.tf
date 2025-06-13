terraform {
  backend "s3" {
    bucket         = "stack1-terraform-states"
    key            = "stack1/terraform.tfstate"
    region         = "eu-west-2"
    use_lockfile   = true
    encrypt        = true
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
       source = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "linux_vpc" {
  cidr_block = var.vpc_cidr
  tags       = { Name = "${var.name_prefix}-vpc" }
}

resource "aws_subnet" "linux_subnet" {
  vpc_id                  = aws_vpc.linux_vpc.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.name_prefix}-subnet" }
}

resource "aws_internet_gateway" "linux_igw" {
  vpc_id = aws_vpc.linux_vpc.id
  tags   = { Name = "${var.name_prefix}-igw" }
}

resource "aws_route_table" "linux_rt" {
  vpc_id = aws_vpc.linux_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.linux_igw.id
  }
  tags = { Name = "${var.name_prefix}-rt" }
}

resource "aws_route_table_association" "linux_rta" {
  subnet_id      = aws_subnet.linux_subnet.id
  route_table_id = aws_route_table.linux_rt.id
}

resource "aws_security_group" "linux_sg" {
  vpc_id = aws_vpc.linux_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_cidr
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.name_prefix}-sg" }
}
# Create Elastic IPs for each server
resource "aws_eip" "server_eips" {
  for_each = var.server_instances
  domain   = "vpc"

  tags     = merge(
    {
      Name = "${local.server_names[each.key]}-eip"
    },
    each.value.additional_tags
  )
}


# Generate a unique key pair for each server
resource "tls_private_key" "ssh_key" {
  for_each  = var.server_instances
  algorithm = "RSA"
  rsa_bits  = 4096
}


locals {
  server_os_types = {
    for k, ami in data.aws_ami.server_ami : k => (
      can(regex("windows", lower(ami.description))) ? "win" : "lnx"
    )
  }
}

# Get the OS type and create the server name using the same pattern
locals {
  server_names = {
    for k, v in var.server_instances : k => "aws-srv-${local.server_os_types[k]}-${format("%02d", v.index)}"
  }
}

# Create a key pair in AWS for each server using the server name
resource "aws_key_pair" "server_key" {
  for_each   = var.server_instances
  key_name   = "${local.server_names[each.key]}-key"
  public_key = tls_private_key.ssh_key[each.key].public_key_openssh
}

# Save the private key locally for each server using the server name
resource "local_file" "private_key" {
  for_each        = var.server_instances
  content         = tls_private_key.ssh_key[each.key].private_key_pem
  filename        = "${path.module}/ssh_keys/${local.server_names[each.key]}.pem"
  file_permission = "0600"

  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/ssh_keys"
  }
}


# Look up AMI information to get OS details
data "aws_ami" "server_ami" {
  for_each = var.server_instances

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "image-id"
    values = [each.value.ami_id]
  }
}


# Update the EC2 instances section - modify the existing aws_instance resource:

resource "aws_instance" "linux_servers" {
  for_each = var.server_instances

  ami                    = each.value.ami_id
  instance_type          = each.value.instance_type
  subnet_id              = aws_subnet.linux_subnet.id
  vpc_security_group_ids = [aws_security_group.linux_sg.id]
  key_name               = aws_key_pair.server_key[each.key].key_name

  tags = merge(
    {
      Name = local.server_names[each.key]
    },
    each.value.additional_tags
  )
}

# Associate Elastic IPs with instances
resource "aws_eip_association" "server_eip_assoc" {
  for_each    = var.server_instances
  instance_id = aws_instance.linux_servers[each.key].id
  allocation_id = aws_eip.server_eips[each.key].id
}