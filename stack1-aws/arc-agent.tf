# stack1-aws/arc-agent.tf
# Azure Arc agent installation for AWS VMs

# Install Arc agent on each AWS instance
resource "null_resource" "install_arc_agent" {
  for_each = aws_instance.ubuntu_servers

  depends_on = [
    aws_instance.ubuntu_servers,
    local_file.private_key,
    aws_route_table_association.ubuntu_rta
  ]

  # Trigger reinstall if instance changes
  triggers = {
    instance_id = each.value.id
    public_ip   = each.value.public_ip
    private_ip  = each.value.private_ip
  }

  # Add a delay to ensure instance is fully ready
  provisioner "local-exec" {
    command = "sleep 30"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.ssh_key[each.key].private_key_pem
    host        = each.value.public_ip
    timeout     = "10m"
  }

  # Wait for instance to be ready
  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for cloud-init to finish...'",
      "cloud-init status --wait",
      "echo 'Instance ready for Arc installation'"
    ]
  }

  # Install Arc agent
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y curl wget",

      # Download and install Arc agent (more reliable method)
      "echo 'Downloading Azure Arc agent...'",
      "wget https://aka.ms/azcmagent -O ~/install_linux_azcmagent.sh",
      "chmod +x ~/install_linux_azcmagent.sh",
      "sudo ~/install_linux_azcmagent.sh",

      # Verify installation
      "azcmagent --version",

      # Connect to Azure Arc
      "echo 'Connecting to Azure Arc...'",
      "sudo azcmagent connect \\",
      "  --service-principal-id ${var.arc_client_id} \\",
      "  --service-principal-secret '${var.arc_client_secret}' \\",
      "  --tenant-id ${var.azure_tenant_id} \\",
      "  --subscription-id ${var.azure_subscription_id} \\",
      "  --resource-group ${var.arc_resource_group} \\",
      "  --location '${var.azure_region}' \\",
      "  --tags 'Environment=Development,Cloud=AWS,OS=Ubuntu,Server=${local.server_names[each.key]}'",

      # Verify connection
      "echo 'Verifying Arc connection...'",
      "sudo azcmagent show"
    ]
  }
}