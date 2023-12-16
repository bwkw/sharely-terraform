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

resource "aws_secretsmanager_secret" "aurora_credentials" {
  name = "${local.common_name_prefix}-aurora-credentials"

#   普通に消してしまうと復元待機期間に引っかかってしまうので消さないように
#   lifecycle {
#     prevent_destroy = true
#   }

#   消したい場合は、復元待機期間を無視するように
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "aurora_credentials_version" {
  secret_id     = aws_secretsmanager_secret.aurora_credentials.id
  secret_string = "{\"username\":\"${var.database.username}\", \"password\":\"${var.database.password}\"}"
}
