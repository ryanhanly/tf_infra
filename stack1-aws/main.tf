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
      version = "~> 5.0"
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

# Data source to find Ubuntu AMIs
data "aws_ami" "ubuntu" {
  for_each    = var.server_instances
  most_recent = true
  owners      = ["099720109477"] # Canonical's AWS account

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_vpc" "ubuntu_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "${var.name_prefix}-vpc" }
}

resource "aws_subnet" "ubuntu_subnet" {
  vpc_id                  = aws_vpc.ubuntu_vpc.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags                    = { Name = "${var.name_prefix}-subnet" }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_internet_gateway" "ubuntu_igw" {
  vpc_id = aws_vpc.ubuntu_vpc.id
  tags   = { Name = "${var.name_prefix}-igw" }
}

resource "aws_route_table" "ubuntu_rt" {
  vpc_id = aws_vpc.ubuntu_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ubuntu_igw.id
  }
  tags = { Name = "${var.name_prefix}-rt" }
}

resource "aws_route_table_association" "ubuntu_rta" {
  subnet_id      = aws_subnet.ubuntu_subnet.id
  route_table_id = aws_route_table.ubuntu_rt.id
}

resource "aws_security_group" "ubuntu_sg" {
  name_prefix = "${var.name_prefix}-sg"
  vpc_id      = aws_vpc.ubuntu_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_cidr
  }

  # Allow HTTP for Ubuntu repo access within VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
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

locals {
  server_names = {
    for k, v in var.server_instances : k => "aws-srv-ubuntu-${format("%02d", v.index)}"
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

# Create user data script for Ubuntu configuration
locals {
  ubuntu_user_data = base64encode(templatefile("${path.module}/ubuntu-userdata.sh", {
    mirror_server_ip = var.mirror_server_ip
  }))
}

resource "aws_instance" "ubuntu_servers" {
  for_each = var.server_instances

  ami                         = data.aws_ami.ubuntu[each.key].id
  instance_type               = each.value.instance_type
  subnet_id                   = aws_subnet.ubuntu_subnet.id
  vpc_security_group_ids      = [aws_security_group.ubuntu_sg.id]
  key_name                    = aws_key_pair.server_key[each.key].key_name
  user_data                   = local.ubuntu_user_data
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  tags = merge(
    {
      Name = local.server_names[each.key]
      Environment = "Development"
      OS = "Ubuntu"
      OSVersion = "22.04"
    },
    each.value.additional_tags
  )
}

# Create Elastic IPs for each server
resource "aws_eip" "server_eips" {
  for_each = aws_instance.ubuntu_servers

  instance = each.value.id
  domain   = "vpc"

  tags = merge(
    {
      Name = "${local.server_names[each.key]}-eip"
      Environment = "Development"
    },
    each.value.tags
  )

  depends_on = [aws_internet_gateway.ubuntu_igw]
}