variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}

variable "alb_arn_suffix" {
  description = "ARN suffix of the Application Load Balancer for CloudWatch metrics"
  type        = string
}

variable "portal_target_group_arn_suffix" {
  description = "ARN suffix of the Portal Target Group for CloudWatch metrics"
  type        = string
}

variable "backend_target_group_arn_suffix" {
  description = "ARN suffix of the Backend Target Group for CloudWatch metrics"
  type        = string
}

variable "alert_email" {
  description = "Email address for SNS operational alert notifications"
  type        = string
  default     = "admin@example.com"
}