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

resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = "${local.common_name_prefix}-aurora-cluster"
  engine                  = "aurora-mysql"
  database_name           = "${var.app_name}${var.environment}"
  master_username         = var.database.username
  master_password         = var.database.password
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
  vpc_security_group_ids  = var.security_group_ids
  db_subnet_group_name    = aws_db_subnet_group.aurora.name
  availability_zones      = [var.az.a, var.az.c]
}

resource "aws_rds_cluster_instance" "aurora" {
  for_each           = var.az
  identifier         = "${local.common_name_prefix}-aurora-instance-${each.key}"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = var.database.instance_class
  availability_zone  = each.value
  engine             = "aurora-mysql"
}

resource "aws_db_subnet_group" "aurora" {
  name       = "${local.common_name_prefix}-aurora-subnet-group"
  subnet_ids = var.pri2_subnet_ids

  tags = {
    Name = "${local.common_name_prefix}-aurora-subnet-group"
  }
}
