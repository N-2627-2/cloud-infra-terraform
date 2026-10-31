output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Canonical hosted zone ID of the Application Load Balancer"
  value       = aws_lb.main.zone_id
}

output "portal_target_group_arn" {
  description = "ARN of the Portal Target Group"
  value       = aws_lb_target_group.portal.arn
}

output "backend_target_group_arn" {
  description = "ARN of the Backend Target Group"
  value       = aws_lb_target_group.backend.arn
}

output "alb_arn_suffix" {
  description = "ARN suffix of the Application Load Balancer for CloudWatch metrics"
  value       = aws_lb.main.arn_suffix
}

output "portal_target_group_arn_suffix" {
  description = "ARN suffix of the Portal Target Group for CloudWatch metrics"
  value       = aws_lb_target_group.portal.arn_suffix
}

output "backend_target_group_arn_suffix" {
  description = "ARN suffix of the Backend Target Group for CloudWatch metrics"
  value       = aws_lb_target_group.backend.arn_suffix
}