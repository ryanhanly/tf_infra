output "server_public_ips" {
  description = "Public IPs for all server instances"
  value = {
    for k, instance in aws_instance.ubuntu_servers :
    instance.tags.Name => instance.public_ip
  }
}

output "server_ids" {
  description = "IDs for all server instances"
  value = {
    for k, instance in aws_instance.ubuntu_servers :
    instance.tags.Name => instance.id
  }
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.ubuntu_vpc.id
}

output "subnet_id" {
  description = "ID of the created subnet"
  value       = aws_subnet.ubuntu_subnet.id
}