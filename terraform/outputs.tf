output "app_url" {
  description = "Open this in a browser once the services are healthy."
  value       = "http://${aws_lb.main.dns_name}"
}

output "ecr_web_repository" {
  value = aws_ecr_repository.app["web"].repository_url
}

output "ecr_api_repository" {
  value = aws_ecr_repository.app["api"].repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "github_deploy_role_arn" {
  description = "Save this as the AWS_ROLE_ARN repository variable in GitHub (Settings > Secrets and variables > Actions > Variables)."
  value       = aws_iam_role.github_deploy.arn
}

output "rds_endpoint" {
  value = aws_db_instance.main.address
}
