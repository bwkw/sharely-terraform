variable "app_name" {
  type    = string
  default = "sharely"
}

variable "environment" {
  type    = string
  default = "stg"
}

variable "region" {
  type    = string
  default = "ap-northeast-1"
}

variable "vpc_cidr" {
  type    = string
  default = "192.168.0.0/24"
}

variable "az" {
  type = object({
    a = string
    c = string
  })
  default = {
    a = "ap-northeast-1a"
    c = "ap-northeast-1c"
  }
}

variable "pub_subnets" {
  type = object({
    a = string
    c = string
  })
  default = {
    a = "192.168.0.0/27"
    c = "192.168.0.32/27"
  }
}

variable "pri1_subnets" {
  type = object({
    a = string
    c = string
  })
  default = {
    a = "192.168.0.64/27"
    c = "192.168.0.96/27"
  }
}

variable "pri2_subnets" {
  type = object({
    a = string
    c = string
  })
  default = {
    a = "192.168.0.128/27"
    c = "192.168.0.160/27"
  }
}

variable "database_secret" {
  type = object({
    username = string
    password = string
  })
  default = {
    username = ""
    password = ""
  }
  sensitive = true
}

variable "database_instance_class" {
  type    = string
  default = "db.t4g.medium"
}

variable "task" {
  description = "Task related configurations"
  type = object({
    desired_count = number
    cpu           = string
    memory        = string
  })
  default = {
    desired_count = 2
    cpu           = "256" # 0.25 vCPU
    memory        = "512"
  }
}

variable "autoscaling" {
  description = "Autoscaling related configurations"
  type = object({
    cpu = object({
      scale_up_target_value = number
      scale_out_cooldown    = number
      scale_in_cooldown     = number
    })
    memory = object({
      scale_up_target_value = number
      scale_out_cooldown    = number
      scale_in_cooldown     = number
    })
    min_capacity = number
    max_capacity = number
  })
  default = {
    cpu = {
      scale_up_target_value = 70
      scale_out_cooldown    = 60
      scale_in_cooldown     = 60
    }
    memory = {
      scale_up_target_value = 80
      scale_out_cooldown    = 300
      scale_in_cooldown     = 600
    }
    min_capacity              = 1
    max_capacity              = 2
  }
}

variable "iam_role_oidc_thumbprint" {
  type    = string
  default = "3EA80E902FC385F36BC08193FBC678202D572994"
}

variable "iam_role_github_actions" {
  type = object({
    repository = string
    branch     = string
  })
  default = {
    repository = "bwkw/sharely-app"
    branch     = "stg"
  }
}

variable "sts_audience" {
  type    = string
  default = "sts.amazonaws.com"
}
