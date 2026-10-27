resource "aws_security_group" "vpn" {
  name        = "securechain-vpn-sg-${var.environment}"
  description = "Allow IPsec/WireGuard tunnel traffic from Lab"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 500
    to_port     = 500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
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

resource "aws_route" "lab_traffic" {
  route_table_id         = var.private_route_table_id
  destination_cidr_block = var.allowed_lab_cidr
  network_interface_id   = aws_instance.vpn.primary_network_interface_id
}

resource "aws_instance" "vpn" {
  ami                         = "ami-0c7217cdde317cfec"
  instance_type               = "t3.micro"
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.vpn.id]
  source_dest_check           = false

  tags = {
    Name = "securechain-vpn-gateway-${var.environment}"
  }
}

output "vpn_public_ip" {
  description = "Public IP for GNS3 / VyOS router to peer with"
  value       = aws_instance.vpn.public_ip
}