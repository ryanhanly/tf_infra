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

# Add to stack1-aws/outputs.tf

output "server_elastic_ips" {
  description = "Elastic IPs for all server instances"
  value = {
    for k, eip in aws_eip.server_eips :
    aws_instance.ubuntu_servers[k].tags.Name => eip.public_ip
  }
}

output "debug_instance_details" {
  description = "Debug: Instance connection details"
  value = {
    for k, instance in aws_instance.ubuntu_servers : k => {
      instance_id = instance.id
      private_ip  = instance.private_ip
      public_ip   = instance.public_ip
      elastic_ip  = aws_eip.server_eips[k].public_ip
      public_dns  = instance.public_dns
      state       = instance.instance_state
    }
  }
}