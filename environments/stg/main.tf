module "alb" {
  source = "../../modules/alb"

  environment = var.environment
  app_name    = var.app_name

  vpc_id = module.vpc.id
  security_group_ids = {
    pub  = [module.vpc.security_group_ids["pub_alb"]]
    pri1 = [module.vpc.security_group_ids["pri_alb"]]
  }
  subnet_ids = {
    pub  = [module.vpc.subnet_ids["pub_a"], module.vpc.subnet_ids["pub_c"]]
    pri1 = [module.vpc.subnet_ids["pri1_a"], module.vpc.subnet_ids["pri1_c"]]
  }
}

module "aurora" {
  source = "../../modules/aurora"

  app_name    = var.app_name
  environment = var.environment

  az                 = var.az
  pri2_subnet_ids    = [module.vpc.subnet_ids["pri2_a"], module.vpc.subnet_ids["pri2_c"]]
  security_group_ids = [module.vpc.security_group_ids["aurora"]]
  database = {
    instance_class = var.database_instance_class
    username       = var.database_secret.username
    password       = var.database_secret.password
  }
}

module "ecr" {
  source = "../../modules/ecr"

  app_name    = var.app_name
  environment = var.environment
}

module "ecs" {
  source = "../../modules/ecs"

  app_name    = var.app_name
  environment = var.environment

  region = var.region
  images = {
    url = {
      frontend = module.ecr.repository_urls["frontend"],
      backend  = module.ecr.repository_urls["backend"],
    }
    tag = {
      frontend = var.images.tag.frontend
      backend  = var.images.tag.backend
    }
  }
  task = {
    desired_count = var.task.desired_count
    cpu           = var.task.cpu
    memory        = var.task.memory
    subnet_ids = {
      frontend = [module.vpc.subnet_ids["pub_a"], module.vpc.subnet_ids["pub_c"]]
      backend  = [module.vpc.subnet_ids["pub_a"], module.vpc.subnet_ids["pub_c"]]
    }
    security_group_ids = {
      frontend = [module.vpc.security_group_ids["frontend_ecs_tasks"]]
      backend  = [module.vpc.security_group_ids["backend_ecs_tasks"]]
    }
  }
  autoscaling = {
    cpu_scale_up_target_value = var.autoscaling.cpu_scale_up_target_value
    scale_out_cooldown        = var.autoscaling.scale_out_cooldown
    scale_in_cooldown         = var.autoscaling.scale_in_cooldown
    min_capacity              = var.autoscaling.min_capacity
    max_capacity              = var.autoscaling.max_capacity
  }
  alb_target_group_arns = {
    pub = module.alb.target_group_arns["pub"]
    pri = module.alb.target_group_arns["pri1"]
  }
  cloudwatch_log_group_name = module.cloudwatch.log_group_name
}

module "oidc" {
  source = "../../modules/oidc"

  app_name    = var.app_name
  environment = var.environment

  ecr_repository_arns = [module.ecr.repository_arns["frontend"], module.ecr.repository_arns["backend"]]
  oidc_thumbprint     = var.iam_role_oidc_thumbprint
  github_actions      = var.iam_role_github_actions
  sts_audience        = var.sts_audience
}

module "secrets-manager" {
  source = "../../modules/secrets-manager"

  app_name    = var.app_name
  environment = var.environment

  database = {
    username = var.database_secret.username
    password = var.database_secret.password
  }
}

module "vpc" {
  source = "../../modules/vpc"

  app_name    = var.app_name
  environment = var.environment

  vpc_cidr     = var.vpc_cidr
  az           = var.az
  pub_subnets  = var.pub_subnets
  pri1_subnets = var.pri1_subnets
  pri2_subnets = var.pri2_subnets
}

module "vpc-endpoint" {
  source = "../../modules/vpc-endpoint"

  app_name    = var.app_name
  environment = var.environment

  region             = var.region
  vpc_id             = module.vpc.id
  pri_route_table_id = module.vpc.route_table_ids.pri
  pri1_subnet_ids    = [module.vpc.subnet_ids["pri1_a"], module.vpc.subnet_ids["pri1_c"]]
  vpc_endpoint_sg_ids = {
    ecr_api         = [module.vpc.security_group_ids["vpc_endpoint_ecr_api"]]
    ecr_dkr         = [module.vpc.security_group_ids["vpc_endpoint_ecr_dkr"]]
    secrets_manager = [module.vpc.security_group_ids["vpc_endpoint_secrets_manager"]]
  }
}
