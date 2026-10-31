variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "private_app_subnet_ids" {
  description = "List of private application subnet IDs for ECS tasks"
  type        = list(string)
}

variable "app_security_group_id" {
  description = "Security group ID for application container tasks"
  type        = string
}

variable "ecs_execution_role_arn" {
  description = "IAM Role ARN for ECS execution"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "IAM Role ARN for ECS tasks"
  type        = string
}

variable "portal_target_group_arn" {
  description = "ARN of the Portal Target Group from ALB module"
  type        = string
}

variable "backend_target_group_arn" {
  description = "ARN of the Backend Target Group from ALB module"
  type        = string
}

variable "db_secret_arn" {
  description = "ARN of the Secrets Manager secret containing DB credentials"
  type        = string
  default     = ""
}