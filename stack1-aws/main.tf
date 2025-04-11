provider "aws" {
    region = var.aws_region
}

resource "aws_vpc" "linux_vpc" {
    cidr_block = var.vpc_cidr
    tags       = { Name = "${var.name_prefix}-vpc"}
}

resource "aws_subnet" "linux_subnet" {
    vpc_id                  = aws_vpc.linux_vpc.id
    cidr_block              = var.subnet_cidr
    map_public_ip_on_launch = true
    tags                    = { Name = "${var.name_prefix}-subnet"}
}

resource "aws_internet_gateway" "linux_igw" {
    vpc_id  =   aws_vpc.linux_vpc.id
    tags    =   { Name = "${var.name_prefix}-igw"}
}

resource "aws_route_table" "linux_rt" {
    vpc_id = aws_vpc.linux_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.linux_igw.id
    }
    tags   = { Name = "${var.name_prefix}-rt"}
}

resource "aws_route_table_association" "linux_rta" {
    subnet_id = aws_subnet.linux_subnet.id
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
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = { Name = "${var.name_prefix}-sg" }
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

locals {
  # Extract OS shortname from AMI description (e.g., "ubuntu" -> "ub")
  server_os_types = {
    for k, ami in data.aws_ami.server_ami : k => (
      contains(lower(ami.description), "ubuntu") ? "ub" :
      contains(lower(ami.description), "amazon linux") ? "al" :
      contains(lower(ami.description), "centos") ? "ct" :
      contains(lower(ami.description), "debian") ? "db" :
      contains(lower(ami.description), "fedora") ? "fc" :
      contains(lower(ami.description), "red hat") ? "rh" :
      "lx" # default for unknown Linux
    )
  }
}

resource "aws_instance" "linux_servers" {
  for_each = var.server_instances

  ami                    = each.value.ami_id
  instance_type          = each.value.instance_type
  subnet_id              = aws_subnet.linux_subnet.id
  vpc_security_group_ids = [aws_security_group.linux_sg.id]
  key_name               = var.key_name

  tags = merge(
    {
      Name = "srv_${lookup(local.server_os_types, each.key, "lx")}_${format("%02d", each.value.index)}"
    },
    each.value.additional_tags
  )
}