

For AWS
# Stop all Development servers
aws ec2 stop-instances --instance-ids $(aws ec2 describe-instances --filters "Name=tag:Environment,Values=Development" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text --region eu-west-2)

# Start all Development servers
aws ec2 start-instances --instance-ids $(aws ec2 describe-instances --filters "Name=tag:Environment,Values=Development" "Name=instance-state-name,Values=stopped" --query "Reservations[].Instances[].InstanceId" --output text --region eu-west-2)

ssh short names
mirror-server
ubuntu-vm01
ubuntu-vm02
aws-vm01
aws-vm02
aws-vm03

Azure outputs
Outputs:

assigned_vms = {
  "ubuntu-vm01" = "/subscriptions/810ef0ef-448f-48b1-88b9-1f3f0f26a320/resourceGroups/azr-ubuntu-vms-rg/providers/Microsoft.Compute/virtualMachines/azr-srv-ubuntu-01"
  "ubuntu-vm02" = "/subscriptions/810ef0ef-448f-48b1-88b9-1f3f0f26a320/resourceGroups/azr-ubuntu-vms-rg/providers/Microsoft.Compute/virtualMachines/azr-srv-ubuntu-02"
}
maintenance_configuration_id = "/subscriptions/810ef0ef-448f-48b1-88b9-1f3f0f26a320/resourceGroups/azr-ubuntu-vms-rg/providers/Microsoft.Maintenance/maintenanceConfigurations/azr-inf-ubuntu-updates"
maintenance_configuration_name = "azr-inf-ubuntu-updates"
resource_group_name = "azr-ubuntu-vms-rg"
ssh_connection_strings = {
  "ubuntu-vm01" = "ssh ubuntu@51.140.112.60 -i modules/azure_vm/ssh_keys/azr-srv-ubuntu-01_key.pem"
  "ubuntu-vm02" = "ssh ubuntu@51.140.122.228 -i modules/azure_vm/ssh_keys/azr-srv-ubuntu-02_key.pem"
}
update_manager_summary = {
  "duration" = "03:00"
  "maintenance_schedule" = "2025-07-15 22:00 (GMT Standard Time)"
  "reboot_setting" = "IfRequired"
  "recurrence" = "Month Second Tuesday"
  "vm_count" = 2
}
vm_public_ips = {
  "ubuntu-vm01" = "51.140.112.60"
  "ubuntu-vm02" = "51.140.122.228"
}

##### Stack1-aws

Outputs:

debug_instance_details = {
  "ubuntu-server1" = {
    "instance_id" = "i-0cc27d9245db9c2a5"
    "private_ip" = "10.0.1.10"
    "public_dns" = "ec2-3-8-78-128.eu-west-2.compute.amazonaws.com"
    "public_ip" = "3.8.78.128"
    "state" = "running"
  }
  "ubuntu-server2" = {
    "instance_id" = "i-0e32269c258e57da8"
    "private_ip" = "10.0.1.246"
    "public_dns" = "ec2-18-171-57-13.eu-west-2.compute.amazonaws.com"
    "public_ip" = "18.171.57.13"
    "state" = "running"
  }
  "ubuntu-server3" = {
    "instance_id" = "i-03fd5a884d2b006d9"
    "private_ip" = "10.0.1.195"
    "public_dns" = "ec2-13-40-5-161.eu-west-2.compute.amazonaws.com"
    "public_ip" = "13.40.5.161"
    "state" = "running"
  }
}
server_ids = {
  "aws-srv-ubuntu-01" = "i-0cc27d9245db9c2a5"
  "aws-srv-ubuntu-02" = "i-0e32269c258e57da8"
  "aws-srv-ubuntu-03" = "i-03fd5a884d2b006d9"
}
server_public_ips = {
  "aws-srv-ubuntu-01" = "3.8.78.128"
  "aws-srv-ubuntu-02" = "18.171.57.13"
  "aws-srv-ubuntu-03" = "13.40.5.161"
}
subnet_id = "subnet-01d1812360b3b058f"
vpc_id = "vpc-0d0ec1fb5ccba6713"


#####
stack4 outputs
Outputs:

maintenance_configuration_id = "/subscriptions/810ef0ef-448f-48b1-88b9-1f3f0f26a320/resourceGroups/azr-ubuntu-mirror-rg/providers/Microsoft.Maintenance/maintenanceConfigurations/azr-ubuntu-mirror-updates"
mirror_server_private_ip = "172.16.1.4"
mirror_server_public_ip = "172.166.188.125"
mirror_url = "http://172.166.188.125/ubuntu/"
resource_group_name = "azr-ubuntu-mirror-rg"
ssh_connection_command = "ssh ubuntu-admin@172.166.188.125 -i ./ssh_keys/azr-srv-mirror-01.pem"
ssh_key_location = "./ssh_keys/azr-srv-mirror-01.pem"
storage_account_name = "ubunturepo6f17e455"
update_manager_summary = {
  "duration" = "02:00"
  "maintenance_schedule" = "2025-07-15 01:00 (GMT Standard Time)"
  "reboot_setting" = "IfRequired"
  "recurrence" = "Month First Sunday"
}



### stack5

arc_client_id = "41f45bbc-3c67-40f1-8462-51d391eb100c"
arc_client_secret = <sensitive>
arc_resource_group_name = "rg-arc-aws-servers"
arc_setup_summary = {
  "app_name" = "arc-aws-servers-sp"
  "location" = "uksouth"
  "resource_group" = "rg-arc-aws-servers"
  "sp_client_id" = "41f45bbc-3c67-40f1-8462-51d391eb100c"
}
