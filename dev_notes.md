

For AWS
# Stop all Development servers
aws ec2 stop-instances --instance-ids $(aws ec2 describe-instances --filters "Name=tag:Environment,Values=Development" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text --region eu-west-2)

# Start all Development servers
aws ec2 start-instances --instance-ids $(aws ec2 describe-instances --filters "Name=tag:Environment,Values=Development" "Name=instance-state-name,Values=stopped" --query "Reservations[].Instances[].InstanceId" --output text --region eu-west-2)



Azure outputs
Outputs:

resource_group_name = "azr-ubuntu-vms-rg"
ssh_connection_strings = {
  "ubuntu-vm01" = "ssh ubuntu@51.140.112.60 -i modules/azure_vm/ssh_keys/azr-srv-ubuntu-01_key.pem"
  "ubuntu-vm02" = "ssh ubuntu@51.140.122.228 -i modules/azure_vm/ssh_keys/azr-srv-ubuntu-02_key.pem"
}
vm_public_ips = {
  "ubuntu-vm01" = "51.140.112.60"
  "ubuntu-vm02" = "51.140.122.228"
}

AWS stack outputs
server_ids = {
  "aws-srv-ubuntu-01" = "i-0a44375b80e25e7b2"
  "aws-srv-ubuntu-02" = "i-040bd5f4eb4229374"
  "aws-srv-ubuntu-03" = "i-0d7f3b05ccaee1675"
}
server_public_ips = {
  "aws-srv-ubuntu-01" = "18.171.183.85"
  "aws-srv-ubuntu-02" = "18.170.51.58"
  "aws-srv-ubuntu-03" = "18.175.236.2"
}
subnet_id = "subnet-01d1812360b3b058f"
vpc_id = "vpc-0d0ec1fb5ccba6713"