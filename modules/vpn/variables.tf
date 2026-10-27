variable "vpc_id" {
  description = "VPC ID where the VPN gateway will reside"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID that hosts the VPN endpoint"
  type        = string
}

variable "private_route_table_id" {
  description = "Private route table that sends lab traffic through the VPN gateway"
  type        = string
}

variable "allowed_lab_cidr" {
  description = "CIDR block of the remote lab network"
  type        = string
  default     = "10.20.0.0/16"
}

variable "peer_public_ip_cidr" {
  description = "Public IPv4 address of the VPN peer, in /32 CIDR notation"
  type        = string

  validation {
    condition     = can(cidrhost(var.peer_public_ip_cidr, 0)) && endswith(var.peer_public_ip_cidr, "/32")
    error_message = "Set the VPN peer's public IPv4 address as a /32 CIDR, for example 203.0.113.10/32."
  }
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}
