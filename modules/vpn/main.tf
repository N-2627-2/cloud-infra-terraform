data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_iam_role" "vpn" {
  name = "securechain-vpn-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "securechain-vpn-role-${var.environment}"
  }
}

resource "aws_iam_role_policy" "read_private_key" {
  name = "read-wireguard-private-key"
  role = aws_iam_role.vpn.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = var.wireguard_private_key_secret_arn
    }]
  })
}

resource "aws_iam_instance_profile" "vpn" {
  name = "securechain-vpn-profile-${var.environment}"
  role = aws_iam_role.vpn.name
}

resource "aws_security_group" "vpn" {
  name        = "securechain-vpn-sg-${var.environment}"
  description = "Allow WireGuard traffic only from the configured peer"
  vpc_id      = var.vpc_id

  ingress {
    description = "WireGuard from the configured peer"
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = [var.peer_public_ip_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "securechain-vpn-sg-${var.environment}"
  }
}

resource "aws_instance" "vpn" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.vpn.id]
  iam_instance_profile        = aws_iam_instance_profile.vpn.name
  source_dest_check           = false
  user_data_replace_on_change = true
  user_data                   = <<-EOF
    #!/bin/bash
    set -euo pipefail
    export DEBIAN_FRONTEND=noninteractive

    apt-get update
    apt-get install -y awscli jq wireguard

    SECRET_JSON="$(aws secretsmanager get-secret-value --region "${var.aws_region}" --secret-id "${var.wireguard_private_key_secret_arn}" --query SecretString --output text)"
    PRIVATE_KEY="$(printf '%s' "$SECRET_JSON" | jq -er '.private_key')"

    install -d -m 0700 /etc/wireguard
    umask 077
    cat >/etc/wireguard/wg0.conf <<WG_CONF
    [Interface]
    Address = 10.99.0.1/24
    ListenPort = 51820
    PrivateKey = $PRIVATE_KEY
    PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT
    PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT

    [Peer]
    PublicKey = ${var.wireguard_peer_public_key}
    AllowedIPs = ${var.wireguard_peer_tunnel_cidr}, ${var.allowed_lab_cidr}
    WG_CONF

    chmod 0600 /etc/wireguard/wg0.conf
    printf '%s\n' 'net.ipv4.ip_forward=1' >/etc/sysctl.d/99-wireguard-forwarding.conf
    sysctl --system
    systemctl enable --now wg-quick@wg0
  EOF

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = "securechain-vpn-gateway-${var.environment}"
  }
}

resource "aws_eip" "vpn" {
  domain   = "vpc"
  instance = aws_instance.vpn.id

  tags = {
    Name = "securechain-vpn-eip-${var.environment}"
  }
}

resource "aws_route" "lab_traffic" {
  route_table_id         = var.private_route_table_id
  destination_cidr_block = var.allowed_lab_cidr
  network_interface_id   = aws_instance.vpn.primary_network_interface_id
}
