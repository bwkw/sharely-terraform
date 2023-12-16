variable "region" {
  description = "AWS region"
  type        = string
}

variable "app_name" {
  description = "The name of the application."
  type        = string
}

variable "environment" {
  description = "The environment where infrastructure is deployed, e.g., 'dev', 'stg', 'prod'."
  type        = string
}

variable "task" {
  description = "Task related configurations"
  type = object({
    desired_count = number
    cpu           = string
    memory        = string
    subnet_ids = object({
      frontend = list(string)
      backend  = list(string)
    })
    security_group_ids = object({
      frontend = list(string)
      backend  = list(string)
    })
  })
}

variable "images" {
  description = "Docker image configurations"
  type = object({
    url = object({
      frontend = string
      backend  = string
    })
    tag = object({
      frontend = string
      backend  = string
    })
  })
}

variable "autoscaling" {
  description = "Autoscaling related configurations"
  type = object({
    cpu_scale_up_target_value = number
    scale_out_cooldown        = number
    scale_in_cooldown         = number
    min_capacity              = number
    max_capacity              = number
  })
}

variable "alb_target_group_arns" {
  description = "ALB target groups ARNs"
  type = object({
    pub = string
    pri = string
  })
}

variable "cloudwatch_log_group_name" {
  description = "CloudWatch log group name"
  type        = string
}
