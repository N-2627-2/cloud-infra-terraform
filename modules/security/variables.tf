variable "vpc_id" {
  description = "The ID of the VPC where security groups will be created"
  type        = string
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}