variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "db_subnet_group_name" {
  description = "Database subnet group name from VPC module"
  type        = string
}

variable "db_security_group_id" {
  description = "Security group ID for database access"
  type        = string
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "securechain"
}

variable "db_username" {
  description = "Master database username"
  type        = string
  default     = "dbadmin"
}

variable "allocated_storage" {
  description = "Allocated storage in gigabytes"
  type        = number
  default     = 20
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.micro"
}