output "alb_security_group_id" {
  description = "ID of the Application Load Balancer Security Group"
  value       = aws_security_group.alb_sg.id
}

output "app_security_group_id" {
  description = "ID of the Application Tier Security Group"
  value       = aws_security_group.app_sg.id
}

output "db_security_group_id" {
  description = "ID of the Database Tier Security Group"
  value       = aws_security_group.db_sg.id
}

output "ecs_execution_role_arn" {
  description = "ARN of the ECS Execution Role"
  value       = aws_iam_role.ecs_execution_role.arn
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS Task Role"
  value       = aws_iam_role.ecs_task_role.arn
}