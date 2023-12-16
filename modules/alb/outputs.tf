output "target_group_arns" {
  description = "The ARNs of the ALB target groups for the ECS service"
  value = {
    pub  = aws_lb_target_group.alb["pub"].arn,
    pri1 = aws_lb_target_group.alb["pri1"].arn
  }
}