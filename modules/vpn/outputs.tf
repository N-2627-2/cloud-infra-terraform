output "vpn_public_ip" {
  description = "Static Public Elastic IP of the AWS VPN Gateway endpoint"
  value       = aws_eip.vpn.public_ip
}

output "vpn_security_group_id" {
  description = "Security group ID of the VPN endpoint"
  value       = aws_security_group.vpn.id
}

output "vpn_instance_id" {
  description = "EC2 Instance ID of the VPN Gateway"
  value       = aws_instance.vpn.id
}

output "vpn_private_ip" {
  description = "Private IP address of the VPN Gateway instance inside the public subnet"
  value       = aws_instance.vpn.private_ip
}