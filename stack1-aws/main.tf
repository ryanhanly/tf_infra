provider "aws" {
    region = var.aws_region
}

resource "aws_vpc" "linux_vpc" {
    cidr_block = "10.0.0.0/16"
    tags       = { Name = "linux-vpc"}
}

resource "aws_subnet" "linux_subnet" {
    vpc_id                  = aws_vpc.linux_vpc.id
    cidr_block              = "10.0.1.0/24"
    map_public_ip_on_launch = true
    tags                    = { Name = "linux-subnet"}
}

resource "aws_internet_gateway" "linux_igw" {
    vpc_id  =   aws_vpc.linux_vpc.id
}

resource "aws_route_table" "linux_rt" {
    vpc_id = aws_vpc.linux_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.linux_igw.id
    }
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
        protocol    = tcp
        cidr_blocks = ["0.0.0.0/0"] # Restrict to only you IP in production
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = { Name = "linux-sg" }
}
