output "ecr_registry_id" {
  value = aws_ecr_repository.ecr_repository.registry_id
}

output "ecr_repository_url" {
  value = aws_ecr_repository.ecr_repository.repository_url
}