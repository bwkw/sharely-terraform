output "ecs_log_group" {
  value = {
    name = aws_cloudwatch_log_group.ecs_logs.name
  }
}
