output "server_public_ips" {
  description = "Static Public IPs for all server instances"
  value = {
    for k, instance in aws_instance.linux_servers :
    instance.tags.Name => aws_eip.server_eips[k].public_ip
  }
}

output "server_static_ips_list" {
  description = "List of static public IPs for use in other stacks"
  value = [
    for k, eip in aws_eip.server_eips : eip.public_ip
  ]
}

output "server_ids" {
  description = "IDs for all server instances"
  value = {
    for k, instance in aws_instance.linux_servers :
    instance.tags.Name => instance.id
  }
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.linux_vpc.id
}

output "subnet_id" {
  description = "ID of the created subnet"
  value       = aws_subnet.linux_subnet.id
}