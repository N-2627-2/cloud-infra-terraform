output "cluster_id" {
  description = "ID of the ECS Cluster"
  value       = aws_ecs_cluster.main.id
}

output "cluster_name" {
  description = "Name of the ECS Cluster"
  value       = aws_ecs_cluster.main.name
}

output "backend_ecr_repository_url" {
  description = "URL of the Backend ECR Repository"
  value       = aws_ecr_repository.backend.repository_url
}

output "portal_ecr_repository_url" {
  description = "URL of the Portal ECR Repository"
  value       = aws_ecr_repository.portal.repository_url
}

output "n8n_ecr_repository_url" {
  description = "URL of the n8n ECR Repository"
  value       = aws_ecr_repository.n8n.repository_url
}

output "portal_service_name" {
  description = "Name of the Portal ECS Service"
  value       = aws_ecs_service.portal.name
}

output "backend_service_name" {
  description = "Name of the Backend ECS Service"
  value       = aws_ecs_service.backend.name
}