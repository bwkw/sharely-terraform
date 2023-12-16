output "repository_urls" {
  description = "ECR repository URLs"
  value = {
    for key, ecr_repository in aws_ecr_repository.common : key => ecr_repository.repository_url
  }
}

output "repository_arns" {
  description = "ECR repository ARNs"
  value = {
    for key, ecr_repository in aws_ecr_repository.common : key => ecr_repository.arn
  }
}
