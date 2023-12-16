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

  subnets = {
    pub_a = {
      cidr_block              = var.pub_subnets.a
      availability_zone       = var.az.a
      map_public_ip_on_launch = true
      subnet_type             = "public"
    },
    pub_c = {
      cidr_block              = var.pub_subnets.c
      availability_zone       = var.az.c
      map_public_ip_on_launch = true
      subnet_type             = "public"
    },
    pri1_a = {
      cidr_block              = var.pri1_subnets.a
      availability_zone       = var.az.a
      map_public_ip_on_launch = false
      subnet_type             = "private"
    },
    pri1_c = {
      cidr_block              = var.pri1_subnets.c
      availability_zone       = var.az.c
      map_public_ip_on_launch = false
      subnet_type             = "private"
    },
    pri2_a = {
      cidr_block              = var.pri2_subnets.a
      availability_zone       = var.az.a
      map_public_ip_on_launch = false
      subnet_type             = "private"
    },
    pri2_c = {
      cidr_block              = var.pri2_subnets.c
      availability_zone       = var.az.c
      map_public_ip_on_launch = false
      subnet_type             = "private"
    }
  }

  route_table_associations = {
    pub = ["pub_a", "pub_c"],
    pri = ["pri1_a", "pri1_c", "pri2_a", "pri2_c"]
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.common_name_prefix}-vpc"
  }
}

resource "aws_subnet" "common" {
  for_each = local.subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip_on_launch

  tags = {
    Name = "${local.common_name_prefix}-${replace(each.key, "_", "-")}-sub"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "${local.common_name_prefix}-igw"
  }
}

resource "aws_route_table" "pub" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = {
    Name = "${local.common_name_prefix}-pub-rt"
  }
}

resource "aws_route_table" "pri" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "${local.common_name_prefix}-pri-rt"
  }
}

resource "aws_route_table_association" "pub" {
  for_each = toset(local.route_table_associations.pub)

  subnet_id      = aws_subnet.common[each.key].id
  route_table_id = aws_route_table.pub.id
}

resource "aws_route_table_association" "pri" {
  for_each = toset(local.route_table_associations.pri)

  subnet_id      = aws_subnet.common[each.key].id
  route_table_id = aws_route_table.pri.id
}

# パブリックALBのセキュリティグループ
resource "aws_security_group" "pub_alb" {
  name   = "${local.common_name_prefix}-pub-alb-sg"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.common_name_prefix}-pub-alb-sg"
  }
}

resource "aws_security_group_rule" "pub_alb_ingress" {
  for_each = {
    http  = { port = 80, cidr = "0.0.0.0/0" },
    https = { port = 443, cidr = "0.0.0.0/0" }
  }

  security_group_id = aws_security_group.pub_alb.id
  type              = "ingress"
  from_port         = each.value["port"]
  to_port           = each.value["port"]
  protocol          = "tcp"
  cidr_blocks       = [each.value["cidr"]]
}

resource "aws_security_group_rule" "pub_alb_egress" {
  for_each = {
    http  = { port = 80, sg = aws_security_group.frontend_ecs_tasks.id },
    https = { port = 443, sg = aws_security_group.frontend_ecs_tasks.id }
  }

  security_group_id        = aws_security_group.pub_alb.id
  type                     = "egress"
  from_port                = each.value["port"]
  to_port                  = each.value["port"]
  protocol                 = "tcp"
  source_security_group_id = each.value["sg"]
}


# Frontendコンテナのセキュリティグループ
resource "aws_security_group" "frontend_ecs_tasks" {
  name   = "${local.common_name_prefix}-frontend-ecs-tasks-sg"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.common_name_prefix}-frontend-ecs-tasks-sg"
  }
}

resource "aws_security_group_rule" "frontend_ecs_tasks_ingress" {
  for_each = {
    http  = { port = 80, sg = aws_security_group.pub_alb.id },
    https = { port = 443, sg = aws_security_group.pub_alb.id }
  }

  security_group_id        = aws_security_group.frontend_ecs_tasks.id
  type                     = "ingress"
  from_port                = each.value["port"]
  to_port                  = each.value["port"]
  protocol                 = "tcp"
  source_security_group_id = each.value["sg"]
}

resource "aws_security_group_rule" "frontend_ecs_tasks_egress" {
  security_group_id = aws_security_group.frontend_ecs_tasks.id
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

# プライベートALBのセキュリティグループ
resource "aws_security_group" "pri_alb" {
  name   = "${local.common_name_prefix}-pri-alb-sg"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.common_name_prefix}-pri-alb-sg"
  }
}
resource "aws_security_group_rule" "pri_alb_ingress" {
  for_each = {
    http  = { port = 80, sg = aws_security_group.frontend_ecs_tasks.id },
    https = { port = 443, sg = aws_security_group.frontend_ecs_tasks.id }
  }

  security_group_id        = aws_security_group.pri_alb.id
  type                     = "ingress"
  from_port                = each.value["port"]
  to_port                  = each.value["port"]
  protocol                 = "tcp"
  source_security_group_id = each.value["sg"]
}

resource "aws_security_group_rule" "pri_alb_egress" {
  for_each = {
    http  = { port = 80, sg = aws_security_group.backend_ecs_tasks.id },
    https = { port = 443, sg = aws_security_group.backend_ecs_tasks.id }
  }

  security_group_id        = aws_security_group.pri_alb.id
  type                     = "egress"
  from_port                = each.value["port"]
  to_port                  = each.value["port"]
  protocol                 = "tcp"
  source_security_group_id = each.value["sg"]
}

# Backendコンテナのセキュリティグループ
resource "aws_security_group" "backend_ecs_tasks" {
  name   = "${local.common_name_prefix}-backend-ecs-tasks-sg"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.common_name_prefix}-backend-ecs-tasks-sg"
  }
}

resource "aws_security_group_rule" "backend_ecs_tasks_ingress" {
  for_each = {
    http  = { port = 80, sg = aws_security_group.pri_alb.id },
    https = { port = 443, sg = aws_security_group.pri_alb.id }
  }

  security_group_id        = aws_security_group.backend_ecs_tasks.id
  type                     = "ingress"
  from_port                = each.value["port"]
  to_port                  = each.value["port"]
  protocol                 = "tcp"
  source_security_group_id = each.value["sg"]
}

resource "aws_security_group_rule" "backend_ecs_tasks_egress" {
  security_group_id = aws_security_group.backend_ecs_tasks.id
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Auroraのセキュリティグループ
resource "aws_security_group" "aurora" {
  name   = "${local.common_name_prefix}-aurora-sg"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.common_name_prefix}-aurora-sg"
  }
}

resource "aws_security_group_rule" "aurora_ingress" {
  for_each = {
    mysql = { port = 3306, sg = aws_security_group.backend_ecs_tasks.id }
  }

  security_group_id        = aws_security_group.aurora.id
  type                     = "ingress"
  from_port                = each.value["port"]
  to_port                  = each.value["port"]
  protocol                 = "tcp"
  source_security_group_id = each.value["sg"]
}

# VPC Endpoint for Secrets Manager のセキュリティグループ
resource "aws_security_group" "vpc_endpoint_secrets_manager" {
  name   = "${local.common_name_prefix}-secrets-manager-vpc-endpoint-sg"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.common_name_prefix}-secrets-manager-vpc-endpoint-sg"
  }
}

resource "aws_security_group_rule" "vpc_endpoint_secrets_manager_ingress" {
  for_each = {
    https = { port = 443, sg = aws_security_group.backend_ecs_tasks.id }
  }

  security_group_id        = aws_security_group.vpc_endpoint_secrets_manager.id
  type                     = "ingress"
  from_port                = each.value["port"]
  to_port                  = each.value["port"]
  protocol                 = "tcp"
  source_security_group_id = each.value["sg"]
}

# VPC Endpoint for ECR のセキュリティグループ
resource "aws_security_group" "vpc_endpoint_ecr_api" {
  name   = "${local.common_name_prefix}-vpc-endpoint-ecr-api-sg"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.common_name_prefix}-vpc-endpoint-ecr-api-sg"
  }
}

resource "aws_security_group_rule" "vpc_endpoint_ecr_api_ingress" {
  for_each = {
    from_frontend = { port = 443, sg = aws_security_group.frontend_ecs_tasks.id },
    from_backend  = { port = 443, sg = aws_security_group.backend_ecs_tasks.id }
  }

  security_group_id        = aws_security_group.vpc_endpoint_ecr_api.id
  type                     = "ingress"
  from_port                = each.value["port"]
  to_port                  = each.value["port"]
  protocol                 = "tcp"
  source_security_group_id = each.value["sg"]
}

resource "aws_security_group_rule" "vpc_endpoint_ecr_api_egress" {
  security_group_id = aws_security_group.vpc_endpoint_ecr_api.id
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "vpc_endpoint_ecr_dkr" {
  name   = "${local.common_name_prefix}-vpc-endpoint-ecr-dkr-sg"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.common_name_prefix}-vpc-endpoint-ecr-dkr-sg"
  }
}

resource "aws_security_group_rule" "vpc_endpoint_ecr_dkr_ingress" {
  for_each = {
    from_frontend = { port = 443, sg = aws_security_group.frontend_ecs_tasks.id },
    from_backend  = { port = 443, sg = aws_security_group.backend_ecs_tasks.id }
  }

  security_group_id        = aws_security_group.vpc_endpoint_ecr_dkr.id
  type                     = "ingress"
  from_port                = each.value["port"]
  to_port                  = each.value["port"]
  protocol                 = "tcp"
  source_security_group_id = each.value["sg"]
}

resource "aws_security_group_rule" "vpc_endpoint_ecr_dkr_egress" {
  security_group_id = aws_security_group.vpc_endpoint_ecr_dkr.id
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
