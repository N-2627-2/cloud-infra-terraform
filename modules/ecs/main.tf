resource "aws_ecs_cluster" "main" {
  name = "securechain-cluster-${var.environment}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "securechain-cluster-${var.environment}"
  }
}

resource "aws_ecr_repository" "backend" {
  name                 = "securechain-backend-${var.environment}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "securechain-ecr-backend-${var.environment}"
  }
}

resource "aws_ecr_repository" "portal" {
  name                 = "securechain-portal-${var.environment}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "securechain-ecr-portal-${var.environment}"
  }
}

resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/securechain-backend-${var.environment}"
  retention_in_days = 7

  tags = {
    Name = "securechain-cw-backend-${var.environment}"
  }
}

resource "aws_cloudwatch_log_group" "portal" {
  name              = "/ecs/securechain-portal-${var.environment}"
  retention_in_days = 7

  tags = {
    Name = "securechain-cw-portal-${var.environment}"
  }
}