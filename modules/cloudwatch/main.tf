resource "aws_cloudwatch_log_group" "ecs_logs" {
  name = "/ecs/${var.environment}/${var.app_name}"
  retention_in_days = 60
}
