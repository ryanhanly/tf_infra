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

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags       = { Name = "${var.name_prefix}-vpc" }
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.name_prefix}-subnet" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = { Name = "${var.name_prefix}-igw" }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "${var.name_prefix}-rt" }
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.vpc.id
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

# Generate a unique key pair for each server
resource "tls_private_key" "ssh_key" {
  for_each  = var.server_instances
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create the server name based on OS type
locals {
  server_names = {
    for k, v in var.server_instances : k => "aws-srv-${v.os_type == "ubuntu" || v.os_type == "linux" ? "lnx" : v.os_type == "windows" ? "win" : "lnx"}-${format("%02d", v.index)}"
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

resource "aws_instance" "servers" {
  for_each = var.server_instances

  ami                    = each.value.ami_id
  instance_type          = each.value.instance_type
  subnet_id              = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name               = aws_key_pair.server_key[each.key].key_name

  tags = merge(
    {
      Name = local.server_names[each.key]
    },
    each.value.additional_tags
  )
}