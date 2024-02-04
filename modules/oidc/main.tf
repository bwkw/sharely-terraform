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
  common_name_prefix = "${var.app_name}-${var.environment}"  
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = [var.sts_audience]
  thumbprint_list = [var.oidc_thumbprint]
}

resource "aws_iam_role" "github_actions" {
  name = "${local.common_name_prefix}-oidc-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity",
      Effect = "Allow",
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      },
      Condition = {
        StringLike = {
          "token.actions.githubusercontent.com:aud" : var.sts_audience,
          "token.actions.githubusercontent.com:sub" : "repo:${var.github_actions.repository}:*"
        }
      }
    }]
  })

  tags = {
    Name = "${local.common_name_prefix}-iam-role-github-actions"
  }
}

resource "aws_iam_policy" "github_actions_ecr" {
  name = "github-actions-ecr"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Action" : "ecr:GetAuthorizationToken",
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "ecr:UploadLayerPart",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:CompleteLayerUpload",
          "ecr:BatchCheckLayerAvailability",
        ],
        "Effect" : "Allow",
        "Resource" : var.ecr_repository_arns
      }]
  })
}

resource "aws_iam_policy" "github_actions_ecs" {
  name = "github-actions-ecs"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Action" : [
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "iam:PassRole",  // ECSのタスク定義を登録する際に、タスク実行ロールをパスする権限が必要
          "ecs:DescribeServices",
          "ecs:UpdateService",
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_ecr" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_ecr.arn
}

resource "aws_iam_role_policy_attachment" "github_actions_ecs" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_ecs.arn
}
