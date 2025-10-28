
output "vm_names" {
  value = [for k, v in module.vm_name : v.vm_name]
}

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