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
}

resource "aws_vpc_endpoint" "secrets_manager" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.rds"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.pri1_subnet_ids
  security_group_ids  = var.vpc_endpoint_sg_ids.secrets_manager
  private_dns_enabled = true

  tags = {
    Name = "${local.common_name_prefix}-secrets-manager-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.pri1_subnet_ids
  security_group_ids  = var.vpc_endpoint_sg_ids.ecr_api
  private_dns_enabled = true

  tags = {
    Name = "${local.common_name_prefix}-ecr-api-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.pri1_subnet_ids
  security_group_ids  = var.vpc_endpoint_sg_ids.ecr_dkr
  private_dns_enabled = true

  tags = {
    Name = "${local.common_name_prefix}-ecr-dkr-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint" "cloudwatch" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.pri1_subnet_ids
  security_group_ids  = var.vpc_endpoint_sg_ids.cloudwatch_logs
  private_dns_enabled = true

  tags = {
    Name = "${local.common_name_prefix}-cloudwatch-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type   = "Gateway"
  route_table_ids     = [var.pri_route_table_id]

  tags = {
    Name = "${local.common_name_prefix}-s3-vpc-endpoint"
  }
}
