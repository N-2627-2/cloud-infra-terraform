resource "aws_security_group" "vpn" {
  name        = "securechain-vpn-sg-${var.environment}"
  description = "Allow VPN tunnel traffic strictly from Lab Peer"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = [var.peer_public_ip_cidr]
  }

  ingress {
    from_port   = 500
    to_port     = 500
    protocol    = "udp"
    cidr_blocks = [var.peer_public_ip_cidr]
  }

  ingress {
    from_port   = 4500
    to_port     = 4500
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
  ami                    = "ami-0c7217cdde317cfec"
  instance_type          = "t3.micro"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.vpn.id]
  source_dest_check      = false

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y wireguard strongswan net-tools
              sysctl -w net.ipv4.ip_forward=1
              echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
              EOF

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