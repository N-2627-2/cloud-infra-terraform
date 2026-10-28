variable "aws_region" {
  description = "AWS region for the development environment"
  type        = string
  default     = "us-east-1"
}

variable "vpn_peer_public_ip_cidr" {
  description = "Public IPv4 address of the remote WireGuard peer, in /32 CIDR notation"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpn_peer_public_ip_cidr, 0)) && endswith(var.vpn_peer_public_ip_cidr, "/32")
    error_message = "Set the remote peer's public IPv4 address as a /32 CIDR."
  }
}

variable "vpn_peer_public_key" {
  description = "Base64-encoded WireGuard public key for the remote peer"
  type        = string
}

variable "vpn_peer_tunnel_cidr" {
  description = "Tunnel address assigned to the remote WireGuard peer, in /32 CIDR notation"
  type        = string
  default     = "10.99.0.2/32"

  validation {
    condition     = can(cidrhost(var.vpn_peer_tunnel_cidr, 0)) && endswith(var.vpn_peer_tunnel_cidr, "/32")
    error_message = "Set the peer tunnel address as a /32 CIDR."
  }
}

variable "vpn_private_key_secret_arn" {
  description = "ARN of a Secrets Manager secret containing the gateway private key as JSON field private_key"
  type        = string
}

variable "vpn_allowed_lab_cidr" {
  description = "Remote lab network routed through the VPN"
  type        = string
  default     = "10.20.0.0/16"
}
