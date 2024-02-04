terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.13"
    }
  }
}

# ---------------------------------------
# local variables
# ---------------------------------------
locals {
  common_name_prefix = "${var.app_name}-${var.environment}"

  task_definitions = {
    "frontend" = {
      image_url             = var.images.url.frontend
      latest_image_tag      = var.images.latest_tag.frontend
      subnet_ids            = var.task.subnet_ids.frontend
      security_group_ids    = var.task.security_group_ids.frontend
      target_group_arn      = var.alb_target_group_arns.pub
    }
    "backend" = {
      image_url             = var.images.url.backend
      latest_image_tag      = var.images.latest_tag.backend
      subnet_ids            = var.task.subnet_ids.backend
      security_group_ids    = var.task.security_group_ids.backend
      target_group_arn      = var.alb_target_group_arns.pri
    }
  }
}

# ---------------------------------------
# ECS Task Execution Role
# ---------------------------------------
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${local.common_name_prefix}-ecs-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Effect = "Allow",
      }
    ]
  })

  tags = {
    Name = "${local.common_name_prefix}-ecs-execution-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_attachments" {
  for_each = {
    task_execution = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    ecr_read       = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  }

  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = each.value
}

# ---------------------------------------
# ECS Cluster
# ---------------------------------------
resource "aws_ecs_cluster" "main" {
  name = "${local.common_name_prefix}-cluster"

  tags = {
    Name = "${local.common_name_prefix}-ecs-cluster"
  }
}

# ---------------------------------------
# ECS Service
# ---------------------------------------
resource "aws_ecs_service" "common" {
  for_each = local.task_definitions

  name            = "${each.key}-service"
  cluster         = aws_ecs_cluster.main.arn
  task_definition = aws_ecs_task_definition.common[each.key].arn
  launch_type     = "FARGATE"
  desired_count   = var.task.desired_count
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  network_configuration {
    subnets          = each.value.subnet_ids
    security_groups  = each.value.security_group_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = each.value.target_group_arn
    container_name   = "${local.common_name_prefix}-${each.key}-container"
    container_port   = 3000
  }

  tags = {
    Name = "${local.common_name_prefix}-ecs-service"
  }
}

#----------------------------------------
# ECS Task Definition
#----------------------------------------
resource "aws_ecs_task_definition" "common" {
  for_each = local.task_definitions

  family                   = "${local.common_name_prefix}-${each.key}-task-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task.cpu
  memory                   = var.task.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name  = "${local.common_name_prefix}-${each.key}-container"
    image = "${each.value.image_url}:${each.value.latest_image_tag}"
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000 // Fargateでは無視される
    }]
#    runtime_platform = {
#      operating_system_family = "LINUX"
#      cpu_architecture = "ARM64"
#    }
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-region        = var.region
        awslogs-group         = var.cloudwatch_log_group_name
        awslogs-stream-prefix = "app-fargate"
      }
    }
  }])

  tags = {
    Name = "${local.common_name_prefix}-ecs-task-definition"
  }
}

#----------------------------------------
# autoscaling
#----------------------------------------
resource "aws_appautoscaling_target" "common" {
  for_each = local.task_definitions

  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${each.key}-service"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity = var.autoscaling.min_capacity
  max_capacity = var.autoscaling.max_capacity

  depends_on = [aws_ecs_service.common]
}

resource "aws_appautoscaling_policy" "cpu_scaling_policy" {
  for_each = local.task_definitions

  name               = "cpu-scale-up"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${each.key}-service"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = aws_appautoscaling_target.common[each.key].service_namespace
  scalable_dimension = aws_appautoscaling_target.common[each.key].scalable_dimension

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.autoscaling.cpu.scale_up_target_value
    scale_out_cooldown = var.autoscaling.cpu.scale_out_cooldown
    scale_in_cooldown  = var.autoscaling.cpu.scale_in_cooldown
  }

  depends_on = [aws_ecs_service.common]
}

resource "aws_appautoscaling_policy" "memory_scaling_policy" {
  for_each = local.task_definitions

  name               = "memory-scale-up"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${each.key}-service"
  policy_type        = "TargetTrackingScaling"
  scalable_dimension = aws_appautoscaling_target.common[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.common[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = var.autoscaling.memory.scale_up_target_value
    scale_out_cooldown = var.autoscaling.memory.scale_out_cooldown
    scale_in_cooldown  = var.autoscaling.memory.scale_in_cooldown
  }

  depends_on = [aws_ecs_service.common]
}
