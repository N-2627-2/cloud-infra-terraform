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

variable "aws_region" {
  description = "AWS region used to read the WireGuard private key secret"
  type        = string
}

variable "allowed_lab_cidr" {
  description = "CIDR block of the remote lab network"
  type        = string
  default     = "10.20.0.0/16"

  validation {
    condition     = can(cidrhost(var.allowed_lab_cidr, 0))
    error_message = "Set a valid IPv4 CIDR for the remote lab network."
  }
}

variable "peer_public_ip_cidr" {
  description = "Public IPv4 address of the VPN peer, in /32 CIDR notation"
  type        = string

  validation {
    condition     = can(cidrhost(var.peer_public_ip_cidr, 0)) && endswith(var.peer_public_ip_cidr, "/32")
    error_message = "Set the VPN peer's public IPv4 address as a /32 CIDR, for example 203.0.113.10/32."
  }
}

variable "wireguard_peer_public_key" {
  description = "Base64-encoded WireGuard public key for the remote peer"
  type        = string

  validation {
    condition     = length(trimspace(var.wireguard_peer_public_key)) > 0
    error_message = "Set the remote peer's WireGuard public key."
  }
}

variable "wireguard_peer_tunnel_cidr" {
  description = "Tunnel address assigned to the remote WireGuard peer, in /32 CIDR notation"
  type        = string
  default     = "10.200.0.2/32"

  validation {
    condition     = can(cidrhost(var.wireguard_peer_tunnel_cidr, 0)) && endswith(var.wireguard_peer_tunnel_cidr, "/32")
    error_message = "Set the peer tunnel address as a /32 CIDR."
  }
}

variable "wireguard_private_key_secret_arn" {
  description = "Secrets Manager ARN containing the gateway private key as JSON field private_key"
  type        = string
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}
