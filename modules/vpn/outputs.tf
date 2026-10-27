output "vpn_public_ip" {
  description = "Public IP for GNS3 / VyOS router to peer with"
  value       = aws_instance.vpn.public_ip
}

output "vpn_security_group_id" {
  description = "Security group ID of the VPN endpoint"
  value       = aws_security_group.vpn.id
}