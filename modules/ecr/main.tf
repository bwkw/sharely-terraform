terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.13"
    }
  }
}

locals {
  ecr_repositories = {
    frontend = {
      name: "${var.app_name}-${var.environment}-frontend",
      description: "Keep only 10 images for frontend app"
    },
    backend = {
      name: "${var.app_name}-${var.environment}-backend",
      description: "Keep only 10 images for backend app"
    }
  }
}

resource "aws_ecr_repository" "common" {
  for_each = local.ecr_repositories

  name                 = each.value.name
  image_tag_mutability = "IMMUTABLE"

  tags = {
    Name        = each.value.name
    Environment = var.environment
  }
}

resource "aws_ecr_lifecycle_policy" "common" {
  for_each = local.ecr_repositories

  repository = aws_ecr_repository.common[each.key].name
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = each.value.description
        selection = {
          tagStatus   = "untagged"
          countType  = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
