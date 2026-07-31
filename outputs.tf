output "repository_url" {
  value       = aws_ecr_repository.app_repo.repository_url
  description = "The URL of the created ECR repository"
}

output "repository_arn" {
  value       = aws_ecr_repository.app_repo.arn
  description = "The ARN of the created ECR repository"
}

## ECS 

output "ecs_cluster_name" {
  value       = aws_ecs_cluster.zomato_cluster.name
  description = "Name of the created ECS Cluster"
}

output "ecs_service_name" {
  value       = aws_ecs_service.zomato_service.name
  description = "Name of the created ECS Service"
}
