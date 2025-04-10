output "srv_ub_01_public_ip" {
    description = "Public IP for srv_ub_01"
    value       = aws_instance.srv_ub_01.public_ip
}
