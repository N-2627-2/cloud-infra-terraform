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
  force_delete         = true

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
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "securechain-ecr-portal-${var.environment}"
  }
}

resource "aws_ecr_repository" "n8n" {
  name                 = "securechain-n8n-${var.environment}"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "securechain-ecr-n8n-${var.environment}"
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

resource "aws_ecs_task_definition" "portal" {
  family                   = "securechain-portal-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "portal"
      image     = "${aws_ecr_repository.portal.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.portal.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "portal"
        }
      }
    }
  ])

  tags = {
    Name = "securechain-td-portal-${var.environment}"
  }
}

resource "aws_ecs_task_definition" "backend" {
  family                   = "securechain-backend-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = "${aws_ecr_repository.backend.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "POSTGRES_SERVER", value = var.db_host },
        { name = "POSTGRES_USER", value = var.db_user },
        { name = "POSTGRES_DB", value = var.db_name }
      ]
      secrets = var.db_secret_arn != "" ? [
        {
          name      = "POSTGRES_PASSWORD"
          valueFrom = "${var.db_secret_arn}:password::"
        }
      ] : []
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.backend.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "backend"
        }
      }
    }
  ])

  tags = {
    Name = "securechain-td-backend-${var.environment}"
  }
}

resource "aws_ecs_service" "portal" {
  name            = "securechain-portal-service-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.portal.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_app_subnet_ids
    security_groups  = [var.app_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.portal_target_group_arn
    container_name   = "portal"
    container_port   = 3000
  }

  depends_on = [aws_ecs_task_definition.portal]
}

resource "aws_ecs_service" "backend" {
  name            = "securechain-backend-service-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_app_subnet_ids
    security_groups  = [var.app_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.backend_target_group_arn
    container_name   = "backend"
    container_port   = 8000
  }

  depends_on = [aws_ecs_task_definition.backend]
}