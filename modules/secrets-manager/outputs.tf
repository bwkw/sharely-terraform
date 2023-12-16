output "aurora_credentials_secret_arn" {
  value = aws_secretsmanager_secret.aurora_credentials.arn
}
