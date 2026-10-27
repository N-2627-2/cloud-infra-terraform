variable "vpc_id" {
  description = "VPC ID where the VPN Gateway will reside"
  type        = string
}

variable "public_subnet_id" {
  description = "Public Subnet ID to host the public-facing VPN endpoint"
  type        = string
}

variable "private_route_table_id" {
  description = "Private Route Table ID to attach the GNS3 route"
  type        = string
}

variable "allowed_lab_cidr" {
  description = "CIDR block of the GNS3 / Warehouse Lab network"
  type        = string
  default     = "10.20.0.0/16"
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}