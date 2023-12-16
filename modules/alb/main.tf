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

  alb_configs = {
    pub = {
      internal           = false,
      security_groups    = var.security_group_ids.pub,
      subnets            = var.subnet_ids.pub
    },
    pri1 = {
      internal           = true,
      security_groups    = var.security_group_ids.pri1,
      subnets            = var.subnet_ids.pri1
    }
  }
}

resource "aws_lb" "alb" {
  for_each = local.alb_configs

  name               = "${local.common_name_prefix}-${each.key}-alb"
  internal           = each.value.internal
  load_balancer_type = "application"
  security_groups    = each.value.security_groups
  subnets            = each.value.subnets

  enable_deletion_protection = false

  tags = {
    Name = "${local.common_name_prefix}-${each.key}-alb"
  }
}

resource "aws_lb_listener" "http" {
  for_each = local.alb_configs

  load_balancer_arn = aws_lb.alb[each.key].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb[each.key].arn
  }
}

resource "aws_lb_target_group" "alb" {
  for_each = local.alb_configs

  name     = "${local.common_name_prefix}-${each.key}-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}
