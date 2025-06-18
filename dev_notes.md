

For AWS 
# Stop all Development servers
aws ec2 stop-instances --instance-ids $(aws ec2 describe-instances --filters "Name=tag:Environment,Values=Development" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text --region eu-west-2)

# Start all Development servers
aws ec2 start-instances --instance-ids $(aws ec2 describe-instances --filters "Name=tag:Environment,Values=Development" "Name=instance-state-name,Values=stopped" --query "Reservations[].Instances[].InstanceId" --output text --region eu-west-2)